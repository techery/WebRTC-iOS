//
//  SDPParser.m
//  AppRTCDemo
//
//  Created by Sergey Zenchenko on 1/24/14.
//  Copyright (c) 2014 Google. All rights reserved.
//

#import "SDPParser.h"

@implementation SDPParser

+ (NSString *)firstMatch:(NSRegularExpression *)pattern
              withString:(NSString *)string {
    NSTextCheckingResult *result =
    [pattern firstMatchInString:string
                        options:0
                          range:NSMakeRange(0, [string length])];
    if (!result)
        return nil;
    return [string substringWithRange:[result rangeAtIndex:1]];
}

+ (NSString *)preferISAC:(NSString *)origSDP {

    int mLineIndex = -1;
    NSString *isac16kRtpMap = nil;
    NSArray *lines = [origSDP componentsSeparatedByString:@"\n"];
    NSRegularExpression *isac16kRegex = [NSRegularExpression
                                         regularExpressionWithPattern:@"^a=rtpmap:(\\d+) ISAC/16000[\r]?$"
                                         options:0
                                         error:nil];
    for (int i = 0; (i < [lines count]) && (mLineIndex == -1 || isac16kRtpMap == nil); ++i) {
        NSString *line = [lines objectAtIndex:i];
        if ([line hasPrefix:@"m=audio "]) {
            mLineIndex = i;
            continue;
        }
        isac16kRtpMap = [self firstMatch:isac16kRegex withString:line];
    }
    if (mLineIndex == -1) {
        NSLog(@"No m=audio line, so can't prefer iSAC");
        return origSDP;
    }
    if (isac16kRtpMap == nil) {
        NSLog(@"No ISAC/16000 line, so can't prefer iSAC");
        return origSDP;
    }
    
    NSArray *origMLineParts = [[lines objectAtIndex:mLineIndex] componentsSeparatedByString:@" "];
    NSMutableArray *newMLine = [NSMutableArray arrayWithCapacity:[origMLineParts count]];
    int origPartIndex = 0;
    
    [newMLine addObject:[origMLineParts objectAtIndex:origPartIndex++]];
    [newMLine addObject:[origMLineParts objectAtIndex:origPartIndex++]];
    [newMLine addObject:[origMLineParts objectAtIndex:origPartIndex++]];
    [newMLine addObject:isac16kRtpMap];
    
    for (; origPartIndex < [origMLineParts count]; ++origPartIndex) {
        if ([isac16kRtpMap compare:[origMLineParts objectAtIndex:origPartIndex]]
            != NSOrderedSame) {
            [newMLine addObject:[origMLineParts objectAtIndex:origPartIndex]];
        }
    }
    
    NSMutableArray *newLines = [NSMutableArray arrayWithCapacity:[lines count]];
    [newLines addObjectsFromArray:lines];
    [newLines replaceObjectAtIndex:mLineIndex withObject:[newMLine componentsJoinedByString:@" "]];
    
    return [newLines componentsJoinedByString:@"\n"];
}

@end

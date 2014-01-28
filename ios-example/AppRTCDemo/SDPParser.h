//
//  SDPParser.h
//  AppRTCDemo
//
//  Created by Sergey Zenchenko on 1/24/14.
//  Copyright (c) 2014 Google. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDPParser : NSObject

+ (NSString *)preferISAC:(NSString *)origSDP;

@end

//
//  WRTCListener.m
//  AppRTCDemo
//
//  Created by Sergey Zenchenko on 1/25/14.
//  Copyright (c) 2014 Google. All rights reserved.
//

#import "WRTCListener.h"
#import "SDPParser.h"

@implementation WRTCListener

- (void)onSDPSet
{
    if (!self.peerConnection.localDescription) {
        [self.peerConnection createAnswerWithDelegate:self constraints:self.constraints];
    }
}

- (BOOL)isAudioEnabled
{
    return NO;
}

@end

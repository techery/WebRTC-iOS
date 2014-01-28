//
//  WRTCSpeaker.m
//  AppRTCDemo
//
//  Created by Sergey Zenchenko on 1/25/14.
//  Copyright (c) 2014 Google. All rights reserved.
//

#import "WRTCSpeaker.h"

@implementation WRTCSpeaker

- (void)start
{
    
    NSArray *mandatory = @[
                           [[RTCPair alloc] initWithKey:@"OfferToReceiveAudio" value:@"true"]
                           ];
    
    NSArray *optional = @[[[RTCPair alloc] initWithKey:@"internalSctpDataChannels" value:@"true"],
                          [[RTCPair alloc] initWithKey:@"DtlsSrtpKeyAgreement" value:@"true"]];
    
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatory optionalConstraints:optional];
    
    
    [self.peerConnection createOfferWithDelegate:self constraints:constraints];
}

@end

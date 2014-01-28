//
//  RTCPCObserver.h
//  AppRTCDemo
//
//  Created by Sergey Zenchenko on 1/24/14.
//  Copyright (c) 2014 Google. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTCPeerConnectionDelegate.h"
#import "SimpleSignallingChannel.h"

@interface RTCPCObserver : NSObject <RTCPeerConnectionDelegate>

- (id)initWithDelegate:(id<SignallingChannel>)channel;

@end

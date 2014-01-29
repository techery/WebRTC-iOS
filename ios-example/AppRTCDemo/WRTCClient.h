//
//  WRTCClient.h
//  AppRTCDemo
//
//  Created by Sergey Zenchenko on 1/25/14.
//  Copyright (c) 2014 Google. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleSignallingChannel.h"
#import "RTCPCObserver.h"

typedef void (^SignallingEventCallback)(NSDictionary *signal);

@interface WRTCClient : NSObject <RTCSessionDescriptonDelegate>

@property (nonatomic, strong) id<SignallingChannel> signallingChannel;

@property(nonatomic, strong) RTCPCObserver *pcObserver;
@property(nonatomic, strong) RTCPeerConnection *peerConnection;
@property(nonatomic, strong) NSMutableArray *queuedRemoteCandidates;
@property (nonatomic, strong) RTCMediaConstraints *constraints;

- (id)initWithSignallingChannel:(id<SignallingChannel>)channel;
- (void)disconnect;
- (void)start;
- (void)onSDPSet;
- (void)on:(NSString*)eventName do:(SignallingEventCallback)callback;
- (BOOL)isAudioEnabled;

@end

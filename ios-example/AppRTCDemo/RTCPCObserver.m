//
//  RTCPCObserver.m
//  AppRTCDemo
//
//  Created by Sergey Zenchenko on 1/24/14.
//  Copyright (c) 2014 Google. All rights reserved.
//

#import "RTCPCObserver.h"

@interface RTCPCObserver ()

@property (nonatomic, strong) id<SignallingChannel> signallingChannel;

@end

@implementation RTCPCObserver

- (id)initWithDelegate:(id<SignallingChannel>)channel {
    if (self = [super init]) {
        self.signallingChannel = channel;
    }
    return self;
}

- (void)peerConnectionOnError:(RTCPeerConnection *)peerConnection {
    NSLog(@"PCO onError.");
    NSAssert(NO, @"PeerConnection failed.");
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
 signalingStateChanged:(RTCSignalingState)stateChanged {
    NSLog(@"PCO onSignalingStateChange: %d", stateChanged);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
           addedStream:(RTCMediaStream *)stream {
    NSLog(@"PCO onAddStream.");
    NSAssert([stream.audioTracks count] >= 1,
             @"Expected at least 1 audio stream");
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
         removedStream:(RTCMediaStream *)stream {
    NSLog(@"PCO onRemoveStream.");
    if (stream.audioTracks.count > 0) {
            [stream removeAudioTrack:[stream.audioTracks objectAtIndex:0]];
    }
}

- (void)peerConnectionOnRenegotiationNeeded:(RTCPeerConnection *)peerConnection {
    NSLog(@"PCO onRenegotiationNeeded.");
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
       gotICECandidate:(RTCICECandidate *)candidate {
    
    NSDictionary *json = @{
                            @"type" : @"candidate",
                            @"sdpMLineIndex" : [NSNumber numberWithInt:candidate.sdpMLineIndex],
                            @"sdpMid" : candidate.sdpMid,
                            @"candidate" : candidate.sdp
                           };
    
    [self.signallingChannel post:json];
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
   iceGatheringChanged:(RTCICEGatheringState)newState {
    NSLog(@"PCO onIceGatheringChange. %d", newState);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
  iceConnectionChanged:(RTCICEConnectionState)newState {
    NSLog(@"PCO onIceConnectionChange. %d", newState);
    if (newState == RTCICEConnectionConnected)
        NSLog(@"ICE Connection Connected.");
    NSAssert(newState != RTCICEConnectionFailed, @"ICE Connection failed!");
}


@end
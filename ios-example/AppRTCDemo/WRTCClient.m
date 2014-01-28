//
//  WRTCClient.m
//  AppRTCDemo
//
//  Created by Sergey Zenchenko on 1/25/14.
//  Copyright (c) 2014 Google. All rights reserved.
//

#import "WRTCClient.h"
#import "SDPParser.h"

@interface WRTCClient () <SignallingChannelDelegate>

@property (nonatomic, strong) NSMutableDictionary *callbacks;

@end

@implementation WRTCClient

- (void)disconnect
{
    [self.signallingChannel post:@{ @"type" : @"bye" }];
    [RTCPeerConnectionFactory deinitializeSSL];
}

- (id)initWithSignallingChannel:(id<SignallingChannel>)channel
{
    self = [super init];
    if (self) {
        self.callbacks = [NSMutableDictionary new];
        [RTCPeerConnectionFactory initializeSSL];
        self.signallingChannel = channel;
        self.signallingChannel.delegate = self;
        
        NSArray *mandatory = @[
                               [[RTCPair alloc] initWithKey:@"OfferToReceiveAudio" value:@"true"],
                               [[RTCPair alloc] initWithKey:@"googEchoCancellation" value:@"true"],
                               [[RTCPair alloc] initWithKey:@"googAutoGainControl" value:@"true"],
                               ];
        
        NSArray *optional = @[[[RTCPair alloc] initWithKey:@"internalSctpDataChannels" value:@"true"],
                              [[RTCPair alloc] initWithKey:@"DtlsSrtpKeyAgreement" value:@"true"]];
        
        self.constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatory optionalConstraints:optional];
        
        [self on:@"candidate" do:^(NSDictionary *signal) {
            [self processCandidateMessage:signal];
        }];
        
        [self on:@"bye" do:^(NSDictionary *signal) {
            [self disconnect];
        }];
        
        [self on:@"offer" do:^(NSDictionary *signal) {
            [self processOfferOrAnswer:signal];
        }];
        
        [self on:@"answer" do:^(NSDictionary *signal) {
            [self processOfferOrAnswer:signal];
        }];
    }
    return self;
}

- (void)on:(NSString*)eventName do:(SignallingEventCallback)callback
{
    self.callbacks[eventName] = [callback copy];
}

- (void)channelConected:(id<SignallingChannel>)channel
{
    [self setupConnection];
    [self start];
}

- (void)channel:(id<SignallingChannel>)channel didReceiveMessage:(NSDictionary*)message
{
    NSString *eventName = [message objectForKey:@"type"];
    
    SignallingEventCallback callback = self.callbacks[eventName];
    
    NSParameterAssert(callback);
    
    if (callback) {
        callback(message);
    }
}

- (void)channelClosed:(id<SignallingChannel>)channel
{
    [self disconnect];
}

- (void)start
{
    
}

- (void)setupConnection {
    
    NSParameterAssert(self.signallingChannel);
    
    self.queuedRemoteCandidates = [NSMutableArray array];
    self.pcObserver = [[RTCPCObserver alloc] initWithDelegate:self.signallingChannel];
    
    RTCPeerConnectionFactory *peerConnectionFactory = [RTCPeerConnectionFactory new];
    
    self.peerConnection = [peerConnectionFactory peerConnectionWithICEServers:nil
                                                                  constraints:self.constraints
                                                                     delegate:self.pcObserver];
    
    RTCMediaStream *lms = [peerConnectionFactory mediaStreamWithLabel:@"ARDAMS"];
    [lms addAudioTrack:[peerConnectionFactory audioTrackWithID:@"ARDAMSa0"]];
    
    [self.peerConnection addStream:lms constraints:self.constraints];
}

- (void)processCandidateMessage:(NSDictionary *)message {
    RTCICECandidate *candidate = [[RTCICECandidate alloc] initWithMid:message[@"sdpMid"]
                                                                index:[message[@"sdpMLineIndex"] intValue]
                                                                  sdp:message[@"candidate"]];
    if (self.queuedRemoteCandidates) {
        [self.queuedRemoteCandidates addObject:candidate];
    } else {
        [self.peerConnection addICECandidate:candidate];
    }
}

- (void)processOfferOrAnswer:(NSDictionary *)message{
    RTCSessionDescription *sdp = [[RTCSessionDescription alloc] initWithType:message[@"type"]
                                                                         sdp:[SDPParser preferISAC:message[@"sdp"]]];
    
    [self.peerConnection setRemoteDescriptionWithDelegate:self sessionDescription:sdp];
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didCreateSessionDescription:(RTCSessionDescription *)origSdp error:(NSError *)error {
    NSAssert(!error, error.description);
    
    RTCSessionDescription *sdp = [[RTCSessionDescription alloc] initWithType:origSdp.type sdp:[SDPParser preferISAC:origSdp.description]];
    [self.peerConnection setLocalDescriptionWithDelegate:self sessionDescription:sdp];
    
    [self.signallingChannel post:@{@"type" : sdp.type, @"sdp" : sdp.description}];
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didSetSessionDescriptionWithError:(NSError *)error {
    NSAssert(!error, error.description);
    
    if (self.peerConnection.remoteDescription != nil && self.peerConnection.localDescription != nil) {
        [self drainRemoteCandidates];
    }
    
    [self onSDPSet];
}

- (void)onSDPSet
{
    
}

- (void)drainRemoteCandidates {
    for (RTCICECandidate *candidate in self.queuedRemoteCandidates) {
        [self.peerConnection addICECandidate:candidate];
    }
    
    self.queuedRemoteCandidates = nil;
}


@end

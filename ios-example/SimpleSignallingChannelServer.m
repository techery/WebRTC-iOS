
//
//  BGSocketChannelServer.m
//  Socket
//
//  Created by TheSooth on 1/24/14.
//  Copyright (c) 2014 com.appdevstudio. All rights reserved.
//

#import "SimpleSignallingChannelServer.h"
#import "AsyncSocket.h"

@interface SimpleSignallingChannelServer () <AsyncSocketDelegate>

@property (nonatomic, strong) NSMutableArray *sockets;
@property (nonatomic, strong) AsyncSocket *socket;

@end

@implementation SimpleSignallingChannelServer

@synthesize delegate = _delegate;

- (id)init
{
    self = [super init];
    if (self) {
        self.sockets = [NSMutableArray array];
        [self initSockets];
        
    }
    return self;
}

- (void)initSockets
{
    self.socket = [[AsyncSocket alloc] initWithDelegate:self];
    [self.socket acceptOnPort:8080 error:nil];
    [self.socket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
}

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
	[self.sockets addObject:newSocket];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    [self.delegate didReceiveMessageChannel:[[SimpleSignallingChannel alloc] initWithSocket:sock]];
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	[self.sockets removeObject:sock];
}

@end

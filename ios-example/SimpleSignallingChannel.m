//
//  BGMessageChannel.m
//  Socket
//
//  Created by TheSooth on 1/24/14.
//  Copyright (c) 2014 com.appdevstudio. All rights reserved.
//

#import "SimpleSignallingChannel.h"

static const UInt16 kSocketPort = 8080;

@interface SimpleSignallingChannel () <AsyncSocketDelegate>

@property (nonatomic, strong) AsyncSocket *inputSocket;

@end

@implementation SimpleSignallingChannel

@synthesize delegate = _delegate;

- (id)initWithSocket:(AsyncSocket *)inputSocket
{
    self = [super init];
    if (self) {
        self.inputSocket = inputSocket;
        [self.inputSocket setDelegate:self];
        [self.inputSocket readDataToData:[AsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
    }
    
    return self;
}

- (id)initWithIP:(NSString *)aIP delegate:(id<SignallingChannelDelegate>)delegate
{
    self = [super init];

    if (self) {
        self.delegate = delegate;
        self.inputSocket = [[AsyncSocket alloc] initWithDelegate:self];
        [self.inputSocket connectToHost:aIP onPort:kSocketPort error:nil];
        [self.inputSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    }
    
    return self;
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    [self.delegate channelConected:self];
    [self.inputSocket readDataToData:[AsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
}

- (void)post:(NSDictionary *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Post message: %@", message);
        NSData *encodedData = [NSJSONSerialization dataWithJSONObject:message options:0 error:nil];
        
        [self.inputSocket writeData:encodedData withTimeout:READ_TIMEOUT tag:0];
        [self.inputSocket writeData:[AsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
    });
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag == 0) {
        [self.inputSocket readDataToData:[AsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
    }
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
    NSDictionary *decodedData = [NSJSONSerialization JSONObjectWithData:strData options:0 error:nil];
    
    [self.delegate channel:self didReceiveMessage:decodedData];
    
    [self.inputSocket readDataToData:[AsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
}

@end

//
//  WebSocketSignallingChannel.m
//  AppRTCDemo
//
//  Created by Sergey Zenchenko on 1/26/14.
//  Copyright (c) 2014 Google. All rights reserved.
//

#import "WebSocketSignallingChannel.h"
#import "SRWebSocket.h"

@interface WebSocketSignallingChannel () <SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *socket;

@end

@implementation WebSocketSignallingChannel

@synthesize delegate = _delegate;

- (id)initWithIP:(NSString *)aIP delegate:(id<SignallingChannelDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"ws://%@:10000/signalling", aIP]];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        
        self.socket = [[SRWebSocket alloc] initWithURLRequest:req];
        
        self.socket.delegate = self;
        [self.socket open];
    }
    return self;
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    [self.delegate channelConected:self];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@":( Websocket Failed With Error %@", error);
    self.socket = nil;
    [self.delegate channelClosed:self];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(NSString*)message;
{
    NSLog(@"Received \"%@\"", message);
    
    NSDictionary *decodedData = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    [self.delegate channel:self didReceiveMessage:decodedData];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed");
    self.socket = nil;
    [self.delegate channelClosed:self];
}

- (void)post:(NSDictionary *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData *encodedData = [NSJSONSerialization dataWithJSONObject:message options:0 error:nil];
        
        NSString *json = [[NSString alloc] initWithData:encodedData encoding:NSUTF8StringEncoding];
        
        [self.socket send:json];
    });
}

@end

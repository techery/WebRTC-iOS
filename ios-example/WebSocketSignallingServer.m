//
//  WebSocketSignallingServer.m
//  AppRTCDemo
//
//  Created by Sergey Zenchenko on 1/26/14.
//  Copyright (c) 2014 Google. All rights reserved.
//

#import "WebSocketSignallingServer.h"
#import "HTTPServer.h"
#import "SignallingHTTPConnection.h"

@interface WebSocketSignallingServer ()

@property (nonatomic, strong) HTTPServer *httpServer;

@end

@implementation WebSocketSignallingServer

@synthesize delegate = _delegate;

- (id)init
{
    self = [super init];
    
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newSocketConnected:) name:kNewSocketConnected object:nil];
        
        self.httpServer = [[HTTPServer alloc] init];
        [self.httpServer setConnectionClass:[SignallingHTTPConnection class]];
        [self.httpServer setPort:10000];
        
        NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
        [self.httpServer setDocumentRoot:webPath];
        
        NSError *error;
        if(![self.httpServer start:&error]) {
            
        }
    }
    
    return self;
}

- (void)newSocketConnected:(NSNotification*)notification
{
    [self.delegate didReceiveMessageChannel:[notification object]];
}

@end

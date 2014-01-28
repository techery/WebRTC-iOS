//
//  BGMessageChannel.h
//  Socket
//
//  Created by TheSooth on 1/24/14.
//  Copyright (c) 2014 com.appdevstudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "SignallingChannel.h"

@interface SimpleSignallingChannel : NSObject <SignallingChannel>

- (id)initWithSocket:(AsyncSocket *)inputSocket;
- (id)initWithIP:(NSString *)aIP delegate:(id<SignallingChannelDelegate>)delegate;

@end

//
//  SignallingChannel.h
//  AppRTCDemo
//
//  Created by Sergey Zenchenko on 1/26/14.
//  Copyright (c) 2014 Google. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SignallingChannel;

@protocol SignallingChannelDelegate <NSObject>

- (void)channelConected:(id<SignallingChannel>)channel;
- (void)channel:(id<SignallingChannel>)channel didReceiveMessage:(NSDictionary*)message;
- (void)channelClosed:(id<SignallingChannel>)channel;

@end

@protocol SignallingChannel <NSObject>

@property (nonatomic, weak) id<SignallingChannelDelegate> delegate;

- (id)initWithIP:(NSString *)aIP delegate:(id<SignallingChannelDelegate>)delegate;
- (void)post:(NSDictionary*)message;

@end

@protocol SignallingChannelServerDelegate <NSObject>

- (void)didReceiveMessageChannel:(id <SignallingChannel>)messageChannel;

@end

@protocol SignallingChannelServer <NSObject>

@property (nonatomic, weak) id <SignallingChannelServerDelegate> delegate;

@end


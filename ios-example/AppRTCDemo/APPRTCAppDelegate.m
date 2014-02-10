#import "APPRTCAppDelegate.h"
#import "APPRTCViewController.h"
#import "RTCPCObserver.h"
#import "SDPParser.h"
#import "SimpleSignallingChannelServer.h"
#import "WRTCClient.h"
#import "WRTCSpeaker.h"
#import "WRTCListener.h"

#import "WebSocketSignallingChannel.h"
#import "WebSocketSignallingServer.h"

@interface APPRTCAppDelegate () <SignallingChannelServerDelegate>

@property (nonatomic, strong) WRTCClient *client;
@property (nonatomic, strong) id<SignallingChannelServer> server;

@end

@implementation APPRTCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [APPRTCViewController new];
    
    self.server = [WebSocketSignallingServer new];
    self.server.delegate = self;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSString *ip = [url host];
    
    self.client = [[WRTCSpeaker alloc] initWithSignallingChannel:[[WebSocketSignallingChannel alloc] initWithIP:ip delegate:nil]];

    return YES;
}

- (void)didReceiveMessageChannel:(id<SignallingChannel>)channel
{
    self.client = [[WRTCListener alloc] initWithSignallingChannel:channel];
}

@end

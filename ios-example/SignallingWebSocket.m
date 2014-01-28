#import "SignallingWebSocket.h"
#import "HTTPLogging.h"

static const int httpLogLevel = HTTP_LOG_LEVEL_WARN | HTTP_LOG_FLAG_TRACE;

@implementation SignallingWebSocket

@synthesize delegate = _delegate;

- (id)initWithIP:(NSString *)aIP delegate:(id<SignallingChannelDelegate>)delegate
{
    return [self init];
}

- (void)setDelegate:(id<SignallingChannelDelegate>)d
{
    _delegate = d;
    
    if (isStarted) {
        [self.delegate channelConected:self];
    }
}

- (void)didClose
{
    [super didClose];
    [self.delegate channelClosed:self];
}

- (void)didReceiveMessage:(NSString *)msg
{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[msg dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
	[self.delegate channel:self didReceiveMessage:dict];
}

- (void)post:(NSDictionary *)message
{
    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message options:0 error:nil] encoding:NSUTF8StringEncoding];
    [self sendMessage:json];
}

@end

#import <Foundation/Foundation.h>
#import "WebSocket.h"
#import "SignallingChannel.h"

@interface SignallingWebSocket : WebSocket <SignallingChannel>

@end

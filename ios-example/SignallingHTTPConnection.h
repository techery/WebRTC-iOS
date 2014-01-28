#import <Foundation/Foundation.h>
#import "HTTPConnection.h"

@class SignallingWebSocket;

extern NSString * const kNewSocketConnected;

@interface SignallingHTTPConnection : HTTPConnection
{
	SignallingWebSocket *ws;
}

@end

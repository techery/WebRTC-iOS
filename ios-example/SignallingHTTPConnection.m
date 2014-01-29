#import "SignallingHTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPResponse.h"
#import "HTTPDynamicFileResponse.h"
#import "GCDAsyncSocket.h"
#import "SignallingWebSocket.h"
#import "HTTPLogging.h"

NSString * const kNewSocketConnected = @"kNewSocketConnected";

@implementation SignallingHTTPConnection

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	if ([path isEqualToString:@"/crowdmics.js"]) {
		NSString *wsLocation;
		
		NSString *wsHost = [request headerField:@"Host"];
		if (wsHost == nil) {
			NSString *port = [NSString stringWithFormat:@"%hu", [asyncSocket localPort]];
			wsLocation = [NSString stringWithFormat:@"ws://localhost:%@/web_signalling", port];
		} else {
			wsLocation = [NSString stringWithFormat:@"ws://%@/service", wsHost];
		}
		
		NSDictionary *replacementDict = [NSDictionary dictionaryWithObject:wsLocation forKey:@"WEBSOCKET_URL"];
		
		return [[HTTPDynamicFileResponse alloc] initWithFilePath:[self filePathForURI:path]
		                                            forConnection:self
		                                                separator:@"%%"
		                                    replacementDictionary:replacementDict];
	}
	
	return [super httpResponseForMethod:method URI:path];
}

- (WebSocket *)webSocketForURI:(NSString *)path
{
	if([path isEqualToString:@"/signalling"]) {
        SignallingWebSocket *socket = [[SignallingWebSocket alloc] initWithRequest:request socket:asyncSocket];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNewSocketConnected object:socket];
        
		return socket;
	}
	
	return [super webSocketForURI:path];
}

@end

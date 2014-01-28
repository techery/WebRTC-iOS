#import "APPRTCViewController.h"

@interface APPRTCViewController ()

@end

@implementation APPRTCViewController

- (IBAction)connect:(id)sender
{
    NSString *url = [NSString stringWithFormat:@"apprtc://%@", self.textField.text];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end

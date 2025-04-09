#import "AirPlayMenu.h"
#import <AVKit/AVKit.h>

@implementation AirPlayMenu

- (void)show:(CDVInvokedUrlCommand*)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        AVRoutePickerView *routePickerView = [[AVRoutePickerView alloc] initWithFrame:CGRectMake(0,0,1,1)];
        routePickerView.hidden = YES;
        [self.webView.superview addSubview:routePickerView];

        for (UIView *subview in routePickerView.subviews) {
            if ([subview isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subview;
                [button sendActionsForControlEvents:UIControlEventTouchUpInside];
                break;
            }
        }

        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    });
}

@end

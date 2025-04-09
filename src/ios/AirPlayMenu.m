#import <Cordova/CDV.h>
#import <AVKit/AVKit.h>

@interface AirPlayMenu : CDVPlugin
- (void)show:(CDVInvokedUrlCommand*)command;
@end

@implementation AirPlayMenu

- (void)show:(CDVInvokedUrlCommand*)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        AVRoutePickerView *routePickerView = [[AVRoutePickerView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        routePickerView.activeTintColor = [UIColor clearColor];
        routePickerView.tintColor = [UIColor clearColor];

        [self.webView.superview addSubview:routePickerView];

        for (UIView *view in routePickerView.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                [button sendActionsForControlEvents:UIControlEventTouchUpInside];
                break;
            }
        }

        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    });
}

@end

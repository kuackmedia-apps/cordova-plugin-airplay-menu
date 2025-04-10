#import <Cordova/CDV.h>

@interface AirPlayMenu : CDVPlugin
- (void)show:(CDVInvokedUrlCommand*)command;
- (void)getConnectedDevice:(CDVInvokedUrlCommand*)command;
- (void)startMonitoringDeviceChanges:(CDVInvokedUrlCommand*)command;
@end

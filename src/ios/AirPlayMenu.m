#import "AirPlayMenu.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

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

- (void)getConnectedDevice:(CDVInvokedUrlCommand*)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        AVAudioSessionRouteDescription *currentRoute = [[AVAudioSession sharedInstance] currentRoute];
        NSString *connectedDevice = @"";

        if(currentRoute.outputs.count > 0){
            AVAudioSessionPortDescription *output = currentRoute.outputs.firstObject;

            // Tipo de salida: Bluetooth, CarPlay, AirPlay, o altavoz
            NSString *portType = output.portType;
            NSString *deviceName = output.portName;

            // Determina si está conectado a AirPlay/Bluetooth/CarPlay
            if ([portType isEqualToString:AVAudioSessionPortAirPlay] ||
                [portType isEqualToString:AVAudioSessionPortBluetoothA2DP] ||
                [portType isEqualToString:AVAudioSessionPortBluetoothLE] ||
                [portType isEqualToString:AVAudioSessionPortBluetoothHFP] ||
                [portType isEqualToString:AVAudioSessionPortCarAudio]) {

                connectedDevice = deviceName;
            }
        }

        NSDictionary *resultDict = @{
            @"connected": @(connectedDevice.length > 0),
            @"deviceName": connectedDevice
        };

        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    });
}

@end

#import "AirPlayMenu.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CDVAudioSessionManager.h"

@interface AirPlayMenu ()
@property (nonatomic, strong) NSString* deviceChangeCallbackId;
@end

@implementation AirPlayMenu

- (void)pluginInitialize {
    // Configurar AVAudioSession utilizando el gestor centralizado
    [[CDVAudioSessionManager sharedInstance] setupAudioSessionForPlayback];
    [[CDVAudioSessionManager sharedInstance] activateAudioSession];

    // Registrar para notificaciones de cambio de ruta
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(audioRouteChanged:)
        name:AVAudioSessionRouteChangeNotification
        object:nil];
}

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
    [self sendCurrentDeviceInfo:command.callbackId keepCallback:NO];
}

- (void)startMonitoringDeviceChanges:(CDVInvokedUrlCommand*)command {
    self.deviceChangeCallbackId = command.callbackId;
    [self sendCurrentDeviceInfo:self.deviceChangeCallbackId keepCallback:YES];
}

- (void)audioRouteChanged:(NSNotification*)notification {
    if (self.deviceChangeCallbackId) {
        [self sendCurrentDeviceInfo:self.deviceChangeCallbackId keepCallback:YES];
    }
}

- (void)sendCurrentDeviceInfo:(NSString*)callbackId keepCallback:(BOOL)keepCallback {
    AVAudioSessionRouteDescription *currentRoute = [[AVAudioSession sharedInstance] currentRoute];
    NSString *connectedDevice = @"";
    NSString *deviceType = @"none";
    NSDictionary *extraInfo = nil;

    if(currentRoute.outputs.count > 0){
        AVAudioSessionPortDescription *output = currentRoute.outputs.firstObject;
        NSString *portType = output.portType;
        NSString *deviceName = output.portName;

        // Información adicional para depuración
        extraInfo = @{
            @"portType": portType,
            @"UID": output.UID ?: @"",
            @"outputChannels": @(output.channels.count)
        };

        if ([portType isEqualToString:AVAudioSessionPortAirPlay]) {
            deviceType = @"airplay";
            connectedDevice = deviceName;
        } else if ([portType isEqualToString:AVAudioSessionPortBluetoothA2DP] ||
                   [portType isEqualToString:AVAudioSessionPortBluetoothLE] ||
                   [portType isEqualToString:AVAudioSessionPortBluetoothHFP]) {
            deviceType = @"bluetooth";
            connectedDevice = deviceName;
        } else if ([portType isEqualToString:AVAudioSessionPortCarAudio]) {
            deviceType = @"carplay";
            connectedDevice = deviceName;
        }
    }

    NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"connected": @(connectedDevice.length > 0),
        @"deviceName": connectedDevice,
        @"deviceType": deviceType
    }];

    // Añadir información extra para depuración
    if (extraInfo) {
        [resultDict setObject:extraInfo forKey:@"extraInfo"];
    }

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
    pluginResult.keepCallback = @(keepCallback);
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

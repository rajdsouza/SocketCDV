/********* SocketCDV.h Cordova Plugin Implementation *******/
#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>
#import "ScanApiHelper.h"


@interface SocketCDV : CDVPlugin {
    NSMutableArray* _devices;
}

@property BOOL softScannerEnabled;



@property (strong, nonatomic) ScanApiHelper* ScanApi;
@property (strong, nonatomic) NSTimer* ScanApiConsumer;
@property (strong, nonatomic) NSString *scanApiVersion;
@property (nonatomic) BOOL doAppDataConfirmation;

- (void)initDT:(CDVInvokedUrlCommand*)command;

@end
/********* SocketCDV.m Cordova Plugin Implementation *******/

#import "SocketCDV.h"
#import "ScanApiHelper.h"
#import "MainViewController.h"


@interface SocketCDV ()
 @property (strong, nonatomic) NSString *barcodeData;
 @property (strong, nonatomic) NSString *errorCB;
@end

@implementation SocketCDV
{
#ifdef USE_SOFTSCAN
    DeviceInfo* _softScanDeviceInfo;
#endif
    DeviceInfo* _deviceInfoToTrigger;
    NSDate* _lastCheck;
    NSInteger _sameSecondCount;
}


@synthesize ScanApi;
@synthesize ScanApiConsumer;
@synthesize scanApiVersion;
@synthesize barcodeData;
@synthesize errorCB;

- (void)initDT:(CDVInvokedUrlCommand*)command
{
    
    NSLog(@"Socket: Init Called");
    
        CDVPluginResult* pluginResult = nil;
        NSUInteger argumentsCount = command.arguments.count;
        self.barcodeData = argumentsCount ? command.arguments[0] : @"barcodeData";
        self.errorCB     = (argumentsCount > 1) ? command.arguments[1] : nil;
        _devices=[[NSMutableArray alloc]init];
        
        _doAppDataConfirmation=YES;
        if (ScanApi==nil) {
            ScanApi=[[ScanApiHelper alloc]init];
            [ScanApi setDelegate:self];
            [ScanApi open];
            ScanApiConsumer=[NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];

        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(NSString*)getScanApiVersion
{
    return scanApiVersion;
}

-(void)onTimer: (NSTimer*)theTimer{
    if(theTimer==ScanApiConsumer){
        [ScanApi doScanApiReceive];
    }
}

- (void)sendBarcodeData:(NSString *)data type:(NSString *) type {
    
    NSLog(@"%@({ message: '%@' });", self.barcodeData, data);
    
    // Strip any newline characters
    data = [[data componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
    
    NSString *jsStatement = [NSString stringWithFormat:@"SocketCDV.onBarcodeData('%@', '%@');",data, type ];
    
    if ([self.webView isKindOfClass:[UIWebView class]]) {
        [(UIWebView*)self.webView stringByEvaluatingJavaScriptFromString:jsStatement];
    }
    
    
}

-(void) onDecodedData:(DeviceInfo *)device decodedData:(ISktScanDecodedData*)decodedData{

    
    NSString *barcode = [NSString stringWithUTF8String:(const char *)[decodedData getData]];
    NSLog(@"Barcode scanned: -%@-",barcode);
    //NSLog(@"barcodeNSData: barcode - %@, type - %@", [[NSString alloc] initWithData:barcode encoding:NSUTF8StringEncoding], isotype);
    [self sendBarcodeData:barcode type:@"NA"];
    
}


#pragma mark - Device Info List management
-(void) updateDevicesList:(DeviceInfo*) deviceInfo Add:(BOOL)add{
    if(add==YES){
        [_devices addObject:deviceInfo];
    }
    else{
        [_devices removeObject:deviceInfo];
    }
    
    NSMutableString* temp=[[NSMutableString alloc]init];
    for (DeviceInfo* info in _devices) {
        [temp appendString:[info getName]];
        [temp appendString:@"\n"];
    }
    if(_devices.count>0)
        [temp appendString:@"ready to scan"];
    else
        [temp appendString:@"Waiting for Scanner..."];
    
    
   //NSLog(@"Status is %lu", _devices.count);
    
}

-(void)onGetSymbologyDpm:(ISktScanObject*)scanObj{
    SKTRESULT result=[[scanObj Msg]Result];
    if(SKTSUCCESS(result)){
        DeviceInfo* deviceInfo=[ScanApi getDeviceInfoFromScanObject:scanObj];
        if(deviceInfo!=nil){
            ISktScanSymbology*symbology=[[scanObj Property]Symbology];
            if([symbology getStatus]==kSktScanSymbologyStatusDisable){
                [ScanApi postSetSymbologyInfo:deviceInfo SymbologyId:kSktScanSymbologyDirectPartMarking Status:TRUE Target:self Response:@selector(onSetSymbology:)];
            }
        }
    }
    else{
        // an error message should be displayed here
        // indicating that the DPM symbology status cannot be retrieved
    }
}

// callback received when the Set Symbology Status is completed
-(void)onSetSymbology:(ISktScanObject*)scanObj{
    SKTRESULT result=[[scanObj Msg]Result];
    if(!SKTSUCCESS(result)){
        // display an error message saying a symbology cannot be set
    }
}

/**
 *
 */
-(void) onSetDataConfirmationMode:(ISktScanObject*)scanObj{
    SKTRESULT result=[[scanObj Msg]Result];
    if(SKTSUCCESS(result)){
        NSLog(@"DataConfirmation Mode OK");
    }
    else{
        NSLog(@"DataConfirmation Mode Error %ld",result);
    }
}



/**
 * called when ScanAPI initialization has been completed
 * @param result contains the initialization result
 */
-(void) onScanApiInitializeComplete:(SKTRESULT) result{
    if(SKTSUCCESS(result)){
        
        // make sure we support SoftScan
        [ScanApi postSetSoftScanStatus:kSktScanSoftScanNotSupported Target:self Response:@selector(onSetSoftScanStatus:)];
        
        // ask for ScanAPI version (not a requirement but always nice to know)
        [ScanApi postGetScanApiVersion:self Response:@selector(onGetScanApiVersion:)];
        
        // configure ScanAPI for doing App Data confirmation,
        // if TRUE then SingleEntry will confirm the decoded data
        if(_doAppDataConfirmation==YES){
            [ScanApi postSetConfirmationMode:kSktScanDataConfirmationModeApp Target:self Response:@selector(onSetDataConfirmationMode:)];
        }
        // NSString log =@"Waiting for scanner...";
       NSLog(@"Waiting for scanner...");
    }
    else{
        // NSString log=[NSString stringWithFormat:@"Error initializing ScanAPI:%ld",result];
        NSLog(@"Error initializing ScanAPI:%ld",result);
    }
}




/**
 *
 */
-(void) onDataConfirmation:(ISktScanObject*)scanObj{
    SKTRESULT result=[[scanObj Msg]Result];
    if(SKTSUCCESS(result)){
        NSLog(@"Data Confirmed OK");
    }
    else{
        NSLog(@"Data Confirmed Error %ld",result);
    }
}

/**
 *
 */
-(void) onSetLocalDecodeAction:(ISktScanObject*)scanObj{
    SKTRESULT result=[[scanObj Msg]Result];
    if(SKTSUCCESS(result)){
        NSLog(@"Local Decode Action OK");
    }
    else{
        NSLog(@"Local Decode Action Error %ld",result);
    }
}

/**
 *
 */
-(void) onGetSoftScanStatus:(ISktScanObject*)scanObj{
    SKTRESULT result=[[scanObj Msg]Result];
    if(SKTSUCCESS(result)){
        ISktScanProperty* property=[scanObj Property];
        if([property getByte]==kSktScanEnableSoftScan){
            NSLog(@"SoftScan is ENABLED");
            _softScannerEnabled=TRUE;
        }
        else{
            _softScannerEnabled=FALSE;
            NSLog(@"SoftScan is DISABLED");
        }
        
        NSLog(@"SoftScan status:");
    }
    else{
        NSLog(@"getting SoftScanStatus returned the error %ld",result);
    }
}

/**
 *
 */
-(void) onSetSoftScanStatus:(ISktScanObject*)scanObj{
    SKTRESULT result=[[scanObj Msg]Result];
    if(SKTSUCCESS(result)){
        NSLog(@"SoftScan set status success");
    }
    else{
        NSLog(@"SoftScan set status returned the error %ld",result);
    }
}

/**
 *
 */
-(void) onSetTrigger:(ISktScanObject*)scanObj{
    SKTRESULT result=[[scanObj Msg]Result];
    if(SKTSUCCESS(result)){
        NSLog(@"Trigger set success");
    }
    else{
        NSLog(@"Trigger set returned the error %ld",result);
    }
}

-(void) onGetScanApiVersion:(ISktScanObject*)scanObj{
    SKTRESULT result=[[scanObj Msg]Result];
    if(SKTSUCCESS(result)){
         ISktScanProperty* property=[scanObj Property];
        if([property getType]==kSktScanPropTypeVersion){
            scanApiVersion=[NSString stringWithFormat:@"%lx.%lx.%lx.%ld",
                            [[property Version]getMajor],
                            [[property Version]getMiddle],
                            [[property Version]getMinor],
                            [[property Version]getBuild]];
        }
    }
    else{
        scanApiVersion=[NSString stringWithFormat:@"Get ScanAPI version Error: %ld",result];
    }
}

-(void)onDeviceArrival:(SKTRESULT)result device:(DeviceInfo*)deviceInfo{
    
    NSLog(@"Device had arrived");
    
    [self updateDevicesList:deviceInfo Add:YES];
    
    
    
#ifdef USE_SOFTSCAN
    // if the scanner is a SoftScan scanner
    if([deviceInfo.getTypeString compare:@"SoftScan"]==NSOrderedSame){
        //_softScannerTriggerBtn.hidden=NO;
        //_softScanDeviceInfo=deviceInfo;
        //if(_deviceInfoToTrigger==nil)
        //    _deviceInfoToTrigger=deviceInfo;
        NSMutableDictionary* overlayParameter=[[NSMutableDictionary alloc]init];
        [overlayParameter setValue:self forKey:[NSString stringWithCString:kSktScanSoftScanContext encoding:NSASCIIStringEncoding]];
        [ScanApi postSetOverlayView:deviceInfo OverlayView:overlayParameter Target:self Response:@selector(onSetOverlayView:)];
    }
    else
#endif
    {
        if([deviceInfo.getTypeString compare:@"CHS 8Ci Scanner"]==NSOrderedSame){
            //_softScannerTriggerBtn.hidden=NO;
            //_deviceInfoToTrigger=deviceInfo;
        }
        if(_doAppDataConfirmation==YES){
            // switch the comment between the 2 following lines for handling the
            // data confirmation beep from the scanner (local)
            // if none is set, the scanner will beep only once when SingleEntry actually
            // confirm the decoded data, otherwise the scanner will beep twice, one locally,
            // and one when SingleEntry will confirm the decoded data
            [ScanApi postSetDecodeAction:deviceInfo DecodeAction:kSktScanLocalDecodeActionNone Target:self Response:@selector(onSetLocalDecodeAction:)];
            
            //        [ScanApi postSetDecodeAction:deviceInfo DecodeAction:kSktScanLocalDecodeActionBeep|kSktScanLocalDecodeActionFlash|kSktScanLocalDecodeActionRumble Target:self Response:@selector(onSetLocalDecodeAction:)];
        }
        
        // for demonstration only, let's make sure the DPM is enabled
        // first interrogate the scanner to see if it's already enabled
        // and in the onGetSymbologyDpm callback, if the DPM is not already set
        // then we send a Symbology property to enable it.
        [ScanApi postGetSymbologyInfo:deviceInfo SymbologyId:kSktScanSymbologyDirectPartMarking Target:self Response:@selector(onGetSymbologyDpm:)];
    }
    
}

-(void) onDeviceRemoval:(DeviceInfo*) deviceRemoved{
    [self updateDevicesList:deviceRemoved Add:NO];
}
/**
 * called each time ScanAPI is reporting an error
 * @param result contains the error code
 */
-(void) onError:(SKTRESULT) result{
   NSLog(@"ScanAPI is reporting an error: %ld",result);
}
/**
 * called when ScanAPI has been terminated. This will be
 * the last message received from ScanAPI
 */
-(void) onScanApiTerminated{
    
}




@end

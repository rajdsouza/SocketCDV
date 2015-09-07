# SocketCDV
Cordova plugin for Socket Mobile Devices 
========================
Inspiration from https://github.com/ttatarinov/lineapro-phonegap-plugin


## Quick start
To start plugin need to execute 'SocketCDV.initDT()' method. 
Recommended to add this into 'deviceready' handler.

## Device support
All what the framework supports. Its needs to be downloaded sepatetly from socket mobiles developer portal.

## Supported features:

* Automatically connects device when available
* Reads barcode and send it to barcodeData function

## capturing the barcode read event
The plugin will execute barcodeData function which can be used to access the read barcode

<script>
            var barcodeData = function (barcode, type) {
                console.log(barcode);
                // your code here
            };
</script>            

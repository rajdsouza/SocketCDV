# SocketCDV
Cordova plugin for Socket Mobile Devices 
========================
Inspiration from https://github.com/ttatarinov/lineapro-phonegap-plugin

## Quick start
Install the [Socket SDK](https://www.socketmobile.com/developers/welcome/).

To start plugin need to execute `SocketCDV.initDT()` method (after the `deviceready` event has fired).

Pass in a callback function to handle the barcode data as it is returned.

```js

// Barcode handler
var handleBarcode = function(barcodeData, barcodeType) {
   console.info("Barcode data: " + barcodeData);
};

// Initialise the barcode reader, pass the barcode handler function as the only parameter
SocketCDV.initDT(handleBarcode);

```

`Barcode data: 4548718727797`

## Device support
Any device supported by the Socket SDK framework.

## Supported features

* Automatically connects device when available
* Reads barcode and send it to barcodeData function

## Future Feature Improvements 

1. ~~Add a custom function which can recieve barcode read event~~
2. A way to display the device which is connected






cordova.define("au.com.rcgcorp.socketcdv.SocketCDV", function(require, exports, module) {
var argscheck = require('cordova/argscheck'),
    channel = require('cordova/channel'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec'),
    cordova = require('cordova');
              
 function SocketCDV() {
    this.results = [];
    this.connCallback = null;
    this.errorCallback = null;
    this.cancelCallback = null;
    this.barcodeCallback = null;
}

SocketCDV.prototype.onBarcodeData = function(data, type){
   this.barcodeCallback(data, type);
}
               
SocketCDV.prototype.initDT = function(barcodeCallback) {
    this.barcodeCallback = barcodeCallback;
    exec(null, null, "SocketCDV", "initDT", []);
};


module.exports = new SocketCDV();
});

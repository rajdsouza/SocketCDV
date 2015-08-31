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
    
}


SocketCDV.prototype.initDT = function() {
    exec(null, null, "SocketCDV", "initDT", []);
};


module.exports = new SocketCDV();
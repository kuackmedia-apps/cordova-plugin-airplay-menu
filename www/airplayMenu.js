var exec = require('cordova/exec');

exports.show = function(success, error) {
  exec(success, error, 'AirPlayMenu', 'show', []);
};

exports.getConnectedDevice = function(success, error) {
  exec(success, error, 'AirPlayMenu', 'getConnectedDevice', []);
};

exports.onDeviceChange = function(callback) {
  exec(callback, null, 'AirPlayMenu', 'startMonitoringDeviceChanges', []);
};

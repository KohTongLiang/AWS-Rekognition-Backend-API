var mongoose = require('mongoose');
var DeviceSchema = new mongoose.Schema({
  deviceId: String,
  fcmToken: String,
  platform: String,
},
  {
    timestamps: true
  });

mongoose.model('Device', DeviceSchema);

module.exports = mongoose.model('Device');
var mongoose = require('mongoose');
var NotificationSchema = new mongoose.Schema({
    deviceId: String,
    documentAddress: String,
    type: String,
    sender: String,
    message: String,
},
{
  timestamps: true
});

mongoose.model('Notification', NotificationSchema);

module.exports = mongoose.model('Notification');
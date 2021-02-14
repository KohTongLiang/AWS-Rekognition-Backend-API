var express = require('express');
var router = express.Router();
var Device = require('../Model/Device');
var Notification = require('../Model/Notification');
var moment = require('moment');
const gcm = require('node-gcm');

// POST /push/register
// Register user device
router.post('/register', (req, res) => {
    Device.findOneAndUpdate({ deviceId: req.body.deviceId }, req.body, { upsert: true, new: true, setDefaultsOnInsert: true }, (err, device) => {
        if (err) {
            res.sendStatus(500);
        }
        res.sendStatus(200);
    });
});

// PUT /push/updateToken
// Updates user's fcmToken in the rare event that it gets refreshed
router.put('/updateToken/:id', (req, res) => {
    Device.findOneAndUpdate({ deviceId: req.params.id }, { fcmToken: req.body.fcmToken }, (err, device) => {
        if (err) {
            res.sendStatus(500);
        }

        res.sendStatus(200);
    });
});

// POST /push/send/:id
// Send notification to specific user id
router.post('/sendNotification/:id', (req, res) => {
    Device.findOne({ deviceId: req.params.id }, (err, device) => {
        if (err) {
            return res.sendStatus(err);
        }

        if (!device) {
            return res.sendStatus(404);
        }

        updateNotificationDb(device.deviceId, req.body.type, req.body.documentAddress, req.body.sender);
        sendAndroid(device.fcmToken, req.body.type, req.body.documentAddress);
        return res.sendStatus(200);
    });
});

const updateNotificationDb = (deviceId, type, documentAddress, sender) => {
    var notificationMessage;

    if (type === 'view') {
        notificationMessage = sender + ' sent you a document to sign ';
    } else if (type === 'sign') {
        notificationMessage = sender + ' has signed your document ';
    }

    Notification.create({ deviceId: deviceId, type: type, message: notificationMessage, documentAddress: documentAddress }, (err, device) => {
        if (err) {
            console.log('Failure');
        }

        console.log('Success'); // all these consol.logs to be replaced with proper logging
    });
}

// function to send push notification to android
const sendAndroid = (devices, type, documentAddress) => {
    if (type === 'view') {
        var pushTitle = 'View Document';
        var content = 'View document: ' + documentAddress;
    } else if (type === 'sign') {
        var pushTitle = 'Sign Document';
        var content = 'Sign awaiting document: ' + documentAddress;
    }

    let message = new gcm.Message({
        notification: {
            title: pushTitle
        }
    });

    let sender = new gcm.Sender('AAAAh8pfSZw:APA91bFWiiC6wYaKFzpf-yMLtmQQHa_UgB4d2CoGeh8xPKNfU6moORW7H6X68CRdKI3z6sQqQWsakEqrzRKG94nESZiVAFlI2H3_lAuV9ipr9xJAlq_xTB5HCmseeKEfOjFTU4lgqnyo');

    sender.send(message, devices, function (err, response) {
        if (err) {
            console.error(err);
        } else {
            console.log(response);
        }
    });
}

// can include function to push to IOS in the future

module.exports = router;
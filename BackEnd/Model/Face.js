var mongoose = require('mongoose');
var schema = new mongoose.Schema({
    studentMatricNo: {
        type: String,
        required: true
    },
    faceId: {
        type: String,
        required: true
    }
},
    { timestamps: true });

mongoose.model('Face', schema);

module.exports = mongoose.model('Face');
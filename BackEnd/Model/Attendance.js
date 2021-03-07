var mongoose = require('mongoose');
var schema = new mongoose.Schema({
    studentMatricNo: {
        type: String,
        required: true
    },
    classListId: {
        type: mongoose.Schema.ObjectId,
        required: true
    },
    studentName: {
        type: String,
        required: true
    },
    attendance: {
        type: Boolean,
        required: true,
        default: false
    }
},
    { timestamps: true });

mongoose.model('Attendance', schema);

module.exports = mongoose.model('Attendance');
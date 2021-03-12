var mongoose = require('mongoose');
var schema = new mongoose.Schema({
    studentName: {
        type: String,
        required: true
    },
    studentEmail: {
        type: String,
        required: true
    },
    studentMatricNo: {
        type: String,
        required: true
    },
    studentYear: {
        type: Number,
        required: true
    },
    image: {
        type: String,
        required: true
    }
},
    { timestamps: true });

mongoose.model('Student', schema);

module.exports = mongoose.model('Student');
var mongoose = require('mongoose');

var schema = new mongoose.Schema({
    students: {
        type: Array,
        required: false,
        default: []
    },
    moduleCode: {
        type: String,
        required: true
    },
    startTime: {
        type: Date,
        required: true
    },
    endTime: {
        type: Date,
        required: true
    },
    sessionStarted: {
        type: Boolean,
        default: false
    }
},
    { timestamps: true });

mongoose.model('ClassList', schema);

module.exports = mongoose.model('ClassList');
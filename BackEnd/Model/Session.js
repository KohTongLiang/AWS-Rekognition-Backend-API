var mongoose = require('mongoose');
var ClassList = require('./ClassList');

var schema = new mongoose.Schema({
    weekNo: {
        type: Number,
        required: false
    },
    date: {
        type: Date,
        required: true
    },
    class: {
        type: mongoose.Types.ObjectId,
        required: true,
        ref: ClassList
    },
    attended: {
        type: Array,
        default: []
    },
    active: {
        type: Boolean,
        default: false
    }
},
    { timestamps: true });

mongoose.model('Session', schema);

module.exports = mongoose.model('Session');
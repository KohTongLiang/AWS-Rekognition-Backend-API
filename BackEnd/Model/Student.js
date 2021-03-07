var mongoose = require('mongoose');
var schema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    email: {
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
    studentImage: {
        type: String,
        require: true
    },
    attended: {
        type: Boolean,
        default: false
    }
},
    { timestamps: true });

mongoose.model('Student', schema);

module.exports = mongoose.model('Student');
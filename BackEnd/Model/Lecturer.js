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
    password: {
        type: String,
        required: true
    },
},
    { timestamps: true });

mongoose.model('Lecturer', schema);

module.exports = mongoose.model('Lecturer');
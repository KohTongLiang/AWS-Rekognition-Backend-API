var mongoose = require('mongoose');
var schema = new mongoose.Schema({
    moduleCode: {
        type: String,
        required: true
    },
    moduleName: {
        type: String,
        required: true
    },
    moduleDescription: {
        type: String,
        required: true
    }
},
    { timestamps: true });

mongoose.model('Module', schema);

module.exports = mongoose.model('Module');
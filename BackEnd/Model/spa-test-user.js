var mongoose = require('mongoose');  
var UserSchema = new mongoose.Schema({
    id: Number,
    firstName: String,
    lastName: String,
    email: String,
    dob: String
});

mongoose.model('spa-test-user', UserSchema);

module.exports = mongoose.model('spa-test-user');
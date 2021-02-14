var mongoose = require('mongoose');  
var UserSchema = new mongoose.Schema({  
  Name: String,
  Email: String,
  Password: String
},
{ timestamps: true});

mongoose.model('User', UserSchema);

module.exports = mongoose.model('User');
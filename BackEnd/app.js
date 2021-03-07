// imports and dependencies
var express = require('express');
var app = express();
var cors = require('cors');
const dotenv = require('dotenv');
var bodyParser = require('body-parser');
const cookieParser = require("cookie-parser");
const fileUpload = require('express-fileupload');
var moment = require('moment');
const path = require('path');
var AWS = require("aws-sdk");
var multer = require('multer');

AWS.config.update({
  accessKeyId: AWS.config.credentials.accessKeyId,
  secretAccessKey: AWS.config.credentials.secretAccessKey,
  region: "ap-southeast-1",
});

const s3 = new AWS.S3();
// AWS.config.getCredentials(function(err) {
//   if (err) console.log(err.stack);
//   // credentials not loaded
//   else {
//     console.log("Access key:", AWS.config.credentials.accessKeyId);
//   }
// });


// import controllers
const AuthController = require('./Controller/AuthController');
const ClassListController = require('./Controller/ClassListController');
const StudentController = require('./Controller/StudentController');
const ModuleController = require('./Controller/ModuleController');
const AdminController = require('./Controller/AdminController.js');

// setup environmental variable
dotenv.config();

// setup connection to database
var db = require('./db');

// setup up scheduler
var schedule = require('./Scheduler/Scheduler');

// create a logger middlware to manipulate req/res
const logger = (req, res, next) => {
  console.log(`${req.protocol}://${req.get('host')}${req.originalUrl}: ${moment().format()}`);
  next();
}

// middleware
app.use(fileUpload());
app.use(logger);
app.use(cookieParser());
app.use(bodyParser.urlencoded({ extended: false, limit: '50mb' }));
app.use(bodyParser.json({ limit: '50mb' }));
app.use(cors());

// Add css and boostrap to path
app.use(express.static(path.join(__dirname, "public")));

// app routes
app.use('/auth', AuthController);
app.use('/classList', ClassListController);
app.use('/student', StudentController);
app.use('/module', ModuleController)
app.use('/admin', AdminController);

// setup port
var port = process.env.PORT || 5000;

// kill process when nodemon exits
process.once("SIGHUP", function () {
  process.exit();
})

// start the app
app.listen(port, function () {
  console.log('Express server listening on port ' + port);
});
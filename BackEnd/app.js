// imports and dependencies
var express = require('express');
var app = express();
var cors = require('cors');
const dotenv = require('dotenv');
var bodyParser = require('body-parser');
const cookieParser = require("cookie-parser");
var moment = require('moment');
const path = require('path')

// import controllers
var HomeController = require('./Controller/HomeController')
var UserController = require('./Controller/UserController');
var AuthController = require('./Controller/AuthController');
var AdminController = require('./Controller/AdminController');
var PushController = require('./Controller/PushController');
var TestController = require('./Controller/TestController');

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

// set pug view template
app.set('view engine', 'pug');

// middleware
app.use(logger);
app.use(cookieParser());
app.use(bodyParser.urlencoded({ extended: false, limit: '50mb' }));
app.use(bodyParser.json({limit: '50mb'}));
app.use(cors());
// to restrict origin
// var allowedOrigins = ['http://localhost:3000',
//                       'http://yourapp.com'];
// app.use(cors({
//   origin: function(origin, callback){
//     // allow requests with no origin 
//     // (like mobile apps or curl requests)
//     if(!origin) return callback(null, true);
//     if(allowedOrigins.indexOf(origin) === -1){
//       var msg = 'The CORS policy for this site does not ' +
//                 'allow access from the specified Origin.';
//       return callback(new Error(msg), false);
//     }
//     return callback(null, true);
//   }
// }));

// Add css and boostrap to path
app.use(express.static(path.join(__dirname, "public")));

// app routes
app.use('/', HomeController);
app.use('/admin', AdminController)
app.use('/users', UserController);
app.use('/api/auth', AuthController);
app.use('/push', PushController);
app.use('/test', TestController);

// setup port
var port = process.env.PORT || 5000;

// start the app
app.listen(port, function() {
  console.log('Express server listening on port ' + port);
});
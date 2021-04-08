var express = require('express');
var router = express.Router();
var jwt = require('jsonwebtoken');
var bcrypt = require('bcryptjs');
var VerifyToken = require('../Auth/VerifyToken');
const Lecturer = require('../Model/Lecturer');

// POST /auth/register
router.post('/register', function (req, res) {
    var hashedPassword = bcrypt.hashSync(req.body.password, 8);

    Lecturer.create({
        name: req.body.name,
        email: req.body.email,
        password: hashedPassword
    }, function (err, lecturer) {
        if (err) {
            return res.status(500).send({ auth: false, message: "There was a problem registering the account."});
        }

        // create a token
        var token = jwt.sign({ id: lecturer._id }, process.env.SECRET_KEY, {
            expiresIn: 86400 // expires in 24 hours
        });

        res.status(200).send({ auth: true, token: token });
    });
});

// POST /auth/login
router.post('/login', function (req, res) {
    Lecturer.findOne({ email: req.body.email }, function (err, lecturer) {
        if (err) {
            return res.status(500).send('Error on the server.');
        }

        if (!lecturer) {
            return res.status(401).send({ auth: false, token: null, message: 'No such user found.' });
        }

        var passwordIsValid = bcrypt.compareSync(req.body.password, lecturer.password);
        if (!passwordIsValid) {
            return res.status(401).send({ auth: false, token: null, message: "Invalid password" });
        }

        // create a JWT Token
        var token = jwt.sign({ id: lecturer._id }, process.env.SECRET_KEY, {
            expiresIn: 86400 // expires in 24 hours
        });

        return res.status(200).send({ auth: true, token: token });
    });
});

module.exports = router;
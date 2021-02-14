var express = require('express');
var router = express.Router();
var User = require('../Model/User');
var jwt = require('jsonwebtoken');
var bcrypt = require('bcryptjs');
var VerifyToken = require('../Auth/VerifyToken');

// POST /api/auth/register
router.post('/register', function (req, res) {
    var hashedPassword = bcrypt.hashSync(req.body.Password, 8);

    User.create({
        Name: req.body.Name,
        Email: req.body.Email,
        Password: hashedPassword
    }, function (err, user) {
        if (err) {
            return res.status(500).send("There was a problem registering the user.");
        }

        // create a token
        var token = jwt.sign({ id: user._id }, process.env.SECRET_KEY, {
            expiresIn: 86400 // expires in 24 hours
        });

        res.status(200).send({ auth: true, token: token });
    });
});

// POST /api/auth/login
router.post('/login', function (req, res) {
    User.findOne({ Email: req.body.Email }, function (err, user) {
        if (err) {
            return res.status(500).send('Error on the server.');
        }

        if (!user) {
            return res.status(401).send({ auth: false, token: null, message: 'No such user found.' });
        }

        var passwordIsValid = bcrypt.compareSync(req.body.Password, user.Password);
        if (!passwordIsValid) {
            return res.status(401).send({ auth: false, token: null, message: "Invalid password" });
        }

        // create a JWT Token
        var token = jwt.sign({ id: user._id }, process.env.SECRET_KEY, {
            expiresIn: 86400 // expires in 24 hours
        });

        // create a cookie and store JWT in cookie
        const cookieOptions = {
            httpOnly: true,
            expires: 0
        }

        //  res.cookie('apiAccessJwt', token, cookieOptions);

        return res.status(200).cookie('apiAccessJwt', token, cookieOptions).send({ auth: true, token: token });
    });
});

// GET /api/auth/logout
router.get('/logout', VerifyToken, function (req, res, next) {
    const userJWT = req.cookies.apiAccessJwt;
    const userJWTPayload = jwt.verify(userJWT, process.env.SECRET_KEY);

    res.clearCookie('apiAccessJwt');
    User.findOneAndUpdate({ apiAccessJwt: userJWTPayload.apiAccessJwt },
        {
            apiAccessJwt: null,
            apiAccessJwtSecret: null
        },
        function (err, result) {
            if (err) {
                console.log(err)
            }
            else {
                console.log("Deleted access token for", result.name)
            }
            return res.render(
                'index',
                {
                    loggedIn: false
                }
            );
        });
});
// router.get('/logout', function(req, res) {
//     res.status(200).send({ auth: false, token: null });
// });

// GET /api/auth/me
router.get('/me', VerifyToken, function (req, res, next) {
    User.findById(req.userId, { password: 0 }, function (err, user) {
        if (err) {
            return res.status(500).send("There was a problem finding the user.");
        }

        if (!user) {
            return res.status(404).send("No user found.");
        }

        res.status(200).send(user);
    });
});

module.exports = router;
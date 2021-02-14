var jwt = require('jsonwebtoken');

function CheckSignIn(req, res, next) {
    const token = req.cookies.apiAccessJwt;
    // var token = req.headers['x-access-token'];

    // if client does not have cookie
    if (!token) {
        next();
    }


    // if cookie existm verify if the JWT TOken is valid
    jwt.verify(token, process.env.SECRET_KEY, function (err, decoded) {
        // invalid JWT Token
        if (err) {
            next();
        }
        
        req.loggedIn = true;
        next();
    });
}

module.exports = CheckSignIn;
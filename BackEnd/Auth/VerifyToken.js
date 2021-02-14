var jwt = require('jsonwebtoken');

function VerifyToken(req, res, next) {
    const token = req.cookies.apiAccessJwt;
    // var token = req.headers['x-access-token'];

    // if client does not have cookie
    if (!token) {
        return res.status(403).send({ auth: false, message: 'No token provided.' });
        // return res.render(
        //     'index'
        // );
    }


    // if cookie existm verify if the JWT TOken is valid
    jwt.verify(token, process.env.SECRET_KEY, function (err, decoded) {
        // invalid JWT Token
        if (err) {
            return res.status(500).send({ auth: false, message: 'Failed to authenticate token.' });
            // return res.render(
            //     'index'
            // );
        }

        // if everything good, save to request for use in other routes
        req.userId = decoded.id;
        req.loggedIn = true;
        next();
    });
}

module.exports = VerifyToken;
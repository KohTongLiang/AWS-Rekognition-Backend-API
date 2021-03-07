var jwt = require('jsonwebtoken');

function VerifyToken(req, res, next) {
    // const token = req.cookies.apiAccessJwt;
    const token = req.headers['x-access-token'];

    // if client does not have cookie
    if (!token) {
        return res.status(403).send({ auth: false, message: 'No token provided.' });
    }


    // if cookie existm verify if the JWT TOken is valid
    jwt.verify(token, process.env.SECRET_KEY, function (err, decoded) {

        // invalid JWT Token
        if (err) {
            return res.status(401).send({ auth: false, message: 'Failed to authenticate token.' });
        }

        next();
    });
}

module.exports = VerifyToken;
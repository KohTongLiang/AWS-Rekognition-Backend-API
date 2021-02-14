var express = require('express');
var router = express.Router();
var CheckSignIn = require('../Auth/CheckSignIn');
var User = require('../Model/User');

// GET /
// Landing page when user enter URL
// Get landing page and return to user
router.get('/', CheckSignIn, (req, res) => {
    return res.render(
        'index',
        {
            loggedIn: req.loggedIn
        }
    );
});

// GET /about
// About page to describe functionality of the website
// Get about page and return to user
router.get('/about', CheckSignIn, (req, res) => {
    return res.render(
        'about',
        {
            loggedIn: req.loggedIn
        }
    );
});

// GET /login
// Login page to allow administrator of TrueSign to login to perfor admin functionalities
// Get lgoin page and return to user
router.get('/login', CheckSignIn, (req, res) => {
    if (!req.loggedIn) {
        return res.render(
            'login'
        );
    } else {
        return res.render(
            'index',
            {
                loggedIn: req.loggedIn,
            }
        )
    }
});

module.exports = router;
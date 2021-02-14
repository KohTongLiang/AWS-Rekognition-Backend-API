var express = require('express');
var router = express.Router();
var spaTestUser = require('../Model/spa-test-user');
var moment = require('moment');

// KYC Portion for TrueSign system

// GET /test
// GET ALL USERS
router.get('/', (req, res) => {
    spaTestUser.find({}, (err, user) => {
        if (err) {
            return res.status(500).json({ message: 'There was a problem retrieving user data' });
        }
        return res.status(200).send(user);
    })
});

// GET /test/:id
// GET SINGLE ARTICLE BY USER ID
router.get('/:id', (req, res) => {
    spaTestUser.findById(req.params.id, (err, user) => {
        if (err) {
            return res.status(500).json({ message: 'There was a problem finding the customer.' });
        }

        if (!user) {
            return res.status(404).json({ message: 'No article found.' });
        }

        return res.status(200).send(user);
    });
});

// POST /test/
// CREATE NEW USER
// AUTH REQUIRED TO CREATE AN CUSTOMER
router.post('/', (req, res) => {
    spaTestUser.create(req.body, (err, user) => {
        if (err) {
            return res.status(500).json({ message: 'There was a problem creating user.' });
        }

        return res.status(200).send(user);
    });
});

router.put('/:id', (req, res) => {
    spaTestUser.findByIdAndUpdate(req.params.id, req.body, { new: true }, function (err, user) {
        if (err) {
            return res.status(500).send("There was a problem updating the user.");
        }
        return res.status(200).send(user);
    });
}); // end of update single customer

// DELETE /test/:id
// DELETE ARTICLE BY ARTICLE ID
router.delete('/:id', (req, res) => {
    spaTestUser.deleteOne( { _id: req.params.id }, (err, user) => {
        if (err) {
            // return res.status(500).json({ message: 'There was a problem deleting article.' });
            return res.status(500).json({ message: err });
        }
        return res.status(200).send(user);
    });
});

module.exports = router;
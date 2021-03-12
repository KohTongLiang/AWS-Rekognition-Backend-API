var express = require('express');
var router = express.Router();
const { ClassList, Session } = require('../Model/ClassList');
const Attendance = require('../Model/Attendance');
const VerifyToken = require('../Auth/VerifyToken');
var facialAWS = require("../Services/ImageRecognition");

// POST /classList
// Creating a class list
router.post('/', VerifyToken, (req, res) => {
    ClassList.create( req.body, (err, classList) => {
        if (err) return res.status(500).send({ message: "There was a problem creating class list"});

        res.status(200).send({ message: "Successfully created Class List" });
    });
});

// GET /classList
// Getting all class list
router.get('/', VerifyToken, (req, res) => {
    ClassList.find().populate('sessions').exec((err, classList) => {
        if (err) return res.status(500).send({ message: "There was a problem retrieving class list"});

        res.status(200).send(classList);
    });
});

// GET /classList/:id
// Getting 1 specific class list
router.get('/:id', VerifyToken, (req,res) => {
    ClassList.findOne({_id: req.params.id}).populate('sessions').exec((err, classList) => {
        if (err) return res.status(500).send({ message: "There was a problem retrieving class list"});
        
        res.status(200).send(classList);        
    });
});

// PUT /classList /:id
// Updating 1 specific class list
router.put('/:id', VerifyToken, (req, res) => {
    ClassList.findOneAndUpdate({_id: req.params.id}, req.body, (err, classList) => {
        if (err) return res.status(500).send({ message: "There was a problem updating class list"});
        
        res.status(200).send({ message: 'Successfully updated classlist '});
    });
});

// DELETE /classList/:id
router.delete('/:id', VerifyToken, (req, res) => {
    ClassList.findOneAndDelete({_id: req.params.id}, (err, classList) => {
        if (err) return res.status(500).send({ message: "There was a problem deleting class list"});

        res.status(200).send({ message: 'Successfully deleted classlist '});
    });
});


module.exports = router;
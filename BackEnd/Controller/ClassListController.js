var express = require('express');
var router = express.Router();
const ClassList = require('../Model/ClassList');
const Attendance = require('../Model/Attendance');
const VerifyToken = require('../Auth/VerifyToken');
var facialAWS = require("../Services/ImageRecognition");

// POST /classList/
// Creating a class list
router.post('/', VerifyToken, (req, res) => {
    ClassList.create( req.body, (err, classList) => {
        console.log(err);
        if (err) return res.status(500).send({ message: "There was a problem creating class list"});

        res.status(200).send(classList);
    });
});

// GET /classList/
// Getting all class list
router.get('/', VerifyToken, (req, res) => {
    ClassList.find((err, classList) => {
        if (err) return res.status(500).send({ message: "There was a problem retrieving class list"});

        res.status(200).send(classList);
    });
});

// GET /classList/:id
// Getting 1 specific class list
router.get('/:id', VerifyToken, (req,res) => {
    ClassList.findOne({_id: req.params.id}, (err, classList) => {
        if (err) return res.status(500).send({ message: "There was a problem retrieving class list"});
        
        res.status(200).send(classList);        
    });
});

// PUT /classList /:id
// Updating 1 specific class list
router.put('/:id', VerifyToken, (req, res) => {
    ClassList.findOneAndUpdate({_id: req.params.id}, req.body, (err, classList) => {
        if (err) return res.status(500).send({ message: "There was a problem updating class list"});
        
        res.status(200).send(classList);      
    });
});

// DELETE /classList/:id
router.delete('/:id', VerifyToken, (req, res) => {
    ClassList.findOneAndDelete({_id: req.params.id}, (err, classList) => {
        if (err) return res.status(500).send({ message: "There was a problem deleting class list"});

        res.status(200).send({ message: 'Ok' });
    });
});

// Manual trigger session start
router.post('/startSession/:id', VerifyToken, (req, res) => {
    ClassList.findOneAndUpdate({ _id: req.params.id }, { sessionStarted: req.body.sessionStatus }, (err, result) => {
        if (err) return res.status(500).send({ message: "There was a problem starting the class session"});

        res.status(200).send({ message: 'Ok' });
    });
});

// Attendance Report Endpoints

// GET /classList/attendance/:classListId
// Generate list of students and their attendance for a particular class list.
router.get('/attendance/:classListId', VerifyToken, (req, res) => {
    Attendance.find({ classListId: req.params.classListId }, (err, attendance) => {
        if (err) return res.status(500).send({ message: "There was a problem generating attendance report"});

        res.status(200).send(attendance);
    });
});

// POST /classList/attendance/:classListId
// POST class list id and base64 encoding of image
router.post('/attendance/:classListId', VerifyToken, (req, res) => {
    const obj = {
        photo: req.body.image
    }

    //calling method API AWS to recoknition face.
    facialAWS.search_face(obj, function (data) {
        if (data.found) {
            // mark student as attended
            const studentMatricNoQuery = data.ExternalImageId;

            Attendance.findOneAndUpdate({ studentMatricNo: studentMatricNoQuery}, { $set: { attendance: true }}, {new: true}, (err, attendance) => {
                if (err) return res.status(500).send({ message: "There was a problem marking the attendance"});

                res.status(200).send({ message: "Attendance has been successfully marked." });
            });
        } else {
            res.status(404).send({ message: "Identity not detected." });
        }
    });
});

// POST /classList/attendance/manual/:classListId
// POST class list id and student matric number to manually register student's IC
router.post('/attendance/manual/:classListId', VerifyToken, (req, res) => {
    Attendance.findOneAndUpdate({ studentMatricNo: req.body.studentMatricNo}, { $set: { attendance: true }}, {new: true}, (err, attendance) => {
        if (err) return res.status(500).send({ message: "There was a problem marking the attendance"});

        res.status(200).send({ message: "Attendance has been successfully marked." });
    });
});

module.exports = router;
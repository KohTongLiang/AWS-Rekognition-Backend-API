var express = require('express');
var router = express.Router();
// const Session = require('../Model/Session');
const { ClassList, Session } = require('../Model/ClassList');
const VerifyToken = require('../Auth/VerifyToken');
const facialAWS = require("../Services/ImageRecognition");

// POST /session
// Create a session
router.post('/', VerifyToken, (req, res) => {
    Session.create(req.body, (err, session) => {
        if (err) return res.status(500).send({ message: "There was a problem creating session" });

        res.status(200).send({ message: "Successfully created session" });
    });
});

// GET /session
// Getting all session
router.get('/', VerifyToken, (req, res) => {
    Session.find().populate('class').exec((err, session) => {
        if (err) return res.status(500).send({ message: "There was a problem retrieving session" });

        res.status(200).send(session);
    });
});

// GET /session/:id
// Getting 1 specific session
router.get('/:id', VerifyToken, (req, res) => {
    Session.findOne({ _id: req.params.id }, (err, session) => {
        if (err) return res.status(500).send({ message: "There was a problem retrieving session" });

        res.status(200).send(session);
    });
});

// PUT /session/:id
// Updating 1 specific session
router.put('/:id', VerifyToken, (req, res) => {
    Session.findOneAndUpdate({ _id: req.params.id }, req.body, (err, session) => {
        if (err) return res.status(500).send({ message: "There was a problem updating session" });

        ClassList.findOneAndUpdate({ _id: req.body.classListId }, { $push: { 'sessions': session._id } }, (err, result) => {
            if (err) return res.status(500).send({ message: "There was a problem creating session" });

            res.status(200).send({ message: "Successfully created session" });
        });
    });
});

// DELETE /session/:id
router.delete('/:id', VerifyToken, (req, res) => {
    Session.findOneAndDelete({ _id: req.params.id }, (err, session) => {
        if (err) return res.status(500).send({ message: "There was a problem deleting session" });

        res.status(200).send({ message: "Successfully deleted Session" });
    });
});


// Attendance Marking Endpoints

// POST /session/attendance/:sessionId
// POST session id and base64 encoding of image
router.post('/attendance/:sessionId', VerifyToken, (req, res) => {
    const obj = {
        photo: req.body.image
    }

    // calling method API AWS to recoknition face.
    facialAWS.search_face(obj, function (data) {
        if (data.found) {
            // mark student as attended
            const studentMatricNoQuery = data.ExternalImageId;

            // check if student registered to the class, if it is not registered, send a error message
            Session.findOne({ _id: req.params.sessionId }).populate('class').exec((err, session) => {
                const registeredStudents = session.class.students;

                // if (registeredStudents.includes(studentMatricNoQuery)) {
                    // student is registered
                    Session.findOneAndUpdate({ _id: req.params.sessionId }, { $addToSet: { attended: studentMatricNoQuery } }, (err, result) => {
                        if (err) return res.status(500).send({ message: "There was a problem marking the attendance" });

                        res.status(200).send({ message: "Attendance has been successfully marked." });
                    });
                // } else {
                //     // student is not registered in the class
                //     res.status(404).send({ message: "Student is not registered in the class." });
                // }
            });
        } else {
            res.status(404).send({ message: "Identity not detected." });
        }
    });
});

// POST /classList/attendance/manual/:sessionId
// POST session id and student matric number to manually register student's IC
router.post('/attendance/manual/:sessionId', VerifyToken, (req, res) => {

    // check if student registered to the class, if it is not registered, send a error message
    Session.findOne({ _id: req.params.sessionId }).populate('class').exec((err, session) => {
        const registeredStudents = session.class.students;
        console.log(registeredStudents);

        if (registeredStudents.includes(req.body.studentMatricNo)) {
            // student is registered in class
            Session.findOneAndUpdate({ _id: req.params.sessionId }, { $push: { attended: req.body.studentMatricNo } }, { new: true }, (err, attendance) => {
                if (err) return res.status(500).send({ message: "There was a problem marking the attendance" });

                res.status(200).send({ message: "Attendance has been successfully marked." });
            });
        } else {
            // student is not registered in class
            res.status(404).send({ message: "Student is not registered in the class." });
        }
    });
});

// GET /session/:id
// Getting 1 specific session
router.get('/getActiveSession/active', VerifyToken, (req, res) => {
    Session.find({ active: true }).populate('class').exec((err, session) => {
        if (err) return res.status(500).send({ message: "There was a problem retrieving session" });

        res.status(200).send(session);
    });
});


module.exports = router;

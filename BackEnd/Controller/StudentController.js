var express = require('express');
var router = express.Router();
const Student = require('../Model/Student')
const VerifyToken = require('../Auth/VerifyToken');
const facialAWS = require("../Services/ImageRecognition");
const Face = require('../Model/Face');

// POST /student
// Create a student record and index their face
router.post('/', VerifyToken, (req, res) => {
    Student.create(req.body, (err, student) => {
        if (err) return res.status(500).send({ message: "There was a problem creating Student" });

        // create an object matching face with matric no.
        const obj = {
            photo: req.body.image,
            id_user: req.body.studentMatricNo
        }

        // call AWS rekognition API to index face
        facialAWS.indexFaces(obj, function (data) {
            if (data.found) {
                Face.create({ faceId: data.resultAWS.FaceId, studentMatricNo: req.body.studentMatricNo }, (err, result) => {
                    if (err) return res.status(500).send({ message: "There was a problem indexing student's face. Kindly update the student's photo at a later stage." });

                    res.status(200).send({ message: "Successfully created Student" });
                });
            } else {
                if (err) return res.status(500).send({ message: "There was a problem indexing student's face. Kindly update the student's photo at a later stage." });
            }
        });
    });
});

// PUT /student/:studentMatriNo
// Update a student record and update their face image
router.put('/:studentMatricNo', VerifyToken, (req, res) => {
    Student.findOneAndUpdate({ studentMatricNo: req.params.studentMatriNo }, req.body, (err, student) => {
        if (err) return res.status(500).send({ message: "There was a problem creating Student" });

        //
        Face.findOne({ studentMatricNo: req.params.studentMatricNo }, (err, result) => {
            //recive param face_id, thats is a unique key of face.
            const obj = {
                face_id: result.faceId,
                id_user: req.params.studentMatricNo,
                photo: req.body.image
            }

            facialAWS.updateFace(obj, data => {
                Face.findOneAndUpdate({ studentMatricNo: req.params.studentMatricNo}, { faceId: data.resultAWS.FaceId }, (err, result) => {
                    if (err) return res.status(500).send({ message: "There was a problem indexing student's face. Kindly update the student's photo at a later stage." });

                    res.status(200).send({ message: "Successfully edited Student" });
                });
            });

            //calling method API AWS to delete face.    
            // facialAWS.deleteFace(obj, function (data) {
            //     Face.findOneAndDelete({ studentMatricNo: req.params.studentMatricNo }, (err, result) => {
            //         if (err) return res.status(500).send({ message: "There was a problem deleting face." });

            //         // create an object matching face with matric no.
            //         const obj = {
            //             photo: req.body.image,
            //             id_user: req.params.studentMatricNo
            //         }

            //         // call AWS rekognition API to index face
            //         facialAWS.indexFaces(obj, function (data) {
            //             if (data.found) {
            //                 Face.create({ faceId: data.resultAWS.FaceId, studentMatricNo: req.params.studentMatricNo }, (err, result) => {
            //                     if (err) return res.status(500).send({ message: "There was a problem indexing student's face. Kindly update the student's photo at a later stage." });

            //                     res.status(200).send({ message: "Successfully created Student" });
            //                 });
            //             } else {
            //                 res.status(200).send({ message: "Successfully created Student" });
            //             }
            //         });
            //     });
            // });
        });
    });
});

// GET /student/
// Getting all students
router.get('/', VerifyToken, (req, res) => {
    Student.find().populate('faceId').exec((err, studentList) => {
        if (err) return res.status(500).send({ message: "There was a problem retrieving student list" });

        res.status(200).send(studentList);
    });
});

// GET /student/:studentMatricNo
// Getting 1 specific student
router.get('/:studentMatricNo', VerifyToken, (req, res) => {
    Student.findOne({ studentMatricNo: req.params.studentMatricNo }, (err, studentList) => {
        if (err) return res.status(500).send({ message: "There was a problem retrieving student list" });

        res.status(200).send(studentList);
    });
});

// DELETE /student/:studentMatricNo
// Deleting 1 specific student
router.delete('/:studentMatricNo', VerifyToken, (req, res) => {

    Face.findOne({ studentMatricNo: req.params.studentMatricNo }, (err, result) => {
        //recive param face_id, thats is a unique key of face.
        const obj = {
            face_id: result.faceId
        }

        //calling method API AWS to delete face.    
        facialAWS.deleteFace(obj, function (data) {
            Face.findOneAndDelete({ studentMatricNo: req.params.studentMatricNo }, (err, result) => {
                if (err) return res.status(500).send({ message: "There was a problem deleting face." });

                Student.findOneAndDelete({studentMatricNo: req.params.studentMatricNo}, (err, student) => {
                    if (err) return res.status(500).send({ message: "There was a problem deleting student"});
            
                    res.status(200).send({ message: 'Ok' });
                });                
            });
        });
    });

});

module.exports = router;
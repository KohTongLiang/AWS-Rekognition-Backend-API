var express = require('express');
var router = express.Router();
const Student = require('../Model/Student')
const VerifyToken = require('../Auth/VerifyToken');

// GET /student/
// Getting all students
router.get('/', VerifyToken, (req, res) => {
    Student.find((err, studentList) => {
        if (err) return res.status(500).send({ message: "There was a problem retrieving student list"});
        
        res.status(200).send(studentList);
    });
});

// GET /student/:id
// Getting 1 specific student
router.get('/:id', VerifyToken, (req,res) => {
    Student.findOne({_id: req.params.id}, (err, studentList) => {
        if (err) return res.status(500).send({ message: "There was a problem retrieving student list"});
        
        res.status(200).send(studentList);        
    });
});

module.exports = router;
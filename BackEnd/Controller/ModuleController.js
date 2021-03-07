var express = require('express');
var router = express.Router();
const Module = require('../Model/Module')
const VerifyToken = require('../Auth/VerifyToken');

// GET /module/
// Getting all modules
router.get('/', VerifyToken, (req, res) => {
    Module.find((err, moduleList) => {
        if (err) return res.status(500).send({ message: "There was a problem retrieving module list"});

        res.status(200).send(moduleList);
    });
});

// GET /module/:id
// Getting 1 specific module
router.get('/:id', VerifyToken, (req,res) => {
    Module.findOne({_id: req.params.id}, (err, moduleList) => {
        if (err) return res.status(500).send({ message: "There was a problem retrieving module list"});
        
        res.status(200).send(moduleList);        
    });
});

module.exports = router;
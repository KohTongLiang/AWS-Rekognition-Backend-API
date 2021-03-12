var express = require('express');
var router = express.Router();
const Module = require('../Model/Module')
const VerifyToken = require('../Auth/VerifyToken');

// POST /module
// Create a module
router.post('/', VerifyToken, (req, res) => {
    Module.create( req.body, (err, session) => {
        if (err) return res.status(500).send({ message: "There was a problem creating module"});

        res.status(200).send({ message: "Successfully created module" });
    });
});

// PUT /module/:id
// Updating 1 specific module
router.put('/:id', VerifyToken, (req, res) => {
    Module.findOneAndUpdate({_id: req.params.id}, req.body, (err, module) => {
        if (err) return res.status(500).send({ message: "There was a problem updating Module"});
        
        res.status(200).send({ message: "Successfully updated Module"});      
    });
});

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

// DELETE /module/:id
// Delet module from module list
router.delete('/:id', VerifyToken, (req, res) => {
    Module.findOneAndDelete({_id: req.params.id}, (err, module) => {
        if (err) return res.status(500).send({ message: "There was a problem deleting Module"});

        res.status(200).send({ message: 'Successfully deleted Module' });
    });
});

module.exports = router;
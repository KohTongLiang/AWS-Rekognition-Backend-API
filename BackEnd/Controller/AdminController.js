var express = require('express');
var router = express.Router();
var Customer = require('../Model/Customer');
var moment = require('moment');
const VerifyToken = require('../Auth/VerifyToken');

// GET /admin/
// VIEW VERIFY CUSTOMERS
// Extract all kyc data from database and display on a simple web page.
router.get('/', VerifyToken, (req,res) => {
    let customers;
    Customer.find((err, cus) => {
        return res.render(
            'verify-customer',
            {
                CustomerList : cus,
                loggedIn: req.loggedIn,
            }
        );
    });
});

// PUT /admin/verifyCustomer/:id
// SET SELECTED CUSTOMER AS VERIFIED
// Input customer id and update database as verified
router.put('/verifyCustomer/:id', (req, res) => {
    // Update
    Customer.findByIdAndUpdate(
        req.params.id,
        { "$set": { Status: "Verified" } },
        { new: true },
        function (err, cus) {
            if (err) {
                console.log(err);
                return res.status(500).send("There was a problem verifying the user.");
            }
            return res.status(200).json({ message: 'OK' });
    });
}); // end of update single customer

module.exports = router;
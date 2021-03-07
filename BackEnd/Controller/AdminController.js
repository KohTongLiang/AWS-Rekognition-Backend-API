var express = require("express");
var router = express.Router();
var facialAWS = require("../Services/ImageRecognition");
const Face = require('../Model/Face');

/* Method - Detect face of users by photo.
   Recive - Photo in format base 64.
   Return - Return result of reconize.
*/
router.post('/detectFace', function (req, res) {

    //recive param photo in base64.
    const obj = {
        photo: req.body.photo
    }

    //calling method API AWS to recoknition face.
    facialAWS.search_face(obj, function (data) {

        if (data.found) {
            res.send(data);
        } else {
            res.send(data);
        }

    });

});

/* Method - Index new face of user by photo.
   Recive - Photo in format base 64,
            Id_user is a external id of your control aplication.
   Return - Return result of index.
*/
router.post('/indexNewFace', function (req, res) {
    //recive params photo in base64 and any string represent id.
    const obj = {
        photo: req.body.image,
        id_user: req.body.studentMatricNo
    }

    //calling method API AWS to index face.
    facialAWS.indexFaces(obj, function (data) {
        if (data.found) {
            Face.create({ faceId: data.resultAWS.FaceId, studentMatricNo: req.body.studentMatricNo}, (err, result) => {
                if (err) return res.status(500).send({ message: "There was a problem indexing face."});

                res.status(200).send(data);
            });
        } else {
            res.send(data);
        }
    });

});

/* Method - Delete face in collection.
   Recive - Face_id unique ID in AWS represent.
   Return - Return result of delete.
*/
router.post('/deleteFace', function (req, res) {

    Face.findOne({studentMatricNo: req.body.studentMatricNo}, (err, result) => {
       //recive param face_id, thats is a unique key of face.
        const obj = {
            face_id: result.faceId
        }

        //calling method API AWS to delete face.    
        facialAWS.deleteFace(obj, function (data) {
            Face.findOneAndDelete({ studentMatricNo: req.body.studentMatricNo }, (err, result) => {
                if (err) return res.status(500).send({ message: "There was a problem deleting face."});

                res.status(200).send(data);
            });
        }); 
    });
});

module.exports = router;
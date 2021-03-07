const AWS = require("aws-sdk");
const multer = require("multer");
const multerS3 = require("multer-s3");

const s3 = new AWS.S3();

AWS.config.update({
    accessKeyId: AWS.config.credentials.accessKeyId,
    secretAccessKey: AWS.config.credentials.secretAccessKey,
    region: "ap-southeast-1",
});

const ImageUpload = multer({
    storage: multerS3({
        s3: s3,
        acl: "public-read",
        bucket: "cz3002",
        metadata: function (req, file, cb) {
            cb(null, { fieldName: "TESTING_METADATA" });
            console.log("test");
        },
        key: function (req, file, cb) {
            cb(null, Date.now().toString());
            console.log("test");
        },
    }),
});

module.exports = ImageUpload;
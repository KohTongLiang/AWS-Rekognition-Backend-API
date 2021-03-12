const config = require('./config');
var AWS = require('aws-sdk');
AWS.config.region = config.region;

var uuid = require('uuid');
var fs = require('fs');
var path = require('path');

var rekognition = new AWS.Rekognition({region: config.region});

//set defaut obj to return results data
var objReturn = {
	found: false,
	resultAWS:''
}

module.exports.search_face = function(obj, callback){
	
	console.log("Find face ...")
	
	rekognition.searchFacesByImage({
	 	"CollectionId": config.collectionName,
	 	"FaceMatchThreshold": 70, //set minumum match in image send
	 	"Image": {
			'Bytes': new Buffer(obj.photo, 'base64')
	 	},
	 	"MaxFaces": 1 // set the number face detect in image send
	}, function(err, data) {
	 	if (err) {
			console.log(err)
			callback(err);
	 	} else { 
             console.log(data);
			if(data.FaceMatches && data.FaceMatches.length > 0 && data.FaceMatches[0].Face)
			{
				console.log(data.FaceMatches[0])
				// callback (data.FaceMatches[0].Face);	
                callback ({ found: true, ExternalImageId: data.FaceMatches[0].Face.ExternalImageId });
			} else {
				// objReturn.found = false
				// callback (objReturn);
                callback ({ found: false });
			}
		}
	});
}

module.exports.indexFaces = function (obj,callback){
	
	console.log("Index new image face ...")
    console.log(config.collectionName);

	rekognition.indexFaces({
		"CollectionId": config.collectionName,
		"DetectionAttributes": [ "ALL" ], // set detect all atributes on image send.
		"ExternalImageId": obj.id_user, 
		"Image": { 
			'Bytes': new Buffer(obj.photo, 'base64')
		}
	}, function(err, data) {
		if (err) {
			console.log(err, err.stack); // an error occurred
			
			objReturn.found = false
			objReturn.resultAWS = err, err.stack
			callback(objReturn)
		} else {
            console.log(data);
			console.log(data.FaceRecords[0].Face); // successful response

			objReturn.found = true
			objReturn.resultAWS = data.FaceRecords[0].Face
			callback(objReturn)
		}
	});

}

module.exports.deleteFace = function (obj,callback){

	console.log("Delete image face ...")
	
	//prepare params to delete face index.
	var params_deletion = { CollectionId: config.collectionName, FaceIds: [obj.face_id] };

	rekognition.deleteFaces(params_deletion, function(err, data) {
		if (err) callback(err, err.stack);  // an error occurred
		else     callback(true,data);      // successful response
	});
}

module.exports.updateFace = (obj, callback) => {

	console.log("Updating image face ...");

	var params_deletion = { CollectionId: config.collectionName, FaceIds: [obj.face_id] };

	rekognition.deleteFaces(params_deletion, function(err, data) {
		if (err) {
			callback(err, err.stack);  // an error occurred
		} else {
			// add in new face
			rekognition.indexFaces({
				"CollectionId": config.collectionName,
				"DetectionAttributes": [ "ALL" ], // set detect all atributes on image send.
				"ExternalImageId": obj.id_user, 
				"Image": { 
					'Bytes': new Buffer(obj.photo, 'base64')
				}
			}, function(err, data) {
				if (err) {
					console.log(err, err.stack); // an error occurred
					
					objReturn.found = false
					objReturn.resultAWS = err, err.stack
					callback(objReturn)
				} else {
					console.log(data);
					console.log(data.FaceRecords[0].Face); // successful response
		
					objReturn.found = true
					objReturn.resultAWS = data.FaceRecords[0].Face
					callback(objReturn)
				}
			});
		}
	});

}

module.exports.getFaces = (faceId, callback) => {

	console.log("Getting image faces...");

	const params_list = { CollectionId: config.collectionName, FaceIds: faceId };
	rekognition.listFaces(params_list, (err, data) => {
		if (err) callback(err, err.stack);

		callback(data);
	});
}
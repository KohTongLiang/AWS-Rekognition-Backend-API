
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

enum DialogAction {CANCEL, CONFIRM}

Future<DialogAction> showDeleteAlertDialog(BuildContext context, String itemType) =>showSimpleAlertDialog(context,  'Confirm delete?', 'This will permanently delete the $itemType involved!');

Future<DialogAction> showSimpleAlertDialog(BuildContext context, String title, String message) async {
  return showDialog<DialogAction>(
    context: context,
    barrierDismissible: false, // user must tap button for close dialog!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey),),
            onPressed: () {
              Navigator.of(context).pop(DialogAction.CANCEL);
            },
          ),
          FlatButton(
            child: const Text('ACCEPT'),
            onPressed: () {
              Navigator.of(context).pop(DialogAction.CONFIRM);
            },
          )
        ],
      );
    },
  );
}

ProgressDialog showProgressDialog(BuildContext context, String message ){
  ProgressDialog pr = new ProgressDialog(context, isDismissible: false);
  pr.style(
      message: message,
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      progressWidget: CircularProgressIndicator(),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progress: 0.0,
      maxProgress: 100.0,
      progressTextStyle: TextStyle(color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
  );
  return pr;
}


//dynamic showFaceDetection(BuildContext context, FaceInfo faceInfo){
//  return showDialog(
//    context: context,
//    builder: (context)=>FaceDetectDialog(faceInfo: faceInfo,)
//  );
//}


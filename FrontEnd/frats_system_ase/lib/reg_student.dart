import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:frats_system_ase/utils/frats_api.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'sidebar.dart';
import 'utils/validator.dart';
import 'utils/dialog_helper.dart';

final _appFont = const TextStyle(
  fontSize: 24.0,
);

class RegStudentScreen extends StatefulWidget {
  @override
  RegStudentState createState() => RegStudentState();
}

class RegStudentState extends State<RegStudentScreen> {
  final _formKey = GlobalKey<FormState>();

//  String _email;
  String _picPath;

  TextEditingController inputCtrlName = TextEditingController();
  TextEditingController inputCtrlEmail = TextEditingController();
  TextEditingController inputCtrlMatricNo = TextEditingController();

  @override
  void dispose() {
    super.dispose();

    // remove temp photo
    _removeTempPhoto();
    inputCtrlName.dispose();
    inputCtrlEmail.dispose();
    inputCtrlMatricNo.dispose();
  }

  _removeTempPhoto() {
    if (this._picPath != null) {
      File(this._picPath).delete();
      this._picPath = null;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Register New Student",
            style: _appFont,
          ),
          actions: <Widget>[
            /*IconButton(
            icon: Icon(Icons),
            color: Colors.pink,
            onPressed: _pushSaved,
          ),*/
          ],
        ),
        drawer: launchSidebar(context),
        body: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: <Widget>[
                Positioned(
                  child: _addStudentForm(),
                )
              ],
            ),
          ),
        ),
        floatingActionButton: new Builder(builder: (BuildContext context) {
          return FloatingActionButton(
              //onPressed: _incrementCounter,
              tooltip: 'Confirm Add Student',
              child: Icon(Icons.add),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();

                  if (this._picPath == null) {
                    final sbMissingPhoto = SnackBar(
                      content: Text('Student photo is missing'),
                      duration: Duration(seconds: 3),
                    );
                    Scaffold.of(context).showSnackBar(sbMissingPhoto);
                    return;
                  }

                  _doAddStudent(context);
                }
              });
        }) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  _doAddStudent(BuildContext context) {
    // collect data

    String name = inputCtrlName.text;
    String email = inputCtrlEmail.text;
    String matricNo = inputCtrlMatricNo.text;
    List<int> imgBytes = File(this._picPath).readAsBytesSync();
    String imgBase64 = base64Encode(imgBytes);

    // show loading dialog
    ProgressDialog pr = showProgressDialog(context, "Adding student...");

    // call api
    AWSFEUtil.registerStudent(matricNo, name, email, imgBase64)
        .then((final response) {
      // cancel loading dialog

      // clean input

        _clearInput();
        _removeTempPhoto();


    });
  }

  _clearInput() {
    inputCtrlName.text = "";
    inputCtrlEmail.text = "";
    inputCtrlMatricNo.text = "";
  }

  Widget _addStudentForm() {
    return Form(
      key: _formKey,
      child: Column(children: <Widget>[
        _studentNameTextField(),
        _studentEmailTextField(),
        _studentMatricTextField(),
        _newStudentPhoto(),
      ]),
    );
  }

  Widget _studentNameTextField() {
    return new Padding(
        padding:
            EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
        child: TextFormField(
            controller: inputCtrlName,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  inputCtrlName.clear();
                },
              ),

              filled: true,
              focusColor: Colors.grey,
              border: UnderlineInputBorder(
                  borderSide: const BorderSide(
                color: Colors.purple,
                width: 5.0,
              )),
              focusedBorder: UnderlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.purple,
                  width: 5.0,
                ),
              ),
              //icon: Icon(Icons.person),
              //contentPadding: const EdgeInsets.all(15.0),
              hintText: 'Student Name',
              labelText: 'Student Name*',
            ),
            //Validator receives text user has entered.
            //validator: validateEmpty,
            validator: Validator.validateStudentName,
            keyboardType: TextInputType.text,
            onSaved: (String val) {}));
  }

  Widget _studentEmailTextField() {
    return new Padding(
        padding:
            EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
        child: TextFormField(
            controller: inputCtrlEmail,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  //set controller clear
                  inputCtrlEmail.clear();
                },
              ),
              filled: true,
              focusColor: Colors.grey,
              border: UnderlineInputBorder(
                  borderSide: const BorderSide(
                color: Colors.purple,
                width: 5.0,
              )),
              focusedBorder: UnderlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.purple,
                  width: 5.0,
                ),
              ),
              //icon: Icon(Icons.person),
              //contentPadding: const EdgeInsets.all(15.0),
              hintText: 'e.g. ATAN0112@e.ntu.edu.sg',
              labelText: 'Institutional E-mail*',
            ),
            //Validator receives text user has entered.
            validator: Validator.validateEmail,
            keyboardType: TextInputType.text,
            onSaved: (String val) {}));
  }

  Widget _studentMatricTextField() {
    return new Padding(
        padding:
            EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
        child: TextFormField(
            controller: inputCtrlMatricNo,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  //set controller clear
                  inputCtrlMatricNo.clear();
                },
              ),
              filled: true,
              focusColor: Colors.grey,
              border: UnderlineInputBorder(
                  borderSide: const BorderSide(
                color: Colors.purple,
                width: 5.0,
              )),
              focusedBorder: UnderlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.purple,
                  width: 5.0,
                ),
              ),
              //icon: Icon(Icons.person),
              //contentPadding: const EdgeInsets.all(15.0),
              hintText: 'e.g. U1820300T',
              labelText: 'Matriculation Number*',
            ),
            //Validator receives text user has entered.
            //validator: validateEmpty,
            validator: Validator.validateMatricNo,
            keyboardType: TextInputType.text,
            onSaved: (String val) {}));
  }

  Widget _newStudentPhoto() {
    return new Container(
      alignment: Alignment(-1, -1),
      padding: EdgeInsets.only(top: 15.0, bottom: 30.0, left: 30),
      child: Column(
        children: <Widget>[
          Text(
            "Take Photo",
            textAlign: TextAlign.left,
            style: const TextStyle(
                fontSize: 16,
                color: Colors.purple,
                fontWeight: FontWeight.bold),
          ),
          DottedBorder(
            borderType: BorderType.RRect,
            strokeWidth: 3,
            color: Colors.purple,
            dashPattern: [6, 6],
            //padding: EdgeInsets.all(0),
            child: FlatButton(
              color: Colors.white,
              onPressed: () {
                _takePhoto(context);
              },
              child: _picPath == null
                  ? Icon(
                      Icons.add_a_photo,
                      size: 80.0,
                    )
                  : Image.file(
                      File(_picPath),
                      width: 100,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Text createText(String val) {
    return Text(
      val,
      textAlign: TextAlign.left,
      style: TextStyle(
        color: Colors.purple,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  _takePhoto(BuildContext context) async {
    dynamic result = await Navigator.of(context).pushNamed("/take_photo");
    try {
      if (result != null) {
        _removeTempPhoto();
        setState(() {
          // update path to display photo
          this._picPath = result as String;
        });
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frats_system_ase/classes/course.dart';
import 'package:frats_system_ase/utils/frats_api.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'sidebar.dart';
import 'utils/validator.dart';
import 'utils/dialog_helper.dart';

final _appFont = const TextStyle(
  fontSize: 24.0,
);

class AddCourseScreen extends StatefulWidget {
  @override
  AddCourseState createState() => AddCourseState();
}

class AddCourseState extends State<AddCourseScreen> {
  TextEditingController courseCodeCtrl = TextEditingController();
  TextEditingController courseNameCtrl = TextEditingController();
  TextEditingController acadYearCtrl = TextEditingController();
  Course course;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    courseNameCtrl.dispose();
    courseCodeCtrl.dispose();
    acadYearCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add New Course",
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
                child: regStudentWidget(),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: new Builder(builder: (BuildContext context) {
        return FloatingActionButton(
            //onPressed: _incrementCounter,
            tooltip: 'Confirm Add Course',
            child: Icon(Icons.add),
            onPressed: () {
              _doAddCourse(context);
            });
      }), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  _doAddCourse(BuildContext context){
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      course = new Course();
      course.courseCode = courseCodeCtrl.text;
      course.courseName = courseNameCtrl.text;
      course.acadYear = acadYearCtrl.text;

      ProgressDialog pr = showProgressDialog(context, "please wait");
      pr.show();
      AWSFEUtil.addCourse(course).then((response) {
        pr.dismiss();
        if (response.found) {
          courseNameCtrl.clear();
          courseCodeCtrl.clear();
          acadYearCtrl.clear();
        }
        final snackBar = SnackBar(
          content: Text(response.result),
        );
        Scaffold.of(context).hideCurrentSnackBar();
        Scaffold.of(context).showSnackBar(snackBar);
      });
    }
  }

  Widget regStudentWidget() {
    return Form(
      key: _formKey,
      child: Column(children: <Widget>[
        _courseCodeTextField(),
        _courseNameTextField(),
        _acadYearTextField(),
      ]),
    );
  }

  Widget _courseCodeTextField() {
    return new Padding(
        padding:
            EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
        child: TextFormField(
            controller: courseCodeCtrl,
            validator: Validator.validateCourseCode,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  //set controller clear
                  courseCodeCtrl.clear();
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
              hintText: 'e.g. CZ3002, CE2007, CX3004',
              labelText: 'Course Code*',
            ),
            initialValue: null,
            //Validator receives text user has entered.
            //validator: validateEmpty,
            keyboardType: TextInputType.text,
            onSaved: (String val) {})
    );
  }

  Widget _courseNameTextField() {
    return new Padding(
        padding:
            EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
        child: TextFormField(
            controller: courseNameCtrl,
            validator: Validator.validateCourseName,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  //set controller clear
                  courseNameCtrl.clear();
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
              hintText: 'e.g. Advanced Software Engineering, Microprocessors',
              labelText: 'Course Name*',
            ),
            initialValue: null,
            //Validator receives text user has entered.
            //validator: validateEmpty,
            keyboardType: TextInputType.text,
            onSaved: (String val) {})
    );
  }

  Widget _acadYearTextField() {
    return new Padding(
        padding:
            EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
        child: TextFormField(
            controller: acadYearCtrl,
            validator: Validator.validateAcadYear,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  //set controller clear
                  acadYearCtrl.clear();
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
              hintText: 'e.g. AY1920S2',
              labelText: 'Academic Year and Semester*',
            ),
            initialValue: null,
            //Validator receives text user has entered.
            //validator: validateEmpty,
            keyboardType: TextInputType.text,
            onSaved: (String val) {})
    );
  }
}

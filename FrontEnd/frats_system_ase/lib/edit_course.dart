import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frats_system_ase/classes/course.dart';
import 'package:frats_system_ase/utils/frats_api.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'classes/course.dart';
import 'sidebar.dart';
import 'utils/validator.dart';
import 'utils/dialog_helper.dart';

final _appName = 'Edit Course';
final _appFont = const TextStyle(
  fontSize: 24.0,
);
final _subFont = const TextStyle(
  fontSize: 18.0,
);
Icon _defaultIcon;

class EditCourseScreen extends StatefulWidget {
  @override
  EditCoursePage createState() => EditCoursePage();
}

///Stateful class for main page of the application.
class EditCoursePage extends State<EditCourseScreen> {
  final GlobalKey<ScaffoldState> _courseListScaffold = GlobalKey<ScaffoldState>();
  bool loading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _courseListScaffold,
      appBar: AppBar(
        title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _appName,
                style: _appFont,
              ),
              Text(
                "Select Course",
                style: _subFont,
              )
            ]),
      ),
      drawer: launchSidebar(context),
      body: SingleChildScrollView(
        //physics: NeverScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              Positioned(
                child: listCourses(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget listCourses() {
    return Scaffold(
        body: FutureBuilder<List<Course>>(
          future: AWSFEUtil.getCourses(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Course> courseList = snapshot.data;
              return _courseListView(courseList);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return Align(
                child: CircularProgressIndicator(),
                alignment: FractionalOffset.center);
          },
        ));
  }

  Widget _courseListView(courseList) {
    return Scrollbar(
        child: ListView.builder(
            itemCount: courseList.length,
            itemBuilder: (context, index) {
              return _courseTile(courseList[index], Icons.face);
            }));
  }

  ListTile _courseTile(Course course, IconData icon) => ListTile(
        title: Text(course.courseName,
            style: TextStyle(
              //fontWeight: FontWeight.w500,
              fontSize: 20,
            )),
        subtitle: Text(course.courseCode),
        leading: Icon(
          icon,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditCourseInfoState(course: course),
            ),
          ).then((value) {
            setState(() {
              final snackBar = SnackBar(
                content: Text('$value'),
              );
              _courseListScaffold.currentState.hideCurrentSnackBar();
              _courseListScaffold.currentState.showSnackBar(snackBar);
            });
          });
        },
      );
}

/// ======================================================================================================================

class EditCourseInfoState extends StatefulWidget {
  final Course course;

  const EditCourseInfoState({Key key, @required this.course}) : super(key: key);

  @override
  EditCourseInfoPage createState() => EditCourseInfoPage();
}

class EditCourseInfoPage extends State<EditCourseInfoState> {
  Course editedCourse;
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController acadYearController = TextEditingController();
  TextEditingController courseCodeController = TextEditingController();

  List<String> optMenu = <String>[
    "Delete",
  ];

  @override
  void dispose() {
    nameController.dispose();
    acadYearController.dispose();
    courseCodeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext build) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Course Details',
          style: _appFont,
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _menuSelected,
            itemBuilder: (BuildContext context) {
              return optMenu.map((String value) {
                return PopupMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: displayCourseInfo(widget.course),
      floatingActionButton: new Builder(builder: (BuildContext context) {
        return FloatingActionButton(
            //onPressed: _incrementCounter,
            tooltip: 'Confirm Edit Student',
            child: Icon(Icons.check),
            onPressed: () {
              // Some code to View the change.
              if (_formKey.currentState.validate()) {
                editedCourse = new Course();
                editedCourse.courseName = nameController.text;
                editedCourse.courseCode = courseCodeController.text;
                editedCourse.acadYear = acadYearController.text;
                ProgressDialog pr =
                    showProgressDialog(context, "Please wait...");
                pr.show();
                AWSFEUtil.editCourse(widget.course, editedCourse).then((value) {
                  pr.hide();
                  print(value);
                  Navigator.pop(context, value.result);
                });
              }
            });
      }),
    );
  }

  _menuSelected(String menu) {
    if (menu == "Delete") {
      showDeleteAlertDialog(_formKey.currentContext, "course").then((value) {
        if (value == DialogAction.CONFIRM) {
          AWSFEUtil.deleteCourse(widget.course).then((response) {
            Navigator.pop(_formKey.currentContext, response.result);
          });
        }
      });
    }
  }

  Widget displayCourseInfo(Course course) {
    nameController = TextEditingController(text: course.courseName);
    courseCodeController = TextEditingController(text: course.courseCode);
    acadYearController = TextEditingController(text: course.acadYear);
    return Form(
      key: _formKey,
      child: Column(children: <Widget>[
        _courseCodeTextFormField(),
        _courseNameTextField(),
        _acadYearTextFormField(),
      ]),
    );
  }

  Widget _courseNameTextField() {
    return new Padding(
        padding:
            EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
        child: TextFormField(
          controller: nameController,
          validator: Validator.validateCourseName,
          decoration: const InputDecoration(
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
            hintText: 'Course Name',
            labelText: 'Course Name*',
          ),
          keyboardType: TextInputType.text,
        ));
  }

  Widget _acadYearTextFormField() {
    return new Padding(
        padding:
            EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
        child: TextFormField(
          controller: acadYearController,
          validator: Validator.validateAcadYear,
          decoration: const InputDecoration(
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
            hintText: 'e.g. AY1920S1, AY1819S2',
            labelText: 'Academic Year*',
          ),
          keyboardType: TextInputType.text,
        ));
  }

  Widget _courseCodeTextFormField() {
    return new Padding(
        padding:
            EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
        child: TextFormField(
          controller: courseCodeController,
          validator: Validator.validateCourseCode,
          enabled: false,
          decoration: const InputDecoration(
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
            hintText: 'e.g. CZ1007, CE2004',
            labelText: 'Course Code*',
          ),
          keyboardType: TextInputType.text,
        ));
  }
}

ProgressDialog showProgressDialog(BuildContext context, String message) {
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
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
  return pr;
}

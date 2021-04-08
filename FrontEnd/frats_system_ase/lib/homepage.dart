import 'dart:ui';

import 'package:flutter/material.dart';

import 'sidebar.dart';
import 'utils/flutter_custom_icons.dart';

final _regStudentRoute = '/reg_student';
final _editStudentRoute = '/edit_student';
final _addClassRoute = '/add_class';
final _addCourseRoute = '/add_course';
final _editCourseRoute = '/edit_course';
final _manageClassRoute = '/manage_class';
final _startEndClassRoute = '/start_end_class';
final _reportMgmtRoute = '/report_mgmt';
final _takeAttendanceRoute = '/take_attendance';
final _logoutRoute = '/logout';

Text _appName() {
  return Text('Face Recognition\nAttendance Taking System (FRATS)',
      style: TextStyle(fontSize: 20.0));
}

Text _appSub() {
  return Text('',
      style: TextStyle(fontSize: 12.0));
}

final _widgetFont = const TextStyle(
  fontSize: 20.0,
  fontWeight: FontWeight.w500,
);

///Function for creating the main page of the MainPage
class FratsAppScreen extends StatefulWidget {
  /* final Admin admin;

  const FratsAppScreen({Key key, @required this.admin})
      : super(key: key);
*/
  @override
  FratsAppState createState() => FratsAppState();
}

///Stateful class for main page of the application.
class FratsAppState extends State<FratsAppScreen> {
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _appName(),
              _appSub(),
            ]),
      ),
      drawer: launchSidebar(context),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              Positioned(
                child: mainpageWidgets(context),
              )
            ],
          ),
        ),
      ),
    );
  }

  ListView mainpageWidgets(BuildContext context) {
    return ListView(
      children: <Widget>[
       // _regStudentTile(context),
       // Divider(),
        _editStudentTile(context),
        Divider(),
       // _addCourseTile(context),
       // Divider(),
       // _editCourseTile(context),
       // Divider(),
       // _addClassTile(context),
       // Divider(),
        _manageClassTile(context),
        Divider(),
        _takeAttendance(context),
        Divider(),
       // _startEndClassTile(context),
       // Divider(),
       // _reportMgmtTile(context),
       // Divider(),
        _logoutTile(context),
      ],
    );
  }

  ListTile _regStudentTile(BuildContext context) {
    return ListTile(
      leading: Icon(FlutterCustom.student_plus),
      title: Text('Register New Student', style: _widgetFont),
      onTap: () {
        navigateToPage(context, _regStudentRoute);
      },
    );
  }

  ListTile _editStudentTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.face),
      title: Text('Manage Student Records', style: _widgetFont),
      onTap: () {
        navigateToPage(context, _editStudentRoute);
      },
    );
  }

  ListTile _addCourseTile(BuildContext context) {
    return ListTile(
      leading: Icon(FlutterCustom.school_plus),
      title: Text('Add Course', style: _widgetFont),
      onTap: () {
        navigateToPage(context, _addCourseRoute);
      },
    );
  }

  ListTile _editCourseTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.school),
      title: Text('Edit Course', style: _widgetFont),
      onTap: () {
        navigateToPage(context, _editCourseRoute);
      },
    );
  }

  ListTile _addClassTile(BuildContext context) {
    return ListTile(
      leading: Icon(FlutterCustom.class_plus),
      title: Text('Add Class', style: _widgetFont),
      onTap: () {
        navigateToPage(context, _addClassRoute);
      },
    );
  }

  ListTile _manageClassTile(BuildContext context) {
    return ListTile(
      leading: Icon(FlutterCustom.class_manage),
      title: Text('Manage Courses, Classes and Sessions', style: _widgetFont),
      onTap: () {
        navigateToPage(context, _manageClassRoute);
      },
    );
  }

  ListTile _startEndClassTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.alarm),
      title: Text('Start/End Class Sessions\n& Take Attendance',
          style: _widgetFont),
      onTap: () {
        navigateToPage(context, _startEndClassRoute);
      },
    );
  }

  ListTile _reportMgmtTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.assessment),
      title: Text('Report Management', style: _widgetFont),
      onTap: () {
        navigateToPage(context, _reportMgmtRoute);
      },
    );
  }

  ListTile _takeAttendance(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.assessment),
      title: Text('Take Attendance', style:_widgetFont),
      onTap: () {
        // TODO: Update state of the app, transition, etc.
        navigateToPage(context, _takeAttendanceRoute);
      },
    );
  }

  ListTile _logoutTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.exit_to_app),
      title: Text('Log Out', style: _widgetFont),
      onTap: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).pushNamed(_logoutRoute);
        //Navigator.of(context).popUntil((route) => route.isFirst);
        //Scaffold.of(context).showSnackBar(SnackBar(content: Text('Successfully logged out.')));
      },
    );
  }

  void navigateToPage(BuildContext context, String route) {
    ModalRoute.of(context).settings.name == route
        ? {}
        : Navigator.of(context).pushNamed(route);
  }
}

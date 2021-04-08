import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frats_system_ase/utils/globals.dart' as globals;

import 'utils/flutter_custom_icons.dart';

final _appName = 'Welcome,\n';
final _appFont = const TextStyle(
  color: Colors.white,
  fontSize: 24.0,
);

final _homepageRoute = '/homepage';
final _regStudentRoute = '/reg_student';
final _editStudentRoute = '/edit_student';
final _addClassRoute = '/add_class';
final _addCourseRoute = '/add_course';
final _editCourseRoute = '/edit_course';
final _manageClassRoute = '/manage_class';
final _startEndClassRoute = '/start_end_class';
final _reportMgmtRoute = '/report_mgmt';
final _takeAttendanceRoute = '/take_attendance';
//final _exitCamViewRoute = '/camera_view';
final _logoutRoute = '/logout';

Drawer launchSidebar(BuildContext context) {
  return Drawer(
      child: ListView(
        // Remove padding from listview
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              child: Stack(children: <Widget>[
                Positioned(
                  top: 2,
                  left: 16,
                  child: Container(
                    width: 90.0,
                    height: 90.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/images/empty_dp.png'),
                      ),
                      color: Colors.pinkAccent,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8.0,
                  left: 16.0,
                  child: Text(
                    _appName + globals.adminName,
                    style: _appFont,
                  ),
                )
              ]),
              decoration: BoxDecoration(
                color: Colors.pink,
              ),
            ),
            _homepageTile(context),
            _editStudentTile(context),
            _manageClassTile(context),
//            _regStudentTile(context),
//            _addCourseTile(context),
//            _editCourseTile(context),
//            _addClassTile(context),
//            _startEndClassTile(context),
//            _reportMgmtTile(context),
            _takeAttendance(context),
            _logoutTile(context),
            // TODO: Add more ListTiles on this line if needed
          ]));
}

ListTile _homepageTile(BuildContext context) {
  return ListTile(
    leading: Icon(Icons.home),
    title: Text('Back to Home'),
    onTap: () {
      // TODO: Update state of the app, transition, etc.
      // Navigator.popUntil(context, ModalRoute.withName('/homepage'));
      // Navigator.of(context).popUntil(ModalRoute.withName('/homepage'));
      navigateToPage(context, _homepageRoute);
    },
  );
}

ListTile _regStudentTile(BuildContext context) {
  return ListTile(
    leading: Icon(FlutterCustom.student_plus),
    title: Text('Register New Student'),
    onTap: () {
      // TODO: Update state of the app, transition, etc.
      navigateToPage(context, _regStudentRoute);
    },
  );
}

ListTile _editStudentTile(BuildContext context) {
  return ListTile(
    leading: Icon(Icons.face),
    title: Text('Manage Student Records'),
    onTap: () {
      // TODO: Update state of the app, transition, etc.
      navigateToPage(context, _editStudentRoute);
    },
  );
}

ListTile _addCourseTile(BuildContext context) {
  return ListTile(
    leading: Icon(FlutterCustom.school_plus),
    title: Text('Add Course'),
    onTap: () {
      // TODO: Update state of the app, transition, etc.
      navigateToPage(context, _addCourseRoute);
    },
  );
}

ListTile _editCourseTile(BuildContext context) {
  return ListTile(
    leading: Icon(Icons.school),
    title: Text('Edit Course'),
    onTap: () {
      // TODO: Update state of the app, transition, etc.
      navigateToPage(context, _editCourseRoute);
    },
  );
}

ListTile _addClassTile(BuildContext context) {
  return ListTile(
    leading: Icon(FlutterCustom.class_plus),
    title: Text('Add Class'),
    onTap: () {
      // TODO: Update state of the app, transition, etc.
      navigateToPage(context, _addClassRoute);
    },
  );
}

ListTile _manageClassTile(BuildContext context) {
  return ListTile(
    leading: Icon(FlutterCustom.class_manage),
    title: Text('Manage Courses, Classes and Sessions'),
    onTap: () {
      // TODO: Update state of the app, transition, etc.
      navigateToPage(context, _manageClassRoute);
    },
  );
}

ListTile _startEndClassTile(BuildContext context) {
  return ListTile(
    leading: Icon(Icons.alarm),
    title: Text('Start/End Class Sessions & Take Attendance'),
    onTap: () {
      // TODO: Update state of the app, transition, etc.
      navigateToPage(context, _startEndClassRoute);
    },
  );
}

ListTile _reportMgmtTile(BuildContext context) {
  return ListTile(
    leading: Icon(Icons.assessment),
    title: Text('Report Management'),
    onTap: () {
      // TODO: Update state of the app, transition, etc.
      navigateToPage(context, _reportMgmtRoute);
    },
  );
}

ListTile _takeAttendance(BuildContext context) {
  return ListTile(
    leading: Icon(Icons.assessment),
    title: Text('Take Attendance'),
    onTap: () {
      // TODO: Update state of the app, transition, etc.
      navigateToPage(context, _takeAttendanceRoute);
    },
  );
}

ListTile _logoutTile(BuildContext context) {
  return ListTile(
    leading: Icon(Icons.exit_to_app),
    title: Text('Log Out'),
    onTap: () {
      // TODO: Update state of the app, transition, etc.
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).pushNamed(_logoutRoute);
    },
  );
}

void navigateToPage(BuildContext context, String route) {
  Navigator.pop(context);
  print(ModalRoute.of(context).settings.name);
  ModalRoute.of(context).settings.name == route
      ? {}
      : route == _homepageRoute
      ? Navigator.popUntil(context, ModalRoute.withName(route))
      : Navigator.of(context).pushNamed(
      route); //If navigating to other page, push page onto stack.
}

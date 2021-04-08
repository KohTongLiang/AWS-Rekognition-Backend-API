import 'package:flutter/material.dart';
import 'package:frats_system_ase/add_class.dart';
import 'package:frats_system_ase/add_course.dart';
import 'package:frats_system_ase/add_session.dart';
import 'package:frats_system_ase/edit_course.dart';
import 'package:frats_system_ase/logout.dart';
import 'package:frats_system_ase/reg_student.dart';
import 'package:frats_system_ase/edit_student.dart';
import 'package:frats_system_ase/manage_class.dart';
import 'package:frats_system_ase/take_photo.dart';
import 'package:frats_system_ase/start_end_class.dart';
import 'package:frats_system_ase/take_attendance.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'homepage.dart';
import 'login.dart';

void main() {
  //Crashlytics.instance.enableInDevMode = true; // Uncomment to crash in debug mode
  Crashlytics.instance.log("Setting up Crashlytics. DEBUG MODE: ${Crashlytics.instance.enableInDevMode}");
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runApp(MyApp());
}

/**
 * Function for running the main app. Not to be touched.
 */
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FRATS Application',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.pink,
      ),
      home: Scaffold(
        /*appBar: AppBar(
          title: Text("FRATS Application"),
        ),*/
        body: LoginScreen(),
      ),
      routes: <String, WidgetBuilder>{
        '/login': (_) => new LoginScreen(), // Login Page
        '/homepage': (_) => new FratsAppScreen(), // Home Page
        //'/homepage': (_) => new ManageClassScreen(),
        '/reg_student': (_) => new RegStudentScreen(),
        '/edit_student': (_) => new EditStudentScreen(),
        '/add_course': (_) => new AddCourseScreen(),
        '/edit_course': (_) => new EditCourseScreen(),
        '/add_class': (_) => new AddClassScreen(),
        '/manage_class': (_) => new ManageClassScreen(),
        '/start_end_class': (_) => new StartEndClassScreen(),
        '/logout': (_) => new LogoutScreen(),
        '/take_photo':(_)=>new TakePhotoScreen(),
        '/take_attendance': (_)=>new TakeAttendanceScreen(),
        '/add_session': (_) => new AddSessionScreen(),
      },
    );
  }
}
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frats_system_ase/add_session.dart';
import 'package:frats_system_ase/classes/course_class.dart';
import 'package:frats_system_ase/classes/session.dart';
import 'package:frats_system_ase/session_page.dart';
import 'package:frats_system_ase/utils/flutter_custom_icons.dart';
import 'package:intl/intl.dart';
import 'package:frats_system_ase/classes/course.dart';
import 'package:frats_system_ase/utils/frats_api.dart';

import 'classes/course.dart';
import 'sidebar.dart';
import 'utils/flutter_custom_icons.dart';

final _appName = 'Start/End Classes';
final _appFont = const TextStyle(
  fontSize: 24.0,
);
final _subFont = const TextStyle(
  fontSize: 18.0,
);
Icon _defaultIcon;
DateFormat sgDateFormat = DateFormat("dd MMM yyyy");
DateFormat dateTimeFormat = DateFormat("E dd MMM yyyy',' HHmm'hrs'");

class StartEndClassScreen extends StatefulWidget {
  @override
  StartEndClassState createState() => StartEndClassState();
}

///Stateful class for main page of the application.
class StartEndClassState extends State<StartEndClassScreen> {
  bool loading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              return _courseTile(courseList[index], Icons.school);
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
              builder: (context) => SelectCourseClassState(course: course),
            ),
          );
        },
      );
}

/// ======================================================================================================================

class SelectCourseClassState extends StatefulWidget {
  final Course course;

  const SelectCourseClassState({Key key, @required this.course})
      : super(key: key);

  @override
  SelectCourseClassPage createState() => SelectCourseClassPage();
}

class SelectCourseClassPage extends State<SelectCourseClassState> {
  @override
  Widget build(BuildContext build) {
    return Scaffold(
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
                "Select Class for ${widget.course.courseCode}",
                style: _subFont,
              )
            ]),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              Positioned(
                child: listCourseClasses(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget listCourseClasses() {
    return Scaffold(
        body: FutureBuilder<List<CourseClass>>(
      future: AWSFEUtil.getClasses(widget.course),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<CourseClass> classList = snapshot.data;
          return _classesListView(classList);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Align(
            child: CircularProgressIndicator(),
            alignment: FractionalOffset.center);
      },
    ));
  }

  Widget _classesListView(classList) {
    return Scrollbar(
        child: ListView.builder(
            itemCount: classList.length,
            itemBuilder: (context, index) {
              return _classTile(classList[index], FlutterCustom.class_manage);
            }));
  }

  ListTile _classTile(CourseClass cc, IconData icon) => ListTile(
        title: Text("${cc.name}-${cc.type}",
            style: TextStyle(
              //fontWeight: FontWeight.w500,
              fontSize: 20,
            )),
        subtitle: Text("${cc.location}, ${cc.startTime} - ${cc.endTime}"),
        leading: Icon(
          icon,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SelectClassSessionState(c: widget.course, cc: cc),
            ),
          );
        },
      );
}

/// ======================================================================================================================

class SelectClassSessionState extends StatefulWidget {
  final CourseClass cc;
  final Course c;

  const SelectClassSessionState({Key key, @required this.c, @required this.cc})
      : super(key: key);

  @override
  SelectClassSessionPage createState() => SelectClassSessionPage();
}

class SelectClassSessionPage extends State<SelectClassSessionState> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext build) {
    return Scaffold(
      key: _scaffoldKey,
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
                "Select Session for ${widget.c.courseCode} ${widget.cc.name}-${widget.cc.type}",
                style: _subFont,
              )
            ]),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              Positioned(
                child: listClassSessions(),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: new Builder(builder: (BuildContext context) {
        return FloatingActionButton(
          tooltip: "add new session",
          child: Icon(Icons.add),
          onPressed: () {
            _toAddSessionPage(context);
          },
        );
      }),
    );
  }

  _toAddSessionPage(BuildContext context) async {
    dynamic result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AddSessionScreen(course: widget.c, courseClass: widget.cc),
        ));
    if (result != null) {
      // reload page
      print("reload page");
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  SelectClassSessionState(c: widget.c, cc: widget.cc)));
    }
  }

  Widget listClassSessions() {
    return Scaffold(
        body: FutureBuilder<List<Session>>(
      future: AWSFEUtil.getSessions(widget.c, widget.cc),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Session> sessionList = snapshot.data;
          return _sessionsListView(sessionList);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Align(
            child: CircularProgressIndicator(),
            alignment: FractionalOffset.center);
      },
    ));
  }

  Widget _sessionsListView(sessionList) {
    return Scrollbar(
        child: ListView.builder(
            itemCount: sessionList.length,
            itemBuilder: (context, index) {
              return _sessionTile(
                  sessionList[index], FlutterCustom.class_manage);
            }));
  }

  ListTile _sessionTile(Session s, IconData icon) => ListTile(
        title: Text(
            "Week ${s.weekNum} - ${dateTimeFormat.format(s.date).toString()}",
            style: TextStyle(
              //fontWeight: FontWeight.w500,
              fontSize: 20,
            )),
        subtitle: Text(s.isActive ? "ACTIVE" : "INACTIVE"),
        trailing: Icon(s.isActive ? Icons.alarm : null),
        leading: Icon(
          icon,
        ),
        onTap: () {
          _toSessionTakeAttendance(s);
        }
  );


  _toSessionTakeAttendance(Session session){
    _scaffoldKey.currentState.hideCurrentSnackBar();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
              SessionTabPage(c: widget.c, cc: widget.cc, s: session),

      ),
    ).then((value) {
      setState(() {
        print("popToShowSessions: $value");
        if (value != null) {
          _scaffoldKey.currentState.hideCurrentSnackBar();
          final snackBar = SnackBar(
            content: Text(value.result),
            action: SnackBarAction(
              label: 'Session ${widget.cc.name} ended.',
              onPressed: () {},
            ),
          );
          _scaffoldKey.currentState.showSnackBar(snackBar);
        }
      });
    });
  }
}

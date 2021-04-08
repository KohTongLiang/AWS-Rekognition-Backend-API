import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frats_system_ase/add_class.dart';
import 'package:frats_system_ase/add_session.dart';
import 'package:frats_system_ase/classes/course_class.dart';
import 'package:frats_system_ase/classes/session.dart';
import 'package:frats_system_ase/session_page.dart';
import 'package:frats_system_ase/utils/flutter_custom_icons.dart';
import 'package:intl/intl.dart';
import 'package:frats_system_ase/classes/course.dart';
import 'package:frats_system_ase/utils/frats_api.dart';
import 'package:frats_system_ase/edit_course.dart';

import 'classes/course.dart';
import 'edit_class.dart';
import 'sidebar.dart';
import 'utils/flutter_custom_icons.dart';
import 'utils/dialog_helper.dart';

final _appName = 'Manage Classes and Sessions';
final _appFont = const TextStyle(
  fontSize: 24.0,
);
final _subFont = const TextStyle(
  fontSize: 15.0,
);
Icon _defaultIcon;
DateFormat dateTimeFormat = DateFormat("E dd MMM yyyy',' HHmm'hrs'");

class ManageClassScreen extends StatefulWidget {
  @override
  ManageClassSelectCourseState createState() => ManageClassSelectCourseState();
}

///Stateful class for main page of the application.
class ManageClassSelectCourseState extends State<ManageClassScreen> {
  bool loading = false;
  List<Course> courseList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Manage Course",
                style: _appFont,
              ),
              Text(
                "> Select/Add Course",
                style: _subFont,
              )
            ]),
      ),
      drawer: launchSidebar(context),
      body: listCourses(),
      floatingActionButton: new Builder(builder: (context) {
        return FloatingActionButton(
          tooltip: "Add Course",
          child: Icon(Icons.add),
          onPressed: () {
            _toAddCoursePage(context);
          },
        );
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCourseData();
  }

  _toAddCoursePage(BuildContext context) async {
    var result = await Navigator.of(context).pushNamed("/add_course");
    if (result != null){
      final sbResult = SnackBar (
        content: Text(result),
        duration: Duration(seconds: 3),
      );
      Scaffold.of(context).hideCurrentSnackBar();
      Scaffold.of(context).showSnackBar(sbResult);
    }
    _loadCourseData();
  }

  _editCourseInfo(BuildContext context, Course course) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCourseInfoState(course: course),
      ),
    );
    if (result != null){
      final sbResult = SnackBar (
        content: Text(result),
        duration: Duration(seconds: 3),
      );
      Scaffold.of(context).hideCurrentSnackBar();
      Scaffold.of(context).showSnackBar(sbResult);
    }
    _loadCourseData();
  }

  _loadCourseData() async {
    try {
      setState(() {
        loading = true;
      });

      AWSFEUtil.getCourses().then((value) {
        setState(() {
          loading = false;
          courseList = value;
        });
      });
    } catch (error) {
      print(error.toString());
      setState(() {
        loading = false;
      });
    }
  }

  Widget listCourses() {
    if (loading) {
      return Align(
          child: CircularProgressIndicator(),
          alignment: FractionalOffset.center);
    }
    if (courseList == null) {
      return Center(
        child: Text("Something wrong."),
      );
    }
    if (courseList.length == 0) {
      return Center(
        child: Text(
          "No course found, \nplease add with + button below",
          textAlign: TextAlign.center,
        ),
      );
    }
    return _courseListView(courseList);
  }

  Widget _courseListView(courseList) {
    return ListView.builder(
        itemCount: courseList.length,
        itemBuilder: (context, index) {
          return _courseTile(courseList[index], Icons.school);
        });
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
        trailing: IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            _editCourseInfo(context, course);
          },
        ),
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  List<CourseClass> classList;

  @override
  void initState() {
    super.initState();
    _loadClassData();
  }

  _loadClassData() async {
    try {
      print("before load classes");
      setState(() {
        loading = true;
      });

      AWSFEUtil.getClasses(widget.course).then((value) {
        print("updaet classes");
        setState(() {
          loading = false;
          classList = value;
        });
      });
    } catch (error) {
      print(error.toString());
      setState(() {
        loading = false;
      });
    }
  }

  Widget build(BuildContext build) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Manage Class",
                style: _appFont,
              ),
              Text(
                "> ${widget.course.courseCode} > Select/Add Class ",
                style: _subFont,
              )
            ]),
      ),
      body: listCourseClasses(),
      floatingActionButton: new Builder(builder: (context) {
        return FloatingActionButton(
          tooltip: "Add Course",
          child: Icon(Icons.add),
          onPressed: () async {
            var result = await _toAddCourseClassPage(context);
            if (result != null){
              final sbResult = SnackBar (
                content: Text(result),
                duration: Duration(seconds: 3),
              );
              _scaffoldKey.currentState.hideCurrentSnackBar();
              _scaffoldKey.currentState.showSnackBar(sbResult);
            }
            _loadClassData();
          },
        );
      }),
    );
  }

  _toAddCourseClassPage(BuildContext context) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddClassScreen(
            course: widget.course,
          ),
        )).then((value) {
      setState(() {
        final snackbar = SnackBar(
          content: Text(value),
          duration: Duration(seconds: 3),
        );
        _scaffoldKey.currentState.showSnackBar(snackbar);
      });
    });
    _loadClassData();
  }

  Widget listCourseClasses() {
    if (loading) {
      return Align(
          child: CircularProgressIndicator(),
          alignment: FractionalOffset.center);
    }
    if (classList == null) {
      return Center(
        child: Text("Something wrong."),
      );
    }
    if (classList.length == 0) {
      return Center(
        child: Text(
          "No class found, \nplease add with + button below",
          textAlign: TextAlign.center,
        ),
      );
    }
    return _classesListView(classList);
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
        trailing: IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    EditClassInfoState(c: widget.course, cc: cc),
              ),
            ).then((value) {
              _loadClassData();
              setState(() {
                final snackBar = SnackBar(
                  content: Text(value.result),
                  duration: Duration(seconds: 3),
                );
                _scaffoldKey.currentState.hideCurrentSnackBar();
                _scaffoldKey.currentState.showSnackBar(snackBar);
              });
            });
          },
        ),
        onTap: () {
          _toListSessionPage(context, cc);
        },
      );

  _toListSessionPage(BuildContext context, CourseClass cc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectClassSessionState(c: widget.course, cc: cc),
      ),
    ).then((value) {
      setState(() {
        final snackBar = SnackBar(
          content: Text(value.result),
          duration: Duration(seconds: 3),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      });
    });
  }
}

///==================================================================================================
///==================================================================================================
///==================================================================================================
///==================================================================================================
///==================================================================================================
///==================================================================================================
///==================================================================================================
///==================================================================================================

///Manage a session or add a session after tapping into the class
class SelectClassSessionState extends StatefulWidget {
  final CourseClass cc;
  final Course c;

  const SelectClassSessionState({
    Key key,
    @required this.c,
    @required this.cc,
  }) : super(key: key);

  @override
  SelectClassSessionPage createState() => SelectClassSessionPage();
}

class SelectClassSessionPage extends State<SelectClassSessionState> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  List<Session> sessionList;

  @override
  void initState() {
    super.initState();
    _loadSessionData();
  }

  _loadSessionData() {
    try {
      setState(() {
        loading = true;
      });

      AWSFEUtil.getSessions(widget.c, widget.cc).then((value) {
        setState(() {
          loading = false;
          sessionList = value;
        });
      });
    } catch (error) {
      print(error.toString());
      setState(() {
        loading = false;
      });
    }
  }

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
                "Manage Session",
                style: _appFont,
              ),
              Text(
                "> ${widget.c.courseCode} > ${widget.cc.name}-${widget.cc.type} > Select/Add Session",
                style: _subFont,
              )
            ]),
      ),
      body: listClassSessions(),
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
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AddSessionScreen(course: widget.c, courseClass: widget.cc),
        ));
    _loadSessionData();
    if (result != null){
      final sbResult = SnackBar (
        content: Text(result),
        duration: Duration(seconds: 3),
      );
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(sbResult);
    }
  }

  Widget listClassSessions() {
    if (loading) {
      return Align(
          child: CircularProgressIndicator(),
          alignment: FractionalOffset.center);
    }
    if (sessionList == null) {
      return Center(
        child: Text("Something wrong."),
      );
    }
    if (sessionList.length == 0) {
      return Center(
        child: Text(
          "No session found, \nplease add with + button below",
          textAlign: TextAlign.center,
        ),
      );
    }
    return _sessionsListView(sessionList);
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
        //TODO: format date
        title: Text(
            "Week ${s.weekNum} - ${dateTimeFormat.format(s.date).toString()}",
            style: TextStyle(
              //fontWeight: FontWeight.w500,
              fontSize: 20,
            )),
        subtitle: Text(s.isActive ? "ACTIVE" : "INACTIVE"),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            _doDeleteSession(context, s);
          },
        ),
        leading: Icon(
          icon,
        ),
        onTap: () {
          _toSessionTabPage(s);
        },
      );

  _toSessionTabPage(Session session) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SessionTabPage(c: widget.c, cc: widget.cc, s: session),
      ),
    ).then((value) {
      _loadSessionData();
    });
  }

  // TODO: should move to edit session
  _doDeleteSession(BuildContext context, Session session) {
    showDeleteAlertDialog(context, "session").then((value) {
      if (value == DialogAction.CONFIRM) {
        AWSFEUtil.deleteSession(widget.c, widget.cc, session).then((response) {
          _loadSessionData();

          final snackBar = SnackBar(
            content: Text(response.result),
          );
          _scaffoldKey.currentState.hideCurrentSnackBar();
          _scaffoldKey.currentState.showSnackBar(snackBar);
        });
      }
    });
  }
}

import 'package:flutter/material.dart';
import 'package:frats_system_ase/classes/session.dart';
import 'package:frats_system_ase/session_page.dart';
import 'package:frats_system_ase/utils/flutter_custom_icons.dart';
import 'package:frats_system_ase/utils/frats_api.dart';
import 'package:intl/intl.dart';
import 'package:frats_system_ase/sidebar.dart';

final _appName = 'Take Attendance';
final _appFont = const TextStyle(
  fontSize: 24.0,
);
final _subFont = const TextStyle(
  fontSize: 18.0,
);
Icon _defaultIcon;
DateFormat dateTimeFormat = DateFormat("E dd MMM yyyy',' HHmm'hrs'");

class TakeAttendanceScreen extends StatefulWidget {
  TakeAttendancePage createState() => TakeAttendancePage();
}

class TakeAttendancePage extends State<TakeAttendanceScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    AWSFEUtil.listActiveSessions();
  }

  @override
  Widget build(BuildContext context) {
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
                "Select an Active Session",
                style: _subFont,
              )
            ]),
      ),
      drawer: launchSidebar(context),
      body: listActiveSessions(),
      /*floatingActionButton: new Builder(builder: (BuildContext context) {
        return FloatingActionButton(
          tooltip: "add new session",
          child: Icon(Icons.add),
          onPressed: () {
            _toAddSessionPage(context);
          },
        );
      }),*/
    );
  }

  Widget listActiveSessions() {
    return FutureBuilder<List<Session>>(
      future: AWSFEUtil.listActiveSessions(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Session> sessionList = snapshot.data;
          if (sessionList.length > 0) {
            return _sessionsListView(sessionList);
          }
          return Align(
            child: Text("No session found"),
            alignment: Alignment.center,
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Align(
            child: CircularProgressIndicator(),
            alignment: FractionalOffset.center);
      },
    );
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
            "${s.course.courseCode} ${s.courseClass.name}-${s.courseClass.type} @ ${s.courseClass.location}",
            style: TextStyle(
              //fontWeight: FontWeight.w500,
              fontSize: 20,
            )),
        subtitle: Text((s.isActive ? "ACTIVE" : "INACTIVE") + " - Week ${s.weekNum} - ${dateTimeFormat.format(s.date).toString()}"),
        leading: Icon(
          icon,
        ),
        onTap: () {
          _toSessionTabPage(s);
        },
      );

  _toSessionTabPage(Session session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SessionTabPage(c: session.course, cc: session.courseClass, s: session),
      ),
    );
  }
}

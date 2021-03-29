import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frats_system_ase/classes/course_class.dart';

import 'package:frats_system_ase/classes/session.dart';
import 'package:intl/intl.dart';
import 'package:frats_system_ase/classes/course.dart';
import 'package:frats_system_ase/utils/frats_api.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:frats_system_ase/classes/student.dart';

import 'classes/course.dart';
import 'classes/frats_response.dart';
import 'utils/dialog_helper.dart';

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

class SessionTabPage extends StatefulWidget {
  final CourseClass cc;
  final Course c;
  final Session s;

  const SessionTabPage(
      {Key key, @required this.c, @required this.cc, @required this.s})
      : super(key: key);

  @override
  _SessionTabPageState createState() => _SessionTabPageState();
}

class _SessionTabPageState extends State<SessionTabPage>
    with SingleTickerProviderStateMixin {
  final List<Tab> tabOptions = <Tab>[
    Tab(text: 'Info'),
    Tab(text: 'Attendance'),
  ];

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabOptions.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String pageName =
        "${widget.c.courseCode}-${widget.cc.name}-${widget.cc.type} - Week ${widget.s.weekNum}";
    return Scaffold(
        appBar: new AppBar(
          title: Text(pageName),
          bottom: TabBar(
            controller: _tabController,
            tabs: tabOptions,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          // TODO map to specific view
          children: _listTabViewItem(),
        ));
  }

  _listTabViewItem() {
    return <Widget>[
      SessionInfoState(
        c: widget.c,
        cc: widget.cc,
        s: widget.s,
      ),
      SessionAttendanceWidget(
        c: widget.c,
        cc: widget.cc,
        s: widget.s,
      ),
    ];
  }
}

// =====================================================================================================
// =====================================================================================================

class SessionInfoState extends StatefulWidget {
  final CourseClass cc;
  final Course c;
  final Session s;

  const SessionInfoState(
      {Key key, @required this.c, @required this.cc, @required this.s})
      : super(key: key);

  @override
  SessionInfoPage createState() => SessionInfoPage();
}

class SessionInfoPage extends State<SessionInfoState> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext build) {
    return Scaffold(
        key: _scaffoldKey,
//      resizeToAvoidBottomInset: false,
        body: prepareSessionInfoFields()
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  // TODO: change layout here
  Widget prepareSessionInfoFields() {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return Form(
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                    ),
                    child: Column(children: <Widget>[
                      _classNameTextField(),
                      _startTimeTextField(),
                      _endTimeTextField(),
                      _dayOfWeekTextField(),
                      _evenOrOddTextField(),
                      _locationTextField(),
                      _weekNumTextField(),
                      _dateTextField(),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
                        child: Center(child: _toggleStartEndClassButton()),
                      ),
                    ]),
                  )));
        });
  }

  Widget _classNameTextField() {
    return new Padding(
        padding:
        EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 5.0),
        child: TextFormField(
            enabled: false,
            decoration: InputDecoration(
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
              hintText: 'e.g. FSP1, SS2, SSR3, TSP4',
              labelText: 'Class Name*',
            ),
            initialValue: widget.cc.name,
            onSaved: (String val) {
              //_email = val;
              //TODO: Save user input for database validation.
            }));
  }

  static var optsDayOfWeek = [0,1,2,3,4,5,6];
  static var optsDayOfWeekStr = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
  Widget _dayOfWeekTextField() {
    return new Padding(
        padding:
        EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 5.0),
        child: TextFormField(
            enabled: false,
            decoration: InputDecoration(
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
              hintText: 'e.g. CZ3002, CE2007, CX3004',
              labelText: 'Day of Week*',
            ),
            initialValue: optsDayOfWeekStr[widget.cc.dayOfWeek],
            onSaved: (String val) {
              //_email = val;
              //TODO: Save user input for database validation.
            }));
  }

  static var optsEvenOdd = [0,1,2];
  static var optsEvenOddStr = ['Weekly', 'Odd week only', 'Even week only'];
  Widget _evenOrOddTextField() {
    return new Padding(
        padding:
        EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 5.0),
        child: TextFormField(
            enabled: false,
            decoration: InputDecoration(
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
              hintText: 'e.g. CZ3002, CE2007, CX3004',
              labelText: 'Even or Odd',
            ),
            initialValue: optsEvenOddStr[widget.cc.evenOdd],
            onSaved: (String val) {
              //_email = val;
              //TODO: Save user input for database validation.
            }));
  }

  Widget _weekNumTextField() {
    return new Padding(
        padding:
        EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 5.0),
        child: TextFormField(
            enabled: false,
            decoration: InputDecoration(
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
              hintText: 'e.g. CZ3002, CE2007, CX3004',
              labelText: 'Week Number*',
            ),
            initialValue: widget.s.weekNum.toString(),
            onSaved: (String val) {
              //_email = val;
              //TODO: Save user input for database validation.
            }));
  }

  Widget _locationTextField() {
    return new Padding(
        padding:
        EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 5.0),
        child: TextFormField(
            enabled: false,
            decoration: InputDecoration(
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
              hintText: 'e.g. Software Lab 3',
              labelText: 'Location*',
            ),
            initialValue: widget.cc.location,
            onSaved: (String val) {
              //_email = val;
              //TODO: Save user input for database validation.
            }));
  }

  Widget _startTimeTextField() {
    return new Padding(
        padding:
        EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 5.0),
        child: TextFormField(
            enabled: false,
            decoration: InputDecoration(
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
              //contentPadding: const EdgeInsets.all(15.0),
              hintText: 'e.g. 1430',
              labelText: 'Start Time*',
            ),
            initialValue: widget.cc.startTime,
            onSaved: (String val) {
              //_email = val;
              //TODO: Save user input for database validation.
            }));
  }

  Widget _endTimeTextField() {
    return new Padding(
        padding:
        EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 5.0),
        child: TextFormField(
            enabled: false,
            decoration: InputDecoration(
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
              //contentPadding: const EdgeInsets.all(15.0),
              hintText: 'e.g. 1630',
              labelText: 'End Time*',
            ),
            initialValue: widget.cc.endTime,
            onSaved: (String val) {
              //_email = val;
              //TODO: Save user input for database validation.
            }));
  }

  Widget _dateTextField() {
    return new Padding(
        padding:
        EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 5.0),
        child: TextFormField(
            enabled: false,
            decoration: InputDecoration(
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
              hintText: 'e.g. 11/2/2020',
              labelText: 'Date*',
            ),
            initialValue: sgDateFormat.format(widget.s.date).toString(),
            onSaved: (String val) {
              //_email = val;
              //TODO: Save user input for database validation.
            }));
  }

  Widget _toggleStartEndClassButton() {
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.blueAccent,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width * 0.4,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          if (widget.s.isActive) {
            _doEndSession();
          } else {
            _doStartSession();
          }
        },
        child: Text(
          widget.s.isActive ? "End Class" : "Start Class",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18.0, color: Colors.white),
        ),
      ),
    );
  }

  _doStartSession() {
    ProgressDialog prStart = showProgressDialog(context, "Starting session...");
    //prStart.show();
    AWSFEUtil.startSession(widget.c, widget.cc, widget.s).then((value) {

      setState(() {
        widget.s.isActive = true;
        final snackBar = SnackBar(
          content: Text("Session ${widget.cc.name} started."),
          action: SnackBarAction(
            label: '',
            onPressed: () {},
          ),
        );
        _scaffoldKey.currentState.hideCurrentSnackBar();
        _scaffoldKey.currentState.showSnackBar(snackBar);
        //prStart.dismiss();
      });
    });

  }

  _doEndSession() {
    ProgressDialog pr = showProgressDialog(context, "Ending session...");
    //pr.show();
    AWSFEUtil.endSession(widget.s).then((value) {
      //pr.dismiss();
      //pr = null;
      setState(() {
        widget.s.isActive = false;
      });
      // TODO cancel snackbar and show snackbar for message
      final snackBar = SnackBar(
        content: Text("Session ${widget.cc.name} ended."),
        action: SnackBarAction(
          label: '',
          onPressed: () {},
        ),
      );
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(snackBar);
    });
  }
}

// =====================================================================================================
// =====================================================================================================
//TODO start of session attendance view
class SessionAttendanceWidget extends StatefulWidget {
  final CourseClass cc;
  final Course c;
  final Session s;

  const SessionAttendanceWidget(
      {Key key, @required this.c, @required this.cc, @required this.s})
      : super(key: key);

  @override
  _SessionAttendanceWidgetState createState() =>
      _SessionAttendanceWidgetState();
}

class _SessionAttendanceWidgetState extends State<SessionAttendanceWidget> {
  bool loading = false;
  List<String> studentList;
  List<String> studentAttendanceList;
  String _picPath;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {

    super.initState();
    studentList = [];
    studentAttendanceList = [];
    _loadAttendanceData();
  }

  _loadAttendanceData()  {

    setState(() {
      loading = true;
    });


    // group of data
    studentList.clear();
    studentAttendanceList.clear();
    widget.s.hasAttended.forEach((value) {
      studentAttendanceList.add(value);

    });

    widget.cc.students.forEach((value) {
      studentList.add(value);

    });
    // update state
    setState(() {
      loading = false;
    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: _showStudentsAttended(),
      floatingActionButton: !widget.s.isActive
          ? null
          : FloatingActionButton(
        tooltip: "Take attendance",
        child: Icon(Icons.camera_alt),
        onPressed: () {
          _takePhoto(context);
        },
      ),
    );
  }

  Widget _showStudentsAttended() {
    if (loading){
      return Align(child: CircularProgressIndicator(), alignment: FractionalOffset.center);
    }

    return Container(
      width: double.infinity,
      child: SingleChildScrollView(
        child:  Column(
          children: <Widget>[
            _header('Attendance List'),
            _studentsListView(studentList),
            //_header('OTHER CLASS'),
            //_studentsListView(studentMakeupList),
          ],
        ),
      ),
    );
  }

  _header(String header){
    return Padding(
      padding: EdgeInsets.all(16.0),
      child:Text(header, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _studentsListView(studentList) {
    if ( studentList.length == 0){
      return Text("No data");
    }

    return ListView.builder(
        primary: false,
        shrinkWrap: true,
        itemCount: studentList.length,
        itemBuilder: (context, index) {
          return _studentText(studentList[index], Icons.face);
        });
  }

  ListTile _studentText(String matricNo, IconData icon) {
    return ListTile(
      title: Text(matricNo,
          style: TextStyle(
            //fontWeight: FontWeight.w500,
            fontSize: 20,
          )),
      //subtitle: Text(student.name,
      //style: TextStyle(
      //color: null,
      //)),
      leading: Icon(
          studentAttendanceList.contains(matricNo) ? Icons.check_box : Icons.check_box_outline_blank),
    );
  }

  //TODO: edit here to attendance taking
  _takePhoto(BuildContext context) async {
    dynamic result = await Navigator.of(context).pushNamed("/take_photo");
    try {
      if (result != null) {
        _removeTempPhoto();
        setState(() {
          this._picPath = result as String;

//          _scaffoldKey.currentState.hideCurrentSnackBar();

          /// Do face recognition on photo taken
          _doDetectFace();
        });
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  _doDetectFace() {
    List<int> imgBytes = File(this._picPath).readAsBytesSync();
    String imgBase64 = base64Encode(imgBytes);
    String id= widget.s.id;
    ProgressDialog pr = showProgressDialog(context, "Finding student...");
    pr.show();


    AWSFEUtil.detectFace(imgBase64, id).then((response) {
      pr.dismiss();
      pr = null;
      print(response['message']);

      /// If face is found in database, we call takeAttendance
     if (response['message'] == "Identity not detected.")
      {
        _displaySnackBar(context, false, response['message']);
       print("1");
      }
      else {
       // final snackBar2 = SnackBar(content: response['message']);
       // _scaffoldKey.currentState.hideCurrentSnackBar();
       // _scaffoldKey.currentState.showSnackBar(snackBar2);
       _displaySnackBar(context, true, response['message']);
       print("1");
       print("0");
      }

      setState(() {
        _loadAttendanceData();
      });

    });
  }

  _doTakeAttendance(FratsResponse response) {
    ProgressDialog pr = showProgressDialog(context, "Taking attendance...");
    pr.show();

    /// If face recognised, check if person has already attendance taken.
    /// If not yet, take attendance.
    /// Else, show that attendance has been taken.
    //AWSFEUtil.takeAttendance(widget.c, widget.cc, widget.s,
    //response.result['student']['MatricID'])
    //.then((value) {
    //print(value.result);
    pr.dismiss();
    pr = null;
    //_displaySnackBar(context, response, null);
    setState(() {
      _loadAttendanceData();
    });
    //});
  }

  _removeTempPhoto() {
    if (this._picPath != null) {
      File(this._picPath).delete();
      this._picPath = null;
    }
  }

  _displaySnackBar(BuildContext context, bool found, String Message) {
    Text snackbarText = Text(
        found
        ? Message
        : "No face found, or invalid face detected!");
    final snackBar = SnackBar(content: snackbarText);
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(snackBar);

  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frats_system_ase/classes/course_class.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'classes/course.dart';
import 'sidebar.dart';
import 'utils/frats_api.dart';
import 'utils/validator.dart';
import 'utils/dialog_helper.dart';

TimeOfDay time = TimeOfDay.now();
DateTime selectedDate = DateTime.now();

final List<String> matricNos = new List<String>();
String moduleID;
final _appFont = const TextStyle(
  fontSize: 24.0,
);

class AddClassScreen extends StatefulWidget {
  final Course course;

  const AddClassScreen({Key key,  this.course}) : super(key: key);

  @override
  AddClassState createState() => AddClassState();
}

class AddClassState extends State<AddClassScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController dateCtrl = TextEditingController();
  TextEditingController startTimeCtrl = TextEditingController();
  TextEditingController endTimeCtrl = TextEditingController();
  TextEditingController inputCtrlAcadYear = TextEditingController();
  TextEditingController inputCtrlName = TextEditingController();
  TextEditingController inputCtrlCode = TextEditingController();
  TextEditingController inputCtrlLocation = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.course!=null){
      inputCtrlCode.text = widget.course.courseCode;
      inputCtrlAcadYear.text = widget.course.acadYear;
      moduleID = widget.course.ObjectId;
    }
  }

  @override
  void dispose() {
    super.dispose();
    dateCtrl.dispose();
    startTimeCtrl.dispose();
    endTimeCtrl.dispose();
    inputCtrlAcadYear.dispose();
    inputCtrlName.dispose();
    inputCtrlCode.dispose();
    inputCtrlLocation.dispose();
  }

  void _clearInput(){
    dateCtrl.clear();
    startTimeCtrl.clear();
    endTimeCtrl.clear();
    inputCtrlAcadYear.clear();
    inputCtrlName.clear();
    inputCtrlCode.clear();
    inputCtrlLocation.clear();
    selectedType = optsTypes[0];
    selectedDayOfWeek = optsDayOfWeek[0];
    selectedEvenOdd = optsEvenOdd[0];
    matricNos.clear();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(
                "Add New Class",
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
            body: AnimatedContainer(
              curve: Curves.easeOut,
              duration: Duration(milliseconds: 400),
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      child: addClassFormScreen(),
                    )
                  ],
                ),
              ),
            ),
            floatingActionButton: new Builder(builder: (BuildContext context) {
              return FloatingActionButton(
                  //onPressed: _incrementCounter,
                  tooltip: 'Confirm Add Class',
                  child: Icon(Icons.add),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();

                      _doAddClass(context);
                    }
                  });
            }) // This trailing comma makes auto-formatting nicer for build methods.
            ));
  }

  //TODO: show progress dialog
  _doAddClass(BuildContext context) {
    // construct data
    ProgressDialog pr = showProgressDialog(context, "Adding class...");
    try {
      CourseClass newClass = new CourseClass(
        dayOfWeek: selectedDayOfWeek,
        evenOdd: selectedEvenOdd,
        name: inputCtrlName.text,
        type: selectedType,
        startTime: startTimeCtrl.text,
        endTime: endTimeCtrl.text,
        location: inputCtrlLocation.text,
        students: matricNos,
      );
      pr.show();
      AWSFEUtil.addClass(moduleID, inputCtrlAcadYear.text, inputCtrlCode.text, newClass)
          .then((response) {
            pr.hide();
        print("_doAddClass: ${response.found}, ${response.result},");

        Navigator.pop(context, response.result);
        // snackbar to show result
        final snackBar = SnackBar(
          content: Text(response.result),
          duration: Duration(seconds: 3),
        );
        Scaffold.of(context).hideCurrentSnackBar();
        Scaffold.of(context).showSnackBar(snackBar);

        if (response.found){
          _clearInput();
        }
      });
    } on Exception catch (_) {
      print("something is wrong in  _doAddClass()");
    }
  }


  Widget addClassFormScreen() {
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
            child: Stack(children: <Widget>[
          Column(children: <Widget>[
            _acadYear(),
            _classNameTextField(),
            _classType(),
            _courseCodeTextField(),
            _locationTextField(),
            _startTimeTextField(),
            _endTimeTextField(),
            _dayOfWeek(),
            _evenOrOdd(),
            _addStudentsButton(),
            SizedBox(
              width: 10.0,
              height: 200.0,
            )
          ]),
        ])));
  }

  Widget _classNameTextField() {
    return new Padding(
        padding:
            EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
        child: TextFormField(
            controller: inputCtrlName,
            validator: Validator.validateClassName,
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
              hintText: 'e.g. FSP1, SS2, SSR3, TSP4',
              labelText: 'Class Name*',
            ),
            //Validator receives text user has entered.
            //validator: validateEmpty,
            keyboardType: TextInputType.text,
            onSaved: (String val) {})
	    );
  }

  Widget _courseCodeTextField() {
    return new Padding(
        padding:
            EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
        child: TextFormField(
            enabled: widget.course==null,
            controller: inputCtrlCode,
            validator: Validator.validateCourseCode,
            decoration: InputDecoration(
              suffixIcon: widget.course!=null?null:IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  inputCtrlCode.clear();
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
            //Validator receives text user has entered.
            //validator: validateEmpty,
            keyboardType: TextInputType.text,
            onSaved: (String val) {})
	    );
  }

  Widget _locationTextField() {
    return new Padding(
        padding:
            EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
        child: TextFormField(
            controller: inputCtrlLocation,
            validator: Validator.validateEmpty,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    inputCtrlLocation.clear();
                  }),
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
              hintText: 'e.g. Software Lab 3',
              labelText: 'Location*',
            ),
            //Validator receives text user has entered.
            //validator: validateEmpty,
            keyboardType: TextInputType.text,
            onSaved: (String val) {})
	    );
  }

  Widget _startTimeTextField() {
    return new Padding(
        padding:
            EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
        child: TextFormField(
            validator: Validator.validateTime,
            enableInteractiveSelection: false,
            focusNode: FocusScopeNode(),
            controller: startTimeCtrl,
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
              suffixIcon: IconButton(
                icon: Icon(Icons.access_time),
                color: Colors.red,
                onPressed: () {
                  _onEndClockButtonPressed(context);
                },
              ),
              //contentPadding: const EdgeInsets.all(15.0),
              hintText: 'e.g. 1430',
              labelText: 'Start Time*',
            ),
            //Validator receives text user has entered.
            //validator: validateEmpty,
            //keyboardType: TextInputType.text,
            onTap: () {
              _onStartClockButtonPressed(context);
            },
            onSaved: (String val) {})
	    );
  }

  Widget _endTimeTextField() {
    return new Padding(
        padding:
            EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
        child: TextFormField(
            validator: Validator.validateTime,
            enableInteractiveSelection: false,
            focusNode: FocusScopeNode(),
            controller: endTimeCtrl,
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
              suffixIcon: IconButton(
                icon: Icon(Icons.access_time),
                color: Colors.red,
                onPressed: () {
                  //_onEndClockButtonPressed(context);
                },
              ),
              //contentPadding: const EdgeInsets.all(15.0),
              hintText: 'e.g. 1630',
              labelText: 'End Time*',
            ),
            //Validator receives text user has entered.
            //validator: validateEmpty,
            //keyboardType: TextInputType.text,
            onTap: () {
              _onEndClockButtonPressed(context);
            },
            onSaved: (String val) {})
	    );
  }

  Widget _acadYear() {
    return new Padding(
        padding:
            EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
        child: TextFormField(
            enabled: widget.course==null,
            controller: inputCtrlAcadYear,
            validator: Validator.validateAcadYear,
            decoration: InputDecoration(
              suffixIcon: widget.course!=null?null:IconButton(
                icon: Icon(Icons.clear),
                onPressed: (){
                  inputCtrlAcadYear.clear();
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
              hintText: 'e.g. AY1920S1',
              labelText: 'Academic Year*',
            ),
            //Validator receives text user has entered.
            //validator: validateEmpty,
            keyboardType: TextInputType.text,
            onSaved: (String val) {})
	    );
  }

  static var optsTypes = ["LEC","STU","TUT","LAB"];
  String selectedType = optsTypes[0];
  Widget _classType() {
    return Padding(
        padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
        child:  new Container(
            color: Colors.grey[200],
            child: new Padding(
              padding: EdgeInsets.only(left: 5.0, right: 0.0, top: 5.0, bottom: 0.0),
              child: Column(
                children: <Widget>[
                  Align(
                    child: Text(
                      'Class Type',
                      style: TextStyle(
                          color: Colors.grey
                      ),
                    ),
                    alignment: Alignment.topLeft,
                  ),
                  DropdownButton<String>(
                    value: selectedType,
                    isExpanded: true,
                    iconSize: 24,
                    elevation: 16,
                    focusColor: Colors.grey,
                    items: optsTypes.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String value) {
                      setState(() {
                        selectedType=value;
                      });
                    },
                  )

                ],
              ),
            )
        )
    );
  }

  static var optsDayOfWeek = [0,1,2,3,4,5,6];
  static var optsDayOfWeekStr = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
  int selectedDayOfWeek = optsDayOfWeek[0];
  Widget _dayOfWeek() {
    return Padding(
        padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
        child:  new Container(
            color: Colors.grey[200],
            child: new Padding(
              padding: EdgeInsets.only(left: 5.0, right: 0.0, top: 5.0, bottom: 0.0),
              child: Column(
                children: <Widget>[
                  Align(
                    child: Text(
                      "Day of week",
                      style: TextStyle(
                          color: Colors.grey
                      ),
                    ),
                    alignment: Alignment.topLeft,
                  ),
                  DropdownButton<int>(
                    value: selectedDayOfWeek,
                    isExpanded: true,
                    iconSize: 24,
                    elevation: 16,
                    focusColor: Colors.grey,
                    items: optsDayOfWeek.map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(optsDayOfWeekStr[value]),
                      );
                    }).toList(),
                    onChanged: (int value) {
                      setState(() {
                        selectedDayOfWeek=value;
                      });
                    },
                  )

                ],
              ),
            )
        )
    );
  }

  static var optsEvenOdd = [0,1,2];
  static var optsEvenOddStr = ['Weekly', 'Odd week only', 'Even week only'];
  int selectedEvenOdd = 0;
  Widget _evenOrOdd() {
    return Padding(
      padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
      child:  new Container(
    color: Colors.grey[200],
        child: new Padding(
          padding: EdgeInsets.only(left: 5.0, right: 0.0, top: 5.0, bottom: 0.0),
          child: Column(
            children: <Widget>[
              Align(
                child: Text(
                  "Even or Odd",
                  style: TextStyle(
                      color: Colors.grey
                  ),
                ),
                alignment: Alignment.topLeft,
              ),
              DropdownButton<int>(
                value: selectedEvenOdd,
                isExpanded: true,
                iconSize: 24,
                elevation: 16,
                focusColor: Colors.grey,
                items: optsEvenOdd.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(optsEvenOddStr[value]),
                  );
                }).toList(),
                onChanged: (int value) {
                  setState(() {
                    selectedEvenOdd=value;
                  });
                },
              )
            ],
          ),
        )
    )
    );
  }


  Widget _addStudentsButton() {
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.blueAccent,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width * 0.4,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          _pushAddStudents(context);
        },
        child: Text(
          "Add Students",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18.0, color: Colors.white),
        ),
      ),
    );
  }

  void _pushAddStudents(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddStudentScreen(),));
  }

  Future<Null> _onStartClockButtonPressed(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: time,
    );
    if (picked != null && picked != time)
      setState(() {
        time = picked;
        startTimeCtrl.text =
            "${time.hour.toString().padLeft(2, "0")}${time.minute.toString().padLeft(2, "0")}";
      });
  }

  Future<Null> _onEndClockButtonPressed(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: time,
    );
    if (picked != null && picked != time)
      setState(() {
        time = picked;
        endTimeCtrl.text =
            "${time.hour.toString().padLeft(2, "0")}${time.minute.toString().padLeft(2, "0")}";
      });
  }
}

/// ADD Student
class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({ Key key }) : super(key: key);

  @override
  AddStudentState createState() => AddStudentState();
}

class AddStudentState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController inputCtrlmatricNos = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    inputCtrlmatricNos.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(title: Text('Add Student to Class', style: _appFont)),
      body: Form(
        key: _formKey,
        child: Column(children: <Widget>[
          _addStudentMatricIdField(),
          Expanded(
            flex: 2,
            child: _listMatricNos(context),
          )

        ]),
      ),
      floatingActionButton: new Builder(builder: (BuildContext context) {
        return FloatingActionButton(
          //onPressed: _incrementCounter,
          tooltip: 'Confirm Add Student',
          child: Icon(Icons.check),
          onPressed: (){
            _addStudentMatric(context);
          },
        );
      }),
    );
  }

  _addStudentMatric(BuildContext context){
    if (_formKey.currentState.validate()) {
      String matric = inputCtrlmatricNos.text.toString().toUpperCase();
      if (matricNos.contains(matric)){
        print(matric+" is existed");
        inputCtrlmatricNos.text = "";

        final sbMissingPhoto = SnackBar (
          content: Text('Matriculation Number ($matric) is already added.'),
          duration: Duration(seconds: 3),
        );
        Scaffold.of(context).hideCurrentSnackBar();
        Scaffold.of(context).showSnackBar(sbMissingPhoto);
        return;
      }

      ProgressDialog pr = showProgressDialog(context, "please wait...");

        if (true) {
          matricNos.add(matric);
          inputCtrlmatricNos.text = "";
          print(matricNos);
          setState(() {});
        }
        else {
          final snackBar = SnackBar(
            content: Text("response.result"),
            duration: Duration(seconds: 3),
          );
          Scaffold.of(context).hideCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snackBar);
        }

    }
  }

  Widget _addStudentMatricIdField() {
    return new Padding(
        padding:
        EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
        child: TextFormField(
            controller: inputCtrlmatricNos,
            validator: Validator.validateMatricNo,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: (){
                  inputCtrlmatricNos.clear();
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
              hintText: 'e,g, U1823456L',
              labelText: 'Student Matriculation Number*',
            ),
            //Validator receives text user has entered.
            //validator: validateEmpty,
            onFieldSubmitted: (_) {
              _addStudentMatric(context);
            },
            keyboardType: TextInputType.text,
            onSaved: (String val) {})
	    );
  }

  ListView _listMatricNos(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: matricNos.length,
        itemBuilder: (context, index) {
          return new ListTile(
            leading: Icon(Icons.face),
            title: new Text(matricNos[index]),
            trailing: IconButton(icon: Icon(Icons.clear),
                onPressed: () {
                  matricNos.remove(matricNos[index]);
                  setState(() {});
                }),
          );
        });
  }
}

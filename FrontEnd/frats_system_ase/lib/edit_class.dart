import 'package:flutter/material.dart';
import 'package:frats_system_ase/utils/dialog_helper.dart';
import 'package:frats_system_ase/utils/frats_api.dart';
import 'package:frats_system_ase/utils/validator.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'classes/course.dart';
import 'classes/course_class.dart';

final _appName = 'Manage Classes and Sessions';
final _appFont = const TextStyle(
  fontSize: 24.0,
);
final _subFont = const TextStyle(
  fontSize: 18.0,
);
List<String> matricNos = new List<String>();

class EditClassInfoState extends StatefulWidget {
  final CourseClass cc;
  final Course c;

  const EditClassInfoState({Key key, @required this.c, @required this.cc})
      : super(key: key);

  @override
  EditClassInfoPage createState() => EditClassInfoPage();
}

class EditClassInfoPage extends State<EditClassInfoState> {
  final _formKey = GlobalKey<FormState>();

  TimeOfDay time = TimeOfDay.now();
  DateTime selectedDate = DateTime.now();

  //TextEditingController dateCtrl = TextEditingController();
  TextEditingController startTimeCtrl = TextEditingController();
  TextEditingController endTimeCtrl = TextEditingController();
  TextEditingController inputCtrlAcadYear = TextEditingController();
  TextEditingController inputCtrlName = TextEditingController();
  TextEditingController inputCtrlCode = TextEditingController();
  TextEditingController inputCtrlLocation = TextEditingController();
  TextEditingController inputCtrlmatricNos = TextEditingController();

  List<String> optMenu = <String>[
    "Delete",
  ];


  @override
  void initState() {
    startTimeCtrl.text =  widget.cc.startTime;
    endTimeCtrl.text = widget.cc.endTime;
    inputCtrlAcadYear.text= widget.c.acadYear;
    inputCtrlName.text = widget.cc.name;
    inputCtrlCode.text = widget.c.courseCode;
    inputCtrlLocation.text = widget.cc.location;
    matricNos = widget.cc.students;
    selectedType=widget.cc.type;
    selectedDayOfWeek=widget.cc.dayOfWeek;
    selectedEvenOdd=widget.cc.evenOdd;
    super.initState();
  }

  @override
  void dispose() {
    startTimeCtrl.dispose();
    endTimeCtrl.dispose();
    inputCtrlName.dispose();
    inputCtrlCode.dispose();
    inputCtrlAcadYear.dispose();
    inputCtrlLocation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Edit Class Information",
                style: _appFont,
              ),
              Text(
                "${widget.c.courseCode} ${widget.cc.name}-${widget.cc.type}",
                style: _subFont,
              )
            ]),
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
      body: SingleChildScrollView(
        //physics: NeverScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              Positioned(
                child: editClassFormScreen(),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: new Builder(builder: (BuildContext context) {
        return FloatingActionButton(
          tooltip: "Edit Class",
          child: Icon(Icons.check),
          onPressed: () {
            _doEditClass(context);
          },
        );
      }),
    );
  }

  _menuSelected(String menu){
    if (menu == "Delete"){
      //show alert dialog
      showDeleteAlertDialog(_formKey.currentContext, "class").then((value) {
        if (value == DialogAction.CONFIRM){
          AWSFEUtil.deleteClass(widget.c, widget.cc).then((response) {
            Navigator.pop(_formKey.currentContext, response.result);
          });
        }
      });
    }
  }

  _doEditClass(BuildContext context) {
    ProgressDialog pr = showProgressDialog(context, 'Please wait...');
    // construct data
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

      //pr.show();
      AWSFEUtil.editClass(widget.c, widget.cc, newClass).then((response) {
        print("_doAddClass: ${response.found}, ${response.result},");
        //pr.dismiss();
        Navigator.pop(context, response);
      });
    } on Exception catch (_) {
     // pr.dismiss();
      print("something is wrong in  _doAddClass()");
    }
  }

  Widget editClassFormScreen() {
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
            controller: inputCtrlCode,
            validator: Validator.validateCourseCode,
            decoration: InputDecoration(
              suffixIcon: IconButton(
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
            onSaved: (String val) {
            }));
  }

  Widget _acadYear() {
    return new Padding(
        padding:
        EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
        child: TextFormField(
            controller: inputCtrlAcadYear,
            validator: Validator.validateAcadYear,
            decoration: InputDecoration(
              suffixIcon: IconButton(
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
            onSaved: (String val) {
            }));
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

  static var optsDayOfWeek = [1,2,3,4,5];
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
                        child: Text(value.toString()),
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

  static var optsEvenOdd = [0, 1,2];
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
//        startTimeCtrl.text = MaterialLocalizations.of(context).formatTimeOfDay(time).toString();
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

        // test printing
//        endTimeCtrl.text = MaterialLocalizations.of(context).formatTimeOfDay(time).toString();
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
      //pr.show();

        //pr.dismiss();
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
            onSaved: (String val) {
              //_email = val;
            }));
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
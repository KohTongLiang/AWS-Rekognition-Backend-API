import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

import 'sidebar.dart';
import 'package:frats_system_ase/utils/frats_api.dart';
import 'package:frats_system_ase/classes/student.dart';

final _appName = 'Edit Student';
final _appFont = const TextStyle(
  fontSize: 24.0,
);
final _subFont = const TextStyle(
  fontSize: 18.0,
);


//TODO: Passing in class, session, student data from screen to screen.
///Function for creating the main page of the MainPage
class EditStudentScreen extends StatefulWidget {
  @override
  EditStudentState createState() => EditStudentState();
}

///Stateful class for main page of the application.
class EditStudentState extends State<EditStudentScreen> {
  bool loading = false;
  List<Student> studentList;
  final GlobalKey<ScaffoldState> _editStudentKey =
      new GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    _loadStudentsData();
  }

  _loadStudentsData() async {
    try{
      setState(() {
        loading = true;
      });
      AWSFEUtil.getStudents().then((value){
        setState(() {
          loading = false;
          studentList = value;
        });
      });

    } catch (error){
      print(error.toString());
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _editStudentKey,
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
                "Select Student",
                style: _subFont,
              )
            ]),
      ),
      drawer: launchSidebar(context),
      body: _buildWidget(),
      floatingActionButton: new Builder(builder: (context){
        return FloatingActionButton(
          tooltip: "Add student",
          child: Icon(Icons.add),
          onPressed: () async {
            await Navigator.pushNamed(context, "/reg_student");
            _loadStudentsData();
          },
        );
      },),
    );
  }

  Widget _buildWidget() {
    return SingleChildScrollView(
      //physics: NeverScrollableScrollPhysics(),
      child: Container(
        padding: EdgeInsets.only(bottom: 75),
        height: MediaQuery.of(context).size.height,
        child: listStudents(),
      ),
    );
  }
  /// ======================================================================================================================
  /// Show all students
  Widget listStudents() {
    return FutureBuilder<List<Student>>(
      future: AWSFEUtil.getStudents(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Student> studList = snapshot.data;
          return _studentsListView(studList);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Align (
            child: CircularProgressIndicator(),
            alignment: FractionalOffset.center);
      },
    );
  }

  Widget _studentsListView(studList) {
    return Scrollbar(
        child: ListView.builder(
            itemCount: studList.length,
            itemBuilder: (context, index) {
              return _tile(studList[index], Icons.face);
            }));
  }

  ListTile _tile(Student stud, IconData icon) => ListTile(
        title: Text(stud.name,
            style: TextStyle(
              //fontWeight: FontWeight.w500,
              fontSize: 20,
            )),
        subtitle: Text(stud.matricNo),
        leading: Icon(
          icon,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditStudentPageState(student: stud),
            ),
          ).then((value) {
            if (value != null){
              final snackBar = SnackBar(
                content: Text('$value'),
              );
              _editStudentKey.currentState.hideCurrentSnackBar();
              _editStudentKey.currentState.showSnackBar(snackBar);
            }

          });
        },
      );
}

/// ======================================================================================================================

class EditStudentPageState extends StatefulWidget {
  final Student student;

  const EditStudentPageState({Key key, @required this.student})
      : super(key: key);

  @override
  EditStudentPage createState() => EditStudentPage();
}

class EditStudentPage extends State<EditStudentPageState> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController, emailController, matricController;
  String _picPath;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    matricController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //AWSFEUtil.getStudentInformation(widget.student.matricNo).then((student) {});
  }
  List<String> optMenu = <String>[
    "Delete",
  ];
  Widget build(BuildContext build) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Student Details', style: _appFont),
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
      body: populateStudentInfo(widget.student.matricNo),
      floatingActionButton: new Builder(builder: (BuildContext context) {
        return FloatingActionButton(
            //onPressed: _incrementCounter,
            tooltip: 'Confirm Edit Student',
            child: Icon(Icons.check),
            onPressed: () {
              // Some code to View the change.
              if (_formKey.currentState.validate()) {
                if (!compareName()) {
                  widget.student.name = nameController.text;
                  print("Invoke name change");
                  print("New name: " + widget.student.name);
                }
                if (!compareEmail()) {
                  widget.student.email = emailController.text;
                  print("Invoke email change");
                }

                String imgBase64;
                if (this._picPath!=null){
                  List<int> imgBytes = File(this._picPath).readAsBytesSync();
                  imgBase64 = "data:image/jpeg;base64,"+base64Encode(imgBytes);
                }


                AWSFEUtil.editStudentInformation(widget.student, imgBase64).then((value) {
                  print(value);
                  Navigator.pop(context, value.result);
                });
              }
            });
      }),
    );
  }
  _menuSelected(String menu){
    if (menu == "Delete"){
      //show alert dialog
      _asyncDeleteDialog(_formKey.currentContext).then((value) {
        if (value == DeleteAction.DELETE) {
          AWSFEUtil.deleteStudent(widget.student.matricNo).then((response) {
            Navigator.pop(_formKey.currentContext, response.result);
          });
        }
      });

    }
  }


  Widget populateStudentInfo(String matric) {
    return SingleChildScrollView(
      child: FutureBuilder<Student>(
        future: AWSFEUtil.getStudentInformation(matric),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Student student = snapshot.data;
            widget.student.email = student.email;
            //widget.student.deleted = student.deleted;
            widget.student.faces = student.faces;
            nameController = TextEditingController(text: widget.student.name);
            emailController = TextEditingController(text: widget.student.email);
            matricController = TextEditingController(text: widget.student.matricNo);

            return displayStudentInfo(student);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return Align (
              child: CircularProgressIndicator(),
              alignment: FractionalOffset.center);
        },
      ),
    );
  }

  Widget displayStudentInfo(Student student) {
    return Form(
      key: _formKey,
      child: Column(children: <Widget>[
        _studentNameTextField(student.name),
        _studentEmailTextField(student.email),
        _studentMatricTextField(student.matricNo),
        _newStudentPhoto(),
      ]),
    );
  }

  Widget _studentNameTextField(String name) {
    return new Padding(
        padding:
            EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
        child: TextFormField(
          controller: nameController,
          validator: validateEmpty,
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
            //icon: Icon(Icons.person),
            //contentPadding: const EdgeInsets.all(15.0),
            hintText: 'Student Name',
            labelText: 'Student Name*',
          ),
          //initialValue: name,
          //Validator receives text user has entered.
          //validator: validateEmpty,
          keyboardType: TextInputType.text,
        ));
  }

  Widget _studentEmailTextField(String email) {
    return new Padding(
        padding:
            EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
        child: TextFormField(
          controller: emailController,
          validator: validateEmail,
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
            //icon: Icon(Icons.person),
            //contentPadding: const EdgeInsets.all(15.0),
            hintText: 'e.g. ATAN0112@e.ntu.edu.sg',
            labelText: 'Institutional E-mail*',
          ),
          //initialValue: email,
          //Validator receives text user has entered.
          //validator: validateEmpty,
          keyboardType: TextInputType.text,
        ));
  }

  Widget _studentMatricTextField(String matric) {
    return new Padding(
        padding:
            EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
        child: TextFormField(
          controller: matricController,
          validator: validateEmpty,
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
            //icon: Icon(Icons.person),
            //contentPadding: const EdgeInsets.all(15.0),
            hintText: 'e.g. U1820300T',
            labelText: 'Matriculation Number*',
          ),
          //initialValue: matric,
          //Validator receives text user has entered.
          //validator: validateEmpty,
          keyboardType: TextInputType.text,
        ));
  }

  Widget _newStudentPhoto() {
    return new Container(
      alignment: Alignment(-1, -1),
      padding: EdgeInsets.only(top: 15.0, bottom: 30.0, left: 30),
      child: Column(
        children: <Widget>[
          Text(
            "Take Photo",
            textAlign: TextAlign.left,
            style: const TextStyle(
                fontSize: 16,
                color: Colors.purple,
                fontWeight: FontWeight.bold),
          ),
          DottedBorder(
            borderType: BorderType.RRect,
            strokeWidth: 3,
            color: Colors.purple,
            dashPattern: [6, 6],
            //padding: EdgeInsets.all(0),
            child: FlatButton(
              color: Colors.white,
              onPressed: () {
                _takePhoto(context);
              },
              child: widget.student.faces!=null? CircularProgressIndicator(): CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }



  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return "Please enter a valid e-mail.";
    else
      return null;
  }

  String validateEmpty(String value) {
    return value == '' ? "This field is required." : null;
  }

  bool compareName() {
    print(nameController.text);
    return widget.student.name == nameController.text;
  }

  bool compareEmail() {
    print(emailController.text);
    return widget.student.email == emailController.text;
  }

  _takePhoto(BuildContext context) async {
    dynamic result = await Navigator.of(context).pushNamed("/take_photo");
    try {
      setState(() {
        // update path to display photo
        this._picPath = result as String;
      });
    } on Exception catch (e) {
      print(e.toString());
    }
  }
}

enum DeleteAction {CANCEL, DELETE}
Future<DeleteAction> _asyncDeleteDialog(BuildContext context) async {
  return showDialog<DeleteAction>(
    context: context,
    barrierDismissible: false, // user must tap button for close dialog!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm delete?'),
        content: const Text(
            'This will permanently delete the student involved!'),
        actions: <Widget>[
          FlatButton(
            child: const Text('CANCEL'),
            onPressed: () {
              Navigator.of(context).pop(DeleteAction.CANCEL);
            },
          ),
          FlatButton(
            child: const Text('ACCEPT'),
            onPressed: () {
              Navigator.of(context).pop(DeleteAction.DELETE);
            },
          )
        ],
      );
    },
  );
}
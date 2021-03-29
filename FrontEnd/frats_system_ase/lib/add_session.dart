import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frats_system_ase/classes/course_class.dart';
import 'package:frats_system_ase/classes/session.dart';
import 'package:frats_system_ase/utils/validator.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'classes/course.dart';
import 'utils/frats_api.dart';
import 'utils/dialog_helper.dart';

TimeOfDay time = TimeOfDay.now();
DateTime selectedDate = DateTime.now();
TextEditingController dateCtrl = TextEditingController();

final _appFont = const TextStyle(
  fontSize: 24.0,
);

class AddSessionScreen extends StatefulWidget {
  final Course course;
  final CourseClass courseClass;

  const AddSessionScreen({Key key, @required this.course, @required this.courseClass}):super(key:key);

  @override
  AddSessionState createState() => AddSessionState();
}

class AddSessionState extends State<AddSessionScreen> {
  final _formKey = GlobalKey<FormState>();

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
                "Add New Session",
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
                  tooltip: 'Confirm Add Student',
                  child: Icon(Icons.add),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();

                      _doAddSession(context);
                    }
                  });
            }) // This trailing comma makes auto-formatting nicer for build methods.
            ));
  }

  _doAddSession(BuildContext context){
    // construct data
    ProgressDialog pd;
    try{
      Session newSession = new Session(
        weekNum: selectedWeekNum,
        date: selectedDate,
      );
      pd = showProgressDialog(context, "Please wait...");
      pd.show();
      AWSFEUtil.addSession(widget.course, widget.courseClass, newSession).then((response){
        pd.dismiss();
        pd = null;
        print("_doAddSession: ${response.found}, ${response.result},");

        // snackbar to show result
        final sbResult = SnackBar (
          content: Text(response.result),
          duration: Duration(seconds: 3),
        );
        Scaffold.of(context).hideCurrentSnackBar();
        Scaffold.of(context).showSnackBar(sbResult);

        Navigator.pop(context, response.result);

      });
    } on Exception catch (_) {
      print("something is wrong in  _doAddSession()");
      if (pd != null){
        pd.dismiss();
        pd = null;
      }
    }

  }


  Widget addClassFormScreen() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
          child: Stack(
              children: <Widget>[
                Column(children: <Widget>[
                  _weekNum(),
                  _dateTextField(), // not used
                  SizedBox(
                    width: 10.0,
                    height: 200.0,
                  )
                ]),
              ]

          )
      )


    );
  }

  static var optsWeekNum = [1,2,3,4,5,6,7,8,9,10,11,12,13];
  int selectedWeekNum = optsWeekNum[0];
  Widget _weekNum() {
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
                      "Week number",
                      style: TextStyle(
                          color: Colors.grey
                      ),
                    ),
                    alignment: Alignment.topLeft,
                  ),
                  DropdownButton<int>(
                    value: selectedWeekNum,
                    isExpanded: true,
                    iconSize: 24,
                    elevation: 16,
                    focusColor: Colors.grey,
                    items: optsWeekNum.map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                    onChanged: (int value) {
                      setState(() {
                        selectedWeekNum=value;
                      });
                    },
                  )

                ],
              ),
            )
        )
    );
  }


  Widget _dateTextField() {
    return new Padding(
        padding:
            EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
        child: TextFormField(
            // TODO: check if date validation is needed
            validator: Validator.validateEmpty,
            enableInteractiveSelection: false,
            focusNode: FocusScopeNode(),
            controller: dateCtrl,
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
              hintText: 'e.g. 11 Feb 2020',
              labelText: 'Date*',
              suffixIcon: IconButton(
                icon: Icon(Icons.date_range),
                color: Colors.red,
                onPressed: () {
                  //_onCalendarButtonPressed(context);
                },
              ),
            ),
            //Validator receives text user has entered.
            //validator: validateEmpty,
            //keyboardType: TextInputType.text,
            onTap: () {
              _onCalendarButtonPressed(context);
            },
            onSaved: (String val) {})
    );
  }

  Future<Null> _onCalendarButtonPressed(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        dateCtrl.text = DateFormat('dd MMM yyyy').format(selectedDate);
      });
  }
}

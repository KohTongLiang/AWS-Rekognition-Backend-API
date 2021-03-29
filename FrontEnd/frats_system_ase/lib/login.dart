import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frats_system_ase/utils/dialog_helper.dart';
import 'package:frats_system_ase/utils/frats_api.dart';
import 'package:frats_system_ase/classes/admin.dart';
import 'package:frats_system_ase/classes/frats_response.dart';
import 'package:frats_system_ase/utils/globals.dart' as globals;
import 'package:frats_system_ase/utils/validator.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'dart:convert';



Admin admin;
FratsResponse response;
bool passwordVisible = false;

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildWidget(),
    );
  }

  Widget _buildWidget() {
    return SingleChildScrollView(
      //physics: NeverScrollableScrollPhysics(),
      child: Container(
        //height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            _buildBackground(),
            Positioned(
              top: 115,
              left: 40,
              right: 40,
              child: LoginFormWidget(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/TestBackground.png"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class LoginFormWidget extends StatefulWidget {
  @override
  LoginFormWidgetState createState() => LoginFormWidgetState();
}

class LoginFormWidgetState extends State<LoginFormWidget> {
  //Global key that uniquely identifies the form widget
  //Allows validation of the form
  final _formKey = GlobalKey<FormState>();

  // Store credentials in variable for sending to backend for authentication.
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        curve: Curves.easeOut,
        duration: Duration(milliseconds: 400),
        child: Form(
            key: _formKey,
            child: Column(children: <Widget>[
                Card(
                    elevation: 15,
                    child: Column(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        //TextFormFields and RaisedButton go in here.
                        _buildLogo(),
                        _buildIntroText(),
                        _buildLoginField(),
                        _buildPasswordField(),
                        _padEmptySpace(25.0),
                        _buildLoginButton(),
                        _padEmptySpace(25.0),
                      ],
                    )),
                _buildExtraInfo(),
              ]
            )));
  }

  Widget _buildLogo() {
    return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/NTULogo.png"),
                alignment: Alignment(0, 0),
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
        ));
  }

  Widget _buildIntroText() {
    return new Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Text(
          "Facial Recognition Attendance Taking System (FRATS)",
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  Widget _buildExtraInfo(){
    return Text(
      "CZ3002 project by Ground One",
      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildLoginField() {
    return new Padding(
        padding: EdgeInsets.all(15.0),
        child: TextFormField(
            controller: usernameController,
            decoration: const InputDecoration(
              icon: Icon(Icons.person),
              //contentPadding: const EdgeInsets.all(15.0),
              hintText: 'e.g. ATAN0112',
              labelText: 'Staff ID*',
            ),
            //Validator receives text user has entered.
            validator: Validator.validateEmpty,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
            onSaved: (String val) {})
    );
  }

  Widget _buildPasswordField() {
    return new Padding(
        padding: EdgeInsets.all(15.0),
        child: TextFormField(
          controller: passwordController,
          validator: Validator.validateEmpty,
          keyboardType: TextInputType.text,
          //controller: _userPasswordController,
          obscureText: !passwordVisible,
          //This will obscure text dynamically
          decoration: InputDecoration(
            icon: Icon(Icons.security),
            labelText: 'Password',
            hintText: 'Enter your password',
            // Here is key idea
            suffixIcon: IconButton(
              icon: Icon(
                // Based on passwordVisible state choose the icon
                passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: Theme.of(context).primaryColorDark,
              ),
              onPressed: () {
                // Update the state i.e. toggle the state of
                // passwordVisible variable
                setState(() {
                  passwordVisible = !passwordVisible;
                });
              },
            ),
          ),
          //onFieldSubmitted: ,
          onSaved: (String val) {})
    );
  }

  Widget _buildLoginButton() {
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.blueAccent,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width * 0.4,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          _validateAndAuthenticate();
          //Validate returns true if form is valid, otherwise false.
        },
        child: Text(
          "Login",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18.0, color: Colors.white),
        ),
      ),
    );
  }

  Widget _padEmptySpace(double val) {
    return SizedBox(
      height: val,
    );
  }

  void _validateAndAuthenticate() {
    Scaffold.of(context).hideCurrentSnackBar();
    if (_formKey.currentState.validate()) {
      // If form is valid, display a snackbar.
      // Call server to authenticate or save information in a database.
      admin = new Admin();
      admin.staffId = usernameController.text;
      admin.password = passwordController.text;

      ProgressDialog pr = showProgressDialog(context, 'Authenticating...');
      pr.show();
      AWSFEUtil.authenticateAdminLogin(admin).then((val) {
        print(val.body);
        Map<String, dynamic> mongoOut = jsonDecode(val.body);
        print("this is the message");
        print(mongoOut["auth"]);
        if (mongoOut['auth']) {
          admin.token= mongoOut['token'];
          globals.adminToken= mongoOut['token'];
          print(globals.adminToken);
          pr.hide();
          globals.adminName = admin.staffId;
          Navigator.of(context).pushReplacementNamed('/homepage').then((value) {
            setState(() {
              usernameController.text = "";
              passwordController.text = "";
            });
          });
        } else {
          pr.hide();
          final snackBar = SnackBar(
            content: Text("Cannot authenticate"),
          );
          Scaffold.of(context).showSnackBar(snackBar);
        }
      });
      // Added a hide dialog in case if the dialog goes on infinitely.
      pr.hide();
    }
  }

  @override
  void initState() {
    passwordVisible = false;
    super.initState();
  }

}
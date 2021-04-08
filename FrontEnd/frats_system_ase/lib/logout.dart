import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frats_system_ase/login.dart';

class LogoutScreen extends StatefulWidget {
  @override
  LogoutScreenState createState() => LogoutScreenState();
}

class LogoutScreenState extends State<LogoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Container(
          //height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              _buildBackground(),
              Positioned(
                top: 125,
                left: 40,
                right: 40,
                child: LoginFormWidget(),
              )
            ],
          ),
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
  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: <Widget>[
      Card(
          elevation: 15,
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //TextFormFields and RaisedButton go in here.
              _buildLogo(),
              _padEmptySpace(25),
              _logoutText(),
              _padEmptySpace(50),
              _loadingIndicator(),
              _padEmptySpace(50),
            ],
          ))
    ]));
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
                alignment: Alignment(0.2, -1.1),
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
        ));
  }

  Widget _logoutText() {
    return Text(
      "You have successfully logged out."
      "\nYou will be redirected to the"
      "\nLogin page in 5 seconds.",
      style: TextStyle(
        fontSize: 20.0,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _loadingIndicator() {
    return CircularProgressIndicator(
      backgroundColor: Colors.white,
      strokeWidth: 3,
    );
  }

  startTime() async {
    var duration = new Duration(seconds: 5);
    return new Timer(duration, route);
  }

  route() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  Widget _padEmptySpace(double val) {
    return SizedBox(
      height: val,
    );
  }
}

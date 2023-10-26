import 'package:flutter/material.dart';
import 'signin.dart';
import 'register.dart';

class Authenticate extends StatefulWidget {
  createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool onSignIn = true;
  bool onSignUp = false;
  bool onSetUsername = false;

  void _toSignUp() {
    setState(() {
      onSignIn = false;
      onSignUp = true;
      onSetUsername = false;
    });
  }

  void _toSignIn() {
    setState(() {
      onSignIn = true;
      onSignUp = false;
      onSetUsername = false;
    });
  }

  _signInAndUp(BuildContext context) {
    if (onSignIn == true && onSignUp == false && onSetUsername == false) {
      return SignIn(toSignUp: _toSignUp);
    } else if (onSignIn == false &&
        onSignUp == true &&
        onSetUsername == false) {
      return Register(toSignIn: _toSignIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _signInAndUp(context),
    );
  }
}
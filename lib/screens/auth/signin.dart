import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../services/database.dart';
import '../../services/auth.dart';
//import '../../shared/loading.dart';
import '../../services/helper/helperFunctions.dart';

class SignIn extends StatefulWidget {
  Function toSignUp;
  SignIn({this.toSignUp}); // Use ({}) when there is a statefull widget

  @override
  createState() => SignInState();
}

class SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  final DatabaseService databaseService = DatabaseService();
  QuerySnapshot snapshotUserInfo;

  // text field state
  String email = '';
  String password = '';
  String error = '';

  bool isError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        title: Text(
          'Log In',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 22,
            fontWeight: FontWeight.w800
          ),
        ),
        elevation: 0.0,
        actions: [
          FlatButton(
            child: Text('SIGN UP'),
            onPressed: () {
              widget.toSignUp();
            })
        ],
      ),
      body: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Form(
              key: _formKey,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                      decoration: InputDecoration(
                        //contentPadding: EdgeInsets.symmetric(horizontal: 5),
                        //isDense: true,
                        border: InputBorder.none,
                        //counter: SizedBox.shrink(),
                        //counterText: '',
                        hintText: 'Email',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 22,
                          //height: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      onChanged: (val) {
                        setState(() => email = val);
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                      decoration: InputDecoration(
                        //contentPadding: EdgeInsets.symmetric(horizontal: 5),
                        //isDense: true,
                        border: InputBorder.none,
                        //counter: SizedBox.shrink(),
                        //counterText: '',
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 22,
                          //height: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      obscureText: true,
                      onChanged: (val) {
                        setState(() => password = val);
                      },
                    ),
                    SizedBox(height: 12.0),
                    InkWell(
                      onTap: () async {
                        try {
                          //if (_formKey.currentState.validate()) {
                            //validate validates the form (true or false)
                            setState(() {
                              loading = true;
                              isError = false;
                            });
                            HelperFunctions.saveUserEmailSharedPreference(email);
                            databaseService.getUserByUserEmail(email).then((val) {
                              if (val.docs.isNotEmpty) {
                                snapshotUserInfo = val;
                                HelperFunctions.saveUserNameSharedPreference(
                                  snapshotUserInfo.docs[0].data()['name']
                                );
                              }
                            });

                            dynamic result = await _auth.signInWithEmailAndPassword(
                              email, password
                            );

                            if (result == null) {
                              setState(() {
                                isError = true;
                                error = 'user not found';
                                loading = false;
                              });
                            }
                          //}
                        } catch(err) {
                          setState(() {
                            isError = true;
                            error = 'user not found';
                            loading = false;
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.tealAccent[400],
                          borderRadius: BorderRadius.circular(100)
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        child: loading ? CupertinoActivityIndicator(
                          radius: 12
                        ) : Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 18,
                            fontWeight: FontWeight.w700
                          ),
                        ),
                      )
                    ),
                    SizedBox(height: 12.0),
                    if (isError)
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 15),
                    )
                  ]))),
    );
  }
}
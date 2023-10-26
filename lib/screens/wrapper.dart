import 'package:flutter/material.dart';
import 'package:untitled_startup/screens/home/home2.dart';
import 'auth/authenticate.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/helper/helperFunctions.dart';

class Wrapper extends StatefulWidget {
  @override
  WrapperState createState() => WrapperState();
}

class WrapperState extends State<Wrapper> {
  bool userIsLoggedIn;

  @override
  void initState() {
    getLoggedInState();
    super.initState();
  }

  getLoggedInState() async {
    await HelperFunctions.getUserLoggedinSharedPreference().then((value) {
      //print(value);
      setState(() {
        userIsLoggedIn = value;
      });
    });
  }

  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    //print('the user is $user');
    // return either home or auth
    //return userIsLoggedIn != null ? Home() : Authenticate();
    if (user == null) {
      return Authenticate();
    } else {
      //print(MediaQuery.of(context).size.width);
      return Home2(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height,
        statusBar: MediaQuery.of(context).padding.top, 
      );
      /*Home(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height,
        statusBar: MediaQuery.of(context).padding.top, 
      );*/
    }
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled_startup/models/user.dart';
import 'package:untitled_startup/screens/home/settings/editProfile.dart';
import 'package:untitled_startup/services/auth.dart';

class Settings extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  final Function popPopOver;
  Settings({this.userInfo, this.popPopOver});
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: AppBar(
          shadowColor: Colors.black.withOpacity(0.4),
          automaticallyImplyLeading: false,
          elevation: 7.0,
          backgroundColor: Colors.grey[50],
          leading: Transform.scale(
            scale: 2,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.keyboard_arrow_left_rounded, color: Colors.grey[800])
            ),
          ),
          title: Container(
            child: Text(
              'Settings',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 22,
                fontWeight: FontWeight.w700
              )
            )
          ),
        ),
      ),
      body: Container(
        //padding: EdgeInsets.only(top: 20),
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => EditProfile(
                      userInfo: widget.userInfo,
                    )
                  )
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  //color: Colors.red,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[350], )
                  )
                ),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 18,
                            fontWeight: FontWeight.w700
                          )
                        )
                      ),
                      Container(
                        child: Transform.scale(
                          scale: 1.4,
                          child: Icon(
                            Icons.keyboard_arrow_right_rounded,
                            //size: 32,
                            color: Colors.grey[500],
                          ),
                        )
                      )
                    ],
                  )
                )
              ),
            ),
            InkWell(
              onTap: () async {
                //Navigator.of(context).pop();
                await _auth.logOut().then((_) {
                  Navigator.of(context).pop();
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.red[100].withOpacity(0.22),
                  border: Border(
                    bottom: BorderSide(color: Colors.red.withOpacity(0.6), )
                  )
                ),
                child: Container(
                  child: Container(
                    child: Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.w700
                      )
                    )
                  )
                )
              ),
            )
          ],
        )
      )
    );
  }
}
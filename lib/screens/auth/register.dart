import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled_startup/models/user.dart';
import '../../services/helper/helperFunctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth.dart';
//import '../../shared/loading.dart';
import '../../services/database.dart';

class Register extends StatefulWidget {
  // when passing props to other stateful widget files pass it to the state full widget
  final Function toSignIn;

  Register({this.toSignIn});
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final DatabaseService databaseService = DatabaseService();
  final HelperFunctions helperFunctions = HelperFunctions();

  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  QuerySnapshot snapshotUserInfo;

  String username = '';
  String name = '';
  String email = '';
  String password = '';
  String error = '';

  bool wierdError = false;

  void registerUserPreferences(myUid) {
  //void registerUserPreferences() {
    Map<String, dynamic> theVideogamesMap = {
      'Among_Us': 0,
      'Apex_Legends': 0,
      'Star_Wars_Battlefront_II': 0,
      'COD_Cold_War': 0,
      'COD_Modern_Warfare': 0,
      'CSGO': 0,
      'Cyberpunk_2077': 0,
      'Dota_2': 0,
      'FIFA': 0,
      'Fortnite': 0,
      'Grand_Theft_Auto_V': 0,
      'League_of_Legends': 0,
      'Madden_NFL': 0,
      'Minecraft': 0,
      'NBA_2K': 0,
      'Overwatch': 0,
      'Rainbow_Six_Siege': 0,
      'Rocket_League': 0,
      'Rust': 0,
      'VALORANT': 0,
      'COD_Warzone': 0,
      'World_of_Warcraft': 0,
      'None': 0,
      'Other': 0,
      'mostLikedVideogames': [],
    };
    DatabaseService(uid: myUid).createUserPreferences(theVideogamesMap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              backgroundColor: Colors.grey[50],
              title: Text(
                'Sign Up',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 22,
                  fontWeight: FontWeight.w800
                ),
              ),
              elevation: 0.0,
              actions: [
                FlatButton(
                  child: Text('SIGN IN'),
                  onPressed: () {
                    widget.toSignIn(); // use widget. to refer to the stateful widget
                  })
              ],
            ),
            body: Container(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                child: Form(
                    key: _formKey,
                    child: Column(children: <Widget>[
                      SizedBox(height: 20.0),
                      TextFormField(
                        validator: (val) =>
                          val.isEmpty || val.length > 15 ? 'ivalid name' : null,
                        onChanged: (val) {
                          setState(() => name = val);
                        },
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
                          hintText: 'Name',
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 22,
                            //height: 1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        validator: (val) =>
                            val.isEmpty || val.length > 15 ? 'ivalid username' : null,
                        onChanged: (val) {
                          setState(() => username = val);
                        },
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
                          hintText: 'Username',
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 22,
                            //height: 1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      ),
                      SizedBox(height: 12.0),
                      TextFormField(
                        validator: (val) {
                          return RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(val)
                              ? null
                              : "invalid email";
                        },
                        onChanged: (val) {
                          setState(() => email = val);
                        },
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 20,
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
                            fontSize: 20,
                            //height: 1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        validator: (val) => val.length < 6
                            ? 'password must have more than 6 characters'
                            : null,
                        obscureText: true,
                        onChanged: (val) {
                          setState(() => password = val);
                        },
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
                        )
                      ),
                      SizedBox(height: 24.0),
                      InkWell(
                        onTap: () async {
                          try {

                            if (_formKey.currentState.validate()) {
                              //validate validates the form (true or false)
                              setState(() {
                                loading = true;
                                wierdError = false;
                              });
                              dynamic result = await _auth
                                  .registerWithEmailAndPassword(email, password)
                                  .then((user) {
                                List<String> splitList = username.toLowerCase().split(" ");
                                List<String> indexList = [];
                                for (int i = 0; i < splitList.length; i++) {
                                  for (int y = 1;
                                      y < splitList[i].length + 1;
                                      y++) {
                                    indexList.add(splitList[i]
                                        .substring(0, y)
                                        .toLowerCase());
                                  }
                                }
                                print(user);
                                print(user.uid);
                                Map<String, dynamic> userMap = {
                                  "username": username.toLowerCase(),
                                  "email": email,
                                  "uid": user.uid,
                                  "userNameIndex": indexList,
                                  "profileImg": 'https://lifelinemedicalservices.co.uk/wp-content/uploads/2020/06/blank-profile-picture-973460_1280.jpg',
                                  'bannerImg': 'https://i.imgur.com/87sk72V.jpg',
                                  'bio': '',
                                  "name": name,
                                  'privacy': false,
                                  'followersCount': 0,
                                  'followingCount': 0,
                                };
                                print(user.uid);
                                HelperFunctions
                                    .saveUserLoggedinSharedPreference(true);
                                HelperFunctions.saveUserEmailSharedPreference(
                                    email);
                                HelperFunctions.saveUserNameSharedPreference(
                                    name);
                                DatabaseService(uid: user.uid)
                                    .uploadUserInfo(userMap);
                                registerUserPreferences(user.uid);
                              });
                              if (result == null) {
                                //error = 'please suply a valid email';
                                loading = false;
                                wierdError = true;
                                /*setState(() {
                                  error = 'please suply a valid email';
                                  loading = false;
                                });*/
                              }
                            }
                          } catch(err) {
                            setState(() {
                              wierdError = true;
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
                          ) :
                          Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 18,
                              fontWeight: FontWeight.w700
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.0),
                      if (wierdError) 
                        Text(
                          'Something wierd happen, try changing inputs value',
                          style: TextStyle(color: Colors.red, fontSize: 15),
                        ),
                    ]))),
          );
  }
}
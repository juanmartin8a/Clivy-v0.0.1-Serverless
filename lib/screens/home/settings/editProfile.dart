import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:untitled_startup/models/user.dart';
import 'package:untitled_startup/screens/home/main/classes/mapsClass.dart';
import 'package:untitled_startup/screens/home/settings/editProfileTF.dart';
import 'package:untitled_startup/services/database.dart';

class EditProfile extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  EditProfile({this.userInfo});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> with SingleTickerProviderStateMixin{
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(bucket: 'gs://untitledstartup-3e326.appspot.com');
  UploadTask _uploadTaskProfileImg;
  TaskSnapshot _taskSnapshotProfileImg;
  UploadTask _uploadTaskBannerImg;
  TaskSnapshot _taskSnapshotBannerImg;
  TabController tabController;
  TextEditingController nameController;
  TextEditingController usernameController;
  TextEditingController bioController;
  bool isLoading = false;
  bool isUploading = false;
  bool hasUploaded = false;
  File imageFile;
  File bannerFile;
  int currentTabIndex = 0;

  void pickProfileImg() async {
    FilePickerResult pickedFile = await FilePicker.platform.pickFiles(type: FileType.image);
    setState(() {
      if (pickedFile != null) {
        imageFile = File(pickedFile.files.first.path);
      } else {
        print('No file selected.');
      }
    });
  }

  void pickBannerImg() async {
    FilePickerResult pickedFileBanner = await FilePicker.platform.pickFiles(type: FileType.image);
    setState(() {
      if (pickedFileBanner != null) {
        bannerFile = File(pickedFileBanner.files.first.path);
      } else {
        print('No file selected.');
      }
    });
  }

  void refresh() {
    setState(() {

    });
  }

  uploadImage(BuildContext context) async {
    final user = Provider.of<CustomUser>(context, listen: false);

    if (imageFile == null && bannerFile != null) {
      isUploading = true;
      String filePathBannerImg = 'users/bannerImg/${user.uid}.jpg';
      _uploadTaskBannerImg =  _storage.ref().child(filePathBannerImg).putFile(File(bannerFile.path));
      _taskSnapshotBannerImg = await _uploadTaskBannerImg;
      final String downloadUrlBannerImg = await _taskSnapshotBannerImg.ref.getDownloadURL();
      //DocumentReference docRef = FirebaseFirestore.instance.collection('posts').doc();
      //List usernameIndex = [];
      List<String> splitList = nameController.text.split(" ");
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
      Map<String, dynamic> theEditMap = {
        'profileImg': widget.userInfo['profileImg'],
        'bannerImg': downloadUrlBannerImg,
        'name': nameController.text,
        'username': usernameController.text,
        'bio': bioController.text,
        'userNameIndex': indexList,
      };
      await DatabaseService(uid: user.uid).editProfile(theEditMap);
      if (mounted) {
        setState(() {
          isUploading = false;
          hasUploaded = true;
          imageFile = null;
          bannerFile = null;
        });
      }

      //setState(() {
        Map<String, dynamic> newMap =  {
        ...MapsClass.users[widget.userInfo['uid']], ...theEditMap
      };
      MapsClass.users[widget.userInfo['uid']] = newMap;

      if (MapsClass.userPosts[widget.userInfo['uid']] != null) {
        if (MapsClass.userPosts[widget.userInfo['uid']]['posts'] != null) {
          MapsClass.userPosts[widget.userInfo['uid']]['posts'].values.toList().forEach((element) {
            Map<String, dynamic> aMap =  {
              ...MapsClass.userPosts[widget.userInfo['uid']]['posts'][element['id']]['userInfo'],
              ...theEditMap
            };
            MapsClass.userPosts[widget.userInfo['uid']]['posts'][element['id']]['userInfo'] = aMap;
          });
        }
      }
      if (MapsClass.posts != null) {
        var postsQuery = MapsClass.posts.values.toList().where((val) => val['postedBy'] == widget.userInfo['uid']).toList();
        if (postsQuery.isNotEmpty) {
          postsQuery.forEach((element) {
            Map<String, dynamic> aMap =  {
              ...MapsClass.posts[element['id']]['userInfo'],
              ...theEditMap
            };
            // MapsClass.posts[element['id']]['userInfo']['bannerImg'] = downloadUrlBannerImg;
            MapsClass.posts[element['id']]['userInfo'] = aMap;
          });
        }
      }
      if (MapsClass.searchedUsers.isNotEmpty) {
        if (MapsClass.searchedUsers[widget.userInfo['uid']] != null) {
          Map<String, dynamic> aMap =  {
            ...MapsClass.searchedUsers[widget.userInfo['uid']], ...theEditMap
          };
          MapsClass.searchedUsers[widget.userInfo['uid']] = aMap;
        }
      }

      Navigator.of(context).pop();

    } else if (imageFile != null && bannerFile == null) {
      isUploading = true;
      String filePathProfileImg = 'users/profileImg/${user.uid}.jpg';
      _uploadTaskProfileImg = _storage.ref().child(filePathProfileImg).putFile(File(imageFile.path));
      _taskSnapshotProfileImg = await _uploadTaskProfileImg;
      final String downloadUrlProfileImg = await _taskSnapshotProfileImg.ref.getDownloadURL();
      List<String> splitList = nameController.text.split(" ");
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
      Map<String, dynamic> theEditMap = {
        'profileImg': downloadUrlProfileImg,
        'bannerImg': widget.userInfo['bannerImg'],
        'name': nameController.text,
        'username': usernameController.text,
        'bio': bioController.text,
        'userNameIndex': indexList,
      };
      await DatabaseService(uid: user.uid).editProfile(theEditMap);
      if (mounted) {
        setState(() {
          isUploading = false;
          hasUploaded = true;
          imageFile = null;
          bannerFile = null;
        });
      }

      Map<String, dynamic> newMap =  {
        ...MapsClass.users[widget.userInfo['uid']], ...theEditMap
      };
      MapsClass.users[widget.userInfo['uid']] = newMap;

      if (MapsClass.userPosts[widget.userInfo['uid']] != null) {
        if (MapsClass.userPosts[widget.userInfo['uid']]['posts'] != null) {
          MapsClass.userPosts[widget.userInfo['uid']]['posts'].values.toList().forEach((element) {
            Map<String, dynamic> aMap =  {
              ...MapsClass.userPosts[widget.userInfo['uid']]['posts'][element['id']]['userInfo'],
              ...theEditMap
            };
            MapsClass.userPosts[widget.userInfo['uid']]['posts'][element['id']]['userInfo'] = aMap;
          });
        }
      }
      if (MapsClass.posts != null) {
        var postsQuery = MapsClass.posts.values.toList().where((val) => val['postedBy'] == widget.userInfo['uid']).toList();
        if (postsQuery.isNotEmpty) {
          postsQuery.forEach((element) {
            Map<String, dynamic> aMap =  {
              ...MapsClass.posts[element['id']]['userInfo'],
              ...theEditMap
            };
            // MapsClass.posts[element['id']]['userInfo']['bannerImg'] = downloadUrlBannerImg;
            MapsClass.posts[element['id']]['userInfo'] = aMap;
          });
        }
      }
      if (MapsClass.searchedUsers.isNotEmpty) {
        if (MapsClass.searchedUsers[widget.userInfo['uid']] != null) {
          Map<String, dynamic> aMap =  {
            ...MapsClass.searchedUsers[widget.userInfo['uid']], ...theEditMap
          };
          MapsClass.searchedUsers[widget.userInfo['uid']] = aMap;
        }
      }
      Navigator.of(context).pop();

    } else if (imageFile == null && bannerFile == null) {
      isUploading = true;
      List<String> splitList = nameController.text.split(" ");
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
      Map<String, dynamic> theEditMap = {
        'name': nameController.text,
        'username': usernameController.text,
        'bio': bioController.text,
        'userNameIndex': indexList,
      };
      await DatabaseService(uid: user.uid).editProfile(theEditMap);
      if (mounted) {
        setState(() {
          isUploading = false;
          hasUploaded = true;
          imageFile = null;
          bannerFile = null;
        });
      }
      Map<String, dynamic> newMap =  {
        ...MapsClass.users[widget.userInfo['uid']], ...theEditMap
      };
      MapsClass.users[widget.userInfo['uid']] = newMap;

      if (MapsClass.userPosts[widget.userInfo['uid']] != null) {
        if (MapsClass.userPosts[widget.userInfo['uid']]['posts'] != null) {
          MapsClass.userPosts[widget.userInfo['uid']]['posts'].values.toList().forEach((element) {
            Map<String, dynamic> aMap =  {
              ...MapsClass.userPosts[widget.userInfo['uid']]['posts'][element['id']]['userInfo'],
              ...theEditMap
            };
            MapsClass.userPosts[widget.userInfo['uid']]['posts'][element['id']]['userInfo'] = aMap;
          });
        }
      }
      if (MapsClass.posts != null) {
        var postsQuery = MapsClass.posts.values.toList().where((val) => val['postedBy'] == widget.userInfo['uid']).toList();
        if (postsQuery.isNotEmpty) {
          postsQuery.forEach((element) {
            Map<String, dynamic> aMap =  {
              ...MapsClass.posts[element['id']]['userInfo'],
              ...theEditMap
            };
            // MapsClass.posts[element['id']]['userInfo']['bannerImg'] = downloadUrlBannerImg;
            MapsClass.posts[element['id']]['userInfo'] = aMap;
          });
        }
      }
      if (MapsClass.searchedUsers.isNotEmpty) {
        if (MapsClass.searchedUsers[widget.userInfo['uid']] != null) {
          Map<String, dynamic> aMap =  {
            ...MapsClass.searchedUsers[widget.userInfo['uid']], ...theEditMap
          };
          MapsClass.searchedUsers[widget.userInfo['uid']] = aMap;
        }
      }

      Navigator.of(context).pop();
    } else if (imageFile != null && bannerFile != null) {
      isUploading = true;
      String filePathProfileImg = 'users/profileImg/${user.uid}.jpg';
      _uploadTaskProfileImg = _storage.ref().child(filePathProfileImg).putFile(File(imageFile.path));
      _taskSnapshotProfileImg = await _uploadTaskProfileImg;
      final String downloadUrlProfileImg = await _taskSnapshotProfileImg.ref.getDownloadURL();

      String filePathBannerImg = 'users/bannerImg/${user.uid}.jpg';
      _uploadTaskBannerImg = _storage.ref().child(filePathBannerImg).putFile(File(bannerFile.path));
      _taskSnapshotBannerImg = await _uploadTaskBannerImg;
      final String downloadUrlBannerImg = await _taskSnapshotBannerImg.ref.getDownloadURL();
      //DocumentReference docRef = FirebaseFirestore.instance.collection('posts').doc();
      List<String> splitList = nameController.text.split(" ");
      List<String> indexList = [];
      //await Future.wait()
      for (int i = 0; i < splitList.length; i++) {
        for (int y = 1;
            y < splitList[i].length + 1;
            y++) {
          indexList.add(splitList[i]
              .substring(0, y)
              .toLowerCase());
        }
      }
      Map<String, dynamic> theEditMap = {
        'profileImg': downloadUrlProfileImg,
        'bannerImg': downloadUrlBannerImg,
        'name': nameController.text,
        'username': usernameController.text,
        'bio': bioController.text,
        'userNameIndex': indexList,
      };
      await DatabaseService(uid: user.uid).editProfile(theEditMap);
      if (mounted) {
        setState(() {
          isUploading = false;
          hasUploaded = true;
          imageFile = null;
          bannerFile = null;
        });
      }

      Map<String, dynamic> newMap =  {
        ...MapsClass.users[widget.userInfo['uid']], ...theEditMap
      };
      MapsClass.users[widget.userInfo['uid']] = newMap;

      if (MapsClass.userPosts[widget.userInfo['uid']] != null) {
        if (MapsClass.userPosts[widget.userInfo['uid']]['posts'] != null) {
          MapsClass.userPosts[widget.userInfo['uid']]['posts'].values.toList().forEach((element) {
            Map<String, dynamic> aMap =  {
              ...MapsClass.userPosts[widget.userInfo['uid']]['posts'][element['id']]['userInfo'],
              ...theEditMap
            };
            MapsClass.userPosts[widget.userInfo['uid']]['posts'][element['id']]['userInfo'] = aMap;
          });
        }
      }
      if (MapsClass.posts != null) {
        var postsQuery = MapsClass.posts.values.toList().where((val) => val['postedBy'] == widget.userInfo['uid']).toList();
        if (postsQuery.isNotEmpty) {
          postsQuery.forEach((element) {
            Map<String, dynamic> aMap =  {
              ...MapsClass.posts[element['id']]['userInfo'],
              ...theEditMap
            };
            // MapsClass.posts[element['id']]['userInfo']['bannerImg'] = downloadUrlBannerImg;
            MapsClass.posts[element['id']]['userInfo'] = aMap;
          });
        }
      }
      if (MapsClass.searchedUsers.isNotEmpty) {
        if (MapsClass.searchedUsers[widget.userInfo['uid']] != null) {
          Map<String, dynamic> aMap =  {
            ...MapsClass.searchedUsers[widget.userInfo['uid']], ...theEditMap
          };
          MapsClass.searchedUsers[widget.userInfo['uid']] = aMap;
        }
      }

      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 2);
    nameController = TextEditingController(text: widget.userInfo['name']);
    usernameController = TextEditingController(text: widget.userInfo['username']);
    bioController = TextEditingController(text: widget.userInfo['bio']);
    tabController.addListener(() {
      setState(() {
        currentTabIndex = tabController.index;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
    nameController.dispose();
    usernameController.dispose();
    bioController.dispose();
  }

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
                'Edit Profile',
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
          //padding: EdgeInsets.symmetric(horizontal: 8),
          child: Stack(
            children: [
              ListView(
                children: [
                  Container(
                    height: 190,
                    margin: EdgeInsets.only(top: 12),
                    //color: Colors.blue,
                    width: MediaQuery.of(context).size.width,
                    child: 
                    TabBarView(
                      controller: tabController,
                      children: [
                        Container(
                          //color: Colors.yellow,
                          padding: EdgeInsets.symmetric(
                            vertical: 35,//MediaQuery.of(context).size.width * (120 / MediaQuery.of(context).size.width), 
                            horizontal: (MediaQuery.of(context).size.width * (1 - ((110 * 1) / MediaQuery.of(context).size.width))) / 2,
                          ),
                          //color: Colors.blue,
                          //decoration: Box,
                          child: GestureDetector(
                            onTap: () {
                              pickProfileImg();
                            },
                            child: CircleAvatar(
                              //radius: 56,
                              backgroundColor: Colors.grey[350],
                              backgroundImage: imageFile == null ? NetworkImage(
                                widget.userInfo['profileImg']
                              ) : FileImage(
                                imageFile
                              )
                            ),
                          )
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.1,
                            vertical: ((MediaQuery.of(context).size.height * 0.1) * 0.85) - 45
                          ),
                          child: GestureDetector(
                            onTap: () {
                              pickBannerImg();
                            },
                            child: Container(
                              //width: MediaQuery.of(context).size.width * 0.8,
                              decoration: bannerFile == null ? 
                              widget.userInfo['bannerImg'] != 'none' ? BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.grey[350],
                                image: DecorationImage(
                                  image: NetworkImage(widget.userInfo['bannerImg']),
                                  fit: BoxFit.cover
                                )
                              ) : BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.grey[350],
                              ) : BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.grey[350],
                                image: DecorationImage(
                                  image: FileImage(bannerFile),
                                  fit: BoxFit.cover
                                )
                              ),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  height: 45 * 0.80,
                                  decoration: BoxDecoration(
                                    color: Colors.white54,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(45 * 0.80),
                                      topRight: Radius.circular(45 * 0.85)
                                    )
                                  ),
                                )
                              )
                            ),
                          ),
                        ),
                      ]
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            color: currentTabIndex == 0 ? Colors.blue : Colors.grey[400],
                            borderRadius: BorderRadius.circular(10)
                          ),
                        ),
                        SizedBox(width: 15),
                        Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            color: currentTabIndex == 1 ? Colors.blue : Colors.grey[400],
                            borderRadius: BorderRadius.circular(10)
                          ),
                        ),
                      ]
                    )
                  ),
                  EditProfileTextFields(
                    nameController: nameController,
                    usernameController: usernameController,
                    bioController: bioController,
                    refresh: refresh,
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromWindowPadding(WidgetsBinding.instance.window.viewInsets,WidgetsBinding.instance.window.devicePixelRatio),
                              child: Align(
                    alignment: Alignment.bottomCenter,
                    child: nameController.text != widget.userInfo['name'] || 
                    usernameController.text != widget.userInfo['username'] || 
                    bioController.text != widget.userInfo['bio'] || 
                    imageFile != null || bannerFile != null ? GestureDetector(
                        onTap: () {
                          if (isUploading != true) {
                            uploadImage(context);
                          } 
                        },
                        child: Container(
                          margin: WidgetsBinding.instance.window.viewInsets.bottom == 0 
                          ? EdgeInsets.only(bottom: 60) : EdgeInsets.only(bottom: 20),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 85),
                            decoration: BoxDecoration(
                              color: Colors.amberAccent[700],
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.4),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 0), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Text(
                              'Done',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 22,
                                fontWeight: FontWeight.w800
                              )
                            ),
                          )
                        ),
                      ) : Container(
                        margin:  WidgetsBinding.instance.window.viewInsets.bottom == 0 
                          ? EdgeInsets.only(bottom: 60) : EdgeInsets.only(bottom: 20),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 85),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.4),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 0), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Text(
                            'Done',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 22,
                              fontWeight: FontWeight.w800
                            )
                          ),
                        )
                      ),
                  ),
              )
            ],
          )
        )
      ),
    );
  }
}
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:untitled_startup/models/user.dart';
import 'package:untitled_startup/screens/home/chat/createChatInfo.dart';
import 'package:untitled_startup/screens/home/chat/inChatScreen.dart';
import 'package:untitled_startup/screens/home/chat/inGCScreen.dart';
import 'package:untitled_startup/screens/home/chat/selectedPeopleGrid.dart';
import 'package:untitled_startup/services/cacheClass/cacheManager.dart';
import 'package:untitled_startup/services/database.dart';

class CreateChat extends StatefulWidget {
  final double statusBar;
  final Map<String, dynamic> myInfo;
  CreateChat({this.statusBar, this.myInfo});
  @override
  _CreateChatState createState() => _CreateChatState();
}

class _CreateChatState extends State<CreateChat> {
  List selectedUser= [];
  List<DocumentSnapshot> selectedUserInfo = [];
  String groupName = '';
  File groupImg;

  final FirebaseStorage _storage = FirebaseStorage.instanceFor(bucket: 'gs://untitledstartup-3e326.appspot.com');
  UploadTask _uploadTask;
  TaskSnapshot _taskSnapshot;

  Map<String, DocumentSnapshot> selectedUserInfoMap = {};
  Map<String, dynamic> selectedUserMap = {};

  TextEditingController _searchController = TextEditingController();
  String searchString = '';
  int prevPost;
  DocumentSnapshot lastDocument;
  bool gettingMorePosts = false;
  bool morePostsAvailable = true;
  List<DocumentSnapshot> searchItems = [];


  // query all users ordered by friends and popularity
  getSearchItems() async {
    if (searchString.length <= 0) {
      setState(() {
        searchItems = [];
      });
      return;
    }
    Query theQuery = FirebaseFirestore.instance.collection('users')
    .where('userNameIndex', arrayContains: searchString).limit(30);
    setState(() {});
    QuerySnapshot querySnapshot = await theQuery.get();
    //print('length is ${querySnapshot.docs.length}');
    searchItems = [];
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      if (searchItems.isNotEmpty) {
        searchItems.add(querySnapshot.docs[i]);
      } else {
        searchItems.add(querySnapshot.docs[i]);
      }
    }
    //thePosts = querySnapshot.docs;
    if (querySnapshot.docs.isEmpty) {
      return ;
    }
    lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    setState(() {});
  }

  groupNameFunc(String groupname) {
    setState(() {
      groupName = groupname;
    });
  }

  groupImgFunc(File groupimg) {
    setState(() {
      groupImg = groupimg;
    });
  }


  //String groupChatId = '';
  //bool chatExists;
  //bool 
  checkIfChatExists(myUid, userUid) async {
    String groupChatId = '';
    bool chatExists;
    if (myUid.substring(0, 1).codeUnitAt(0) > userUid.substring(0, 1).codeUnitAt(0)) {
        groupChatId = '$myUid-$userUid';
    } else {
        groupChatId = '$userUid-$myUid';
    }
    QuerySnapshot theQuery = await FirebaseFirestore.instance.collection('chatRooms')
    .where('id', isEqualTo: groupChatId).get();
    if (theQuery.docs.isNotEmpty) {
      setState(() {   
        chatExists = true;
        //hasChatExistsLoaded = true;
      });
    } else {
      setState(() {   
        chatExists = false;
        //hasChatExistsLoaded = true;
      });
    }
    return [chatExists, groupChatId];
  }

  createGroupChat(myUid) async {
    if (selectedUserMap.length > 1 && selectedUserInfoMap.length > 1) {
      if (groupName != '' || groupImg != null) {
        List toUploadMap = selectedUserMap.values.toList();
        toUploadMap.add(myUid);
        QuerySnapshot theGroupInfo = await FirebaseFirestore.instance
          .collection('chatRooms').where('usersInChat', isEqualTo: toUploadMap)
          .get();
        List chatNameList = [];
        List<String> splitList = groupName.split(" ");
        Map usersInChatMap = {};
        for (int i = 0; i < toUploadMap.length; i++) {
          usersInChatMap[toUploadMap[i]] = toUploadMap[i];
        }
        //List<String> indexList = [];
        for (int j = 0; j < splitList.length; j++) {
          for (int y = 1; y < splitList[j].length + 1; y++) {
            chatNameList.add(splitList[j]
              .substring(0, y)
              .toLowerCase());
          }
        }
        if (theGroupInfo.docs.length <= 0) {
          DocumentReference docRef = FirebaseFirestore.instance.collection('chatRooms').doc();
          String filePath = 'groupImgs/${docRef.id}.jpg';
          _uploadTask = _storage.ref().child(filePath).putFile(File(groupImg.path));
          _taskSnapshot = await _uploadTask;
          final String downloadUrl = await _taskSnapshot.ref.getDownloadURL();
          Map<String, dynamic> groupMap = {
            'id': docRef.id,
            'usersInChat': toUploadMap,
            'usersInChatMap': usersInChatMap,
            'LMTimeReal': DateTime.now(),
            'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
            'type': 'group',
            'lastMessage': '',
            'groupImg': downloadUrl,
            'groupPeople': selectedUserMap.length,
            'groupName': groupName,
            'host': myUid,
            'chatName': chatNameList
          };
          print(myUid);
          print(groupMap);
          DatabaseService().createGroupChat(groupMap, docRef);
          DocumentSnapshot theGroupInfo = await FirebaseFirestore.instance
          .collection('chatRooms').doc(docRef.id).get() ;
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => InGroupChat(
              chatRoomId: docRef.id,
              groupInfo: theGroupInfo.data(),
            ))
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => InGroupChat(
              chatRoomId: theGroupInfo.docs[0].data()['id'],
              groupInfo: theGroupInfo.docs[0].data(),
            ))
          );
        }
      }
    } else if (selectedUserMap.length == 1 && selectedUserInfoMap.length == 1) {
      checkIfChatExists(myUid, selectedUserInfoMap.values.toList()[0].data()['uid']).then((value) {
        if (value[0] == true) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => InChat(
              userInfo: selectedUserInfoMap.values.toList()[0].data(),
              chatRoomId: value[1],
              chatExists: true,
              myInfo: widget.myInfo,
            ))
          );
        } else if (value[0] == false) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => InChat(
              userInfo: selectedUserInfoMap.values.toList()[0].data(),
              chatExists: false,
              myInfo: widget.myInfo,
            ))
          );
        }
      });
    }
  }

  void removeSelectedItem(String theSelectedUid) {
    setState(() {
      selectedUserMap.remove(theSelectedUid); 
      selectedUserInfoMap.remove(theSelectedUid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(56 + widget.statusBar),
          child: Container(
            padding: EdgeInsets.only(top: widget.statusBar),
            child: AppBar(
              automaticallyImplyLeading: false,
              leading: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Transform.scale(
                  scale: 2,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey[800]
                  )
                ),
              ),
              title: Container(
                child: Text(
                  'New Chat',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 21,
                    fontWeight: FontWeight.w800
                  )
                )
              ),
              elevation: 0.0,
              backgroundColor: Colors.grey[50],
              actions: [
                GestureDetector(
                  onTap: () {
                    createGroupChat(user.uid);
                  },
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Chat',
                        style: TextStyle(
                          color: selectedUserMap.length > 0 ?  Colors.blue : Colors.blueGrey,
                          fontSize: 17,
                          fontWeight: FontWeight.w700
                        )
                      )
                    ),
                  )
                )
              ]
            ),
          ),
        ),
        body: Container(
          color: Colors.grey[50],
          child: Column(
            children: [
              CreateChatInfo(
                hasSelectedItems: selectedUserMap.length > 1,
                groupName: groupNameFunc,
                groupImg: groupImgFunc,
              ),
              SelectedPeopleGrid(
                selectedUsers: selectedUserInfoMap.values.toList(),
                hasSelectedItems: selectedUserMap.length > 0,
                removeSelectedItem: removeSelectedItem
              ),
              Container(
                //height: 55,
                //color: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.grey[350],
                    borderRadius: BorderRadius.circular(42)
                  ),
                  child: Row(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.search_rounded,
                            color: Colors.grey[800],
                            size: 28
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.all(2.5),
                          //height:
                          /*decoration: BoxDecoration(
                            color: Colors.grey[350],
                            borderRadius: BorderRadius.circular(40)
                          ),*/
                          child: TextField(
                            keyboardType: TextInputType.text,
                            controller: _searchController,
                            autocorrect: false,
                            onChanged: (values) {
                              setState(() {
                                //refreshSearch(values);
                                searchString = values.toLowerCase();
                              });
                              getSearchItems();
                              _searchController.selection = TextSelection.fromPosition(
                                TextPosition(
                                  offset: _searchController.text.length
                                )
                              );
                            },
                            //cursorHeight: 22,
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 18,
                              height: 1.25,
                              fontWeight: FontWeight.w700,
                            ),
                            //scrollPadding: EdgeInsets.symmetric(vertical: 0),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 5),
                              isDense: true,
                              border: InputBorder.none,
                              //counter: SizedBox.shrink(),
                              //counterText: '',
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 18,
                                height: 1.25,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        )
                      )
                    ],
                  )
                ),
              ),
              Expanded(
                child: Container(
                  child: ListView.builder(
                    itemCount: searchItems.length,
                    itemBuilder: (context, index) {
                      return Container(
                        color: Colors.grey[50],
                        child: GestureDetector(
                          onTap: () {
                            if (selectedUserMap.keys
                            .contains(searchItems[index].data()['uid'])) {
                              setState(() {
                                selectedUserMap.remove(searchItems[index].data()['uid']); 
                                selectedUserInfoMap.remove(searchItems[index].data()['uid']);
                              });
                            } else {
                              setState(() {
                                selectedUserMap[searchItems[index].data()['uid']] = searchItems[index].data()['uid'];
                                selectedUserInfoMap[searchItems[index].data()['uid']] = searchItems[index];
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            color: Colors.grey[50],
                            child: Row(
                              children: [
                                Container(
                                  height: 52,
                                  width: 52,
                                  decoration: BoxDecoration(
                                    //borderRadius: BorderRadius.circular(62),
                                    shape: BoxShape.circle,
                                    color: Colors.grey[350],
                                    /*image: DecorationImage(
                                      image: NetworkImage(
                                        searchItems[index].data()['profileImg']
                                      ),
                                      fit: BoxFit.cover
                                    )*/
                                  ),
                                  child: CachedNetworkImage(
                                    fadeInDuration: Duration(milliseconds: 20),
                                    fadeOutDuration: Duration(milliseconds: 20),
                                    placeholder: (context, url) => Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[350],
                                        shape: BoxShape.circle
                                      )
                                    ),
                                    imageUrl: searchItems[index].data()['profileImg'],
                                    fit: BoxFit.cover,
                                    cacheManager: CustomCacheManager.instance,
                                    imageBuilder: (context, imageProvider) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[350],
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover
                                          )
                                        )
                                      );
                                    }
                                  )
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 6),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Text(
                                          searchItems[index].data()['name'],
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700
                                          )
                                        )
                                      ),
                                      Container(
                                        child: Text(
                                          searchItems[index].data()['username'],
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            height: 1
                                          )
                                        )
                                      ),
                                    ],
                                  )
                                ),
                                const Spacer(),
                                Container(
                                  //margin: EdgeInsets.only(right: 12),
                                  width: 27,
                                  height: 27,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: !selectedUserMap.keys.contains(searchItems[index].data()['uid']) ? Colors.grey[400] : Colors.blue, 
                                      width: 2,
                                    ),
                                    color: !selectedUserMap.keys.contains(searchItems[index].data()['uid']) ? Colors.grey[50] : Colors.blue,
                                  ),
                                  child: !selectedUserMap.keys.contains(searchItems[index].data()['uid']) ? Container() : Icon(
                                    Icons.check_rounded, 
                                    color: Colors.white, 
                                    size: 22
                                  )
                                )
                              ]
                            )
                          )
                        ),
                      );
                    },
                  )
                ),
              )     
            ],
          )
        )
      ),
    );
  }
}
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled_startup/models/user.dart';
import 'package:untitled_startup/screens/home/chat/chatTile.dart';
import 'package:untitled_startup/screens/home/chat/createChats.dart';
import 'package:untitled_startup/screens/home/classes/bubble_indicator.dart';
import 'package:untitled_startup/screens/home/main/classes/mapsClass.dart';
import 'package:untitled_startup/services/database.dart';
import 'package:untitled_startup/screens/home/classes/bubble_indicator.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class Chat extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  //final Map<String, dynamic> myInfo;
  Chat({this.userInfo, @required Key key}) : super(key: key);
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> with SingleTickerProviderStateMixin {
  TabController tabController;
  int tabIndex = 0;

  //List<DocumentSnapshot> searchItems = [];
  String searchString = '';
  TextEditingController _searchChatsController = TextEditingController();

  ScrollController scrollControllerChatRooms = ScrollController();
  DocumentSnapshot lastDocument;
  bool gettingMoreChats = false;
  bool moreChatsAvailable = true;

  bool initialLoadLoaded = false;

  DocumentSnapshot lastDocumentOther;
  bool gettingMoreChatsOther = false;
  bool moreChatsAvailableOther = true;


  getGroupChatInfo(chatId, isSearchChats, isOtherChats, usersInChat) async {
    Map emptyMap = {};
    if (isSearchChats == false) {
      // if (isOtherChats) {
      //   if (mounted) {
      //     setState(() {
      //       MapsClass.chats[chatId]['usersInfo'] = emptyMap;
      //     });
      //   }
      // } else if (!isOtherChats) {
      //   if (mounted) {
      //     setState(() {
      //       MapsClass.chats[chatId]['usersInfo'] = emptyMap;
      //     });
      //   }
      // }
      await getGroupChatUsers(chatId, isSearchChats, usersInChat).then((val) {
        emptyMap['usersInfo'] = val;
      });
      return emptyMap;
    } else if (isSearchChats == true) {
      // if (mounted) {
      //   setState(() {
      //     MapsClass.searchedChats[chatId]['usersInfo'] = emptyMap;
      //   });
      // }
      await getGroupChatUsers(chatId, isSearchChats, usersInChat).then((val) {
        emptyMap['usersInfo'] = val;
      });
      return emptyMap;
    }
  }

  // getChatInfo(isGroup, chatId, isSearchChats, isOtherChats) async {
  //   final user = Provider.of<CustomUser>(context, listen: false);
  //       if (isSearchChats == false) {
  //         if (isOtherChats) {
  //           String userToGetInfoFrom = MapsClass.otherChats[chatId]['usersInChat'][0] == user.uid 
  //             ? MapsClass.otherChats[chatId]['usersInChat'][1]
  //             : MapsClass.otherChats[chatId]['usersInChat'][0];
  //           await DatabaseService(uid: userToGetInfoFrom).getUserByUidFuture().then((val) async {
  //             setState(() {
  //               MapsClass.otherChats[chatId]['userInfo'] = val.data();
  //             });
  //           });
  //         } else if (!isOtherChats) {
  //           String userToGetInfoFrom = MapsClass.chats[chatId]['usersInChat'][0] == user.uid 
  //             ? MapsClass.chats[chatId]['usersInChat'][1]
  //             : MapsClass.chats[chatId]['usersInChat'][0];
  //           await DatabaseService(uid: userToGetInfoFrom).getUserByUidFuture().then((val) async {
  //             setState(() {
  //               MapsClass.chats[chatId]['userInfo'] = val.data();
  //             });
  //           });
  //         }
  //       } else if (isSearchChats == true) {
  //         String userToGetInfoFrom = MapsClass.searchedChats[chatId]['usersInChat'][0] == user.uid 
  //           ? MapsClass.searchedChats[chatId]['usersInChat'][1] 
  //           : MapsClass.searchedChats[chatId]['usersInChat'][0];
  //         await DatabaseService(uid: userToGetInfoFrom).getUserByUidFuture().then((val) async {
  //           setState(() {
  //             MapsClass.searchedChats[chatId]['userInfo'] = val.data();
  //           });
  //         });
  //       }
  //     //}
  // }

  // getFollowingState(userUid, isSearch, myUid, chatId) async {
  //   if (isSearch == false) {
  //     // print('####### START ########');
  //     // print(MapsClass.chats[chatId]['usersInfo'][userUid]['isUserFollowing']);
  //     bool isFollowing;
  //     await DatabaseService(
  //       uid: myUid
  //     ).isFollowingUser(userUid).then((value) {
  //       if (mounted) {
  //         bool val = value;
  //         //setState(() {
  //         MapsClass.chats[chatId]['usersInfo'][userUid]['isUserFollowing'] = val;
  //         setState(() {});
  //       }
  //     });
  //     // print(MapsClass.chats[chatId]['usersInfo'][userUid]['isUserFollowing']);
  //     // print('####### END ########');
  //     return MapsClass.chats[chatId]['usersInfo'][userUid]['isUserFollowing'];
  //   } else if (isSearch == true) {
  //     await DatabaseService(
  //       uid: myUid
  //     ).isFollowingUser(userUid).then((value) {
  //       if (mounted) {
  //         setState(() {
  //           bool val = value;
  //           MapsClass.searchedChats[chatId]['usersInfo'][userUid]['isUserFollowing'] = val;
  //         });
  //       }
  //     });
  //     return MapsClass.searchedChats[chatId]['usersInfo'][userUid]['isUserFollowing'];
  //   }
  // }



  getGroupChatUsers(chatId, isSearch, usersInChat) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    if (isSearch == false) {
      Map userInfo = {};
      Query theQuery = FirebaseFirestore.instance.collection('users')
      .where('uid', whereIn: usersInChat);
      if (mounted) {
        setState(() {});
      }
      QuerySnapshot querySnapshot = await theQuery.get();
      if (querySnapshot.docs.isNotEmpty) {
        await Future.wait(querySnapshot.docs.map((doc) async {
          //MapsClass.chats[chatId]['usersInfo'][doc.data()['uid']] = doc.data();
          userInfo[doc.data()['uid']] = doc.data();
          //await getFollowingState(doc.data()['uid'], isSearch, user.uid, chatId);
        }));
      }
      return userInfo;
    } else if (isSearch == true) {
      Map userInfo = {};
      Query theQuery = FirebaseFirestore.instance.collection('users')
      .where('uid', whereIn: usersInChat);
      if (mounted) {
        setState(() {});
      }
      QuerySnapshot querySnapshot = await theQuery.get();
      if (querySnapshot.docs.isNotEmpty) {
        await Future.wait(querySnapshot.docs.map((doc) async {
          //MapsClass.searchedChats[chatId]['usersInfo'][doc.data()['uid']] = doc.data();
          userInfo[doc.data()['uid']] = doc.data();
          //await getFollowingState(doc.data()['uid'], isSearch, user.uid, chatId);
        }));
      }
      return userInfo;
    }
    if (mounted) {
      setState(() {});
    }
  }

  getUserData(isgroup, usersInChat, myUid) async {
    if (isgroup == false) {
      Map userData = {};
      String userToGetInfoFrom = usersInChat[0] == myUid
        ? usersInChat[1]
        : usersInChat[0];
      await DatabaseService(uid: userToGetInfoFrom).getUserByUidFuture().then((val) async {
        if (mounted) {
          setState(() {
            userData = val.data();
          });
        }
      });
      return userData;
    }
  }

  getSearchItems() async {
    if (searchString.length <= 0) {
      if (mounted) {
        setState(() {
          MapsClass.searchedChats = {};
        });
      }
      return;
    }
    final user = Provider.of<CustomUser>(context, listen: false);
    //List forArrayContains = [user.uid];
    Query theQuery = FirebaseFirestore.instance.collection('chatRooms')
    .where('usersInChatMap.${user.uid}', isEqualTo: user.uid)
    .where('chatName', arrayContains: searchString)
    .limit(30);
    if (mounted) {
      setState(() {});
    }
    QuerySnapshot querySnapshot = await theQuery.get();
    MapsClass.searchedChats = {};
    //querySnapshot.listen((event) async {
    if (querySnapshot.docs.isEmpty) {
      return ;
    }
    if (querySnapshot.docs.isNotEmpty) {
      MapsClass.searchedChats = {};
      Map theMap = {};
      await Future.wait(querySnapshot.docs.map((doc) async {
        Map aMap = {};
        aMap[doc.data()['id']] = doc.data();
        aMap[doc.data()['id']]['userInfo'] = {};
        theMap[doc.data()['id']] = aMap[doc.data()['id']];

        if (doc.data()['type'] != 'group') {
          await getUserData(doc.data()['type'] == 'group', doc.data()['usersInChat'], user.uid).then((val) {
            theMap[doc.data()['id']]['userInfo'] = val;
          });
        }

        if (doc.data()['type'] == 'group') {
          await getGroupChatInfo(doc.data()['id'], true, doc.data()['isMain'] == false, doc.data()['usersInChat']).then((val) {
            theMap[doc.data()['id']]['usersInfo'] = val['usersInfo'];
          });
        }
        //MapsClass.searchedChats = {...aMap,  ...MapsClass.searchedChats};
      }));
      MapsClass.searchedChats = {...MapsClass.searchedChats, ...theMap};
    }
    if (mounted) {
      setState(() {});
    }
  }


  getChats() async {
    if (mounted) {
      setState(() => gettingMoreChats = true);
    }
    final user = Provider.of<CustomUser>(context, listen: false);
    Query theQuery = FirebaseFirestore.instance.collection('chatRooms')
    .where('usersInChat', arrayContains: user.uid)
    //.where(FieldPath(['isMain' , '${user.uid}']), isEqualTo: true)
    .orderBy('lastMessageTime', descending: true)
    .limit(25);
    if (mounted) {
      setState(() {});
    }
    Stream<QuerySnapshot> querySnapshot = theQuery.snapshots();
    querySnapshot.listen((event) async {
      if (event.docs.isNotEmpty) {
        Map theMap = {};
        await Future.wait(event.docs.map((doc) async {
          Map aMap = {};
          aMap[doc.data()['id']] = doc.data();
          //aMap[doc.data()['id']]['theChatImg'] = {};

          theMap[doc.data()['id']] = aMap[doc.data()['id']];

          if (doc.data()['type'] != 'group') {
            await getUserData(doc.data()['type'] == 'group', doc.data()['usersInChat'], user.uid).then((val) {
              theMap[doc.data()['id']]['userInfo'] = val;
            });
          }

          if (doc.data()['type'] == 'group') {
            await getGroupChatInfo(doc.data()['id'], false, doc.data()['isMain'] == false, doc.data()['usersInChat']).then((val) {
              theMap[doc.data()['id']]['usersInfo'] = val['usersInfo'];
            });
          }
          //MapsClass.chats[doc.data()['id']] = aMap[doc.data()['id']];
          //setState(() {});
        }));
        for (var key in theMap.keys.toList()) {
          if (MapsClass.chats.keys.toList().contains(key)) {
            var value = theMap[key];
            MapsClass.chats.remove(key);
            MapsClass.chats[key] = value;
          } else {
            MapsClass.chats = {...MapsClass.chats, ...theMap};
          }
        }
        if (mounted) {
          setState(() {});
        }
        lastDocument = event.docs[event.docs.length - 1];
      } else {
        moreChatsAvailable = false;
      }
    });
    if (mounted) {
      setState(() => gettingMoreChats = false);
    }
  }

  getMoreChats() async {
    if (moreChatsAvailable == false) {
      return;
    }
    if (gettingMoreChats == true) {
      return;
    }
    final user = Provider.of<CustomUser>(context, listen: false);
    if (mounted) {
      setState(() => gettingMoreChats = true);
    }
    Query theQuery = FirebaseFirestore.instance.collection('chatRooms')
    .where('usersInChat', arrayContains: user.uid)
    //.where('isMain.${user.uid}', isEqualTo: true)
    //.where(FieldPath(['isMain' , '${user.uid}']), isEqualTo: true)
    .orderBy('lastMessageTime', descending: true)
    .startAfterDocument(lastDocument).limit(25);
    Stream<QuerySnapshot> querySnapshot = theQuery.snapshots();
    querySnapshot.listen((event) async {
      if (event.docs.isNotEmpty) {
        Map theMap = {};
        await Future.wait(event.docs.map((doc) async {
          Map aMap = {};
          aMap[doc.data()['id']] = doc.data();
          aMap[doc.data()['id']]['userInfo'] = {};

          theMap[doc.data()['id']] = aMap[doc.data()['id']];

          if (doc.data()['type'] != 'group') {
            await getUserData(doc.data()['type'] == 'group', doc.data()['usersInChat'], user.uid).then((val) {
              theMap[doc.data()['id']]['userInfo'] = val;
            });
          }

          if (doc.data()['type'] == 'group') {
            await getGroupChatInfo(doc.data()['id'], false, doc.data()['isMain'] == false, doc.data()['usersInChat']).then((val) {
              theMap[doc.data()['id']]['usersInfo'] = val['usersInfo'];
            });
          }
          //MapsClass.chats[doc.data()['id']] = aMap[doc.data()['id']];

          //MapsClass.chats = {...aMap,  ...MapsClass.chats};
          //await getChatInfo(doc.data()['type'] == 'group', doc.data()['id'], false);
        }));
        //MapsClass.chats = {...MapsClass.chats, ...theMap};
        for (var key in theMap.keys.toList()) {
          if (MapsClass.chats.keys.toList().contains(key)) {
            var value = theMap[key];
            MapsClass.chats.remove(key);
            MapsClass.chats[key] = value;
          } else {
            MapsClass.chats = {...MapsClass.chats, ...theMap};
          }
        }
        if (mounted) {
          setState(() {});
        }
        lastDocument = event.docs[event.docs.length - 1];
      } else {
        moreChatsAvailable = false;
      }
    });
    if (mounted) {
      setState(() => gettingMoreChats = false);
    }
  }

  createChatBottomSheet() {
    double statusBar = MediaQuery.of(context).padding.top;
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      //backgroundColor: Colors.black,
      barrierColor: Colors.black38,
      builder: (context) {
        return CreateChat(
          statusBar: statusBar,
          myInfo: widget.userInfo,
        );
      }
    );
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  callGetChats() async {
    await getChats();
    setState(() {
      initialLoadLoaded = true;
    });
  }

  chatSettings(BuildContext context, int index) {
    showModalBottomSheet(
      context: context, 
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black26,
      builder: (context) {
        return Wrap(
          children: [
            Container(
              margin: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).padding.bottom
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey[50],
              ),
              //height: 200,
              child: Container(
                //padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        //deleteComment(index);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[350])
                          ),
                          //color: Colors.blue,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Text(
                            'Change To Main',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 20,
                              fontWeight: FontWeight.w500
                            )
                          )
                        )
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        //deleteComment(index);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[350])
                          ),
                          //color: Colors.blue,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Text(
                            'Chat',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 20,
                              fontWeight: FontWeight.w500
                            )
                          )
                        )
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 19,
                              fontWeight: FontWeight.w600
                            )
                          )
                        )
                      ),
                    )
                  ],
                )
              ),
            ),

          ],
        );
      }
    );
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 2, initialIndex: 0);
    // tabController.addListener(() {
    //   setState(() {
    //     tabIndex = tabController.index;
    //   });
    // });
    getChats();
    //getChatsOther();
    scrollControllerChatRooms.addListener(() {
      double maxScroll = scrollControllerChatRooms.position.maxScrollExtent;
      double currentScroll = scrollControllerChatRooms.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if (maxScroll - currentScroll < delta) {
        //if (tabIndex == 0) {
        getMoreChats();
        // } else if (tabIndex == 1) {
        //   getMoreChatsOther();
        // }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
    scrollControllerChatRooms.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 1 / 1.05,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 56
              ),
              // height: MediaQuery.of(context).size.height 
              // - (MediaQuery.of(context).padding.top + 45 + 55),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30)
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: Offset(0, -2), // changes position of shadow
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30)
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                  ),
                  //padding: EdgeInsets.symmetric(horizontal: 12),
                  child: CustomScrollView(
                    controller:  scrollControllerChatRooms,
                    //shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    //primary: true,
                    slivers: [
                      SliverToBoxAdapter(
                          child: Container(
                            child: Row(
                              //mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Container(
                                    height: 38,
                                    margin: EdgeInsets.only(
                                      top: 12,
                                      bottom: 6,
                                      left: 12,
                                      //right: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[350],
                                      borderRadius: BorderRadius.circular(76)
                                    ),
                                    child: Row(
                                      //mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
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
                                          child: TextField(
                                            keyboardType: TextInputType.text,
                                            controller: _searchChatsController,
                                            autocorrect: false,
                                            onChanged: (values) {
                                              setState(() {
                                                //refreshSearch(values);
                                                searchString = values.toLowerCase();
                                              });
                                              getSearchItems();
                                              _searchChatsController.selection = TextSelection.fromPosition(
                                                TextPosition(
                                                  offset: _searchChatsController.text.length
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
                                          ),
                                        ),
                                      ],
                                    )
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: InkWell(
                                    onTap: () {
                                      createChatBottomSheet();
                                    },
                                    child: Container(
                                      height: 38,
                                      //color: Colors.red,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        //left: 12,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          CupertinoIcons.plus_bubble,
                                          size: 30,
                                          color: Colors.grey[800]
                                        ),
                                      )
                                    ),
                                  )
                                ),
                              ],
                            ) 
                          ),
                        ),
                        // SliverToBoxAdapter(
                        //   child: Stack(
                        //     children: [
                        //       Container(
                        //         margin: EdgeInsets.symmetric(vertical: 8),
                        //         height: 40,
                        //         child: Stack(
                        //           children: [
                        //             Center(
                        //               child: Container(
                        //                 height: 40,
                        //                 width: 180,
                        //                 child: TabBar(    
                        //                   labelPadding: EdgeInsets.symmetric(horizontal: 1),
                        //                   indicator: BubbleTabBarIndicator(
                        //                     indicatorColor: Colors.greenAccent[400],
                        //                     indicatorHeight: 40,
                        //                     indicatorRadius: 20
                        //                   ),
                        //                   indicatorSize: TabBarIndicatorSize.tab,
                        //                   controller: tabController,
                        //                   labelStyle: TextStyle(
                        //                     fontSize: 18, 
                        //                     color: Colors.grey[800],
                        //                     fontWeight: FontWeight.w700
                        //                   ),
                        //                   labelColor: Colors.grey[800],
                        //                   unselectedLabelColor: Colors.grey[700],
                        //                   unselectedLabelStyle: TextStyle(
                        //                     color: Colors.grey[700],
                        //                     fontSize: 17,
                        //                     fontWeight: FontWeight.w700
                        //                   ),
                        //                   tabs: [
                        //                     Tab(
                        //                       text: 'Main'
                        //                     ),
                        //                     Tab(
                        //                       text: 'Other',
                        //                     )
                        //                   ],
                        //                 ),
                        //               ),
                        //             ),
                        //             Align(
                        //               alignment: Alignment.centerRight,
                        //               child: InkWell(
                        //                 onTap: () {
                        //                   createChatBottomSheet();
                        //                 },
                        //                 child: Container(
                        //                   margin: EdgeInsets.symmetric(horizontal: 12),
                        //                   height: 33,
                        //                   width: 48,
                        //                   decoration: BoxDecoration(
                        //                     color: Colors.grey[800],
                        //                     borderRadius: BorderRadius.circular(8)
                        //                   ),
                        //                 ),
                        //               )
                        //             ),
                        //           ],
                        //         )
                        //       ),
                        //     ],
                        //   )
                        // ),
                        if (searchString == '')
                        SliverList(
                          delegate: SliverChildBuilderDelegate((context, index) {
                            final createdTimeAgo = timeAgo.format(
                            MapsClass.chats.values.toList()[index]['LMTimeReal'].toDate(),locale: 'en_short');
                            final timeElapsed = createdTimeAgo.replaceAll(' ', '');
                            final _timeAgo = timeElapsed.replaceAll('~', '');
                            return Container(
                              //color: Colors.red,
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              //padding: EdgeInsets.symmetric()
                              child: ChatTile(
                                chatRooms: MapsClass.chats.values.toList()[index],
                                myInfo: widget.userInfo,
                                refresh: refresh,
                                index: index,
                                comesFromSearch: true,
                                timeAgo: _timeAgo,
                              ),
                            );
                          },
                          childCount: MapsClass.chats.length //MapsClass.searchedChats.length
                          )
                        )
                        else SliverList(
                          delegate: SliverChildBuilderDelegate((context, index) {
                            final createdTimeAgo = timeAgo.format(
                            MapsClass.chats.values.toList()[index]['LMTimeReal'].toDate(),locale: 'en_short');
                            final timeElapsed = createdTimeAgo.replaceAll(' ', '');
                            final _timeAgo = timeElapsed.replaceAll('~', '');
                            return Container(
                              //color: Colors.red,
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              //padding: EdgeInsets.symmetric()
                              child: ChatTile(
                                chatRooms: MapsClass.searchedChats.values.toList()[index],
                                myInfo: widget.userInfo,
                                refresh: refresh,
                                index: index,
                                comesFromSearch: true,
                                timeAgo: _timeAgo,
                              ),
                            );
                          },
                          childCount: MapsClass.searchedChats.length
                          )
                        )
                    ],
                  )
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
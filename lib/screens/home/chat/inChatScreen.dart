import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled_startup/models/user.dart';
import 'package:untitled_startup/screens/home/chat/inChatTile.dart';
import 'package:untitled_startup/screens/home/main/classes/mapsClass.dart';
import 'package:untitled_startup/services/cacheClass/cacheManager.dart';
import 'package:untitled_startup/services/database.dart';

class InChat extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  final bool chatExists;
  final String chatRoomId;
  final Function refresh;
  final Map<String, dynamic> myInfo;
  final bool comesFromProfile;
  InChat({this.userInfo, this.chatExists, this.chatRoomId, this.myInfo, 
  this.refresh, this.comesFromProfile});
  @override
  _InChatState createState() => _InChatState();
}

class _InChatState extends State<InChat> {
  TextEditingController chatTextController = TextEditingController();

  String theMessage = '';
  String groupChatId;

  isUserFollowing(myUid, otherUserUid) async {
    bool theValue;
    await DatabaseService(
      uid: otherUserUid
    ).isFollowingUser(myUid).then((value) {
      if (mounted) {
        setState(() {
          theValue = value;
        });
      }
    });
    return theValue;
  }

  createUpdateChat(myUid, otherUserUid) async {
    if (theMessage.length > 0) {
      final user = Provider.of<CustomUser>(context, listen: false);
      if (groupChatId == null) {
        if (myUid.substring(0, 1).codeUnitAt(0) > otherUserUid.substring(0, 1).codeUnitAt(0)) {
            groupChatId = '$myUid-$otherUserUid';
        } else {
            groupChatId = '$otherUserUid-$myUid';
        }
        DocumentReference docRef = FirebaseFirestore.instance.collection('chatRooms').doc(groupChatId);
        List usersInChat = [myUid, otherUserUid];
        Map usersInChatMap = {};
        for (int i = 0; i <  usersInChat.length; i++) {
          usersInChatMap[usersInChat[i]] = usersInChat[i];
        }
        List usernamesInChat = [widget.myInfo['username'], widget.userInfo['username']];
        List peopleInChatList = [];
        for (int i = 0; i < usernamesInChat.length; i++) {
          List<String> splitList = usernamesInChat[i].split(" ");
          for (int j = 0; j < splitList.length; j++) {
            for (int y = 1; y < splitList[j].length + 1; y++) {
              peopleInChatList.add(splitList[j]
                .substring(0, y)
                .toLowerCase());
            }
          }
        }
        if (peopleInChatList.length > 1) {
          Map<String, dynamic> chatMap = {
            'id': docRef.id,
            'usersInChat': usersInChat,
            'usersInChatMap': usersInChatMap,
            'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
            'LMTimeReal': DateTime.now(),
            'type': 'normal',
            'lastMessage': theMessage,
            'chatName' : peopleInChatList,
            //'isMain': isMainForUsers
          };
          //print(chatMap);
          // try {
          //   await DatabaseService().createChat(chatMap, docRef);
          // } catch(err) {
          //   return ;
          // }
          //
          DocumentReference docRefsalsa = FirebaseFirestore.instance.collection('chatRooms')
          .doc(groupChatId).collection('chat').doc();
          Map<String, dynamic> messageMap = {
            'message': theMessage,
            'id': docRefsalsa.id,
            'sendBy': user.uid,
            'time': DateTime.now().millisecondsSinceEpoch
          };
          setState(() {
            //chatMessagesMap = {...chatMessagesMap, '${docRefsalsa.id}': messageMap};
            //chatMessagesMap[docRefsalsa.id] = messageMap; 
            chatMessagesMap = {'${docRefsalsa.id}': messageMap, ...chatMessagesMap};
            chatTextController.text = '';
          });
          await sendMessageCreateChat(theMessage, docRefsalsa, messageMap, chatMap, docRef);
          //morePostsAvailable = true;
          // await theOtherGetMoreChats(false, docRefsalsa.id);
          setState(() {
            theMessage = '';
          });
          // if (chatMessagesMap[docRefsalsa.id]['newMessage'] == true 
          // && chatMessagesMap[docRefsalsa.id]['hasbeenSend'] == true) {
          //   MapsClass.users[widget.userInfo['uid']]['hasChat'] = true;
          // }
        }
      } else {
        Map<String, dynamic> chatMap = {
          'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
          'lastMessage': theMessage,
          'LMTimeReal': DateTime.now(),
        };
        //await DatabaseService().updateChat(chatMap, groupChatId);
        //morePostsAvailable = true;
        //DocumentReference docRefsapo;
        DocumentReference docRefsalsa = FirebaseFirestore.instance.collection('chatRooms')
        .doc(groupChatId).collection('chat').doc();
        Map<String, dynamic> messageMap = {
          'message': theMessage,
          'id': docRefsalsa.id,
          'sendBy': user.uid,
          'time': DateTime.now().millisecondsSinceEpoch,
          'timeTS': DateTime.now()
        };
        setState(() {
          chatMessagesMap = {'${docRefsalsa.id}': messageMap, ...chatMessagesMap};
          //chatMessagesMap[docRefsalsa.id] = messageMap; 
          chatTextController.text = '';
        });
        await sendMessage(theMessage, docRefsalsa, messageMap, chatMap);
        print(chatMessagesMap.keys.toList());
        setState(() {
          theMessage = '';
        });
      }
    }
    /*if (widget.comesFromChatScreen == true) {
      widget.refresh();
    }*/
  }

  sendMessageCreateChat(String message, DocumentReference docRef, 
  Map messageMap, Map chatMap, DocumentReference docRef2) async {
    //final user = Provider.of<CustomUser>(context, listen: false);
    if (message.length > 0) {
      try {
        await DatabaseService().createChat(chatMap, docRef2);
        await DatabaseService().sendMessage(messageMap, docRef);
        if (widget.comesFromProfile == true) {
          MapsClass.users[widget.userInfo['uid']]['hasChat'] = true;
        }
        chatMessagesMap[docRef.id]['newMessage'] = true;
        chatMessagesMap[docRef.id]['hasbeenSend'] = true;
      } catch(err) {
        print(err);
        chatMessagesMap[docRef.id]['newMessage'] = true;
        chatMessagesMap[docRef.id]['hasbeenSend'] = false;
      }
      setState(() {});
    }
  }

  sendMessage(String message, DocumentReference docRef, Map messageMap, Map chatMap) async {
    //final user = Provider.of<CustomUser>(context, listen: false);
    if (message.length > 0) {
      try {
        await DatabaseService().sendMessage(messageMap, docRef);
        await DatabaseService().updateChat(chatMap, groupChatId);
        if (widget.comesFromProfile == true) {
          MapsClass.users[widget.userInfo['uid']]['hasChat'] = true;
        }
        chatMessagesMap[docRef.id]['newMessage'] = true;
        chatMessagesMap[docRef.id]['hasbeenSend'] = true;
      } catch(err) {
        print(err);
        chatMessagesMap[docRef.id]['newMessage'] = true;
        chatMessagesMap[docRef.id]['hasbeenSend'] = false;
      }
      setState(() {});
    }
  }

  ScrollController scrollControllerChat = ScrollController();
  int prevPost;
  DocumentSnapshot lastDocument;
  bool gettingMorePosts = false;
  bool morePostsAvailable = true;
  Map<String, dynamic> chatMessagesMap = {};


  // theOtherGetMoreChats(hasChats, chatId) async {
  //   if (hasChats && chatMessagesMap.isNotEmpty) {
  //     DocumentSnapshot theQuery = await FirebaseFirestore.instance.collection('chatRooms').
  //     doc(groupChatId).collection('chat').doc(chatId).get();
  //     if (theQuery.exists) {
  //       chatMessagesMap[theQuery.data()['id']] = theQuery.data();
  //       chatMessagesMap[theQuery.data()['id']]['newMessage'] = true;
  //       chatMessagesMap[theQuery.data()['id']]['hasbeenSend'] = true;
  //     } else {
  //       chatMessagesMap[chatId]['newMessage'] = true;
  //       chatMessagesMap[chatId]['hasbeenSend'] = false;
  //     }
  //   } else {
  //     DocumentSnapshot theQuery = await FirebaseFirestore.instance.collection('chatRooms').
  //     doc(groupChatId).collection('chat').doc(chatId).get();
  //     if (theQuery.exists) {
  //       chatMessagesMap[theQuery.data()['id']] = theQuery.data();
  //       chatMessagesMap[theQuery.data()['id']]['newMessage'] = true;
  //       chatMessagesMap[theQuery.data()['id']]['hasbeenSend'] = true;
  //     } else {
  //       chatMessagesMap[chatId]['newMessage'] = true;
  //       chatMessagesMap[chatId]['hasbeenSend'] = false;
  //     }
  //   }
  //   setState(() {});
  // }

  getChats() async {
    Query theQuery = FirebaseFirestore.instance.collection('chatRooms').
    doc(groupChatId).collection('chat')
    .orderBy('time', descending: false).limit(25);
    setState(() {});
    Stream<QuerySnapshot> querySnapshot = theQuery.snapshots();
    querySnapshot.listen((event) async {
      if (event.docs.isNotEmpty) {
        event.docChanges.forEach((salsa) async {
          if (salsa.type == DocumentChangeType.added) {
            await Future.wait(event.docs.map((doc) async {
              Map aMap = {};
              aMap[doc.data()['id']] = doc.data();
              setState(() {
                chatMessagesMap = {...aMap, ...chatMessagesMap};
                //chatMessagesMap[doc.data()['id']] = aMap[doc.data()['id']];
              });
            }));
          }
        });
        lastDocument = event.docs[event.docs.length - 1];
      } else {
        morePostsAvailable = false;
      }
    });
    setState(() {});
  }

  getMoreChats() async {
    if (morePostsAvailable == false) {
      return;
    }
    if (gettingMorePosts == true) {
      return;
    }
    gettingMorePosts = true;
    Query theQuery = FirebaseFirestore.instance.collection('chatRooms').
    doc(groupChatId).collection('chat')
    .orderBy('time', descending: false).startAfterDocument(lastDocument).limit(25);
    Stream<QuerySnapshot> querySnapshot = theQuery.snapshots();
    querySnapshot.listen((event) async {
      if (event.docs.length < 25 || event.docs.length == 0) {
        morePostsAvailable = false;
      }
      if (event.docs.isNotEmpty) {
        event.docChanges.forEach((salsa) async {
          if (salsa.type == DocumentChangeType.added) {
            await Future.wait(event.docs.map((doc) async {
              Map aMap = {};
              aMap[doc.data()['id']] = doc.data();
              setState(() {
                chatMessagesMap = {...chatMessagesMap, ...aMap};
              });
            }));
          }
        });
        lastDocument = event.docs[event.docs.length - 1];
      } else {
        morePostsAvailable = false;
      }
    });
    setState(() {});
    gettingMorePosts = false;
  }

  int limit = 25;

  @override
  void initState() {
    super.initState();
    if (widget.chatRoomId != null) {
      groupChatId = widget.chatRoomId;
      getChats();
      scrollControllerChat.addListener(() {
        double maxScroll = scrollControllerChat.position.maxScrollExtent;
        double currentScroll = scrollControllerChat.position.pixels;
        double delta = MediaQuery.of(context).size.height;
        if (maxScroll - currentScroll < delta) {
          getMoreChats();
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollControllerChat.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: AppBar(
          automaticallyImplyLeading: false,
          shadowColor: Colors.black.withOpacity(0.4),
          elevation: 7.0,
          backgroundColor: Colors.grey[50],
          leading: Transform.scale(
            scale: 2,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.keyboard_arrow_left_rounded, 
                color: Colors.grey[800]
              ),
              color: Colors.red,
            ),
          ),
          titleSpacing: 0,
          title: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              child: Row(
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[350],
                      /*image: DecorationImage(
                        image: NetworkImage(
                          widget.userInfo['profileImg'],
                        ),
                        //),
                        fit: BoxFit.cover,
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
                      imageUrl: widget.userInfo['profileImg'],
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
                    child: Text(
                      '${widget.userInfo['username']}',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 21,
                        fontWeight: FontWeight.w700
                      )
                    ),
                  )
                ]
              )
            ),
          ),
        ),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  left: 8,
                  right: 8,
                  //bottom: 45 +
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: /*StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('chatRooms').
                      doc(groupChatId).collection('chat')
                      .orderBy('time', descending: true).limit(limit).snapshots(),
                    builder: (context, AsyncSnapshot snapshot) {
                      //print(snapshot.data.docs.length);
                      if (snapshot.hasData) {
                        return ListView.builder(
                          reverse: true,
                          controller: scrollControllerChat,
                          //shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return InChatTile(
                              message: snapshot.data.docs[index].data()['message'],
                              isSendByMe:snapshot.data.docs[index].data()['sendBy'] == user.uid ? true : false,
                              myProfileImg: widget.myInfo['profileImg'],
                              otherUserProfileImg: widget.userInfo['loadedProfileImg'],
                              otherUserName: widget.userInfo['name'],
                            );
                          },
                          itemCount: snapshot.data.docs.length,
                        );
                      } else {
                        return Container();
                      }
                    }
                  )*/
                  CupertinoScrollbar(
                    isAlwaysShown: true,
                    controller: scrollControllerChat,
                    child: ListView.builder(
                      reverse: true,
                      controller: scrollControllerChat,
                      physics: AlwaysScrollableScrollPhysics(),
                      //shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return InChatTile(
                          message: chatMessagesMap.values.toList()[index]['message'],
                          isSendByMe:  chatMessagesMap.values.toList()[index]['sendBy'] == user.uid ? true : false,
                          myProfileImg: widget.myInfo['profileImg'],
                          otherUserProfileImg: widget.userInfo['profileImg'],
                          otherUserName: widget.userInfo['name'],
                          messageInfo: chatMessagesMap.values.toList()[index],
                        );
                      },
                      itemCount: chatMessagesMap.length,
                    ),
                  ),
                )
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                //height: 45 + MediaQuery.of(context).padding.bottom,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: Offset(0, -2), // changes position of shadow
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Container(
                  margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 8,
                        child: Container(
                          //height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[350],
                            //border: Border.all(color: Colors.grey[600], width:2.5),
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: TextField(
                            keyboardType: TextInputType.text,
                            controller: chatTextController,
                            maxLines: 4,
                            minLines: 1,
                            autocorrect: false,
                            onChanged: (value) {
                              setState(() {
                                theMessage = value;
                              });
                            },
                            textCapitalization: TextCapitalization.sentences,
                            cursorHeight: 22,
                            style: TextStyle(
                              color: Colors.grey[850],
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            buildCounter: (BuildContext context, { int currentLength, int maxLength, bool isFocused }) => null,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                              //isDense: true,
                              border: InputBorder.none,
                              hintText: 'Chat',
                              hintStyle: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 18,
                                //height: 2,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        )
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          //color: Colors.red,
                          padding: EdgeInsets.only(bottom: 7),
                          child: InkWell(
                            onTap: () {
                              if (widget.chatExists == true) {
                                createUpdateChat(user.uid, widget.userInfo['uid']);
                              } else {
                                createUpdateChat(user.uid, widget.userInfo['uid']);
                              }
                            },
                            child: Icon(
                              Icons.send_rounded,
                              color: Colors.red,
                              size: 32
                            ),
                          ),
                        )
                      )
                    ]
                  )
                )
              )
            )
          ],
        )
      )
    );
  }
}
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled_startup/models/user.dart';
import 'package:untitled_startup/screens/home/chat/InGroupChatTile.dart';
import 'package:untitled_startup/services/cacheClass/cacheManager.dart';
//import 'package:untitled_startup/screens/home/chat/inChatTile.dart';
//import 'package:untitled_startup/screens/home/chat/inChatTile.dart';
import 'package:untitled_startup/services/database.dart';

class InGroupChat extends StatefulWidget {
  final String chatRoomId;
  final Map<dynamic, dynamic> groupInfo;
  InGroupChat({this.chatRoomId, this.groupInfo});
  @override
  _InGroupChatState createState() => _InGroupChatState();
}

class _InGroupChatState extends State<InGroupChat> {
  TextEditingController chatTextController = TextEditingController();

  String theMessage = '';
  String groupChatId;

  createUpdateChat(myUid) async {
    if (theMessage.length > 0) {
      final user = Provider.of<CustomUser>(context, listen: false);
      Map<String, dynamic> chatMap = {
        'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
        'lastMessage': theMessage,
        'LMTimeReal': DateTime.now(),
      };
      //DatabaseService().updateChat(chatMap, groupChatId);
      //morePostsAvailable = true;
      DocumentReference docRefsalsa = FirebaseFirestore.instance.collection('chatRooms')
      .doc(groupChatId).collection('chat').doc();
      Map<String, dynamic> messageMap = {
        'message': theMessage,
        'id': docRefsalsa.id,
        'sendBy': user.uid,
        'time': DateTime.now().millisecondsSinceEpoch,
        'timeTS': DateTime.now()
      };
      if (mounted) {
        setState(() {
          //chatMessagesMap[docRefsalsa.id] = messageMap;
          chatMessagesMap = {'${docRefsalsa.id}': messageMap, ...chatMessagesMap};
          chatTextController.text = '';
        });
      }
      await sendMessage(theMessage, docRefsalsa, messageMap, chatMap);
      //theOtherGetMoreChats(true, docRefsalsa.id);
      if (mounted) {
        setState(() {
          theMessage = '';
        });
      }
    }
  }

  sendMessage(String message, DocumentReference docRef, Map messageMap, Map chatMap) async {
    //final user = Provider.of<CustomUser>(context, listen: false);
    if (message.length > 0) {
      try {
        await DatabaseService().sendMessage(messageMap, docRef);
        await DatabaseService().updateChat(chatMap, groupChatId);
        chatMessagesMap[docRef.id]['newMessage'] = true;
        chatMessagesMap[docRef.id]['hasbeenSend'] = true;
      } catch(err) {
        chatMessagesMap[docRef.id]['newMessage'] = true;
        chatMessagesMap[docRef.id]['hasbeenSend'] = false;
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  Map<String, dynamic> usersInChatMap = {};

  getGroupUsersInfo() async {
    Query theQuery = FirebaseFirestore.instance.collection('users')
    .where('uid', whereIn: widget.groupInfo['usersInChat']);
    setState(() {});
    QuerySnapshot querySnapshot = await theQuery.get();
    if (querySnapshot.docs.isNotEmpty) {
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        usersInChatMap[querySnapshot.docs[i].data()['uid']] = querySnapshot.docs[i].data();
      }
    }
    setState(() {});
  }

  ScrollController scrollControllerChat = ScrollController();
  int prevPost;
  DocumentSnapshot lastDocument;
  bool gettingMorePosts = false;
  bool morePostsAvailable = true;
  //List<DocumentSnapshot> chatMessages = [];
  Map<String, dynamic> chatMessagesMap = {};

  getChats() async {
    Query theQuery = FirebaseFirestore.instance.collection('chatRooms').
    doc(groupChatId).collection('chat')
    .orderBy('time', descending: false).limit(25);
    setState(() {});
    Stream<QuerySnapshot> querySnapshot = theQuery.snapshots();
    querySnapshot.listen((event) async {
      if (event.docs.isNotEmpty) {
        event.docChanges.forEach((element) async {
          if (element.type == DocumentChangeType.added) {
            await Future.wait(event.docs.map((doc) async {
              Map aMap = {};
              aMap[doc.data()['id']] = doc.data();
              setState(() {
                chatMessagesMap = {...aMap, ...chatMessagesMap};
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
        event.docChanges.forEach((element) async {
          if (element.type == DocumentChangeType.added) {
            await Future.wait(event.docs.map((doc) async {
              Map aMap = {};
              aMap[doc.data()['id']] = doc.data();
              setState(() {
                chatMessagesMap = {...aMap, ...chatMessagesMap};
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

  @override
  void initState() {
    if (widget.chatRoomId != null) {
      groupChatId = widget.chatRoomId;
      getChats();
      //getGroupUsersInfo();
      //print('the group users info is $usersInChatMap');
      scrollControllerChat.addListener(() {
        double maxScroll = scrollControllerChat.position.maxScrollExtent;
        double currentScroll = scrollControllerChat.position.pixels;
        double delta = MediaQuery.of(context).size.height;
        if (maxScroll - currentScroll < delta) {
          getMoreChats();
        }
      });
    }
    super.initState();
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
      //resizeToAvoidBottomInset: false,
      //resizeToAvoidBottomPadding: true,
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
                    /*decoration: widget.groupInfo['groupImg'] != 'none' ? BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[350],
                      image: DecorationImage(
                        image: NetworkImage(
                          widget.groupInfo['groupImg']
                        ),
                        fit: BoxFit.cover,
                      )
                    ) : BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[350],
                    ),*/
                    child: CachedNetworkImage(
                      fadeInDuration: Duration(milliseconds: 20),
                      fadeOutDuration: Duration(milliseconds: 20),
                      placeholder: (context, url) => Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[350],
                          shape: BoxShape.circle
                        )
                      ),
                      imageUrl: widget.groupInfo['groupImg'],
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
                      '${widget.groupInfo['groupName']}',
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
                  child: ListView.builder(
                    reverse: true,
                    controller: scrollControllerChat,
                    //shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InGroupChatTile(
                        message: chatMessagesMap.values.toList()[index]['message'],
                        isSendByMe: chatMessagesMap.values.toList()[index]['sendBy'] == user.uid ? true : false,
                        theProfileImg: widget.groupInfo['usersInfo'][chatMessagesMap.values.toList()[index]['sendBy']]['profileImg'],
                        userName:  widget.groupInfo['usersInfo'][chatMessagesMap.values.toList()[index]['sendBy']]['name'],
                        messageInfo: chatMessagesMap.values.toList()[index],
                      );
                    },
                    itemCount: chatMessagesMap.length,
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
                              //if (widget.chatExists == true) {
                                createUpdateChat(user.uid);
                              //} else {
                              //createUpdateChat(user.uid, widget.userInfo['uid']);
                              //}
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
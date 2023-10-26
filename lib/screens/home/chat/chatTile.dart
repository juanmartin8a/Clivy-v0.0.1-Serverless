import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled_startup/models/user.dart';
import 'package:untitled_startup/screens/home/chat/inChatScreen.dart';
import 'package:untitled_startup/screens/home/chat/inGCScreen.dart';
import 'package:untitled_startup/screens/home/main/classes/mapsClass.dart';
import 'package:untitled_startup/services/cacheClass/cacheManager.dart';
import 'package:untitled_startup/services/database.dart';

class ChatTile extends StatefulWidget {
  final Map chatRooms;
  final Map<String, dynamic> myInfo;
  final int index;
  final Function refresh;
  final bool comesFromSearch;
  final String timeAgo;
  ChatTile({this.chatRooms, this.myInfo, this.refresh, this.index, this.comesFromSearch,
  this.timeAgo});
  @override
  _ChatTileState createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {

  @override
  Widget build(BuildContext context) {
    //final user = Provider.of<CustomUser>(context);
    return widget.chatRooms['type'] != 'group'
    ? Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => InChat(
                chatExists: true,
                userInfo: widget.chatRooms['userInfo'],
                myInfo: widget.myInfo,
                chatRoomId: widget.chatRooms['id'],
                //refresh: widget.refresh,
                //comesFromChatScreen: true,
              )
            )
          );
        },
        child: Container(
          color: Colors.grey[50],
          child: Row(
            children: [
              Container(
                height: 52,
                width: 52,
                child: CachedNetworkImage(
                  fadeInDuration: Duration(milliseconds: 20),
                  fadeOutDuration: Duration(milliseconds: 20),
                  placeholder: (context, url) => Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[350],
                      shape: BoxShape.circle
                    )
                  ),
                  errorWidget: (context, error, url) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[350],
                        shape: BoxShape.circle
                      )
                    );
                  },
                  imageUrl: widget.chatRooms['userInfo']['profileImg'],
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
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 8),
                  //color: Colors.red,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        //color: Colors.red,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${widget.chatRooms['userInfo']['name']}',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 17,
                                fontWeight: FontWeight.w700
                              )
                            ),
                            Container(
                              child: Text(
                                '${widget.timeAgo}',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500
                                )
                              )
                            )
                          ],
                        )
                      ),
                      Container(
                        child: Text(
                          //MapsClass
                          widget.chatRooms['lastMessage'] != null 
                          ? widget.comesFromSearch 
                            ? '${widget.chatRooms['lastMessage']}'
                            : '${widget.chatRooms['lastMessage']}'
                          : '${widget.chatRooms['userInfo']['bio']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1
                          )
                        )
                      )
                    ],
                  )
                ),
              ),
              // const Spacer(),
              // Container(
              //   child: Icon(Icons.keyboard_arrow_right_rounded, 
              //   color: Colors.grey[800], size: 30)
              // )
            ],
          )
        ),
      )
    ) : Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(builder: (context) => InGroupChat(
              chatRoomId: widget.chatRooms['id'],
              groupInfo: widget.chatRooms,
            ))
          );
        },
        child: Container(
          color: Colors.grey[50],
          child: Row(
            children: [
              Container(
                height: 52,
                width: 52,
                /*decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[350],
                  border: Border.all(
                    color: Colors.grey[500],
                    width: 0.2
                  ),
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
                  errorWidget: (context, error, url) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[350],
                        shape: BoxShape.circle
                      )
                    );
                  },
                  imageUrl: widget.chatRooms['groupImg'],
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
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${widget.chatRooms['groupName']}',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 17,
                              fontWeight: FontWeight.w700
                            )
                          ),
                          Container(
                            child: Text(
                              '${widget.timeAgo}',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 16,
                                fontWeight: FontWeight.w500
                              )
                            )
                          )
                        ],
                      ),
                      Container(
                        child: Text(
                          widget.chatRooms['lastMessage'] != ''
                          ? widget.comesFromSearch 
                            ? '${widget.chatRooms['lastMessage']}'
                            : '${widget.chatRooms['lastMessage']}'
                          : 'Start Chating',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w500
                          )
                        )
                      )
                    ],
                  )
                ),
              ),
            ],
          )
        ),
      )
    );
  }
}
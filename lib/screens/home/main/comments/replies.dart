import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled_startup/models/user.dart';
import 'package:untitled_startup/screens/home/main/classes/mapsClass.dart';
import 'package:untitled_startup/screens/home/userProfile/profiles.dart';
import 'package:untitled_startup/services/cacheClass/cacheManager.dart';
import 'package:untitled_startup/services/database.dart';

class Replies extends StatefulWidget {
  final Map<String, dynamic> myInfo;
  final Map<dynamic, dynamic> replies;
  final Map<String, dynamic> replyUserInfo;
  final Map<String, dynamic> commentUserInfo;
  final Map<String, dynamic> commentInfo;
  final String timeAgo;
  final Function getLikedReplyState;
  final Function reply;
  final Function getTaggedFollowingState;
  final Function getReplyFollowingState;
  final Function replySettings;
  Replies({this.replies, this.replyUserInfo, this.timeAgo, this.getLikedReplyState,
  this.commentInfo, this.reply, this.commentUserInfo, this.replySettings,
  this.getTaggedFollowingState, this.getReplyFollowingState, this.myInfo, Key key}) : super(key: key);
  @override
  _RepliesState createState() => _RepliesState();
}

class _RepliesState extends State<Replies> with SingleTickerProviderStateMixin {
  AnimationController likeAnim;
  Animation<double> likeIconSize;
  bool isLiking = false;

  likeComment() {
    setState(() => isLiking = true); 
    final user = Provider.of<CustomUser>(context, listen: false);
    Map<String, dynamic> likeCommentMap = {
      'likedBy': user.uid,
      'commentLiked': widget.commentInfo['commentId']
    };
    likeAnim.forward().whenComplete(() {
      likeAnim.reset();
    });
    DatabaseService(docId: widget.commentInfo['postId'], uid: user.uid)
      .likeReply(likeCommentMap, widget.replies['parentReply'], widget.replies['id']);
    DatabaseService(docId: widget.commentInfo['postId'])
    .incrementReplyLikeCount(widget.replies['parentReply'], 
    {'likes': FieldValue.increment(1)}, widget.replies['id']);
    setState(() => isLiking = false);
  }

  unlikeComment() {
    setState(() => isLiking = true); 
    final user = Provider.of<CustomUser>(context, listen: false);
    likeAnim.forward().whenComplete(() {
      likeAnim.reset();
    });
    DatabaseService(docId: widget.commentInfo['postId'], uid: user.uid)
      .unlikeReply(widget.replies['parentReply'], widget.replies['id']);
    DatabaseService(docId: widget.commentInfo['postId'])
    .incrementReplyLikeCount(widget.replies['parentReply'], 
    {'likes': FieldValue.increment(-1)}, widget.replies['id']);
    setState(() => isLiking = false);
  }

  @override
  void initState() {
    super.initState();
    likeAnim = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    likeIconSize = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem(tween: Tween<double>(begin: 18, end: 22), weight: 18),
      TweenSequenceItem(tween: Tween<double>(begin: 22, end: 14), weight: 18),
      TweenSequenceItem(tween: Tween<double>(begin: 14, end: 18), weight: 18),
    ]).animate(CurvedAnimation(
      parent: likeAnim,
      curve: Curves.easeInOut
    ))
    ..addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.reply(
          widget.commentUserInfo['uid'], 
          widget.commentUserInfo['username'],
          widget.commentInfo,
          widget.commentUserInfo,
          true,
          widget.replyUserInfo['username'],
          widget.replyUserInfo['uid']
        );
      },
      onLongPress: () {
        widget.replySettings(
          context, widget.commentInfo['commentId'], widget.replies['id']
        );
        //print('called');
      },
      child: Container(
        color: Colors.grey[50],
        padding: EdgeInsets.only(
          top: 12,
          left: 2,
          right: 0
          //vertical: 6, horizontal: 1
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context, 
                  CupertinoPageRoute(
                    builder: (context) => Profiles(
                      //currentIndex: widget.index,
                      userInfo: widget.replyUserInfo,
                      maxHeight: MediaQuery.of(context).size.height,
                      isFollowing: widget.replies['isUserFollowing'],
                      myInfo: widget.myInfo,
                    )
                  )
                );
              },
              child: Container(
                height: 26,
                width: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[350],
                  image: DecorationImage(
                    image: NetworkImage(
                      widget.replyUserInfo['profileImg'],
                    ),
                    fit: BoxFit.cover
                  )
                ),
                child: CachedNetworkImage(
                  fadeInDuration: Duration(milliseconds: 10),
                  fadeOutDuration: Duration(milliseconds: 10),
                  placeholder: (context, url) => Container(color: Colors.grey[350]),
                  imageUrl: widget.replyUserInfo['profileImg'],
                  fit: BoxFit.cover,
                  cacheManager: CustomCacheManager.instance,
                  imageBuilder: (context, imageProvider) {
                    return Container(
                      decoration: BoxDecoration(
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
            ),
            Expanded(
              child: Container(
                //color: Colors.red,
                margin: EdgeInsets.only(left: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 0),
                      child: Text(
                        //'${widget.theCommentsList.data()['likes']}likes•${widget.timeAgo}',
                        '${widget.timeAgo}•${widget.replies['likes']}likes',
                        //'${widget.theCommentsList.data()['likes']} likes   ${widget.timeAgo}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        )
                      ),
                    ),
                    Text.rich(
                      //textAlign: TextAlign.center,
                      TextSpan(
                        text: '${widget.replyUserInfo['username']} ',
                        recognizer: TapGestureRecognizer()..onTap = (){
                          Navigator.push(
                            context, 
                            CupertinoPageRoute(
                              builder: (context) => Profiles(
                                //currentIndex: widget.index,
                                userInfo: widget.replyUserInfo,
                                maxHeight: MediaQuery.of(context).size.height,
                                isFollowing: widget.replies['isUserFollowing'],
                                myInfo: widget.myInfo,
                              )
                            )
                          );
                        },
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                        children: //<TextSpan>[
                          //isCommentLoading == false ? 
                          widget.replies['taggedUsersIds'].isNotEmpty
                            ? widget.replies['reply']
                            .split(' ').map<TextSpan>((word) {
                              //print(word);
                              return word.startsWith('@') 
                              && word.length > 1 
                              && widget.replies['taggedUsers'].contains(word)
                              ? TextSpan(
                                text: ' ' + word,
                                recognizer: TapGestureRecognizer()..onTap = (){
                                  Navigator.push(
                                    context, 
                                    CupertinoPageRoute(
                                      builder: (context) {
                                        return Profiles(
                                          //currentIndex: widget.index,
                                          userInfo: widget.replies['theTaggedUsersInfo']
                                            [widget.replies['taggedUsersIds'][
                                              widget.replies['taggedUsers'].indexOf(word)
                                            ]],
                                          maxHeight: MediaQuery.of(context).size.height,
                                          isFollowing: 
                                          widget.replies['theTaggedUsersInfo']
                                            [widget.replies['taggedUsersIds'][
                                              widget.replies['taggedUsers'].indexOf(word)
                                            ]]['isUserFollowing'],
                                          myInfo: widget.myInfo,
                                        );
                                      }
                                    )
                                  );
                                },
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 15.3,
                                  fontWeight: FontWeight.w600,
                                )
                              ) : TextSpan(
                                text: ' ' + word,
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                )
                              );
                            }).toList()
                            : [TextSpan(
                              text: '${widget.replies['reply']}',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              )
                            )]
                      )
                    ),
                  ],
                )
              ),
            ),
            //const Spacer(),
            GestureDetector(
              onTap: () {
                if (isLiking == false) {
                  if (MapsClass.comments[widget.commentInfo['postId']][widget.commentInfo['commentId']]
                  ['theReplies'][widget.replies['id']]['userHasLiked'] == false) {
                    likeComment();
                    MapsClass.comments[widget.commentInfo['postId']][widget.commentInfo['commentId']]
                    ['theReplies'][widget.replies['id']]['userHasLiked'] = true;
                    widget.getLikedReplyState(widget.commentInfo['postId'],
                      widget.replies['id'],
                      widget.replies['parentReply']
                    );
                  } else if (MapsClass.comments[widget.commentInfo['postId']][widget.commentInfo['commentId']]
                  ['theReplies'][widget.replies['id']]['userHasLiked'] == true) {
                    unlikeComment();
                    //MapsClass.comments[widget.commentInfo['postId']][widget.commentInfo['commentId']]
                    //['theReplies'][widget.replies['id']]['userHasLiked'] = false;
                    widget.getLikedReplyState(
                      widget.commentInfo['postId'],
                      widget.replies['id'],
                      widget.replies['parentReply']
                    );
                  }
                }
              },
              child: Container(
                margin: EdgeInsets.only(top: 4, left: 6),
                height: 32,
                width: 32,
                //color: Colors.red,
                child: MapsClass.comments[widget.commentInfo['postId']][widget.commentInfo['commentId']]
                  ['theReplies'][widget.replies['id']]['userHasLiked'] == false ? Icon(
                  Icons.favorite_border_outlined,
                  color: Colors.grey[600],
                  size: likeIconSize.value,
                ) : Icon(
                  Icons.favorite_rounded,
                  color: Colors.red,
                  size: likeIconSize.value,
                )
              ),
            )
          ],
        )
      ),
    );
  }
}
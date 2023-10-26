import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled_startup/screens/home/main/comments/newCommentTile.dart';
import 'package:untitled_startup/services/database.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class CommentsChild extends StatefulWidget {
  final Map<String, dynamic> myInfo;
  final Map<dynamic, dynamic> theCommentsMap;
  final Function reply;
  final Function commentSettings;
  final Function replySettings;
  final Function getLikeState;
  //final Function getReplies;
  //final Function getReplyLikeState;
  //final Function getMoreReplies;
  final Function getFollowingStateComment;
  final Function getFollowingStateCommentTagged;
  final Function forLikeReplyState;
  final Function forFollowingState;
  final Function forGetReplies;
  final Function forReplyTaggedUsers;
  final Function forReplyTaggedUsersFollowingState;
  final Function forCreateReplyTaggedUsers;
  final Function forSeenReplies;
  CommentsChild({this.theCommentsMap, this.reply, this.commentSettings, 
  this.getLikeState, this.forLikeReplyState, this.forFollowingState, 
  this.forGetReplies, this.forReplyTaggedUsers, this.forReplyTaggedUsersFollowingState,
  this.forCreateReplyTaggedUsers, this.getFollowingStateComment, 
  this.getFollowingStateCommentTagged, this.forSeenReplies, this.myInfo, this.replySettings});
  @override
  _CommentsChildState createState() => _CommentsChildState();
}

class _CommentsChildState extends State<CommentsChild> {
  @override
  Widget build(BuildContext context) {
    //print('helo');
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          /*return FutureBuilder<DocumentSnapshot>(
            
            future: DatabaseService(uid: widget.theCommentsMap.values.toList()[index]['commentedBy']).getUserByUidFuture(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              //print('$index  ##  ${theCommentsList[index].data()['commentId']}');
              if (snapshot.hasData) {
                //print('index is ${widget.theCommentsMap.values.toList()[index]}');
                //print(widget.theCommentsMap);
                //print(widget.theCommentsMap['commentId']);*/
                
                //Map<String, dynamic> commentUserInfo = snapshot.data.data();
                //print(widget.theCommentsMap.values.toList()[index]);
                final createdTimeAgo = timeAgo.format(
                widget.theCommentsMap.values.toList()[index]['timeTS'].toDate(),locale: 'en_short');
                final timeElapsed = createdTimeAgo.replaceAll(' ', '');
                //print('hello there');
                return NewCommentTile(
                  myInfo: widget.myInfo,
                  commentInfo: widget.theCommentsMap.values.toList()[index],
                  commentUserInfo: widget.theCommentsMap.values.toList()[index]['userInfo'],
                  timeAgo: timeElapsed,
                  reply: widget.reply,
                  commentSettings: widget.commentSettings,
                  replySettings: widget.replySettings,
                  getLikeState: widget.getLikeState,
                  index: index,
                  commentInfoLength: widget.theCommentsMap.length,
                  //getReplies: widget.getReplies,
                  //getReplyLikeState: widget.getReplyLikeState,
                  //getMoreReplies: widget.getMoreReplies,
                  forLikeReplyState: widget.forLikeReplyState,
                  forFollowingState: widget.forFollowingState,
                  forGetReplies: widget.forGetReplies,
                  forReplyTaggedUsers: widget.forReplyTaggedUsers,
                  forReplyTaggedUsersFollowingState: widget.forReplyTaggedUsersFollowingState,
                  forCreateReplyTaggedUsers: widget.forCreateReplyTaggedUsers,
                  getFollowingStateComment: widget.getFollowingStateComment,
                  getFollowingStateCommentTagged: widget.getFollowingStateCommentTagged,
                  forSeenReplies: widget.forSeenReplies,
                  //key: Key(widget.theCommentsMap.values.toList()[index]['commentId'])
                );
              /*} else {
                return Container();
              }
            }
          );*/
        },
        childCount: widget.theCommentsMap.length,
      ),
    );
  }
}
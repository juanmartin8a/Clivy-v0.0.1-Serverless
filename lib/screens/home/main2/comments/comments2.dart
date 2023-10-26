import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:untitled_startup/models/user.dart';
import 'package:untitled_startup/screens/home/classes/taggedUsersList.dart';
import 'package:untitled_startup/screens/home/main/classes/mapsClass.dart';
import 'package:untitled_startup/screens/home/main/comments/commentsChild.dart';
import 'package:untitled_startup/screens/home/main/comments/replyUserTile.dart';
import 'package:untitled_startup/services/database.dart';

class Comments2 extends StatefulWidget {
  final String postId;
  final bool isFollowing;
  final Map post;
  final Map<String, dynamic> myInfo;
  final Function refresh;
  Comments2({this.postId, this.isFollowing, this.post, this.myInfo,
  this.refresh, Key key}) : super(key: key);
  @override
  _Comments2State createState() => _Comments2State();
}

class _Comments2State extends State<Comments2> {

  RichTextController _commentController2;

  String theComment = '';
  bool isUploading = false;

  bool isFollowing;

  bool isLoadingComments = true;

  deleteComment(commentId) async {
    if (MapsClass.posts[widget.postId] != null) {
      setState(() {
        MapsClass.posts[widget.postId]['comments'] += -1;
      });
    }
    if (MapsClass.userPosts[widget.post['postedBy']] != null) {
      if (MapsClass.userPosts[widget.post['postedBy']]['posts'][widget.postId] != null) {
        setState(() {
          MapsClass.userPosts[widget.post['postedBy']]['posts'][widget.postId]['comments'] += -1;
        });
      }
    }
    widget.refresh();
    setState(() {
      MapsClass.comments[widget.postId].removeWhere((key, value) => key == commentId);
    });
    await DatabaseService(docId: widget.postId).batchedDeleteComment(
      commentId,
      //MapsClass.comments[widget.postId].keys.toList()[index],
      {'comments': FieldValue.increment(-1)}
    );
  }

  deleteReply(commentId, replyId) async {
    if (MapsClass.posts[widget.postId] != null) {
      setState(() {
        MapsClass.posts[widget.postId]['comments'] += -1;
      });
    }
    if (MapsClass.userPosts[widget.post['postedBy']] != null) {
      if (MapsClass.userPosts[widget.post['postedBy']]['posts'][widget.postId] != null) {
        setState(() {
          MapsClass.userPosts[widget.post['postedBy']]['posts'][widget.postId]['comments'] += -1;
        });
      }
    }
    widget.refresh();
    await DatabaseService(
      docId: widget.postId
    ).deleteReplyBatch(
      {'comments': FieldValue.increment(-1)}, 
      {'replies': FieldValue.increment(-1)}, 
      commentId, 
      replyId, 
    );  
    setState(() {
      MapsClass.comments[widget.postId][commentId]['replies'] += -1;
      MapsClass.comments[widget.postId][commentId]['theReplies'].remove(replyId);
      MapsClass.comments[widget.postId][commentId]['theSeenReplies'].remove(replyId);
    });
    // setState(() {
    //   MapsClass.comments[widget.postId].removeWhere((key, value) => key == MapsClass.comments[widget.postId].keys.toList()[index]);
    // });
  }

  preCommentSettings(BuildContext context, String commentId) {
    //deleteComment(index);
    //Navigator.of(context).pop();
    commentSettings(context, () => deleteComment(commentId));
  }

  preReplySettings(BuildContext context, String commentId, String replyId) {
    //deleteReply(commentId, replyId);
    //Navigator.of(context).pop();
    commentSettings(context, () => deleteReply(commentId, replyId));
  }

  commentSettings(
    //BuildContext context, int index, bool isComment, String commentId, String replyId
    BuildContext context, Function theFunction
  ) {
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
                        theFunction();
                        // if (isComment) {
                        //   deleteComment(index);
                        //   //Navigator.of(context).pop();
                        // } else if (!isComment) {
                        //   deleteReply(commentId, replyId);
                        //   //Navigator.of(context).pop();
                        // }
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
                            'Delete',
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

  uploadComment() async {
    if (theComment != '' && mounted) {
      setState(() {
        isUploading = true;
      });
      List theSplittedComment = theComment.split(' ');
      //List forTheTaggedUsers = [];
      //List forTheTaggedUsersIds = [];
      Map forTheTaggedUsersMap = {};
      for (int i = 0; i < theSplittedComment.length; i++) {
        if (!forTheTaggedUsersMap.values.toList().contains(theSplittedComment[i])) {
          if (theSplittedComment[i].startsWith('@')) {
            String theNewString = theSplittedComment[i].replaceAll('@', '');
            if (taggedUsersForUpload.keys.toList().contains(theNewString)) {
              forTheTaggedUsersMap[taggedUsersForUpload[theNewString]] = theSplittedComment[i];
              //forTheTaggedUsers.add(theSplittedComment[i]);
              //forTheTaggedUsersIds.add(taggedUsersForUpload[theNewString]);
            }
          }
        }
      }
      //print(forTheTaggedUsers);
      final user = Provider.of<CustomUser>(context, listen: false);
      DocumentReference docRef = FirebaseFirestore.instance.collection('posts')
      .doc(widget.post['id']).collection('comments').doc();
      Map<String, dynamic> commentMapFake = {
        'postId': widget.post['id'],
        'commentId': docRef.id,
        'commentedBy': user.uid,
        'comment': theComment,
        'likes': 0,
        'timeMS': DateTime.now().millisecondsSinceEpoch,
        'timeTS': DateTime.now(),
        'taggedUsers': forTheTaggedUsersMap.values.toList(),
        'taggedUsersIds': forTheTaggedUsersMap.keys.toList(),
        'taggedUsersMap': forTheTaggedUsersMap,
        'replies': 0
      };
      /*Map<String, dynamic> commentMap = {
        '${docRef.id}': commentMapFake
      };*/
      Map emptyMap = {};
      setState(() {
        //theCommentsList.insert(0, querySnapshot.docs[0]);
        //theCommentsList = [querySnapshot.docs[0], ...theCommentsList];
        emptyMap[docRef.id] = {...commentMapFake};
        emptyMap[docRef.id]['timeTS'] = Timestamp.fromDate(emptyMap[docRef.id]['timeTS']);
        emptyMap[docRef.id]['userInfo'] = widget.myInfo;
        emptyMap[docRef.id]['theReplies'] = {};
        emptyMap[docRef.id]['theSeenReplies'] = {};
        emptyMap[docRef.id]['theTaggedUsersInfo'] = {};
        emptyMap[docRef.id]['userHasLiked'] = false;
        emptyMap[docRef.id]['isUserFollowing'] = false;
        emptyMap[docRef.id]['createdNow'] = true;
        MapsClass.comments[widget.postId] = {...emptyMap, ...?MapsClass.comments[widget.postId]};
      });
      if (MapsClass.posts[widget.postId] != null) {
        setState(() {
          MapsClass.posts[widget.postId]['comments'] += 1;
        });
      }
      if (MapsClass.userPosts[widget.post['postedBy']] != null) {
        if (MapsClass.userPosts[widget.post['postedBy']]['posts'][widget.postId] != null) {
          setState(() {
            MapsClass.userPosts[widget.post['postedBy']]['posts'][widget.postId]['comments'] += 1;
          });
        }
      }
      widget.refresh();
      setState(() {
        _commentController2.text = '';
        theComment = '';
        theWords = [];
        theTaggedUsers = [];
        taggedUsersId = [];
        commentIsReply = false;
        taggedUsersForUpload = {};
        replyCommentInfo = {};
        replyingToMap.clear();
        replyUserInfo.clear();
        theWord = '';
        isUploading = false;
      });
      FocusScope.of(context).unfocus();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.animateTo(
          scrollController.position.minScrollExtent,
          duration: Duration(milliseconds: 350), 
          curve: Curves.ease
        );
      });
      if (MapsClass.comments[widget.postId][docRef.id]['taggedUsersIds'].length > 0) {
        try {
          await getNewUsersTagged(
            commentMapFake,
          ).then((dynamic val) {
            //print(val);
            //setState(() {
              MapsClass.comments[widget.postId][docRef.id]['theTaggedUsersInfo'] = val;
              //isUploading = false;
            //});
            //emptyMap[querySnapshot.docs[0].data()['commentId']]['theTaggedUsersInfo'] = val;
          });
        } catch(err) {
          MapsClass.comments[widget.postId][docRef.id]['couldUpload'] = false;
        }
      }
      setState(() {isUploading = false;});
      //   //MapsClass.comments[widget.postId] = {...emptyMap, ...?MapsClass.comments[widget.postId]};
      //   isUploading = false;
      // });
      try {
        await DatabaseService(docId: widget.postId).batchedUploadComment(
          commentMapFake, docRef, {'comments': FieldValue.increment(1)}
        );
        //await DatabaseService().uploadComment(commentMapFake, docRef);
       // setState(() {
        MapsClass.comments[widget.postId][docRef.id]['couldUpload'] = true;
        MapsClass.comments[widget.postId][docRef.id]['createdNow'] = null;
        MapsClass.comments[widget.postId][docRef.id]['couldUpload'] = null;
       // });
      } catch(err) {
        MapsClass.comments[widget.postId][docRef.id]['couldUpload'] = false;
      }
      setState(() {});
    }
  }

  getNewUsersTagged(commentInfo) async { 
    Map theTaggedUsersIdsMap = {};
    if (commentInfo['taggedUsersIds'].isNotEmpty) {
      //('called');
      Query query = FirebaseFirestore.instance.collection('users')
      .where('uid', whereIn: commentInfo['taggedUsersIds']);
      QuerySnapshot querySnapshot = await query.get();
      if (querySnapshot.docs.isNotEmpty) {
        await Future.wait(querySnapshot.docs.map((doc) async {
          Map aMap = {};
          aMap[doc.data()['uid']] = doc.data();
          theTaggedUsersIdsMap = {...?theTaggedUsersIdsMap, ...aMap};
          // MapsClass.comments[postId][commentId]['theTaggedUserInfo'] = {
          //   ...?MapsClass.comments[postId][commentId]['theTaggedUserInfo'], ...aMap
          // };
          //theCommentsMap[commentId]['theTaggedUsersInfo']
          //= {...theCommentsMap[commentId]['theTaggedUsersInfo'], ...aMap};
          await getNewCommTaggedFollowingState(doc.data()['uid']).then((val) {
            theTaggedUsersIdsMap[doc.data()['uid']]['isUserFollowing'] = val;
          });
        }));
        if (mounted) {
          setState(() {});
        }
      }
    }
    return theTaggedUsersIdsMap;
  }

  getNewCommTaggedFollowingState(commentUserInfo) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    bool value;
    await DatabaseService(
      uid: user.uid
    ).isFollowingUser(commentUserInfo)
    .then((val) {
      if (mounted) {
        value = val;
      }
    });
    return value;
  }

  var focusNode = FocusNode();

  bool commentIsReply = false;
  bool replyForReply = false;
  //String replyingTo = '';
  Map replyCommentInfo = {};
  Map replyingToMap = {};
  Map replyUserInfo = {};

  setReply(userId, userName, commentInfo, commentUserInfo, 
  replyForReply, replyUserName, replyUserUid) async {
    if (replyForReply == false) {
      //if (taggedUsersForUpload.isNotEmpty &&)
      //taggedUsersForUpload.clear();
      replyCommentInfo = {};
      replyingToMap.clear();
      replyUserInfo.clear();
      FocusScope.of(context).requestFocus(focusNode);
      setState(() {
        replyForReply = false;
        commentIsReply = true;
        replyingToMap[userId] = '$userName';
        replyCommentInfo = commentInfo;
        theComment = '';
        replyUserInfo[userId] = commentUserInfo;
        //taggedUsersForUpload[userName] = userId;
        //taggedUsersForUpload[userName] = userId;
      });
    } else {
      taggedUsersForUpload.clear();
      replyCommentInfo = {};
      replyingToMap.clear();
      replyUserInfo.clear();
      FocusScope.of(context).requestFocus(focusNode);
      setState(() {
        replyForReply = true;
        commentIsReply = true;
        replyingToMap[userId] = '$userName';
        replyCommentInfo = commentInfo;
        theComment = '@$replyUserName';
        replyUserInfo[userId] = commentUserInfo;
        taggedUsersForUpload[replyUserName] = replyUserUid;
        //taggedUsersForUpload[userName] = userId;
      });
      _commentController2 = RichTextController(
        text: '@${taggedUsersForUpload.keys.toList()[0]}',
        patternMap: {
          RegExp('@${taggedUsersForUpload.keys.toList()[0]}'): TextStyle(color:Colors.red),
        },
      );
      setState(() {
        _commentController2.selection = TextSelection
        .fromPosition(TextPosition(offset: _commentController2.text.length));
      });
    }
  }

  forLikeReplyState(value, commentId, replyId) {
    //setState(() {
      //theCommentsMap[commentId]['theReplies'][replyId]['userHasLiked'] = value;
      MapsClass.comments[widget.postId][commentId]['theReplies'][replyId]['userHasLiked'] = value;
    //});
  }

  forFollowingState(value, commentId, replyId) {
    //setState(() {
      //theCommentsMap[commentId]['theReplies'][replyId]['isUserFollowing'] = value;
      MapsClass.comments[widget.postId][commentId]['theReplies'][replyId]['isUserFollowing'] = value;
    //});
  }

  forGetReplies(commentId, Map anEmptyMap) {
    //setState(() { 
      
      //theCommentsMap[commentId]['theReplies'] = {...theCommentsMap[commentId]['theReplies'], ...anEmptyMap};
      MapsClass.comments[widget.postId][commentId]['theReplies'] = {
        ...?MapsClass.comments[widget.postId][commentId]['theReplies'], ...anEmptyMap
      };
    //});
  }
  forSeenReplies(Map aMap, commentId, isHide) {
    if (isHide == false) {
      MapsClass.comments[widget.postId][commentId]['theSeenReplies'] = {
        ...?MapsClass.comments[widget.postId][commentId]['theSeenReplies'],
        ...aMap
      };
      //theCommentsMap[commentId]['theSeenReplies'] = {
        //...theCommentsMap[commentId]['theSeenReplies'],
      //   ...aMap
      // };
    } else {
      MapsClass.comments[widget.postId][commentId]['theSeenReplies'] = {};
      //theCommentsMap[commentId]['theSeenReplies'] = {};
    }
  }

  forReplyTaggedUsers(commentId, replyId, Map aMap) {
    MapsClass.comments[widget.postId][commentId]['theReplies'][replyId]['theTaggedUsersInfo'] = {
      ...?MapsClass.comments[widget.postId][commentId]['theReplies'][replyId]['theTaggedUsersInfo'], ...aMap
    };
    // theCommentsMap[commentId]['theReplies'][replyId]['theTaggedUsersInfo']
    //   = {...theCommentsMap[commentId]['theReplies'][replyId]['theTaggedUsersInfo'], ...aMap};
  }
  forReplyTaggedUsersFollowingState(commentId, replyId, userUid, value) {
    MapsClass.comments[widget.postId][commentId]['theReplies'][replyId]['theTaggedUsersInfo']
    //theCommentsMap[commentId]['theReplies'][replyId]['theTaggedUsersInfo']
    [userUid]['isUserFollowing'] = value;
  }
  forCreateReplyTaggedUsers(commentId, replyId) {
    MapsClass.comments[widget.postId][commentId]['theReplies'][replyId]['theTaggedUsersInfo'] = {};
    //theCommentsMap[commentId]['theReplies'][replyId]['theTaggedUsersInfo'][userUid]
    //['isUserFollowing'] = {}
  }

  reply(userReplyingTo, parentReply) async {
    if (theComment.length != 0 && mounted) {
      setState(() {
        isUploading = true;
      });
      final user = Provider.of<CustomUser>(context, listen: false);
      DocumentReference docRef = FirebaseFirestore.instance.collection('posts')
      .doc(replyCommentInfo['postId']).collection('comments')
      .doc(replyCommentInfo['commentId']).collection('replies').doc();
      List theSplittedComment = theComment.split(' ');
      Map forTheTaggedUsersMap = {};
      for (int i = 0; i < theSplittedComment.length; i++) {
        if (!forTheTaggedUsersMap.values.toList().contains(theSplittedComment[i])) {
          if (theSplittedComment[i].startsWith('@')) {
            String theNewString = theSplittedComment[i].replaceAll('@', '');
            if (taggedUsersForUpload.keys.toList().contains(theNewString)) {
              forTheTaggedUsersMap[taggedUsersForUpload[theNewString]] = theSplittedComment[i];
              //forTheTaggedUsers.add(theSplittedComment[i]);
              //forTheTaggedUsersIds.add(taggedUsersForUpload[theNewString]);
            }
          }
        }
      }
      Map<String, dynamic> replyMap = {
        'parentReply': parentReply['commentId'],
        'replyingTo': userReplyingTo,
        'by': user.uid,
        'id': docRef.id,
        'reply': theComment,
        'likes': 0,
        'timeMs': DateTime.now().millisecondsSinceEpoch,
        'timeTS': DateTime.now(),
        'taggedUsers': forTheTaggedUsersMap.values.toList(),
        'taggedUsersIds': forTheTaggedUsersMap.keys.toList(),
        'taggedUsersMap': forTheTaggedUsersMap
      };

      Map emptyMap = {};
      setState(() {
        emptyMap[docRef.id] = {...replyMap};
        emptyMap[docRef.id]['timeTS'] = Timestamp.fromDate(emptyMap[docRef.id]['timeTS']);
        emptyMap[docRef.id]['theTaggedUsersInfo'] = {};
        emptyMap[docRef.id]['userHasLiked'] = false;
        emptyMap[docRef.id]['userInfo'] = widget.myInfo;
        emptyMap[docRef.id]['isUserFollowing'] = false;
        emptyMap[docRef.id]['createdNow'] = true;
        //MapsClass.comments[widget.postId][parentReply['commentId']]['replies'] += 1;
        MapsClass.comments[widget.postId][parentReply['commentId']]['theReplies'] = {
          ...emptyMap, 
          ...?MapsClass.comments[widget.postId][parentReply['commentId']]['theReplies']
        };
        MapsClass.comments[widget.postId][parentReply['commentId']]['theSeenReplies'] = {
          ...emptyMap, 
          ...?MapsClass.comments[widget.postId][parentReply['commentId']]['theSeenReplies']
        };
        //widget.commentInfo['replies']
        MapsClass.comments[widget.postId][parentReply['commentId']]['replies'] += 1;
        //MapsClass.comments[widget.postId] = {...emptyMap, ...?MapsClass.comments[widget.postId]};
      });
      if (MapsClass.posts[widget.postId] != null) {
        setState(() {
          MapsClass.posts[widget.postId]['comments'] += 1;
        });
      }
      if (MapsClass.userPosts[widget.post['postedBy']] != null) {
        if (MapsClass.userPosts[widget.post['postedBy']]['posts'][widget.postId] != null) {
          setState(() {
            MapsClass.userPosts[widget.post['postedBy']]['posts'][widget.postId]['comments'] += 1;
          });
        }
      }
      widget.refresh();
      Map theReplyCommentInfoAgain = {...replyCommentInfo};
      //theReplyCommentInfo ;
      setState(() {
        _commentController2.text = '';
        theComment = '';
        theWords = [];
        theTaggedUsers = [];
        taggedUsersId = [];
        commentIsReply = false;
        taggedUsersForUpload = {};
        replyCommentInfo = {};
        replyingToMap.clear();
        replyUserInfo.clear();
        theWord = '';
        isUploading = false;
      });
      FocusScope.of(context).unfocus();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.animateTo(
          scrollController.position.minScrollExtent,
          duration: Duration(milliseconds: 350), 
          curve: Curves.ease
        );
      });

      if (MapsClass.comments[widget.postId][parentReply['commentId']]
        ['theReplies'][docRef.id]['taggedUsersIds'].length > 0) {
        try {
          await getNewUsersTagged(
            replyMap,
          ).then((dynamic val) {
            //print(val);
            MapsClass.comments[widget.postId][parentReply['commentId']]
              ['theReplies'][docRef.id]['theTaggedUsersInfo'] = val;
            MapsClass.comments[widget.postId][parentReply['commentId']]
              ['theSeenReplies'][docRef.id]['theTaggedUsersInfo'] = val;
            isUploading = false;
            //emptyMap[querySnapshot.docs[0].data()['commentId']]['theTaggedUsersInfo'] = val;
          });
        } catch(err) {
          MapsClass.comments[widget.postId][parentReply['commentId']]
            ['theReplies'][docRef.id]['couldUpload'] = false;
          MapsClass.comments[widget.postId][parentReply['commentId']]
            ['theSeenReplies'][docRef.id]['theTaggedUsersInfo'] = false;
        }
      }
      setState(() {
        isUploading = false;
      });
      try {
        await DatabaseService(
          docId: theReplyCommentInfoAgain['postId']
        ).createReplyBatch(
          {'comments': FieldValue.increment(1)}, 
          {'replies': FieldValue.increment(1)}, 
          theReplyCommentInfoAgain['commentId'], 
          replyMap, 
          docRef
        );
        // await DatabaseService().createReply(replyMap, docRef);
        // DocumentReference docRef1 = FirebaseFirestore.instance.collection('posts')
        //   .doc(theReplyCommentInfoAgain['postId']).collection('comments')
        //   .doc(theReplyCommentInfoAgain['commentId']);
        // await DatabaseService().updateReplyCount(
        //   {'replies': FieldValue.increment(1)},
        //   docRef1
        // );
        //setState(() {
          MapsClass.comments[widget.postId][parentReply['commentId']]
            ['theReplies'][docRef.id]['couldUpload'] = true;
          MapsClass.comments[widget.postId][parentReply['commentId']]
            ['theSeenReplies'][docRef.id]['couldUpload'] = true;
          MapsClass.comments[widget.postId][parentReply['commentId']]
            ['theReplies'][docRef.id]['createdNow'] = null;
          MapsClass.comments[widget.postId][parentReply['commentId']]
            ['theSeenReplies'][docRef.id]['createdNow'] = null;

          MapsClass.comments[widget.postId][parentReply['commentId']]
            ['theReplies'][docRef.id]['couldUpload'] = null;
          MapsClass.comments[widget.postId][parentReply['commentId']]
            ['theSeenReplies'][docRef.id]['couldUpload'] = null;
        //});
      } catch(err) {
        MapsClass.comments[widget.postId][parentReply['commentId']]
          ['theReplies'][docRef.id]['couldUpload'] = false;
        MapsClass.comments[widget.postId][parentReply['commentId']]
          ['theSeenReplies'][docRef.id]['couldUpload'] = false;
      }
      setState(() {});
    }
  }

  getNewUsersTaggedInReply(replyInfo) async { 
    Map theTaggedUsersIdsMap = {};
    if (replyInfo['taggedUsersIds'].isNotEmpty) {
      //('called');
      Query query = FirebaseFirestore.instance.collection('users')
      .where('uid', whereIn: replyInfo['taggedUsersIds']);
      QuerySnapshot querySnapshot = await query.get();
      if (querySnapshot.docs.isNotEmpty) {
        await Future.wait(querySnapshot.docs.map((doc) async {
          Map aMap = {};
          aMap[doc.data()['uid']] = doc.data();
          theTaggedUsersIdsMap = {...?theTaggedUsersIdsMap, ...aMap};
          // MapsClass.comments[postId][commentId]['theTaggedUserInfo'] = {
          //   ...?MapsClass.comments[postId][commentId]['theTaggedUserInfo'], ...aMap
          // };
          //theCommentsMap[commentId]['theTaggedUsersInfo']
          //= {...theCommentsMap[commentId]['theTaggedUsersInfo'], ...aMap};
          await getNewCommTaggedFollowingState(doc.data()['uid'],).then((val) {
            theTaggedUsersIdsMap[doc.data()['uid']]['isUserFollowing'] = val;
          });
        }));
        if (mounted) {
          setState(() {});
        }
      }
    }
    return theTaggedUsersIdsMap;
  }


  getReplyUserInfo(postUserUid, postId, commentId, replyId) async {
    await DatabaseService(uid: postUserUid).getUserByUidFuture().then((val) async {
      setState(() { 
        MapsClass.comments[postId][commentId]['theReplies'][replyId]['userInfo'] = val.data();
      });
    });
    //await loadReplyProfileImgs(postId, commentId, replyId);
    //await loadReplyProfileBannerImgs(postId, commentId, replyId);
  }

  /*loadReplyProfileImgs(postId, commentId, replyId) async {
    var configuration = createLocalImageConfiguration(context);
    CachedNetworkImageProvider loadedImg = CachedNetworkImageProvider("${MapsClass.comments[postId][commentId]['theReplies'][replyId]['userInfo']['profileImg']}")..resolve(configuration);
    setState(() {
      MapsClass.comments[postId][commentId]['theReplies'][replyId]['userInfo']['loadedProfileImg'] = loadedImg;
    });
  }

  loadReplyProfileBannerImgs(postId, commentId, replyId) async {
    var configuration = createLocalImageConfiguration(context);
    CachedNetworkImageProvider loadedImg = CachedNetworkImageProvider("${MapsClass.comments[postId][commentId]['theReplies'][replyId]['userInfo']['bannerImg']}")..resolve(configuration);
    setState(() {
      MapsClass.comments[postId][commentId]['theReplies'][replyId]['userInfo']['loadedProfileBannerImg'] = loadedImg;
    });
  }*/

  ScrollController scrollController = ScrollController();
  DocumentSnapshot firstDoc;
  int prevPost;
  DocumentSnapshot lastDocument;
  bool gettingMorePosts = false;
  bool morePostsAvailable = true;
  List<DocumentSnapshot> theCommentsList =  [];


  Map theCommentsMap = {};

  getTaggedFollowingState(commentUserInfo, commentId, postId) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    await DatabaseService(
      uid: user.uid
    ).isFollowingUser(commentUserInfo)
    .then((value) {
      if (mounted) {
        MapsClass.comments[postId][commentId]['theTaggedUsersInfo']
        //theCommentsMap[commentId]['theTaggedUsersInfo']
        [commentUserInfo]['isUserFollowing'] = value;
      }
    });
  }

  getUsersTagged(commentInfo, commentId, postId) async {
    if (commentInfo['taggedUsersIds'].isNotEmpty) {
      //('called');
      Query query = FirebaseFirestore.instance.collection('users')
      .where('uid', whereIn: commentInfo['taggedUsersIds']);
      QuerySnapshot querySnapshot = await query.get();
      if (querySnapshot.docs.isNotEmpty) {
        await Future.wait(querySnapshot.docs.map((doc) async {
          Map aMap = {};
          aMap[doc.data()['uid']] = doc.data();
          MapsClass.comments[postId][commentId]['theTaggedUsersInfo'] = {
            ...?MapsClass.comments[postId][commentId]['theTaggedUsersInfo'], ...aMap
          };
          //theCommentsMap[commentId]['theTaggedUsersInfo']
          //= {...theCommentsMap[commentId]['theTaggedUsersInfo'], ...aMap};
          await getTaggedFollowingState(doc.data()['uid'], commentId, postId);
          //await loadTaggedProfileImgs(postId, commentId, doc.data()['uid']);
          //await loadTaggedProfileBannerImgs(postId, commentId, doc.data()['uid']);
        }));
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  getLikedState(postId, commentId) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    await DatabaseService(
      docId: postId,
      uid: user.uid
    ).hasLikedComments(commentId).then((value) {
      if (mounted) {
        MapsClass.comments[postId][commentId]['userHasLiked'] = value;
        //theCommentsMap[commentId]['userHasLiked'] = value;
      }
    });
  }

  getUserInfo(postUserUid, postId, commentId) async {
    await DatabaseService(uid: postUserUid).getUserByUidFuture().then((val) async {
      setState(() { 
        MapsClass.comments[postId][commentId]['userInfo'] = val.data();
      });
    });
    // await loadProfileImgs(postId, commentId);
    // await loadProfileBannerImgs(postId, commentId);
  }

  // loadProfileImgs(postId, commentId) async {
  //   var configuration = createLocalImageConfiguration(context);
  //   CachedNetworkImageProvider loadedImg = CachedNetworkImageProvider("${MapsClass.comments[postId][commentId]['userInfo']['profileImg']}")..resolve(configuration);
  //   setState(() {
  //     MapsClass.comments[postId][commentId]['userInfo']['loadedProfileImg'] = loadedImg;
  //   });
  // }

  // loadProfileBannerImgs(postId, commentId) async {
  //   var configuration = createLocalImageConfiguration(context);
  //   CachedNetworkImageProvider loadedImg = CachedNetworkImageProvider("${MapsClass.comments[postId][commentId]['userInfo']['bannerImg']}")..resolve(configuration);
  //   setState(() {
  //     MapsClass.comments[postId][commentId]['userInfo']['loadedProfileBannerImg'] = loadedImg;
  //   });
  // }

  getFollowingState(commentUserInfo, commentId, postId) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    await DatabaseService(
      uid: user.uid
    ).isFollowingUser(commentUserInfo)
    .then((value) {
      if (mounted) {
        MapsClass.comments[postId][commentId]['isUserFollowing'] = value;
        //theCommentsMap[commentId]['isUserFollowing'] = value;
      }
    });
  }

  checkIfUserFollowsAndHasLikedComment(Map commentData, commentId) async {
    await getLikedState(commentData['postId'], commentId);
    await getFollowingState(commentData['commentedBy'], commentId, commentData['postId']);
    //await getUsersTagged(theCommentsMap[commentId], commentId);
    await getUserInfo(commentData['commentedBy'], commentData['postId'], commentId);
    await getUsersTagged(MapsClass.comments[commentData['postId']][commentId], commentId, commentData['postId']);
    //print(theCommentsMap[commentId]);
  }

  //getComments() {
  getComments() async {
    //print(MapsClass.comments[widget.postId]);
    Query theQuery = FirebaseFirestore.instance.collection('posts')
    .doc(widget.post['id']).collection('comments')
    .orderBy('likes', descending: true).limit(15);
    setState(() {});
    QuerySnapshot querySnapshot = await theQuery.get();
    if (querySnapshot.docs.length != 0) {
      //MapsClass.comments = {};
      MapsClass.comments[widget.postId] = {};
      await Future.wait(querySnapshot.docs.map((doc) async {
        MapsClass.comments[widget.postId][doc.data()['commentId']] = doc.data();
        MapsClass.comments[widget.postId][doc.data()['commentId']]['theReplies'] = {};
        MapsClass.comments[widget.postId][doc.data()['commentId']]['theSeenReplies'] = {};
        MapsClass.comments[widget.postId][doc.data()['commentId']]['theTaggedUsersInfo'] = {};
        await checkIfUserFollowsAndHasLikedComment(doc.data(), doc.data()['commentId']);
      }));
      //print('the comments getted: ${MapsClass.comments[widget.postId]}');
      lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
      setState(() {});
    } else {
      setState(() {
        morePostsAvailable = false;
      });
    }
  }

  getMoreComments() async {
    if (morePostsAvailable == false) {
      //print('sapo');
      return;
    }
    if (gettingMorePosts == true) {
      return;
    }
    //print('toro');
    gettingMorePosts = true;
    Query theQuery = FirebaseFirestore.instance.collection('posts')
    .doc(widget.post['id']).collection('comments')
    .orderBy('likes', descending: true)
    .startAfterDocument(lastDocument)
    .limit(15);
    QuerySnapshot querySnapshot = await theQuery.get();
    if (querySnapshot.docs.length < 15 || querySnapshot.docs.length == 0) {
      morePostsAvailable = false;
    }
    if (querySnapshot.docs.length != 0) {
      lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
      await Future.wait(querySnapshot.docs.map((doc) async {
        MapsClass.comments[widget.postId][doc.data()['commentId']] = doc.data();
        MapsClass.comments[widget.postId][doc.data()['commentId']]['theReplies'] = {};
        MapsClass.comments[widget.postId][doc.data()['commentId']]['theSeenReplies'] = {};
        MapsClass.comments[widget.postId][doc.data()['commentId']]['theTaggedUsersInfo'] = {};
        // theCommentsMap[doc.data()['commentId']] = doc.data();
        // theCommentsMap[doc.data()['commentId']]['theReplies'] = {};
        // theCommentsMap[doc.data()['commentId']]['theSeenReplies'] = {};
        // theCommentsMap[doc.data()['commentId']]['theTaggedUsersInfo'] = {};
        await checkIfUserFollowsAndHasLikedComment(doc.data(), doc.data()['commentId']);
      }));
      setState(() {
        gettingMorePosts = false;
      });
    } else {
      setState(() {
        morePostsAvailable = false;
      });
    }
    /*if (mounted) {
      setState(() {});
    }*/

  }

  //tagging system

  Map<String, dynamic> taggedUsersForUpload = {};

  List<DocumentSnapshot> theTaggedUsers = [];
  List taggedUsersId = [];

  searchForTaggedUsers() async {
    String theNewWord = theWord.replaceAll('@', '');
    Query theQuery = FirebaseFirestore.instance.collection('users')
    .where('userNameIndex', arrayContains: theNewWord).limit(12);
    QuerySnapshot querySnapshot = await theQuery.get();
    theTaggedUsers = [];
    taggedUsersId = [];
    if (querySnapshot.docs.isNotEmpty) {
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        if (!theTaggedUsers.contains(querySnapshot.docs[i])) {
          theTaggedUsers.add(querySnapshot.docs[i]);
          taggedUsersId.add(querySnapshot.docs[i].data()['username']);
        }
      }
    }
    setState(() {});
    //print(theTaggedUsers.length);
  }

  void thatAutoCompleteFunction(userName, userUid) {
    String newWord = theWord.substring(1, theWord.length);
    setState((){
      theWords = [];
      theTaggedUsers = [];
      taggedUsersId = [];
      theWord = '';
      _commentController2.text += 
      userName.substring(userName.indexOf(newWord)+newWord.length,userName.length)
      .replaceAll(' ','_');
      theComment = _commentController2.text;
      taggedUsersForUpload[userName] = userUid;
      if (replyingToMap.isNotEmpty) {
        taggedUsersForUpload[replyingToMap.values.toList()[0]] = replyingToMap.keys.toList()[0];
      }
      //taggedUsersForUpload.add(theComment);
    });
    _commentController2 = RichTextController(
      text: _commentController2.text,
      patternMap: taggedUsersForUpload.length == 1 ? {
        RegExp('@${taggedUsersForUpload.keys.toList()[0]}'): TextStyle(color:Colors.red),
      } : taggedUsersForUpload.length == 2 ? {
        RegExp('@${taggedUsersForUpload.keys.toList()[0]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[1]}'): TextStyle(color:Colors.red),
      } : taggedUsersForUpload.length == 3 ? {
        RegExp('@${taggedUsersForUpload.keys.toList()[0]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[1]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[2]}'): TextStyle(color:Colors.red),
      } : taggedUsersForUpload.length == 4 ? {
        RegExp('@${taggedUsersForUpload.keys.toList()[0]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[1]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[2]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[3]}'): TextStyle(color:Colors.red),
      } : taggedUsersForUpload.length == 5 ? {
        RegExp('@${taggedUsersForUpload.keys.toList()[0]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[1]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[2]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[3]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[4]}'): TextStyle(color:Colors.red),
      } : {
        RegExp('@${taggedUsersForUpload.keys.toList()[0]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[1]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[2]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[3]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[4]}'): TextStyle(color:Colors.red),
      }
    );
    setState(() {
      _commentController2.selection = TextSelection
      .fromPosition(TextPosition(offset: _commentController2.text.length));
    });
  }

  List theWords = [];
  String theWord = '';

  theAsyncCall() async {
    await getComments();
    setState(() {
      isLoadingComments = false;
    });
  }

  @override
  void initState() {
    isLoadingComments = true;
    _commentController2 = RichTextController(
      patternMap: //{}
      taggedUsersForUpload.length == 0 ? {
        RegExp(''): TextStyle(color:Colors.red),
      } :
      taggedUsersForUpload.length == 1 ? {
        RegExp('@${taggedUsersForUpload.keys.toList()[0]}'): TextStyle(color:Colors.red),
      } : taggedUsersForUpload.length == 2 ? {
        RegExp('@${taggedUsersForUpload.keys.toList()[0]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[1]}'): TextStyle(color:Colors.red),
      } : taggedUsersForUpload.length == 3 ? {
        RegExp('@${taggedUsersForUpload.keys.toList()[0]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[1]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[2]}'): TextStyle(color:Colors.red),
      } : taggedUsersForUpload.length == 4 ? {
        RegExp('@${taggedUsersForUpload.keys.toList()[0]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[1]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[2]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[3]}'): TextStyle(color:Colors.red),
      } : taggedUsersForUpload.length == 5 ? {
        RegExp('@${taggedUsersForUpload.keys.toList()[0]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[1]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[2]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[3]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[4]}'): TextStyle(color:Colors.red),
      } : {
        RegExp('@${taggedUsersForUpload.keys.toList()[0]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[1]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[2]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[3]}'): TextStyle(color:Colors.red),
        RegExp('@${taggedUsersForUpload.keys.toList()[4]}'): TextStyle(color:Colors.red),
      }
    );
    super.initState();
    isFollowing = widget.isFollowing;
    //getComments();
    //print('rana $isLoadingComments');
    theAsyncCall();
    //getComments();
    //print('sapo $isLoadingComments');
    //_listKey = GlobalKey<SliverAnimatedListState>();
    scrollController.addListener(() {
      double maxScroll = scrollController.position.maxScrollExtent;
      double currentScroll = scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.75;
      //print(currentScroll);
      if (maxScroll - currentScroll < delta) {
        getMoreComments();
      }
    });
    //WidgetsBinding.instance.addPostFrameCallback(_getTotalHeight);
    //commentController.addListener(() { });

  }

  GlobalKey _globalKey = GlobalKey();
  double _dynamicTotalHeight;

  double _getWidgetHeight(GlobalKey key) {
    RenderBox renderBox = key.currentContext.findRenderObject();
    return renderBox.size.height;
  }

  _getTotalHeight(_) {
    _dynamicTotalHeight = 0;
    _dynamicTotalHeight = _getWidgetHeight(_globalKey);
    //_dynamicTotalHeight = _dynamicTotalHeight;
    return _dynamicTotalHeight;
  }

  void cancelReply() {
    setState(() {
      commentIsReply = false;
      replyingToMap.clear();
      replyCommentInfo = {};
      replyUserInfo.clear();
    });
  }

  List<Widget> sliverChilds() {
    if (theTaggedUsers.length <= 0) {
      //print(_dynamicTotalHeight);
      return [
        isLoadingComments == false 
        ? MapsClass.comments[widget.postId] != null //widget.post != null
          ? 
          CommentsChild(
            theCommentsMap: MapsClass.comments[widget.postId],
            reply: setReply,
            commentSettings: preCommentSettings,
            replySettings: preReplySettings,
            getLikeState: getLikedState,
            forLikeReplyState: forLikeReplyState,
            forFollowingState: forFollowingState,
            forGetReplies: forGetReplies,
            forReplyTaggedUsers: forReplyTaggedUsers,
            forReplyTaggedUsersFollowingState: forReplyTaggedUsersFollowingState,
            forCreateReplyTaggedUsers: forCreateReplyTaggedUsers,
            getFollowingStateComment: getFollowingState,
            getFollowingStateCommentTagged: getTaggedFollowingState,
            forSeenReplies: forSeenReplies,
            myInfo: widget.myInfo,
            //getReplies: getReplies,
            //getReplyLikeState: getReplyLikeState,
            //getMoreReplies: getMoreReplies,
          )
          : SliverFixedExtentList(
            delegate: SliverChildListDelegate(
              [
                Container(
                  //height: 70,
                  //color: Colors.red,
                  child: Center(
                    child: Text(
                      'No comments',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 17,
                        fontWeight: FontWeight.w700
                      )
                    ),
                  )
                )
              ]
            ),
            itemExtent: 80
          )
        : SliverToBoxAdapter(
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: CupertinoActivityIndicator(
                radius: 14
              )
            ),
          ),
        )
      ];
    } else {
      return [SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return TaggedUsersList(
              theTaggedUser: theTaggedUsers[index],
              //theCommentController: commentController,
              //theWord: theWord,
              theAutoCompleteFunction: thatAutoCompleteFunction,
            );
          },
          childCount: theTaggedUsers.length,
        ),
      )];
    }
  }

  @override
  void dispose() {
    super.dispose();
    _commentController2.dispose();
    scrollController.dispose();
    theCommentsList.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Container(
            //color: Colors.red,
            //margin: EdgeInsets.only(top: 8),
            child: Stack(
              //mainAxisSize: MainAxisSize.min,
              //mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  //color: Colors.red,
                  margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 60),
                  child: 
                  /*NestedScrollView(
                    controller: scrollController,
                    headerSliverBuilder: (theContext, innerBoxIsScrolled) {
                      return sliverChilds(theContext);
                    },
                    body: Container()
                  )*/
                  CustomScrollView(
                    controller: scrollController,
                    //shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    slivers: sliverChilds()
                  )
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    //height: 45 + MediaQuery.of(context).padding.bottom,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: Offset(0, -2), // changes position of shadow
                        ),
                      ],
                    ),
                    padding: EdgeInsets.only(
                      top: 6,
                      bottom: 8,
                      left: 8,
                      right: 8,
                      //horizontal: 8, vertical: 8
                    ),
                    child: Container(
                      margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                      //padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          replyUserInfo.length > 0 && commentIsReply == true
                          ? Container(
                            child: ReplyUserInfo(
                              userInfo: replyUserInfo.values.toList()[0],
                              cancelReply: cancelReply
                            )
                          )
                          : Container(),
                          Flexible(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  flex: 8,
                                  child: Container(
                                    //height: 40,
                                    decoration: BoxDecoration(
                                      //color: Colors.red,
                                      border: Border.all(color: Colors.greenAccent[700], width:1.2),
                                      borderRadius: BorderRadius.circular(12)
                                    ),
                                    child: TextField(
                                      focusNode: focusNode,
                                      keyboardType: TextInputType.text,
                                      controller: _commentController2,
                                      maxLines: 4,
                                      minLines: 1,
                                      autocorrect: false,
                                      onChanged: (value) {
                                        setState(() {
                                          theComment = value;
                                          theWords = value.split(' ');
                                          if (theWords.length > 0) {
                                            if (theWords[theWords.length - 1].startsWith('@')) {
                                              theWord = theWords[theWords.length - 1];
                                            } else {
                                              theWord = '';
                                            }
                                          } else {
                                            theWord = '';
                                          }
                                          if (theWord.length == 0) {
                                            //theHashtags = {};
                                            theTaggedUsers = [];
                                            taggedUsersId = [];
                                          }
                                          /*theWord = theWords.length > 0 &&
                                            theWords[theWords.length - 1].startsWith('@')
                                            ? theWords[theWords.length - 1]
                                            : '';*/
                                          if (theWord.length > 0) {
                                            if (theWords[theWords.length - 1].startsWith('@')) {
                                              searchForTaggedUsers();
                                            }
                                          }
                                            //&& theWords[theWords.length - 1].startsWith('@')) {
                                            //searchForTaggedUsers();
                                          //}
                                        });
                                        //print(commentIsReply);
                                      },
                                      textCapitalization: TextCapitalization.sentences,
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLength: 120,
                                      buildCounter: (BuildContext context, { int currentLength, int maxLength, bool isFocused }) => null,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                                        isDense: true,
                                        border: InputBorder.none,
                                        //counter: SizedBox.shrink(),
                                        //counterText: '',
                                        hintText: commentIsReply != true ? 'Add a comment...' : 'Reply to ${replyingToMap.values.toList()[0]}',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 17,
                                          //height: 2,
                                          fontWeight: FontWeight.w600,
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
                                        if (isUploading == false) {
                                          if (commentIsReply != true) {
                                            uploadComment();
                                          } else {
                                            reply(replyingToMap.keys.toList()[0], replyCommentInfo);
                                          }
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
                            ),
                          )
                        ],
                      )
                    )
                  )
                )
              ],
            )
          )
      ),
    );
  }
}
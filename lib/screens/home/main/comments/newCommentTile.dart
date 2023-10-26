import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled_startup/models/user.dart';
import 'package:untitled_startup/screens/home/main/classes/mapsClass.dart';
import 'package:untitled_startup/screens/home/main/comments/replies.dart';
import 'package:untitled_startup/screens/home/userProfile/profiles.dart';
import 'package:untitled_startup/services/cacheClass/cacheManager.dart';
import 'package:untitled_startup/services/database.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class NewCommentTile extends StatefulWidget {
  final Map<String, dynamic> myInfo;
  final Map<String, dynamic> commentInfo;
  final Map<String, dynamic> commentUserInfo;
  final String timeAgo;
  final Function reply;
  final Function commentSettings;
  final Function replySettings;
  final Function getLikeState;
  final int index;
  final int commentInfoLength;
  //final Function getReplies;
  final Function getFollowingStateComment;
  final Function getFollowingStateCommentTagged;
  //final Function getReplyLikeState;
  //final Function getMoreReplies;
  final Function forLikeReplyState;
  final Function forFollowingState;
  final Function forGetReplies;
  final Function forReplyTaggedUsers;
  final Function forReplyTaggedUsersFollowingState;
  final Function forCreateReplyTaggedUsers;
  final Function forSeenReplies;
  NewCommentTile({this.timeAgo, this.commentInfo, this.commentUserInfo,
  this.reply, this.commentSettings, this.getLikeState, this.index, 
  this.commentInfoLength, this.forFollowingState, this.forGetReplies,
  this.forLikeReplyState, this.forReplyTaggedUsersFollowingState,
  this.forReplyTaggedUsers, this.forCreateReplyTaggedUsers, 
  this.getFollowingStateComment, this.getFollowingStateCommentTagged,
  this.forSeenReplies, this.myInfo, this.replySettings, Key key}) : super(key: key);

  //ValueNotifier anim = ValueNotifier(false);
  @override
  _NewCommentTileState createState() => _NewCommentTileState();
}

class _NewCommentTileState extends State<NewCommentTile> with TickerProviderStateMixin {
  AnimationController likeAnim;
  Animation<double> likeIconSize;
  bool isLiking = false;
  bool userHasLiked = false;

  List theTaggedUsersArray = [];
  Map<String, Map<String, dynamic>> theTaggedUsersMap = {};  

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
      .likeComment(likeCommentMap, widget.commentInfo['commentId']);
    DatabaseService(docId: widget.commentInfo['postId'])
    .incrementCommentLikeCount(widget.commentInfo['commentId'], 
    {'likes': FieldValue.increment(1)});
    setState(() => isLiking = false);
    widget.getLikeState(
      widget.commentInfo['postId'],
      widget.commentInfo['commentId'],
    );
  }

  unlikeComment() {
    setState(() => isLiking = true); 
    final user = Provider.of<CustomUser>(context, listen: false);
    likeAnim.forward().whenComplete(() {
      likeAnim.reset();
    });
    DatabaseService(docId: widget.commentInfo['postId'], uid: user.uid)
      .unlikeComment(widget.commentInfo['commentId']);
    DatabaseService(docId: widget.commentInfo['postId'])
    .incrementCommentLikeCount(widget.commentInfo['commentId'],
    {'likes': FieldValue.increment(-1)});
    setState(() => isLiking = false);
    widget.getLikeState(
      widget.commentInfo['postId'],
      widget.commentInfo['commentId'],
    );
  }

  List<DocumentSnapshot> commentReplies = [];
  Map theRepliesMap = {};
  DocumentSnapshot lastDocument;
  bool gettingMorePosts = false;
  bool morePostsAvailable = true;

  getTaggedFollowingState(commentUserInfo, commentId, replyId) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    await DatabaseService(
      uid: user.uid
    ).isFollowingUser(commentUserInfo)
    .then((value) {
      //if (mounted) {
      widget.forReplyTaggedUsersFollowingState(commentId, replyId, commentUserInfo, value);
      //}
    });
  }
  getUsersTaggedReplies(commentInfo, commentId, replyId) async {
    if (commentInfo['taggedUsersIds'].isNotEmpty) {
      Query query = FirebaseFirestore.instance.collection('users')
      .where('uid', whereIn: commentInfo['taggedUsersIds']);
      QuerySnapshot querySnapshot = await query.get();
      if (querySnapshot.docs.isNotEmpty) {
        await Future.wait(querySnapshot.docs.map((doc) async {
          Map aMap = {};
          aMap[doc.data()['uid']] = doc.data();
          widget.forReplyTaggedUsers(commentId, replyId, aMap);
          await getTaggedFollowingState(doc.data()['uid'], commentId, replyId);
          // await loadTaggedProfileImgs(widget.commentInfo['postId'], commentId, doc.data()['uid'], replyId);
          // await loadTaggedProfileBannerImgs(widget.commentInfo['postId'], commentId, doc.data()['uid'], replyId);
        }));
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  // loadTaggedProfileImgs(postId, commentId, replyUserUid, replyId) async {
  //   var configuration = createLocalImageConfiguration(context);
  //   CachedNetworkImageProvider loadedImg = CachedNetworkImageProvider("${MapsClass.comments[postId][commentId]['theReplies'][replyId]['theTaggedUsersInfo'][replyUserUid]['profileImg']}")..resolve(configuration);
  //   setState(() {
  //     MapsClass.comments[postId][commentId]['theReplies'][replyId]['theTaggedUsersInfo'][replyUserUid]['loadedProfileImg'] = loadedImg;
  //   });
  // }

  // loadTaggedProfileBannerImgs(postId, commentId, replyUserUid, replyId) async {
  //   var configuration = createLocalImageConfiguration(context);
  //   CachedNetworkImageProvider loadedImg = CachedNetworkImageProvider("${MapsClass.comments[postId][commentId]['theReplies'][replyId]['theTaggedUsersInfo'][replyUserUid]['bannerImg']}")..resolve(configuration);
  //   setState(() {
  //      MapsClass.comments[postId][commentId]['theReplies'][replyId]['theTaggedUsersInfo'][replyUserUid]['loadedProfileBannerImg'] = loadedImg;
  //   });
  // }


  getUserInfo(postUserUid, postId, commentId, replyId) async {
    await DatabaseService(uid: postUserUid).getUserByUidFuture().then((val) async {
      setState(() { 
        MapsClass.comments[postId][commentId]['theReplies'][replyId]['userInfo'] = val.data();
      });
    });
    // await loadProfileImgs(postId, commentId, replyId);
    // await loadProfileBannerImgs(postId, commentId, replyId);
  }

  /*loadProfileImgs(postId, commentId, replyId) async {
    var configuration = createLocalImageConfiguration(context);
    CachedNetworkImageProvider loadedImg = CachedNetworkImageProvider("${MapsClass.comments[postId][commentId]['theReplies'][replyId]['userInfo']['profileImg']}")..resolve(configuration);
    setState(() {
      MapsClass.comments[postId][commentId]['theReplies'][replyId]['userInfo']['loadedProfileImg'] = loadedImg;
    });
  }

  loadProfileBannerImgs(postId, commentId, replyId) async {
    var configuration = createLocalImageConfiguration(context);
    CachedNetworkImageProvider loadedImg = CachedNetworkImageProvider("${MapsClass.comments[postId][commentId]['theReplies'][replyId]['userInfo']['bannerImg']}")..resolve(configuration);
    setState(() {
      MapsClass.comments[postId][commentId]['theReplies'][replyId]['userInfo']['loadedProfileBannerImg'] = loadedImg;
    });
  }*/

  getReplyLikeState(postId, replyId, commentId) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    await DatabaseService(
      docId: postId,
      uid: user.uid
    ).hasLikedReplys(commentId, replyId).then((value) {
      if (mounted) {
        widget.forLikeReplyState(value, commentId, replyId);
      }
    });
  }
  getReplyFollowingState(commentUserInfo, commentId, replyId) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    await DatabaseService(
      uid: user.uid
    ).isFollowingUser(commentUserInfo)
    .then((value) {
      if (mounted) {
        //setState(() {
        widget.forFollowingState(value, commentId, replyId);
      }
    });
    //print(theCommentsMap[commentId]);
  }

  bool canRetriveMore = true;
  int increaseMaxCount = 0;
  int currentCount = -3;
  Map mapForPairs = {};


  checkIfUserFollowsAndHasLikedReply(Map commentData, commentId, replyId, postId) async {
    await getReplyLikeState(postId, replyId, commentId);
    await getReplyFollowingState(commentData['by'], commentId, replyId);
    await getUserInfo(commentData['by'], postId, commentId, replyId);
    await getUsersTaggedReplies(
      widget.commentInfo['theReplies'][replyId], commentId, replyId
    );
    //print(theCommentsMap[commentId]);
  }


  //######################################
  //######################################
  //######################################

  DocumentSnapshot replyLastDoc;
  bool moreRepliesAvailable = true;
  bool gettingMoreReplies = false;

  getReplies(postId, commentId) async {
    Query theQuery = FirebaseFirestore.instance.collection('posts')
    .doc(postId).collection('comments')
    .doc(commentId).collection('replies')
    .orderBy('timeTS', descending: false).limit(3);
    setState(() {});
    QuerySnapshot querySnapshot = await theQuery.get();
    //print('length is ${querySnapshot.docs.length}');
    if (querySnapshot.docs.length != 0) {
      await Future.wait(querySnapshot.docs.map((doc) async {
        Map anEmptyMap = {};
        anEmptyMap[doc.data()['id']] = doc.data();
        widget.forGetReplies(commentId, anEmptyMap);
        widget.forCreateReplyTaggedUsers(
          commentId,
          doc.data()['id']
        );
        //setState(() {
        //theCommentsMap[commentId]['theReplies'] = {...theCommentsMap[commentId]['theReplies'], ...anEmptyMap};
        //});
        //theCommentsMap[doc.data()['commentId']]['theReplies'] = {};
        await checkIfUserFollowsAndHasLikedReply(doc.data(), doc.data()['parentReply'], doc.data()['id'], postId);
      }));
      replyLastDoc = querySnapshot.docs[querySnapshot.docs.length - 1];
      //print(theCommentsMap[commentId]['theReplies']);
    } else {
      //if (mounted) {
        setState(() {
          moreRepliesAvailable = false;
        });
      //}
    }
  }

  getMoreReplies(postId, commentId) async {
    //print('hello');
    if (moreRepliesAvailable == false) {
      return;
    }
    if (gettingMoreReplies == true) {
      return;
    }
    //print('till here');
    //print(replyLastDoc.data()['reply']);
    Query theQuery = FirebaseFirestore.instance.collection('posts')
    .doc(postId).collection('comments')
    .doc(commentId).collection('replies')
    .orderBy('timeTS', descending: false)
    .startAfterDocument(replyLastDoc).
    limit(3);
    setState(() {});
    QuerySnapshot querySnapshot = await theQuery.get();
    //print('the length is ${querySnapshot.docs.length}');
    if (querySnapshot.docs.length < 3 || querySnapshot.docs.length == 0) {
      moreRepliesAvailable = false;
    }
    if (querySnapshot.docs.length != 0) {
      await Future.wait(querySnapshot.docs.map((doc) async {
        Map anEmptyMap = {};
        anEmptyMap[doc.data()['id']] = doc.data();
        widget.forGetReplies(commentId, anEmptyMap);
        widget.forCreateReplyTaggedUsers(
          commentId,
          doc.data()['id']
        );
        //theCommentsMap[commentId]['theReplies'] = {...theCommentsMap[commentId]['theReplies'], ...anEmptyMap};
        await checkIfUserFollowsAndHasLikedReply(doc.data(), doc.data()['parentReply'], doc.data()['id'], postId);
      }));
      replyLastDoc = querySnapshot.docs[querySnapshot.docs.length - 1];
    } else {
      setState(() {
        moreRepliesAvailable = false;
      });
    }
  }

  getCommentReplies() async {
    if (widget.commentInfo['theSeenReplies'].length >= widget.commentInfo['theReplies'].length) {
      if (morePostsAvailable) {
        print(replyLastDoc);
        if (widget.commentInfo['theReplies'].length == 0 || replyLastDoc == null) {
          await getReplies(
            widget.commentInfo['postId'],
            widget.commentInfo['commentId']
          );
        } else {
          //print('hey');
          await getMoreReplies(
            widget.commentInfo['postId'],
            widget.commentInfo['commentId']
          );
        }
      }
    }
    if (increaseMaxCount <= widget.commentInfo['theReplies'].length
    && currentCount < widget.commentInfo['theReplies'].length) {
      //print('helo');
      Map theMap = Map.fromIterables(
        widget.commentInfo['theReplies'].keys.skip(currentCount).take(increaseMaxCount), 
        widget.commentInfo['theReplies'].values.skip(currentCount).take(increaseMaxCount)
      );
      //print('theMap is $theMap');
      //mapForPairs = {...mapForPairs, ...theMap};
      widget.forSeenReplies(theMap, widget.commentInfo['commentId'], false);
    } else {
      setState(() {
        canRetriveMore = false;
      });
      Map theMap = Map.fromIterables(
        widget.commentInfo['theReplies'].keys.skip(currentCount).take(widget.commentInfo['theReplies'].length), 
        widget.commentInfo['theReplies'].values.skip(currentCount).take(widget.commentInfo['theReplies'].length)
      );
      //mapForPairs = {...mapForPairs, ...theMap};
      widget.forSeenReplies(theMap, widget.commentInfo['commentId'], false);
      //print('hello');
    }
    //}
  }

  @override
  void initState() {
    //getUsersTagged();
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
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    likeAnim.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //print(MapsClass.comments[widget.commentInfo['postId']][widget.commentInfo['commentId']]['createdNow']);
    //print(widget.commentInfo['createdNow']);
    //print(widget.commentInfo['comment']);
    //print('hello there');
    return InkWell(
        onTap: () {
          print('tapped 0');
          widget.reply(
            widget.commentUserInfo['uid'], 
            widget.commentUserInfo['username'],
            widget.commentInfo,
            widget.commentUserInfo,
            false,
            'none',
            'none'
          );
        },
        onLongPress: () {
          widget.commentSettings(context, widget.commentInfo["commentId"]);
          //print('called');
        },
        child: Opacity(
          opacity: 1,
          child: Container(
            color: Colors.grey[50],
            padding: EdgeInsets.symmetric(
              vertical: 8, horizontal: 8
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            //fullscreenDialog: true,
                            builder: (context) => Profiles(
                              //currentIndex: widget.index,
                              userInfo: widget.commentUserInfo,
                              maxHeight: MediaQuery.of(context).size.height,
                              isFollowing: widget.commentInfo['isUserFollowing'],
                              myInfo: widget.myInfo,
                            )
                          )
                        );
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[350],
                          // image: DecorationImage(
                          //   image: NetworkImage(
                          //     widget.commentUserInfo['profileImg'],
                          //   ),
                          //   fit: BoxFit.cover
                          // )
                        ),
                        child: CachedNetworkImage(
                          fadeInDuration: Duration(milliseconds: 10),
                          fadeOutDuration: Duration(milliseconds: 10),
                          placeholder: (context, url) => Container(color: Colors.grey[350]),
                          imageUrl: widget.commentUserInfo['profileImg'],
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
                              ),
                            );
                          },
                        )
                      ),
                    ),
                    Expanded(
                      child: Container(
                        //color: Colors.red,
                        margin: EdgeInsets.only(left: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 0),
                              child: widget.commentInfo['createdNow'] == true 
                              ? widget.commentInfo['couldUpload'] == null 
                                ? Text(
                                  'uploading...',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                  )
                                )
                                : widget.commentInfo['couldUpload'] == true 
                                  ? Text(
                                    MapsClass.comments[widget.commentInfo['postId']][widget.commentInfo['commentId']]['likes'] == 1 
                                    ? '${widget.timeAgo}•${MapsClass.comments[widget.commentInfo['postId']][widget.commentInfo['commentId']]['likes']}like'
                                    : '${widget.timeAgo}•${MapsClass.comments[widget.commentInfo['postId']][widget.commentInfo['commentId']]['likes']}likes',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                    )
                                  )
                                  : Text(
                                    'Could Not Upload',
                                    style: TextStyle(
                                      //color: Colors.red,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                    )
                                  )        
                              : Text(
                                //'${widget.theCommentsList.data()['likes']}likes•${widget.timeAgo}',
                                MapsClass.comments[widget.commentInfo['postId']][widget.commentInfo['commentId']]['likes'] == 1 
                                    ? '${widget.timeAgo}•${MapsClass.comments[widget.commentInfo['postId']][widget.commentInfo['commentId']]['likes']}like'
                                    : '${widget.timeAgo}•${MapsClass.comments[widget.commentInfo['postId']][widget.commentInfo['commentId']]['likes']}likes',
                                //'${widget.theCommentsList.data()['likes']} likes   ${widget.timeAgo}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                )
                              ),
                            ),
                            Container(
                              child: Text.rich(
                                //textAlign: TextAlign.center,
                                TextSpan(
                                  text: '${widget.commentUserInfo['username']} ',
                                  recognizer: TapGestureRecognizer()..onTap = (){
                                    Navigator.push(
                                      context, 
                                      CupertinoPageRoute(
                                        //fullscreenDialog: true,
                                        builder: (context) {
                                          return Profiles(
                                            userInfo: widget.commentUserInfo,
                                            maxHeight: MediaQuery.of(context).size.height,
                                            isFollowing: widget.commentInfo['isUserFollowing'],
                                            myInfo: widget.myInfo,
                                          );
                                        }
                                      )
                                    );
                                  },
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    //backgroundColor: Colors.red,
                                    //decorationColor: Colors.blue,
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  children: //<TextSpan>[
                                    //isCommentLoading == false ? 
                                    widget.commentInfo['taggedUsersIds'].isNotEmpty
                                      ? widget.commentInfo['comment']
                                      .split(' ').map<TextSpan>((word) {
                                        return word.startsWith('@') 
                                        && word.length > 1 
                                        && widget.commentInfo['taggedUsers'].contains(word)
                                        ? TextSpan(
                                          text: ' ' + word,
                                          recognizer: TapGestureRecognizer()..onTap = (){
                                            print('tapped 3');
                                            Navigator.push(
                                              context, 
                                              CupertinoPageRoute(
                                                //fullscreenDialog: true,
                                                builder: (context) {
                                                  return Profiles(
                                                    //currentIndex: widget.index,
                                                    userInfo: widget.commentInfo['theTaggedUsersInfo']
                                                    [widget.commentInfo['taggedUsersIds'][
                                                      widget.commentInfo['taggedUsers'].indexOf(word)
                                                    ]],
                                                    maxHeight: MediaQuery.of(context).size.height,
                                                    isFollowing: widget.commentInfo['theTaggedUsersInfo']
                                                    [widget.commentInfo['taggedUsersIds'][
                                                      widget.commentInfo['taggedUsers'].indexOf(word)
                                                    ]]['isUserFollowing'],
                                                    myInfo: widget.myInfo

                                                    //getFollowingState: widget.getFollowingStateCommentTagged,
                                                    //commentId: widget.commentInfo['commentId'],
                                                    //comesFromComments: true,

                                                  );
                                                }
                                              )
                                            );
                                          },
                                          style: TextStyle(
                                            color: Colors.blue,
                                            //backgroundColor: Colors.red,
                                            fontSize: 15.3,
                                            fontWeight: FontWeight.w600,
                                          )
                                        ) : TextSpan(
                                          text: ' ' + word,
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            //backgroundColor: Colors.red,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          )
                                        );
                                      }).toList()
                                      : [TextSpan(
                                        text: '${widget.commentInfo['comment']}',
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                          //backgroundColor: Colors.red,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        )
                                      )]
                                ),
                              ),
                            ),
                          ],
                        )
                      ),
                    ),
                    //const Spacer(),
                    GestureDetector(
                      onTap: () {
                        if (MapsClass.comments[widget.commentInfo['postId']][widget.commentInfo['commentId']]['userHasLiked'] != null) {
                          if (isLiking == false) {
                            if (MapsClass.comments[widget.commentInfo['postId']][widget.commentInfo['commentId']]['userHasLiked'] == false) {
                              likeComment();
                              MapsClass.comments[widget.commentInfo['postId']][widget.commentInfo['commentId']]['userHasLiked'] = true;
                              widget.getLikeState(
                                widget.commentInfo['postId'],
                                widget.commentInfo['commentId'],
                              );
                            } else {
                              //MapsClass.comments[widget.commentInfo['postId']][widget.commentInfo['commentId']]['userHasLiked'] = false;
                              unlikeComment();
                              widget.getLikeState(
                                widget.commentInfo['postId'],
                                widget.commentInfo['commentId'],
                              );
                            }
                          }
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 4, left: 6),
                        height: 32,
                        width: 32,
                        color: Colors.grey[50],
                        child: MapsClass.comments[widget.commentInfo['postId']][widget.commentInfo['commentId']]['userHasLiked'] != null
                        ? MapsClass.comments[widget.commentInfo['postId']][widget.commentInfo['commentId']]['userHasLiked'] == false ? Icon(
                            Icons.favorite_border_outlined,
                            color: Colors.grey[600],
                            size: likeIconSize.value,
                          ) : Icon(
                            Icons.favorite_rounded,
                            color: Colors.red,
                            size: likeIconSize.value,
                          )
                        : Icon(
                            Icons.favorite_rounded,
                            color: Colors.grey[300],
                            size: likeIconSize.value,
                          )
                      ),
                    )
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(left: 40),
                  child: widget.commentInfo['replies'] > 0
                    ? Container(
                      margin: EdgeInsets.only(top: 4),
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedSize(
                              vsync: this,
                              duration: Duration(milliseconds: 150),
                              curve: Curves.decelerate,
                              alignment: Alignment.topCenter,
                              child: Container(
                                //visible: commentReplies.length > 0 ? true : false,
                                //height: double.infinity,
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: MapsClass.comments[widget.commentInfo['postId']][widget.commentInfo['commentId']]['theSeenReplies'].length,
                                  //itemCount: mapForPairs.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final createdTimeAgo = timeAgo.format(
                                    MapsClass.comments[widget.commentInfo['postId']][widget.commentInfo['commentId']]['theSeenReplies']

                                    //widget.commentInfo['theSeenReplies']
                                    .values.toList()[index]['timeTS'].toDate(),locale: 'en_short');
                                    //print('''user has liked ${mapForPairs.values.toList()[index]['reply']} - ${mapForPairs.values.toList()[index]['userHasLiked']}''');
                                    final timeElapsed =
                                      createdTimeAgo.replaceAll(' ', '');
                                    return Container(
                                      child: Replies(
                                        replies: widget.commentInfo['theSeenReplies'].values.toList()[index],
                                        replyUserInfo: widget.commentInfo['theSeenReplies'].values.toList()[index]['userInfo'],
                                        timeAgo: timeElapsed,
                                        getLikedReplyState: getReplyLikeState,
                                        commentInfo: widget.commentInfo,
                                        commentUserInfo: widget.commentUserInfo,
                                        reply: widget.reply,
                                        getReplyFollowingState: getReplyFollowingState,
                                        getTaggedFollowingState: getTaggedFollowingState,
                                        myInfo: widget.myInfo,
                                        replySettings: widget.replySettings,
                                        key: Key(widget.commentInfo['theSeenReplies'].values.toList()[index]['id'])
                                      )
                                    );
                                  },
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                top: MapsClass.comments[widget.commentInfo['postId']][widget.commentInfo['commentId']]['theSeenReplies'].length > 0 ? 12 : 0,
                                bottom: 6
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(      
                                    onTap: () {
                                      if (canRetriveMore == true) {
                                        setState(() {
                                          increaseMaxCount += 3;
                                          currentCount += 3;
                                        });
                                        getCommentReplies();
                                        //currentPage += 1;
                                      }
                                    },                         
                                    child: Container(
                                      child: Text(
                                        'View Replies',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14.2,
                                          fontWeight: FontWeight.w600,
                                        )
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        widget.forSeenReplies({}, widget.commentInfo['commentId'], true);
                                        increaseMaxCount = 0;
                                        currentCount = -3;
                                        canRetriveMore = true;
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(left: 18),
                                      child: Text(
                                        'Hide',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14.2,
                                          fontWeight: FontWeight.w600,
                                        )
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ),
                          ],
                        )
                      )
                    )
                    : Container(),
                )
              ],
            )
          ),
        ),
      );
  }
}
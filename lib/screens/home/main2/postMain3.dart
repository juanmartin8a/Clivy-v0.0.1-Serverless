import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled_startup/models/user.dart';
import 'package:untitled_startup/screens/home/main/classes/mapsClass.dart';
import 'package:untitled_startup/screens/home/main2/postDetails.dart';
import 'package:untitled_startup/screens/home/userProfile/profiles.dart';
import 'package:untitled_startup/services/cacheClass/cacheManager.dart';
import 'package:untitled_startup/services/database.dart';

class PostMain3 extends StatefulWidget {
  final String theCategory;
  final Map postData;
  final Function getLikeState;
  final Function getFollowingState;
  final Map<String, dynamic> myInfo;
  final bool comesFromProfile;
  PostMain3({this.postData, this.getLikeState, this.getFollowingState, 
  this.theCategory, this.myInfo, this.comesFromProfile, Key key}) : super(key: key);
  @override
  _PostMain3State createState() => _PostMain3State();
}

class _PostMain3State extends State<PostMain3> with SingleTickerProviderStateMixin{
  AnimationController animController;
  Animation<double> likeIconSize;

  likePost(userUid, postId, AnimationController animController) {
    Map<String, dynamic> likeMapInfo = {
      'likedBy': userUid,
      'postLiked': postId
    };
    animController.forward().whenComplete(() {
      animController.reset();
    });
    DatabaseService(
      docId: postId,
      uid: userUid,
    ).batchedLikePost(
      likeMapInfo, 
      {'likes': FieldValue.increment(1)}
    );
    // DatabaseService(
    //   docId: postId,
    //   uid: userUid,
    // ).likePost(likeMapInfo);
    // DatabaseService(docId: postId)
    //   .incrementPostLikeCount({'likes': FieldValue.increment(1)});
    setState(() {});
  }

  unlikePost(userUid, postId, AnimationController animController) {
    animController.forward().whenComplete(() {
      animController.reset();
    });
    DatabaseService(
      docId: postId,
      uid: userUid,
    ).batchedUnlikePost(
      {'likes': FieldValue.increment(-1)}
    );
    // DatabaseService(
    //   docId: postId,
    //   uid: userUid
    // ).unlikePost();
    // DatabaseService(docId: postId).incrementPostLikeCount({'likes': FieldValue.increment(-1)});
    setState(() {});
  }

  followUser(userUid, Map postData) {
    Map<String, dynamic> followerMap = {
      'follower': userUid,
      'to': postData['userInfo']['uid'],
    };
    Map<String, dynamic> followingMap = {
      'following': postData['userInfo']['uid'],
      'from': userUid
    };
    DatabaseService().batchedFollow(
      followerMap, userUid, followingMap, postData['userInfo']['uid'],
      {'followersCount': FieldValue.increment(1)}, 
      {'followingCount': FieldValue.increment(1)},
      userUid,
      postData['userInfo']['uid']
    );
    setState(() {});
  }

  unfollowUser(userUid, Map postData) {
    DatabaseService().batchedUnfollow(
      userUid, postData['userInfo']['uid'],
      {'followersCount': FieldValue.increment(-1)}, 
      {'followingCount': FieldValue.increment(-1)},
      userUid,
      postData['userInfo']['uid']
    );
    setState(() {});
  }

  void refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    animController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    likeIconSize = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem(tween: Tween<double>(begin: 28, end: 34), weight: 28),
      TweenSequenceItem(tween: Tween<double>(begin: 34, end: 22), weight: 28),
      TweenSequenceItem(tween: Tween<double>(begin: 22, end: 28), weight: 28),
    ]).animate(CurvedAnimation(
      parent: animController,
      curve: Curves.easeInOut
    ))
    ..addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            fullscreenDialog: true,
            barrierColor: Colors.black.withOpacity(0.8),
            opaque: false,
            reverseTransitionDuration: Duration(milliseconds: 220),
            transitionDuration: Duration(milliseconds: 350),
            transitionsBuilder: (context, anim1, anim2, child) {
              anim1 = CurvedAnimation(
                parent: anim1,
                curve: Curves.fastOutSlowIn
              );
              return FadeTransition(
                opacity: anim1,
                child: child
              );
            },
            pageBuilder: (context, anim1, anim2) => PostDetails(
              postdata: widget.postData,
              likePost: likePost,
              unlikePost: unlikePost,
              getLikeState: widget.getLikeState,
              likeIconSize: likeIconSize,
              theCategory: widget.theCategory,
              followUser: followUser,
              unfollowUser: unfollowUser,
              getFollowingState: widget.getFollowingState,
              myInfo: widget.myInfo,
              comesFromProfile: widget.comesFromProfile == true ? true : false,
              key: widget.key,
              refresh: refresh,
            )
          )
        );
      },
      child: Container(
        margin: EdgeInsets.only(
          top: 10,
          bottom: 14
        ),
        //padding: EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(20)
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              Container(
                child: Column(
                  children: [
                    GestureDetector(
                      onDoubleTap: () {
                        if (widget.comesFromProfile == false || widget.comesFromProfile == null) {
                          if (MapsClass.posts[widget.postData['id']]['userHasLiked'] == false) {
                            likePost(user.uid, widget.postData['id'], animController);
                            MapsClass.posts[widget.postData['id']]['userHasLiked'] = true;
                            MapsClass.posts[widget.postData['id']]['likes'] += 1;
                          } else if (MapsClass.posts[widget.postData['id']]['userHasLiked'] == true) {
                            unlikePost(user.uid, widget.postData['id'], animController);
                            MapsClass.posts[widget.postData['id']]['userHasLiked'] = false;
                            MapsClass.posts[widget.postData['id']]['likes'] += -1;
                          }
                          widget.getLikeState(
                            widget.postData['id'],
                            user.uid,
                            //widget.theCategory
                          ).then((val) {
                            MapsClass.posts[widget.postData['id']]['userHasLiked'] = val;
                            // if (val == true) {
                            //   MapsClass.posts[widget.postData['id']]['likes'] += 1;
                            // } else if (val == false) {
                            //   MapsClass.posts[widget.postData['id']]['likes'] += -1;
                            // }
                            List<dynamic> postsQuery = MapsClass.posts.keys.toList().where((key) => key == widget.postData['id']).toList();
                            if (MapsClass.userPosts[widget.postData['postedBy']] != null) {
                              List<dynamic> postUsersQuery = MapsClass.userPosts[widget.postData['postedBy']]['posts'].keys.toList().where((val) => val == widget.postData['id']).toList();
                              Future.wait(postUsersQuery.map((user) async {
                                MapsClass.userPosts[widget.postData['postedBy']]['posts'][user]['userHasLiked'] = val;
                                if (val == true) {
                                  MapsClass.userPosts[widget.postData['postedBy']]['posts'][user]['likes'] += 1;
                                } else if (val == false) {
                                  MapsClass.userPosts[widget.postData['postedBy']]['posts'][user]['likes'] += -1;
                                }
                              }));
                            }
                            Future.wait(postsQuery.map((post) async {
                              MapsClass.posts[post]['userHasLiked'] = val;
                            }));
                          });
                        } else if (widget.comesFromProfile == true) {
                          if (MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['userHasLiked'] == false) {
                            likePost(user.uid, widget.postData['id'], animController);
                            MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['userHasLiked'] = true;
                            MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['likes'] += 1;
                          } else if (MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['userHasLiked'] == true) {
                            unlikePost(user.uid, widget.postData['id'], animController);
                            MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['userHasLiked'] = false;
                            MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['likes'] += -1;
                          }
                          widget.getLikeState(
                            widget.postData['id'],
                            widget.postData['postedBy'],
                            user.uid,
                          ).then((val) {
                            if (val != null ) {
                              MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['userHasLiked'] = val;
                              List<dynamic> postsQuery = MapsClass.posts.keys.toList().where((key) => key == widget.postData['id']).toList();
                              if (MapsClass.userPosts[widget.postData['postedBy']] != null) {
                                List<dynamic> postUsersQuery = MapsClass.userPosts[widget.postData['postedBy']]['posts'].keys.toList().where((val) => val == widget.postData['id']).toList();
                                Future.wait(postUsersQuery.map((user) async {
                                  MapsClass.userPosts[widget.postData['postedBy']]['posts'][user]['userHasLiked'] = val;
                                }));
                              }
                              Future.wait(postsQuery.map((post) async {
                                MapsClass.posts[post]['userHasLiked'] = val;
                                if (val == true) {
                                  MapsClass.posts[widget.postData['id']]['likes'] += 1;
                                } else if (val == false) {
                                  MapsClass.posts[widget.postData['id']]['likes'] += -1;
                                }
                              }));
                            }
                          });
                        }
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            fullscreenDialog: true,
                            barrierColor: Colors.black.withOpacity(0.8),
                            opaque: false,
                            reverseTransitionDuration: Duration(milliseconds: 220),
                            transitionDuration: Duration(milliseconds: 350),
                            transitionsBuilder: (context, anim1, anim2, child) {
                              anim1 = CurvedAnimation(
                                parent: anim1,
                                curve: Curves.fastOutSlowIn
                              );
                              return FadeTransition(
                                opacity: anim1,
                                child: child
                              );
                            },
                            pageBuilder: (context, anim1, anim2) => PostDetails(
                              postdata: widget.postData,
                              likePost: likePost,
                              unlikePost: unlikePost,
                              getLikeState: widget.getLikeState,
                              likeIconSize: likeIconSize,
                              theCategory: widget.theCategory,
                              followUser: followUser,
                              unfollowUser: unfollowUser,
                              getFollowingState: widget.getFollowingState,
                              myInfo: widget.myInfo,
                              comesFromProfile: widget.comesFromProfile == true ? true : false,
                              key: widget.key,
                              refresh: refresh,
                            )
                          )
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 12,
                          right: 12,
                          //top: 10,
                          //bottom: 10,
                        ),
                        height: (((MediaQuery.of(context).size.width - 22) * widget.postData['postDims'][1]) 
                        / widget.postData['postDims'][0]),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              /*image: DecorationImage(
                                image: NetworkImage(
                                  widget.postData['postImg'],
                                ),
                                fit: BoxFit.cover
                              )*/
                            ),
                            child: CachedNetworkImage(
                              fadeInDuration: Duration(milliseconds: 50),
                              fadeOutDuration: Duration(milliseconds: 50),
                              placeholder: (context, url) => Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[350],
                                  borderRadius: BorderRadius.circular(18),
                                )
                              ),
                              imageUrl: widget.postData['postImg'],
                              fit: BoxFit.cover,
                              cacheManager: CustomCacheManager.instance,
                              imageBuilder: (context, imageProvider) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[350],
                                    borderRadius: BorderRadius.circular(18),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover
                                    )
                                  )
                                );
                              }
                            )
                          )
                        ),
                      )
                    ),
                    widget.postData['caption'] == null 
                    || widget.postData['caption'] == '' ? Container()
                    : Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        padding: EdgeInsets.only(bottom: 0, top: 12),
                        //color: Colors.red,
                        child: Text.rich(
                          TextSpan(
                            children: <InlineSpan> [
                              TextSpan(
                                text: '${widget.postData['caption']}',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 15.8,
                                  fontWeight: FontWeight.w600,
                                  height: 0.9
                                ),
                              ),
                            ]
                          )
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 8,
                        bottom: 8
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => Profiles(
                                    //currentIndex: widget.index,
                                    userInfo: widget.postData['userInfo'],
                                    maxHeight: MediaQuery.of(context).size.height,
                                    isFollowing: widget.comesFromProfile == true ? MapsClass.userPosts[widget.postData['postedBy']]['isUserFollowing'] : widget.postData['isUserFollowing'],
                                    //getFollowingState: widget.getFollowingState,
                                    myInfo: widget.myInfo,
                                  )
                                )
                              );
                            },
                            child: Container(
                              height: 42,
                              width: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: CachedNetworkImage(
                                fadeInDuration: Duration(milliseconds: 50),
                                fadeOutDuration: Duration(milliseconds: 50),
                                placeholder: (context, url) => Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[350],
                                    shape: BoxShape.circle
                                  )
                                ),
                                imageUrl: widget.postData['userInfo']['profileImg'],
                                fit: BoxFit.cover,
                                cacheManager: CustomCacheManager.instance,
                                imageBuilder: (context, imageProvider) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[350],
                                      shape: BoxShape.circle,
                                      //borderRadius: BorderRadius.circular(8),
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
                          Container(
                            margin: EdgeInsets.only(left: 6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => Profiles(
                                          //currentIndex: widget.index,
                                          userInfo: widget.postData['userInfo'],
                                          maxHeight: MediaQuery.of(context).size.height,
                                          isFollowing: widget.comesFromProfile == true ? MapsClass.userPosts[widget.postData['postedBy']]['isUserFollowing'] : widget.postData['isUserFollowing'],
                                          //getFollowingState: widget.getFollowingState,
                                          myInfo: widget.myInfo,
                                        )
                                      )
                                    );
                                  },
                                  child: Container(
                                    child: Text(
                                      '${widget.postData['userInfo']['username']}',
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 16.2,
                                        fontWeight: FontWeight.w700,
                                        //height: 0.
                                      )
                                    )
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => Profiles(
                                          //currentIndex: widget.index,
                                          userInfo: widget.postData['userInfo'],
                                          maxHeight: MediaQuery.of(context).size.height,
                                          isFollowing: widget.comesFromProfile == true ? MapsClass.userPosts[widget.postData['postedBy']]['isUserFollowing'] : widget.postData['isUserFollowing'],
                                          //getFollowingState: widget.getFollowingState,
                                          myInfo: widget.myInfo,
                                        )
                                      )
                                    );
                                  },
                                  child: Container(
                                    child: Text(
                                      '${widget.postData['userInfo']['username']}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w500,
                                        height: 0.95
                                      )
                                    )
                                  ),
                                  
                                )
                              ],
                            )
                          ),
                          const Spacer(),
                          //SizedBox(width: 12),
                          Row(
                            children: [
                              Container(
                                width: 75,
                                //color: Colors.red,
                                // constraints: BoxConstraints(
                                //   minWidth: 40,
                                //   maxWidth: 82
                                // ),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(left: 1),
                                        child: Text(
                                          widget.comesFromProfile == true 
                                          ? '${MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['comments']}'
                                          : '${MapsClass.posts[widget.postData['id']]['comments']}',
                                          //'${widget.postData['comments']}',
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600
                                          )
                                        )
                                      ),
                                      Container(
                                        height: 30,
                                        width: 30,
                                        child: Center(
                                          child: Icon(
                                            CupertinoIcons.text_bubble,
                                            color: Colors.grey[800],
                                            size: 26
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 6
                              ),
                              Container(
                                width: 75,
                                //color: Colors.red,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(left: 1),
                                        child: Text(
                                          '${widget.postData['likes']}',
                                          style: TextStyle(
                                            color: widget.comesFromProfile == null || widget.comesFromProfile == false ?
                                              MapsClass.posts[widget.postData['id']]['userHasLiked'] == true ? Colors.red[600] : Colors.grey[800]
                                            : MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['userHasLiked'] == true ? Colors.red[600] : Colors.grey[800],
                                            //Colors.grey[800],
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600
                                          )
                                        )
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (widget.comesFromProfile == false || widget.comesFromProfile == null) {
                                            if (MapsClass.posts[widget.postData['id']]['userHasLiked'] == false) {
                                              likePost(user.uid, widget.postData['id'], animController);
                                              MapsClass.posts[widget.postData['id']]['userHasLiked'] = true;
                                              MapsClass.posts[widget.postData['id']]['likes'] += 1;
                                            } else if (MapsClass.posts[widget.postData['id']]['userHasLiked'] == true) {
                                              unlikePost(user.uid, widget.postData['id'], animController);
                                              MapsClass.posts[widget.postData['id']]['userHasLiked'] = false;
                                              MapsClass.posts[widget.postData['id']]['likes'] += -1;
                                            }
                                            widget.getLikeState(
                                              widget.postData['id'],
                                              user.uid,
                                              //widget.theCategory
                                            ).then((val) {
                                              MapsClass.posts[widget.postData['id']]['userHasLiked'] = val;
                                              // if (val == true) {
                                              //   MapsClass.posts[widget.postData['id']]['likes'] += 1;
                                              // } else if (val == false) {
                                              //   MapsClass.posts[widget.postData['id']]['likes'] += -1;
                                              // }
                                              List<dynamic> postsQuery = MapsClass.posts.keys.toList().where((key) => key == widget.postData['id']).toList();
                                              if (MapsClass.userPosts[widget.postData['postedBy']] != null) {
                                                List<dynamic> postUsersQuery = MapsClass.userPosts[widget.postData['postedBy']]['posts'].keys.toList().where((val) => val == widget.postData['id']).toList();
                                                Future.wait(postUsersQuery.map((user) async {
                                                  MapsClass.userPosts[widget.postData['postedBy']]['posts'][user]['userHasLiked'] = val;
                                                  if (val == true) {
                                                    MapsClass.userPosts[widget.postData['postedBy']]['posts'][user]['likes'] += 1;
                                                  } else if (val == false) {
                                                    MapsClass.userPosts[widget.postData['postedBy']]['posts'][user]['likes'] += -1;
                                                  }
                                                }));
                                              }
                                              Future.wait(postsQuery.map((post) async {
                                                MapsClass.posts[post]['userHasLiked'] = val;
                                              }));
                                            });
                                          } else if (widget.comesFromProfile == true) {
                                            if (MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['userHasLiked'] == false) {
                                              likePost(user.uid, widget.postData['id'], animController);
                                              MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['userHasLiked'] = true;
                                              MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['likes'] += 1;
                                            } else if (MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['userHasLiked'] == true) {
                                              unlikePost(user.uid, widget.postData['id'], animController);
                                              MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['userHasLiked'] = false;
                                              MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['likes'] += -1;
                                            }
                                            widget.getLikeState(
                                              widget.postData['id'],
                                              widget.postData['postedBy'],
                                              user.uid,
                                            ).then((val) {
                                              if (val != null ) {
                                                MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['userHasLiked'] = val;
                                                List<dynamic> postsQuery = MapsClass.posts.keys.toList().where((key) => key == widget.postData['id']).toList();
                                                if (MapsClass.userPosts[widget.postData['postedBy']] != null) {
                                                  List<dynamic> postUsersQuery = MapsClass.userPosts[widget.postData['postedBy']]['posts'].keys.toList().where((val) => val == widget.postData['id']).toList();
                                                  Future.wait(postUsersQuery.map((user) async {
                                                    MapsClass.userPosts[widget.postData['postedBy']]['posts'][user]['userHasLiked'] = val;
                                                  }));
                                                }
                                                Future.wait(postsQuery.map((post) async {
                                                  MapsClass.posts[post]['userHasLiked'] = val;
                                                  if (val == true) {
                                                    MapsClass.posts[post]['likes'] += 1;
                                                  } else if (val == false) {
                                                    MapsClass.posts[post]['likes'] += -1;
                                                  }
                                                }));
                                              }
                                            });
                                          }
                                        },
                                        child: Container(
                                          height: 35,
                                          width: 35,
                                          child: Center(
                                            child: widget.comesFromProfile == null || widget.comesFromProfile == false ? Icon(
                                              MapsClass.posts[widget.postData['id']]['userHasLiked'] == true ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                                              color: MapsClass.posts[widget.postData['id']]['userHasLiked'] == true ? Colors.red : Colors.grey[800],
                                              //color: Colors.grey[800],
                                              size: likeIconSize.value,
                                            ) : Icon(
                                              MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['userHasLiked'] == true ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                                              color: MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['userHasLiked'] == true ? Colors.red : Colors.grey[800],
                                              //color: Colors.grey[800],
                                              size: likeIconSize.value,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    ),
                    // Container(
                    //   //color: Colors.red,
                    //   margin: EdgeInsets.only(
                    //     left: 12,
                    //     right: 12,
                    //     top: 2
                    //   ),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     children: [
                    //       Row(
                    //         children: [
                    //           GestureDetector(
                    //             onTap: () {
                    //               if (widget.comesFromProfile == false || widget.comesFromProfile == null) {
                    //                 if (MapsClass.posts[widget.postData['id']]['userHasLiked'] == false) {
                    //                   likePost(user.uid, widget.postData['id'], animController);
                    //                   MapsClass.posts[widget.postData['id']]['userHasLiked'] = true;
                    //                   MapsClass.posts[widget.postData['id']]['likes'] += 1;
                    //                 } else if (MapsClass.posts[widget.postData['id']]['userHasLiked'] == true) {
                    //                   unlikePost(user.uid, widget.postData['id'], animController);
                    //                   MapsClass.posts[widget.postData['id']]['userHasLiked'] = false;
                    //                   MapsClass.posts[widget.postData['id']]['likes'] += -1;
                    //                 }
                    //                 widget.getLikeState(
                    //                   widget.postData['id'],
                    //                   user.uid,
                    //                   //widget.theCategory
                    //                 ).then((val) {
                    //                   MapsClass.posts[widget.postData['id']]['userHasLiked'] = val;
                    //                   // if (val == true) {
                    //                   //   MapsClass.posts[widget.postData['id']]['likes'] += 1;
                    //                   // } else if (val == false) {
                    //                   //   MapsClass.posts[widget.postData['id']]['likes'] += -1;
                    //                   // }
                    //                   List<dynamic> postsQuery = MapsClass.posts.keys.toList().where((key) => key == widget.postData['id']).toList();
                    //                   if (MapsClass.userPosts[widget.postData['postedBy']] != null) {
                    //                     List<dynamic> postUsersQuery = MapsClass.userPosts[widget.postData['postedBy']]['posts'].keys.toList().where((val) => val == widget.postData['id']).toList();
                    //                     Future.wait(postUsersQuery.map((user) async {
                    //                       MapsClass.userPosts[widget.postData['postedBy']]['posts'][user]['userHasLiked'] = val;
                    //                       if (val == true) {
                    //                         MapsClass.userPosts[widget.postData['postedBy']]['posts'][user]['likes'] += 1;
                    //                       } else if (val == false) {
                    //                         MapsClass.userPosts[widget.postData['postedBy']]['posts'][user]['likes'] += -1;
                    //                       }
                    //                     }));
                    //                   }
                    //                   Future.wait(postsQuery.map((post) async {
                    //                     MapsClass.posts[post]['userHasLiked'] = val;
                    //                   }));
                    //                 });
                    //               } else if (widget.comesFromProfile == true) {
                    //                 if (MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['userHasLiked'] == false) {
                    //                   likePost(user.uid, widget.postData['id'], animController);
                    //                   MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['userHasLiked'] = true;
                    //                   MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['likes'] += 1;
                    //                 } else if (MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['userHasLiked'] == true) {
                    //                   unlikePost(user.uid, widget.postData['id'], animController);
                    //                   MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['userHasLiked'] = false;
                    //                   MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['likes'] += -1;
                    //                 }
                    //                 widget.getLikeState(
                    //                   widget.postData['id'],
                    //                   widget.postData['postedBy'],
                    //                   user.uid,
                    //                 ).then((val) {
                    //                   if (val != null ) {
                    //                     MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['userHasLiked'] = val;
                    //                     List<dynamic> postsQuery = MapsClass.posts.keys.toList().where((key) => key == widget.postData['id']).toList();
                    //                     if (MapsClass.userPosts[widget.postData['postedBy']] != null) {
                    //                       List<dynamic> postUsersQuery = MapsClass.userPosts[widget.postData['postedBy']]['posts'].keys.toList().where((val) => val == widget.postData['id']).toList();
                    //                       Future.wait(postUsersQuery.map((user) async {
                    //                         MapsClass.userPosts[widget.postData['postedBy']]['posts'][user]['userHasLiked'] = val;
                    //                       }));
                    //                     }
                    //                     Future.wait(postsQuery.map((post) async {
                    //                       MapsClass.posts[post]['userHasLiked'] = val;
                    //                       if (val == true) {
                    //                         MapsClass.posts[post]['likes'] += 1;
                    //                       } else if (val == false) {
                    //                         MapsClass.posts[post]['likes'] += -1;
                    //                       }
                    //                     }));
                    //                   }
                    //                 });
                    //               }
                    //             },
                    //             child: Container(
                    //               height: 30,
                    //               width: 30,
                    //               child: Center(
                    //                 child: widget.comesFromProfile == null || widget.comesFromProfile == false ? Icon(
                    //                   MapsClass.posts[widget.postData['id']]['userHasLiked'] == true ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                    //                   color: MapsClass.posts[widget.postData['id']]['userHasLiked'] == true ? Colors.red : Colors.grey[800],
                    //                   //color: Colors.grey[800],
                    //                   size: likeIconSize.value,
                    //                 ) : Icon(
                    //                   MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['userHasLiked'] == true ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                    //                   color: MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['userHasLiked'] == true ? Colors.red : Colors.grey[800],
                    //                   //color: Colors.grey[800],
                    //                   size: likeIconSize.value,
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //           Container(
                    //             margin: EdgeInsets.only(left: 1),
                    //             child: Text(
                    //               '${widget.postData['likes']}',
                    //               style: TextStyle(
                    //                 color: Colors.grey[800],
                    //                 fontSize: 16,
                    //                 fontWeight: FontWeight.w600
                    //               )
                    //             )
                    //           ),

                    //         ],
                    //       ),
                    //       //SizedBox(width: 12),
                    //       Row(
                    //         children: [
                    //           Container(
                    //             height: 30,
                    //             width: 30,
                    //             child: Center(
                    //               child: Icon(
                    //                 CupertinoIcons.text_bubble,
                    //                 color: Colors.grey[800],
                    //                 size: 24
                    //               ),
                    //             ),
                    //           ),
                    //           Container(
                    //             margin: EdgeInsets.only(left: 1),
                    //             child: Text(
                    //               widget.comesFromProfile == true 
                    //               ? '${MapsClass.userPosts[widget.postData['postedBy']]['posts'][widget.postData['id']]['comments']}'
                    //               : '${MapsClass.posts[widget.postData['id']]['comments']}',
                    //               //'${widget.postData['comments']}',
                    //               style: TextStyle(
                    //                 color: Colors.grey[800],
                    //                 fontSize: 16,
                    //                 fontWeight: FontWeight.w600
                    //               )
                    //             )
                    //           ),
                    //         ],
                    //       ),
                    //       //SizedBox(width: 12),
                    //       Row(
                    //         children: [
                    //           Container(
                    //             height: 30,
                    //             width: 30,
                    //             child: Center(
                    //               child: Icon(
                    //                 Icons.remove_red_eye,
                    //                 color: Colors.grey[800],
                    //                 size: 24
                    //               ),
                    //             ),
                    //           ),
                    //           Container(
                    //             margin: EdgeInsets.only(left: 1),
                    //             child: Text(
                    //               '100',
                    //               style: TextStyle(
                    //                 color: Colors.grey[800],
                    //                 fontSize: 17,
                    //                 fontWeight: FontWeight.w600
                    //               )
                    //             )
                    //           ),
                    //         ],
                    //       )
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ]
          ),
        )
      ),
    );
  }
}
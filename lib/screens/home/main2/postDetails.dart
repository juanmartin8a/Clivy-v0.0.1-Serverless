import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:untitled_startup/models/user.dart';
import 'package:untitled_startup/screens/home/main/classes/mapsClass.dart';
import 'package:untitled_startup/screens/home/main2/comments/comments2.dart';
import 'package:untitled_startup/screens/home/userProfile/profiles.dart';
import 'package:untitled_startup/services/cacheClass/cacheManager.dart';

class PostDetails extends StatefulWidget {
  final Map postdata;
  final Function likePost;
  final Function unlikePost;
  final Function followUser;
  final Function unfollowUser;
  final String theCategory;
  final Function getLikeState;
  final Function getFollowingState;
  final Animation<double> likeIconSize;
  final Map<String, dynamic> myInfo;
  final bool comesFromProfile;
  final Function refresh;
  PostDetails({this.postdata, this.likePost, this.unlikePost,
  this.likeIconSize, this.getLikeState, this.theCategory, this.followUser,
  this.unfollowUser, this.getFollowingState, this.myInfo, this.comesFromProfile,
  this.refresh, Key key}) : super(key: key);
  @override
  _PostDetailsState createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> with TickerProviderStateMixin{
  GlobalKey _theKey = GlobalKey();

  double _widgetHeight;
  bool profilePostInfoIsOpen = true;
  bool aboveBoolIsLoading = false;
  //double postWidth;

  AnimationController animController;
  Animation<double> likeIconSize;

  void refresh() {
    widget.refresh();
    setState(() {});
  }

  @override
  void initState() {
    //getPostAspectRatio();
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(_getTotalHeight);
    animController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    likeIconSize = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem(tween: Tween<double>(begin: 22, end: 28), weight: 22),
      TweenSequenceItem(tween: Tween<double>(begin: 28, end: 16), weight: 22),
      TweenSequenceItem(tween: Tween<double>(begin: 16, end: 22), weight: 22),
    ]).animate(CurvedAnimation(
      parent: animController,
      curve: Curves.easeInOut
    ))
    ..addListener(() { 
      setState(() {});
    });
  }

  double _getWidgetHeight(GlobalKey key) {
    RenderBox context = key.currentContext.findRenderObject();
    return context.size.height;
  }

  _getTotalHeight(_) {
    _widgetHeight = _getWidgetHeight(_theKey);
    return _widgetHeight;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    //final posts = Provider.of<MapsClass>(context, listen: true).uno;
    //print(widget.postdata['isUserFollowing']);
    return Scaffold(
          backgroundColor: Colors.transparent,
          body: 
          Container(
            color: Colors.transparent,
            child: Container(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: MediaQuery.of(context).padding.top + 12,
                      color: Colors.transparent
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      //padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                      height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[50]
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              //left: 1,
                              //right: 1,
                              //bottom: 0,
                              //top: MediaQuery.of(context).padding.top
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[50]
                            ),
                            child: AspectRatio(
                              aspectRatio: widget.postdata['postDims'][0] / widget.postdata['postDims'][1],
                              child: 
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    /*image: DecorationImage(
                                      image: NetworkImage(widget.postdata['postImg']),
                                      fit: BoxFit.cover
                                    )*/
                                  ),
                                  //width: MediaQuery.of(context.size.height)
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      fadeInDuration: Duration(milliseconds: 10),
                                      fadeOutDuration: Duration(milliseconds: 10),
                                      placeholder: (context, url) => Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.grey[350],
                                        ),
                                      ),
                                      imageUrl: widget.postdata['postImg'],
                                      fit: BoxFit.cover,
                                      cacheManager: CustomCacheManager.instance,
                                      imageBuilder: (context, imageProvider) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.grey[350],
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover
                                            )
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                              )
                            )
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (widget.comesFromProfile == false || widget.comesFromProfile == null) {
                                        if (MapsClass.posts[widget.postdata['id']]['userHasLiked'] == false) {
                                          widget.likePost(user.uid, widget.postdata['id'], animController);
                                          MapsClass.posts[widget.postdata['id']]['userHasLiked'] = true;
                                          MapsClass.posts[widget.postdata['id']]['likes'] += 1;
                                        } else if (MapsClass.posts[widget.postdata['id']]['userHasLiked'] == true) {
                                          widget.unlikePost(user.uid, widget.postdata['id'], animController);
                                          MapsClass.posts[widget.postdata['id']]['userHasLiked'] = false;
                                          MapsClass.posts[widget.postdata['id']]['likes'] += -1;
                                        }
                                        widget.getLikeState(
                                          widget.postdata['id'],
                                          user.uid,
                                          //widget.theCategory
                                        ).then((val) {
                                          if (val != null) {
                                            MapsClass.posts[widget.postdata['id']]['userHasLiked'] = val;
                                            List<dynamic> postsQuery = MapsClass.posts.keys.toList().where((key) => key == widget.postdata['id']).toList();
                                            if (MapsClass.userPosts[widget.postdata['postedBy']] != null) {
                                              List<dynamic> postUsersQuery = MapsClass.userPosts[widget.postdata['postedBy']]['posts'].keys.toList().where((val) => val == widget.postdata['id']).toList();
                                              Future.wait(postUsersQuery.map((user) async {
                                                MapsClass.userPosts[widget.postdata['postedBy']]['posts'][user]['userHasLiked'] = val;
                                                if (val == true) {
                                                  MapsClass.userPosts[widget.postdata['postedBy']]['posts'][user]['likes'] += 1;
                                                } else if (val == false) {
                                                  MapsClass.userPosts[widget.postdata['postedBy']]['posts'][user]['likes'] += -1;
                                                }
                                                setState(() {});
                                              }));
                                            }
                                            Future.wait(postsQuery.map((post) async {
                                              setState(() {
                                                MapsClass.posts[post]['userHasLiked'] = val;
                                              });
                                            }));
                                          }
                                        });
                                      } else if (widget.comesFromProfile == true) {
                                        if (MapsClass.userPosts[widget.theCategory]['posts'][widget.postdata['id']]['userHasLiked'] == false) {
                                          widget.likePost(user.uid, widget.postdata['id'], animController);
                                          MapsClass.userPosts[widget.postdata['postedBy']]['posts'][widget.postdata['id']]['userHasLiked'] = true;
                                          MapsClass.userPosts[widget.postdata['postedBy']]['posts'][widget.postdata['id']]['likes'] += 1;
                                        } else if (MapsClass.userPosts[widget.theCategory]['posts'][widget.postdata['id']]['userHasLiked'] == true) {
                                          widget.unlikePost(user.uid, widget.postdata['id'], animController);
                                          MapsClass.userPosts[widget.postdata['postedBy']]['posts'][widget.postdata['id']]['userHasLiked'] = false;
                                          MapsClass.userPosts[widget.postdata['postedBy']]['posts'][widget.postdata['id']]['likes'] += -1;
                                        }
                                        widget.getLikeState(
                                          widget.postdata['id'],
                                          widget.theCategory,
                                          user.uid,
                                        ).then((val) {
                                          if (val != null ) {
                                            MapsClass.userPosts[widget.postdata['postedBy']]['posts'][widget.postdata['id']]['userHasLiked'] = val;
                                            List<dynamic> postsQuery = MapsClass.posts.keys.toList().where((key) => key == widget.postdata['id']).toList();
                                            if (MapsClass.userPosts[widget.postdata['postedBy']] != null) {
                                              List<dynamic> postUsersQuery = MapsClass.userPosts[widget.postdata['postedBy']]['posts'].keys.toList().where((val) => val == widget.postdata['id']).toList();
                                              Future.wait(postUsersQuery.map((user) async {
                                                setState(() {
                                                  MapsClass.userPosts[widget.postdata['postedBy']]['posts'] [user]['userHasLiked'] = val;
                                                });
                                              }));
                                            }
                                            Future.wait(postsQuery.map((post) async {
                                              MapsClass.posts[post]['userHasLiked'] = val;
                                              if (val == true) {
                                                MapsClass.posts[post]['likes'] += 1;
                                              } else if (val == false) {
                                                MapsClass.posts[post]['likes'] += -1;
                                              }
                                              setState(() {});
                                            }));
                                          }
                                        });
                                      }
                                      setState(() {});
                                    },
                                    child: Container(
                                      height: 28,
                                      width: 28,
                                      child: Center(
                                        child: widget.comesFromProfile == null || widget.comesFromProfile == false ? Icon(
                                          MapsClass.posts[widget.postdata['id']]['userHasLiked'] == false ? CupertinoIcons.heart : CupertinoIcons.heart_fill,
                                          color: MapsClass.posts[widget.postdata['id']]['userHasLiked'] == false ? Colors.grey[800] : Colors.red,
                                          //color: Colors.grey[800],
                                          size: likeIconSize.value,
                                        ) : Icon(
                                          MapsClass.userPosts[widget.postdata['postedBy']]['posts'][widget.postdata['id']]['userHasLiked'] == false ? CupertinoIcons.heart : CupertinoIcons.heart_fill,
                                          color: MapsClass.userPosts[widget.postdata['postedBy']]['posts'][widget.postdata['id']]['userHasLiked'] == false ? Colors.grey[800] : Colors.red,
                                          //color: Colors.grey[800],
                                          size: likeIconSize.value,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                  margin: EdgeInsets.only(left: 1),
                                    child: Text(
                                      '${widget.postdata['likes']}',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600
                                      )
                                    )
                                  ),
                                  SizedBox(width: 12),
                                  Container(
                                    height: 28,
                                    width: 28,
                                    child: Center(
                                      child: Icon(
                                        CupertinoIcons.captions_bubble,
                                        color: Colors.grey[700],
                                        size: 22
                                      ),
                                    ),
                                  ),
                                  Container(
                                  margin: EdgeInsets.only(left: 1),
                                    child: Text(
                                      widget.comesFromProfile == true 
                                      ? '${MapsClass.userPosts[widget.postdata['postedBy']]['posts'][widget.postdata['id']]['comments']}'
                                      : '${MapsClass.posts[widget.postdata['id']]['comments']}',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600
                                      )
                                    )
                                  ),
                                  SizedBox(width: 12),
                                  Container(
                                    height: 28,
                                    width: 28,
                                    child: Center(
                                      child: Icon(
                                        Icons.remove_red_eye,
                                        color: Colors.grey[700],
                                        size: 22
                                      ),
                                    ),
                                  ),
                                  Container(
                                  margin: EdgeInsets.only(left: 1),
                                    child: Text(
                                      '100',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600
                                      )
                                    )
                                  ),
                                ],
                              ),
                            )
                          ),
                          AnimatedSize(
                            vsync: this,
                            duration: Duration(milliseconds: 200),
                            alignment: Alignment.topCenter, 
                            child: Container(
                              
                              height: profilePostInfoIsOpen == true ? _widgetHeight : 0,
                              color: Colors.grey[50],
                              key: _theKey,
                              padding: EdgeInsets.only(
                                //top: 10,
                                bottom: 2,
                                left: 12,
                                right: 12 
                                //horizontal: 12
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
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
                                                userInfo: widget.postdata['userInfo'],
                                                maxHeight: MediaQuery.of(context).size.height,
                                                isFollowing: widget.comesFromProfile == true ? MapsClass.userPosts[widget.postdata['postedBy']]['isUserFollowing'] : widget.postdata['isUserFollowing'],
                                                //getFollowingState: widget.getFollowingState,
                                                myInfo: widget.myInfo,
                                              )
                                            )
                                          );
                                        },
                                        child: Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            // image: DecorationImage(
                                            //   image: NetworkImage(
                                            //     widget.postdata['userInfo']['profileImg'],
                                            //   ),
                                            //   fit: BoxFit.cover
                                            // )
                                          ),
                                          child: CachedNetworkImage(
                                            fadeInDuration: Duration(milliseconds: 10),
                                            fadeOutDuration: Duration(milliseconds: 10),
                                            placeholder: (context, url) => Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey[350],
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            imageUrl: widget.postdata['userInfo']['profileImg'],
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
                                                ),
                                              );
                                            }
                                          )
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(left: 6),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text(
                                                  '${widget.postdata['userInfo']['name']}•2d',
                                                  style: TextStyle(
                                                    color: Colors.grey[700],
                                                    fontSize: 15.2,
                                                    fontWeight: FontWeight.w500
                                                  )
                                                )
                                              ),
                                              Container(
                                                child: Text(
                                                  '${widget.postdata['caption']}',
                                                  style: TextStyle(
                                                    color: Colors.grey[800],
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600
                                                  ),
                                                )
                                              )
                                            ],
                                          )
                                        ),
                                      ),
                                      widget.postdata['userInfo']['uid'] == user.uid ? Container() :
                                      GestureDetector(
                                        onTap: () {
                                          if (widget.comesFromProfile == false || widget.comesFromProfile == null) {
                                            if (MapsClass.posts[widget.postdata['id']]['isUserFollowing'] == false) {
                                              widget.followUser(user.uid, widget.postdata);
                                              MapsClass.posts[widget.postdata['id']]['isUserFollowing'] = true;
                                            } else if (MapsClass.posts[widget.postdata['id']]['isUserFollowing'] == true) {
                                              widget.unfollowUser(user.uid, widget.postdata);
                                              MapsClass.posts[widget.postdata['id']]['isUserFollowing'] = false;
                                            }
                                            widget.getFollowingState(
                                              widget.postdata['userInfo']['uid'],
                                              widget.postdata['id'],
                                              user.uid,
                                            ).then((val) {
                                              MapsClass.posts[widget.postdata['id']]['isUserFollowing'] = val;
                                              if (MapsClass.posts.isNotEmpty || MapsClass.posts != null) {
                                                var postsQuery = MapsClass.posts.values.toList().where((val) => val['postedBy'] == widget.postdata['postedBy']).toList();
                                                //var postUsersQuery = MapsClass.userPosts.keys.toList().where((key) => key == widget.postdata['postedBy']).toList();
                                                //print(postsQuery);
                                                if (postsQuery.isNotEmpty || postsQuery != null) {
                                                  Future.wait(postsQuery.map((post) async {
                                                    MapsClass.posts[post['id']]['isUserFollowing'] = val;
                                                  }));
                                                }
                                              }
                                              if (MapsClass.userPosts[widget.postdata['userInfo']['uid']] != null) {
                                                MapsClass.userPosts[widget.postdata['userInfo']['uid']]['isUserFollowing'] = val;
                                              }
                                              if (MapsClass.users[widget.postdata['userInfo']['uid']] != null) {
                                                MapsClass.users[widget.postdata['userInfo']['uid']]['isUserFollowing'] = val;
                                              }
                                              if (MapsClass.searchedUsers[widget.postdata['userInfo']['uid']] != null) {
                                                //if (MapsClass.searchedUsers[widget.postdata['userInfo']['uid']]['isUserFollowing']) {
                                                MapsClass.searchedUsers[widget.postdata['userInfo']['uid']]['isUserFollowing'] = val;
                                                //}
                                              }
                                            });
                                          } else if (widget.comesFromProfile == true) {
                                            if (MapsClass.userPosts[widget.postdata['postedBy']]['isUserFollowing'] == false) {
                                              widget.followUser(user.uid, widget.postdata);
                                              MapsClass.userPosts[widget.postdata['postedBy']]['isUserFollowing'] = true;
                                              MapsClass.users[widget.postdata['userInfo']['uid']]['isUserFollowing'] = true;
                                            } else if (MapsClass.userPosts[widget.postdata['postedBy']]['isUserFollowing'] == true) {
                                              widget.unfollowUser(user.uid, widget.postdata);
                                              MapsClass.userPosts[widget.postdata['postedBy']]['isUserFollowing'] = false;
                                              MapsClass.users[widget.postdata['userInfo']['uid']]['isUserFollowing'] = false;
                                            }
                                            widget.getFollowingState(
                                              user.uid,
                                              widget.postdata['postedBy'],
                                            ).then((val) {
                                              MapsClass.userPosts[widget.postdata['postedBy']]['isUserFollowing'] = val;
                                              if (MapsClass.posts.isNotEmpty || MapsClass.posts != null) {
                                                var postsQuery = MapsClass.posts.values.toList().where((val) => val['postedBy'] == widget.postdata['postedBy']).toList();
                                                if (postsQuery.isNotEmpty || postsQuery != null) {
                                                  Future.wait(postsQuery.map((post) async {
                                                    MapsClass.posts[post['id']]['isUserFollowing'] = val;
                                                  }));
                                                }
                                              }
                                              if (MapsClass.userPosts[widget.postdata['userInfo']['uid']] != null) {
                                                MapsClass.userPosts[widget.postdata['userInfo']['uid']]['isUserFollowing'] = val;
                                              }
                                              if (MapsClass.users[widget.postdata['userInfo']['uid']] != null) {
                                                MapsClass.users[widget.postdata['userInfo']['uid']]['isUserFollowing'] = val;
                                              }
                                              if (MapsClass.searchedUsers[widget.postdata['userInfo']['uid']]['isUserFollowing'] != null) {
                                                MapsClass.searchedUsers[widget.postdata['userInfo']['uid']]['isUserFollowing'] = val;
                                              }
                                            });
                                          }
                                          //print(MapsClass.posts[widget.postdata['id']]['isUserFollowing']);
                                          setState(() {});
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(left: 4),
                                          width: 95,
                                          padding: EdgeInsets.symmetric(vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.tealAccent[400],
                                            borderRadius: BorderRadius.circular(11)
                                          ),
                                          child: Center(
                                            child: widget.comesFromProfile == false || widget.comesFromProfile == null ? Text(
                                              MapsClass.posts[widget.postdata['id']]['isUserFollowing'] == true ? 'Following' : 'Follow',
                                              style: TextStyle(
                                                color: Colors.grey[800],
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700
                                              )
                                            ) : Text(
                                              MapsClass.userPosts[widget.postdata['postedBy']]['isUserFollowing'] == true ? 'Following' : 'Follow',
                                              style: TextStyle(
                                                color: Colors.grey[800],
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700
                                              )
                                            ),
                                          )
                                        ),
                                      )
                                    ],
                                  ),
                                  /*Container(
                                    padding: EdgeInsets.only(
                                      left: 22,
                                      top: 6,  
                                    ),
                                    child: Text(
                                      '${widget.post['caption']}',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 15.3,
                                        fontWeight: FontWeight.w600
                                      ),
                                    )
                                  )*/
                                ],
                              )
                            ),
                          ),
                          Container(
                            height: 30,
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  if (aboveBoolIsLoading == false) {
                                    if (profilePostInfoIsOpen == true) {
                                      setState(() {
                                        aboveBoolIsLoading = true;
                                        profilePostInfoIsOpen = false;
                                      });
                                      Timer.periodic(
                                        Duration(milliseconds: 250),
                                        (timer) {
                                          setState(() {
                                            aboveBoolIsLoading = false;
                                            timer.cancel();
                                          });
                                        }
                                      );
                                    } else if (profilePostInfoIsOpen == false) {
                                      setState(() {
                                        aboveBoolIsLoading = true;
                                        profilePostInfoIsOpen = true;
                                      });
                                      Timer.periodic(
                                        Duration(milliseconds: 250),
                                        (timer) {
                                          setState(() {
                                            aboveBoolIsLoading = false;
                                            timer.cancel();
                                          });
                                        }
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  //color: Colors.grey[50],
                                  child: Icon(
                                    profilePostInfoIsOpen 
                                    ? CupertinoIcons.chevron_compact_up
                                    : CupertinoIcons.chevron_compact_down,
                                    color: Colors.grey[700],
                                    size: 26
                                  ),
                                ),
                              )
                            )
                          ),
                          Container(
                            //padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                            child: Comments2(
                              post: widget.postdata,
                              postId: widget.postdata['id'],
                              isFollowing: widget.postdata['isUserFollowing'],
                              myInfo: widget.myInfo,
                              key: widget.key,
                              refresh: refresh,
                            )
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        margin: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top,
                        ),
                        padding: EdgeInsets.all(8),
                        child: Transform.scale(
                          scale: 2,
                            child: Icon(
                            Icons.keyboard_arrow_left_rounded,
                            color: Colors.white,
                            
                          ),
                        )
                      ),
                    )
                  )
                ],
              )
            )
          )
        );
  }
}
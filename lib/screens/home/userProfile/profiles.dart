import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
//import 'package:file_picker/file_picker.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:untitled_startup/models/user.dart';
//import 'package:untitled_startup/screens/home/chat/chat.dart';
import 'package:untitled_startup/screens/home/chat/inChatScreen.dart';
import 'package:untitled_startup/screens/home/main/classes/mapsClass.dart';
import 'package:untitled_startup/screens/home/main2/postMain2.dart';
import 'package:untitled_startup/screens/home/settings/editProfile.dart';
//import 'package:untitled_startup/screens/home/userProfile/SliverDelegate.dart';
import 'package:untitled_startup/screens/home/userProfile/profileGrid.dart';
import 'package:untitled_startup/screens/home/userProfile/profileTabbarSliver.dart';
import 'package:untitled_startup/screens/home/userProfile/theProfilesSliver.dart';
import 'package:untitled_startup/services/cacheClass/cacheManager.dart';
import 'package:untitled_startup/services/database.dart';
//import 'package:untitled_startup/services/database.dart';


class Profiles extends StatefulWidget {
  final Map<String, dynamic> myInfo;
  final int currentIndex;
  final Map<dynamic, dynamic> userInfo;
  final double maxHeight;
  final bool isFollowing;
  final Function getFollowingState;
  final bool comesFromComments;
  final String commentId;
  final String replyId;
  final bool comesFromReply;
  Profiles({this.currentIndex, this.userInfo, this.maxHeight,
  this.getFollowingState, this.isFollowing, this.myInfo, this.comesFromComments,
  this.commentId, this.replyId, this.comesFromReply});
  @override
  _ProfilesState createState() => _ProfilesState();
}

class _ProfilesState extends State<Profiles> with SingleTickerProviderStateMixin {
  //bool isUploading = false;
  //bool hasUploaded = true;
  //bool isLoading = false;
  //File imageFile;
  //double porcentageHeight = 0.0;
  double theBorderRadius = 45.0;

  TabController tabController;

  Map theSizesMap = {};

  //bool isFollowing;

  ScrollController scrollController = ScrollController();
  DocumentSnapshot firstDoc;
  int prevPost;
  DocumentSnapshot lastDocument;
  bool gettingMorePosts = false;
  bool morePostsAvailable = true;
  //List<DocumentSnapshot> profilePosts = [];
  //Map profilePostsMap = {};

  bool hasLoaded = false;

  //bool chatExists;
  bool hasChatExistsLoaded = false;
  String groupChatId = '';
  checkIfChatExists(myUid, userUid) async {
    if (myUid.substring(0, 1).codeUnitAt(0) > userUid.substring(0, 1).codeUnitAt(0)) {
        groupChatId = '$myUid-$userUid';
    } else {
        groupChatId = '$userUid-$myUid';
    }
    DocumentSnapshot theQuery = await FirebaseFirestore.instance.collection('chatRooms')
    .doc(groupChatId).get();
    hasChatExistsLoaded = true;
    setState(() {});
    return [theQuery.exists, groupChatId];
  }

  getFollowingState(myUid, userUid) async {
    await DatabaseService(
      uid: myUid,
    ).isFollowingUser(userUid).then((value) {
      if (mounted) {
        setState(() {
          MapsClass.userPosts[userUid]['isUserFollowing'] = value;
          MapsClass.users[userUid]['isUserFollowing'] = value;
        });
      }
    });
    return MapsClass.userPosts[userUid]['isUserFollowing'];
  }

  getLikedState(postId, userUid, myInfo) async {
    await DatabaseService(
      docId: postId,
      uid: myInfo
    ).hasLikedPost().then((value) {
      if (mounted) {
        if (MapsClass.userPosts[userUid] != null) {
          //if (MapsClass.userPosts[userUid]['posts'][postId] != null) {
            setState(() {   
              MapsClass.userPosts[userUid]['posts'][postId]['userHasLiked'] = value;
            });
          //}
        }
      }
    });
    if (MapsClass.userPosts[userUid] != null) {
      return MapsClass.userPosts[userUid]['posts'][postId]['userHasLiked'];
    } else {
      return null;
    }
  }

  // loadPostImages(postId, userUid) async {
  //   var configuration = createLocalImageConfiguration(context);
  //   CachedNetworkImageProvider loadedImg = CachedNetworkImageProvider("${MapsClass.userPosts[userUid]['posts'][postId]['postImg']}")..resolve(configuration);
  //   setState(() {
  //     MapsClass.userPosts[userUid]['posts'][postId]['loadedImg'] = loadedImg;
  //   });
  // }

  // loadProfileImgs(postId, userUid) async {
  //   var configuration = createLocalImageConfiguration(context);
  //   CachedNetworkImageProvider loadedImg = CachedNetworkImageProvider("${MapsClass.userPosts[userUid]['posts'][postId]['userInfo']['profileImg']}")..resolve(configuration);
  //   setState(() {
  //     MapsClass.userPosts[userUid]['posts'][postId]['userInfo']['loadedProfileImg'] = loadedImg;
  //   });
  // }

  // loadProfileBannerImg(postId, userUid) async {
  //   var configuration = createLocalImageConfiguration(context);
  //   CachedNetworkImageProvider loadedImg = CachedNetworkImageProvider("${MapsClass.userPosts[userUid]['posts'][postId]['userInfo']['bannerImg']}")..resolve(configuration);
  //   //forYouPosts[postId]['userInfo']['loadedProfileImg'] = loadedImg;
  //   //widget.forProfileLoadedProfileImg(widget.id, loadedImg, postId);
  //   setState(() {
  //     MapsClass.userPosts[userUid]['posts'][postId]['userInfo']['loadedProfileBannerImg'] = loadedImg;
  //   });
  // }

  getAllUserPostThings(postId, userUid, myInfo) async {
    //final user = Provider.of
    //print(profilePostsMap[userUid]['posts'][postId]);
    await getLikedState(postId, userUid, myInfo);
    // awaixploadProfileImgs(postId, userUid);
    //await loadProfileBannerImg(postId, userUid);
  }

  getPosts() async {
    Query theQuery = FirebaseFirestore.instance.collection('posts')
    .where('postedBy', isEqualTo: widget.userInfo['uid'])
    .orderBy('time', descending: true).limit(3);
    setState(() {});
    QuerySnapshot querySnapshot = await theQuery.get();
    if (querySnapshot.docs.isNotEmpty) {
      final user = Provider.of<CustomUser>(context, listen: false);
      //MapsClass.userPosts = {};
      Map<String, dynamic> theMap = {};
      bool isFollowing = widget.isFollowing;
      Map<String, dynamic> theMap2 = {'posts': theMap, 'isUserFollowing': isFollowing};
      MapsClass.userPosts[widget.userInfo['uid']] = theMap2;
      //MapsClass.userPosts[widget.userInfo['uid']]['posts'] = theMap;
      //MapsClass.userPosts[widget.userInfo['uid']]['isUserFollowing'] = isFollowing;
      //List theHeights = [];
      await Future.wait(querySnapshot.docs.map((doc) async {
        Map aMap = {};
        
        aMap[doc.data()['id']] = doc.data();
        aMap[doc.data()['id']]['userInfo'] = widget.userInfo;
        //print(doc.data());

        MapsClass.userPosts[widget.userInfo['uid']]['posts']
          = {... MapsClass.userPosts[widget.userInfo['uid']]['posts'], ...aMap};
        //print(MapsClass.userPosts[widget.userInfo['uid']]['posts']);
        await getAllUserPostThings(doc.data()['id'], widget.userInfo['uid'], user.uid);
      }));
      //print(theHeights);
      lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    } else {
      morePostsAvailable = false;
    }
    hasLoaded = true;
    //thePosts = querySnapshot.docs;
    setState(() {});
  }

  getMorePosts() async {
    if (morePostsAvailable == false) {
      return;
    }
    if (gettingMorePosts == true) {
      return;
    }
    gettingMorePosts = true;
    Query theQuery = FirebaseFirestore.instance.collection('posts')
    .where('postedBy', isEqualTo: widget.userInfo['uid']).orderBy('time', descending: true)
    .startAfterDocument(lastDocument).limit(15);
    QuerySnapshot querySnapshot = await theQuery.get();
    if (querySnapshot.docs.isNotEmpty) {
      if (querySnapshot.docs.length < 12 || querySnapshot.docs.length == 0) {
        morePostsAvailable = false;
      }
      final user = Provider.of<CustomUser>(context, listen: false);
      await Future.wait(querySnapshot.docs.map((doc) async {
        Map aMap = {};
        aMap[doc.data()['id']] = doc.data();
        aMap[doc.data()['id']]['userInfo'] = widget.userInfo;
        MapsClass.userPosts[widget.userInfo['uid']]['posts'] 
          = {...MapsClass.userPosts[widget.userInfo['uid']]['posts'], ...aMap};
        await getAllUserPostThings(doc.data()['id'], widget.userInfo['uid'], user.uid);
      }));
      lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    } else {
      morePostsAvailable = false;
    }
    setState(() {});
    gettingMorePosts = false;

  }

  void scrollToPosition(position) {
    if (scrollController.hasClients) {
      scrollController.jumpTo(position);
    }
  }

  /*getChatExistsAndIsFollowing(myUid, userUid) async {
    Map aMap = {'posts': {}};
    profilePostsMap[userUid] = aMap;
    profilePostsMap[userUid]['isUserFollowing'] = widget.isFollowing;
    await checkIfChatExists(myUid, userUid).then((val) {
      profilePostsMap[userUid]['hasChat'] = val;
    });
  }*/

  bool blackStatusBar = false;

  loadProfile() {
    final user = Provider.of<CustomUser>(context ,listen: false);
    if (MapsClass.users[widget.userInfo['uid']] == null) {
      MapsClass.users[widget.userInfo['uid']] = widget.userInfo;
      MapsClass.users[widget.userInfo['uid']]['isUserFollowing'] = widget.isFollowing;
      MapsClass.userPosts[widget.userInfo['uid']] = {};
      MapsClass.userPosts[widget.userInfo['uid']]['isUserFollowing'] = widget.isFollowing;
      checkIfChatExists(user.uid, widget.userInfo['uid']).then((val) {
        MapsClass.users[widget.userInfo['uid']]['hasChat'] = val[0];
        if (val[0] == true) {
          MapsClass.users[widget.userInfo['uid']]['groupChatId'] = val[1];
        }
      });
      getFollowingState(user.uid, widget.userInfo['uid']).then((val) {
        MapsClass.users[widget.userInfo['uid']]['isUserFollowing'] = val;
        MapsClass.userPosts[widget.userInfo['uid']]['isUserFollowing'] = val;
        if (MapsClass.posts.isNotEmpty || MapsClass.posts == null) {
          List<dynamic> postsQuery = MapsClass.posts.values.toList().where((val) => val['postedBy'] == widget.userInfo['uid']).toList();
          if (postsQuery.isNotEmpty || postsQuery != null) {
            Future.wait(postsQuery.map((post) async {
              MapsClass.posts[post['id']]['isUserFollowing'] = val;
            }));
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    //print(widget.isFollowing);
    if (MapsClass.users[widget.userInfo['uid']] == null) {
      loadProfile();
    }
    tabController = TabController(vsync: this, length: 2);
    getPosts();
    scrollController.addListener(() {
      double maxScroll = scrollController.position.maxScrollExtent;
      double currentScroll = scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if (maxScroll - currentScroll < delta) {
        getMorePosts();
      }
      if (scrollController.offset > 
      ((MediaQuery.of(context).size.height * 0.15) - (MediaQuery.of(context).padding.top + 10))) {
        setState(() {
          blackStatusBar = true;
        });
      } else {
        setState(() {
          blackStatusBar = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        // For Android.
        // Use [light] for white status bar and [dark] for black status bar.
        statusBarIconBrightness: 
          blackStatusBar ? Brightness.dark : Brightness.light,
        // For iOS.
        // Use [dark] for white status bar and [light] for black status bar.
        statusBarBrightness: //Brightness.dark,
        blackStatusBar ? Brightness.light : Brightness.dark,
        
      ),
      child: Scaffold(
        body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: MediaQuery.of(context).size.width,
          //margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05),
          child: Stack(
            children: [
              //FractionallySizedBox(
              Container(
                color: Colors.deepPurpleAccent
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: (MediaQuery.of(context).size.height * 0.15) + 45,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                  ),
                  child: CachedNetworkImage(
                    fadeInDuration: Duration(milliseconds: 10),
                    fadeOutDuration: Duration(milliseconds: 10),
                    placeholder: (context, url) => Container(color: Colors.deepPurpleAccent),
                    imageUrl: MapsClass.users[widget.userInfo['uid']]['bannerImg'],
                    fit: BoxFit.cover,
                    cacheManager: CustomCacheManager.instance,
                  )
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.85,
                  //heightFactor: 0.85,
                  //color: Colors.transparent,
                  child: Container(
                    //height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(theBorderRadius), 
                        topRight: Radius.circular(theBorderRadius)
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: Offset(0, -2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                    )
                  ),
                ),
              ),
              NestedScrollView(
                controller: scrollController,
                headerSliverBuilder: (context, value) {
                  return [
                    SliverPersistentHeader(
                      pinned: true,
                      floating: false,
                      delegate: ProfilesSliverDelegate(
                        sliverHeaderHeight: (MediaQuery.of(context).size.height * 0.15) + 62,
                        statusBar: MediaQuery.of(context).padding.top,
                        //refresh: refresh,
                        userInfo: MapsClass.users[widget.userInfo['uid']],
                        isMyProfile: widget.userInfo['uid'] == user.uid ? true : false,
                        theContext: context
                        //showThePopover: showThePopover
                      )
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate([
                        Container(
                          color: Colors.grey[50],
                          padding: EdgeInsets.only(
                            left: 42,
                            top: 12,
                            bottom: 12
                            //horizontal: 42, vertical: 8
                          ),
                          child: Row(
                            children: [
                              Container(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Followers ',
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        )
                                      ),
                                      TextSpan(
                                        text: '${MapsClass.users[widget.userInfo['uid']]['followersCount']}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        )
                                      )
                                    ]
                                  )
                                )
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 15),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Following ',
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        )
                                      ),
                                      TextSpan(
                                        text: '${MapsClass.users[widget.userInfo['uid']]['followingCount']}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        )
                                      )
                                    ]
                                  )
                                )
                              )
                            ],
                          )
                        ),
                        MapsClass.users[widget.userInfo['uid']] != null ? 
                          MapsClass.users[widget.userInfo['uid']]['bio'] == '' 
                          || MapsClass.users[widget.userInfo['uid']]['bio'] == null
                          ? Container() 
                          : Container(
                            color: Colors.grey[50],
                            padding: EdgeInsets.symmetric(horizontal: 42),
                            child: Text(
                              '${MapsClass.users[widget.userInfo['uid']]['bio']}',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.grey[850],
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              )
                            )
                          ) : Container(),
                        Builder(
                          builder: (context) {
                            if (widget.userInfo['uid'] == user.uid) 
                            return Container(
                              color: Colors.grey[50],
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => EditProfile(
                                        userInfo: widget.userInfo,
                                      )
                                    )
                                  );
                                  //EditProfile();
                                },
                                child: Center(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      bottom: 8,
                                      top: 20
                                    ),
                                    width: 160,
                                    padding: EdgeInsets.symmetric(vertical: 9),
                                    //width: 220,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(35),
                                      border: Border.all(color: Colors.blue, width: 2)
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Edit',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800
                                        )
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                            return Container(
                              color: Colors.grey[50],
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    color: Colors.grey[50],
                                    child: GestureDetector(
                                      onTap: () {
                                        if (MapsClass.users.keys.toList().contains(widget.userInfo['uid'])) {

                                          if (MapsClass.users[widget.userInfo['uid']]['isUserFollowing'] == false) {
                                            Map<String, dynamic> followerMap = {
                                              'follower': user.uid,
                                              'to': widget.userInfo['uid']
                                            };
                                            Map<String, dynamic> followingMap = {
                                              'following': widget.userInfo['uid'],
                                              'from': user.uid
                                            };
                                            DatabaseService().batchedFollow(
                                              followerMap, user.uid, followingMap, widget.userInfo['uid'],
                                              {'followersCount': FieldValue.increment(1)}, 
                                              {'followingCount': FieldValue.increment(1)},
                                              user.uid,
                                              widget.userInfo['uid'],
                                            );
                                            MapsClass.users[widget.userInfo['uid']]['isUserFollowing'] = true;
                                            MapsClass.userPosts[widget.userInfo['uid']]['isUserFollowing'] = true;

                                            getFollowingState(user.uid, widget.userInfo['uid']).then((val) {
                                              MapsClass.users[widget.userInfo['uid']]['isUserFollowing'] = val;
                                              MapsClass.userPosts[widget.userInfo['uid']]['isUserFollowing'] = val;
                                              if ( MapsClass.searchedUsers[widget.userInfo['uid']] != null && 
                                                MapsClass.searchedUsers[widget.userInfo['uid']]['isUserFollowing'] != null) {
                                                MapsClass.searchedUsers[widget.userInfo['uid']]['isUserFollowing'] = val;
                                              }
                                              if (MapsClass.posts.isNotEmpty || MapsClass.posts == null) {
                                                List<dynamic> postsQuery = MapsClass.posts.values.toList().where((val) => val['postedBy'] == widget.userInfo['uid']).toList();
                                                if (postsQuery.isNotEmpty || postsQuery != null) {
                                                  Future.wait(postsQuery.map((post) async {
                                                    MapsClass.posts[post['id']]['isUserFollowing'] = val;
                                                  }));
                                                }
                                              }
                                            });
                                            setState(() {});
                                            //print(isFollowing);

                                          } else if (MapsClass.users[widget.userInfo['uid']]['isUserFollowing'] == true) {
                                            DatabaseService().batchedUnfollow(
                                              user.uid, widget.userInfo['uid'],
                                              {'followersCount': FieldValue.increment(-1)}, 
                                              {'followingCount': FieldValue.increment(-1)},
                                              user.uid,
                                              widget.userInfo['uid'],
                                            );
                                            MapsClass.users[widget.userInfo['uid']]['isUserFollowing'] = false;
                                            MapsClass.userPosts[widget.userInfo['uid']]['isUserFollowing'] = false;
                                            
                                            getFollowingState(user.uid, widget.userInfo['uid']).then((val) {
                                              MapsClass.users[widget.userInfo['uid']]['isUserFollowing'] = val;
                                              MapsClass.userPosts[widget.userInfo['uid']]['isUserFollowing'] = val;
                                              if (MapsClass.searchedUsers[widget.userInfo['uid']] != null &&
                                                MapsClass.searchedUsers[widget.userInfo['uid']]['isUserFollowing'] != null) {
                                                MapsClass.searchedUsers[widget.userInfo['uid']]['isUserFollowing'] = val;
                                              }
                                              if (MapsClass.posts.isNotEmpty || MapsClass.posts == null) {
                                                List<dynamic> postsQuery = MapsClass.posts.values.toList().where((val) => val['postedBy'] == widget.userInfo['uid']).toList();
                                                if (postsQuery.isNotEmpty || postsQuery != null) {
                                                  Future.wait(postsQuery.map((post) async {
                                                    MapsClass.posts[post['id']]['isUserFollowing'] = val;
                                                  }));
                                                }
                                              }
                                            });
                                            setState(() {});

                                          }
                                        }
                                      },
                                      child: Center(
                                        child: MapsClass.users.keys.toList().contains(widget.userInfo['uid'])
                                        ? MapsClass.users[widget.userInfo['uid']]['isUserFollowing'] == true ?
                                          Container(
                                            margin: EdgeInsets.only(
                                              bottom: 8,
                                              top: 8
                                            ),
                                            width: 160,
                                            padding: EdgeInsets.symmetric(vertical: 9),
                                            //width: 220,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              color: Colors.grey[100],
                                              borderRadius: BorderRadius.circular(35),
                                              border: Border.all(color: Colors.grey[800], width: 2)
                                            ),
                                            child: Center(
                                              child: Text(
                                                'Following',
                                                style: TextStyle(
                                                  color: Colors.grey[850],
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w800
                                                )
                                              ),
                                            ),
                                          ) : Container(
                                            margin: EdgeInsets.only(
                                              bottom: 8,
                                              top: 8
                                            ),
                                            width: 160,
                                            padding: EdgeInsets.symmetric(vertical: 9),
                                            //width: 220,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              color: Colors.deepPurpleAccent,
                                              borderRadius: BorderRadius.circular(35),
                                              border: Border.all(color: Colors.deepPurpleAccent, width: 2)
                                            ),
                                            child: Center(
                                              child: Text(
                                                'Follow',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w800
                                                )
                                              ),
                                            ),
                                          )
                                        : Container(
                                          margin: EdgeInsets.only(
                                            bottom: 8,
                                            top: 8
                                          ),
                                          width: 160,
                                          padding: EdgeInsets.symmetric(vertical: 9),
                                          //width: 220,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            color: Colors.deepPurpleAccent,
                                            borderRadius: BorderRadius.circular(35),
                                            border: Border.all(color: Colors.deepPurpleAccent, width: 2)
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Loading..',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800
                                              )
                                            ),
                                          ),
                                        )
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (MapsClass.users[widget.userInfo['uid']]['hasChat'] != null) {
                                        if (MapsClass.users[widget.userInfo['uid']]['hasChat'] == true) {
                                          Navigator.push(
                                            context, 
                                            CupertinoPageRoute(
                                              builder: (context) => InChat(
                                                userInfo: MapsClass.users[widget.userInfo['uid']],
                                                chatExists: true,
                                                chatRoomId: MapsClass.users[widget.userInfo['uid']]['groupChatId'],
                                                myInfo: widget.myInfo,
                                                comesFromProfile: true,
                                              )
                                            )
                                          );
                                        } else if (MapsClass.users[widget.userInfo['uid']]['hasChat'] == false) {
                                          Navigator.push(
                                            context, 
                                            CupertinoPageRoute(
                                              builder: (context) => InChat(
                                                userInfo: MapsClass.users[widget.userInfo['uid']],
                                                chatExists: false,
                                                myInfo: widget.myInfo,
                                                comesFromProfile: true,
                                              )
                                            )
                                          );
                                        }
                                      }
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(left: 8),
                                      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                                      decoration: BoxDecoration(
                                        //color: Colors.red,
                                        color: Colors.grey[100],
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.grey[800], width: 2)
                                      ),
                                      child: Icon(
                                        Icons.mail_outline_rounded,
                                        color: Colors.grey[900],
                                      )
                                    ),
                                  )
                                  
                                ],
                              ),
                            );
                          }
                        ),
                      ]),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: ProfileTabBarDelegate(
                        tabController: tabController
                      ),
                    ),

                  ];
                }, 
                body: Builder(
                  builder: (context) {
                    return Container(
                      color: Colors.grey[50],
                      child: Stack(
                        children: [
                          TabBarView(
                            controller: tabController,
                            children: [
                          
                              ProfileGrid(
                                profilePosts: MapsClass.userPosts[widget.userInfo['uid']]['posts'],
                                profileUserInfo: MapsClass.users[widget.userInfo['uid']],
                                scrollTo: scrollToPosition,
                                comesFromProfiles: true,
                                morePostsAvailable: morePostsAvailable,
                                hasLoaded: hasLoaded,
                                myInfo: widget.myInfo,
                                getFollowingState: getFollowingState,
                                getLikeState: getLikedState,
                                //theGlobalKeys: List<GlobalKey>.generate(profilePosts.length,
                                //  (i) => GlobalKey()),
                              ),
                              Container()
                            ],
                          ),
                          /*Container(
                            color: Colors.transparent,
                            width: MediaQuery.of(context).size.width * 0.1
                          )*/
                        ],
                      )
                    );
                  },
                )
              ),
            ],
          )
          ),
        ),
      ),
    );
  }
}
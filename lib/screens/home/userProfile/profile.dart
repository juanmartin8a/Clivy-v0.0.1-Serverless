import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled_startup/models/user.dart';
import 'package:untitled_startup/screens/home/main/classes/mapsClass.dart';
import 'package:untitled_startup/screens/home/settings/editProfile.dart';
import 'package:untitled_startup/screens/home/userProfile/profileGrid.dart';
import 'package:untitled_startup/screens/home/userProfile/profileTabbarSliver.dart';
import 'package:untitled_startup/screens/home/userProfile/theProfilesSliver.dart';
import 'package:untitled_startup/services/cacheClass/cacheManager.dart';
import 'package:untitled_startup/services/database.dart';
//import 'package:popover/popover.dart';


class Profile extends StatefulWidget {
  final int currentIndex;
  final double currentPagePos;
  final Map<String, dynamic> userInfo;
  Profile({this.currentIndex, this.currentPagePos, this.userInfo, Key key}) : super(key: key);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(bucket: 'gs://untitledstartup-3e326.appspot.com');
  UploadTask _uploadTask;
  TaskSnapshot _taskSnapshot;
  bool isUploading = false;
  bool isLoading = false;
  File imageFile;
  double theBorderRadius = 45.0;

  TabController tabController;

  bool hasLoaded = false;
  

  uploadImage(BuildContext context) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    if (imageFile.path != null) {
      isUploading = true;
      String filePath = 'users/profileImg/${user.uid}.jpg';
      _uploadTask = _storage.ref().child(filePath).putFile(File(imageFile.path));
      _taskSnapshot = await _uploadTask;
      final String downloadUrl = await _taskSnapshot.ref.getDownloadURL();
      Map<String, dynamic> theEditMapMap = {
        'profileImg': downloadUrl
      };
      DatabaseService(uid: user.uid).editProfile(theEditMapMap);
      if (mounted) {
        setState(() {
          isUploading = false;
          imageFile = null;
        });
      }
    }
  }

  void pickFiles(BuildContext context) async {
    FilePickerResult pickedFile = await FilePicker.platform.pickFiles(type: FileType.image);
    setState(() {
      if (pickedFile != null) {
        isLoading = true;
        imageFile = File(pickedFile.files.first.path);
        uploadImage(context);
      } else {
      }
    });
  }


  ScrollController scrollController = ScrollController();
  DocumentSnapshot firstDoc;
  int prevPost;
  DocumentSnapshot lastDocument;
  bool gettingMorePosts = false;
  bool morePostsAvailable = true;
  List<DocumentSnapshot> profilePosts = [];
  //Map<String, dynamic> profilePostsMap = {};

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
        setState(() {   
          //profilePostsMap[userUid]['posts'][postId]['userHasLiked'] = value;
          MapsClass.userPosts[userUid]['posts'][postId]['userHasLiked'] = value;
        });
      }
    });
    if (MapsClass.userPosts[userUid] != null) {
      return MapsClass.userPosts[userUid]['posts'][postId]['userHasLiked'];
    } else {
      return null;
    }
    //return MapsClass.userPosts[userUid]['posts'][postId]['userHasLiked'];
  }

  // loadPostImages(postId, userUid) async {
  //   var configuration = createLocalImageConfiguration(context);
  //   CachedNetworkImageProvider loadedImg = CachedNetworkImageProvider("${profilePostsMap[userUid]['posts'][postId]['postImg']}")..resolve(configuration);
  //   setState(() {
  //     profilePostsMap[userUid]['posts'][postId]['loadedImg'] = loadedImg;
  //   });
  // }

  getAllUserPostThings(postId, userUid, myInfo) async {
    await getLikedState(postId, userUid, myInfo);
    //await loadPostImages(postId, userUid);
  }

  getPosts() async {
    Query theQuery = FirebaseFirestore.instance.collection('posts')
    .where('postedBy', isEqualTo: widget.userInfo['uid'])
    .orderBy('time', descending: true).limit(15);
    setState(() {});
    QuerySnapshot querySnapshot = await theQuery.get();
    if (querySnapshot.docs.isNotEmpty) {
      final user = Provider.of<CustomUser>(context, listen: false);
      Map<String, dynamic> theMap = {};
      bool isFollowing = false;
      Map<String, dynamic> theMap2 = {'posts': theMap, 'isUserFollowing': isFollowing};
      MapsClass.userPosts[widget.userInfo['uid']] = theMap2;
      await Future.wait(querySnapshot.docs.map((doc) async {
        Map aMap = {};
        aMap[doc.data()['id']] = doc.data();
        aMap[doc.data()['id']]['userInfo'] = widget.userInfo;

        MapsClass.userPosts[widget.userInfo['uid']]['posts'] 
          = {... MapsClass.userPosts[widget.userInfo['uid']]['posts'], ...aMap};

        // profilePostsMap[widget.userInfo['uid']]['posts'] 
        //   = {...profilePostsMap[widget.userInfo['uid']]['posts'], ...aMap};
        await getAllUserPostThings(doc.data()['id'], widget.userInfo['uid'], user.uid);
      }));
      lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    } else {
      morePostsAvailable = false;
    }
    hasLoaded = true;
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
    .startAfterDocument(lastDocument).limit(12);
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

  loadProfile() {
    final user = Provider.of<CustomUser>(context ,listen: false);
    if (MapsClass.users[widget.userInfo['uid']] == null) {
      MapsClass.users[widget.userInfo['uid']] = widget.userInfo;
      MapsClass.users[widget.userInfo['uid']]['isUserFollowing'] = false;
      MapsClass.userPosts[widget.userInfo['uid']] = {};
      MapsClass.userPosts[widget.userInfo['uid']]['isUserFollowing'] = false;
      //checkIfChatExists(user.uid, widget.userInfo['uid']).then((val) {
      MapsClass.users[widget.userInfo['uid']]['hasChat'] = false;
      //});
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

  bool blackStatusBar = false;

  @override
  void initState() {
    super.initState();
    if (MapsClass.users[widget.userInfo] == null) {
      loadProfile();
    }
    tabController = TabController(vsync: this, length: 2);
    //getChatExistsAndIsFollowing(user.uid);
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
    return Align(
    alignment: Alignment.bottomCenter,
    child: FractionallySizedBox(
      widthFactor: 1 / 1.05,
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Stack(
            children: [
              Container(
                color: Colors.transparent
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: (MediaQuery.of(context).size.height * 0.15) + 45,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(),
                  child: CachedNetworkImage(
                    fadeInDuration: Duration(milliseconds: 10),
                    fadeOutDuration: Duration(milliseconds: 10),
                    placeholder: (context, url) => Container(color: Colors.transparent),
                    imageUrl: widget.userInfo['bannerImg'],
                    fit: BoxFit.cover,
                    cacheManager: CustomCacheManager.instance,
                    imageBuilder: (context, imageProvider) {
                      return Opacity(
                        opacity: widget.currentPagePos,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover
                            )
                          ),
                        ),
                      );
                    },
                  ),
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
                        userInfo: widget.userInfo,
                        isMyProfile: true,
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
                        widget.userInfo['bio'] == '' || widget.userInfo['bio'] == null
                        ? Container()
                        :  Container(
                          color: Colors.grey[50],
                          padding: EdgeInsets.symmetric(horizontal: 42),
                          child: Text(
                            '${widget.userInfo['bio']}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.grey[850],
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            )
                          )
                        ),
                        Container(
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
                                  top: 8
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
                                profileUserInfo: widget.userInfo,
                                scrollTo: scrollToPosition,
                                comesFromProfiles: false,
                                morePostsAvailable: morePostsAvailable,
                                hasLoaded: hasLoaded,
                                myInfo: widget.userInfo,
                                getFollowingState: getFollowingState,
                                getLikeState: getLikedState,
                                //theGlobalKeys: List<GlobalKey>.generate(profilePosts.length,
                                //  (i) => GlobalKey()),
                              ),
                              Container()
                            ],
                          ),
                          Container(
                            color: Colors.transparent,
                            width: MediaQuery.of(context).size.width * 0.1
                          )
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
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
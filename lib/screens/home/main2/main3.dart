import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled_startup/models/user.dart';
import 'package:untitled_startup/screens/home/main/classes/mapsClass.dart';
//import 'package:untitled_startup/screens/home/main/postData.dart';
import 'package:untitled_startup/screens/home/main2/postMain2.dart';
import 'package:untitled_startup/screens/home/main2/postMain3.dart';
import 'package:untitled_startup/services/database.dart';

class Main3 extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  Main3({this.userInfo, @required Key key}) : super(key: key);
  @override
  _Main3State createState() => _Main3State();
}

class _Main3State extends State<Main3> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {

  ScrollController _scrollController = ScrollController();
  bool isFetching = false;
  bool moreVideogamesAvailable = true;

  Map theVideogamesMap = {};
  DocumentSnapshot lastDocument;
  bool hasLoaded = false;

  bool postsAvailable = true;
  bool gettingMorePosts = false;

  bool isLoadingNewCat = false;

  bool pullToRefresh = false;

  Map currentSearch = {
    'forYou': 'forYou'
  };

  ScrollController _postFeedScrollController = ScrollController();

  Map<String, dynamic> videogameImages = {
    'Among Us': 'assets/images/amongUs.jpg',
    'Apex Legends': 'assets/images/apexLegends.jpg',
    'Star Wars Battlefront II': 'assets/images/battlefront2.jpg',
    'COD: Cold War': 'assets/images/coldWar.jpg',
    'COD: Modern Warfare': 'assets/images/modernWarfare.jpg',
    'CSGO': 'assets/images/CounterStrike.jpg',
    'Cyberpunk 2077': 'assets/images/cyberpunk2077.jpg',
    'Dota 2': 'assets/images/Dota2.jpg',
    'FIFA': 'assets/images/FIFA.jpg',
    'Fortnite': 'assets/images/Fortnite.jpg',
    'Grand Theft Auto V': 'assets/images/GTA.jpg',
    'League of Legends': 'assets/images/LOL.jpg',
    'Madden NFL': 'assets/images/Madden.jpg',
    'Minecraft': 'assets/images/Minecraft.jpg',
    'NBA 2K': 'assets/images/NBA.jpg',
    'Overwatch': 'assets/images/Overwatch.jpg',
    'Rainbow Six Siege': 'assets/images/Rainbows.jpg',
    'Rocket League': 'assets/images/RocketL.jpg',
    'Rust': 'assets/images/Rust.jpg',
    'VALORANT': 'assets/images/VALORANT.jpg',
    'COD: Warzone': 'assets/images/Warzone.jpg',
    'World of Warcraft': 'assets/images/WoW.jpg',
    'None': 'none',
    'Other': 'none'
  };

  getVideogamesFromDB() async {
    setState(() {
      isFetching = true;
    });
    Query theQuery = FirebaseFirestore.instance.collection('videogames')
    //.where('hasData', isEqualTo: true)
    //// REMEMBER TO QUERY BY POPULARITY LATER:)
    .limit(12);
    setState(() {});
    QuerySnapshot querySnapshot = await theQuery.get();
    if (querySnapshot.docs.length < 12 || querySnapshot.docs.length == 0) {
      moreVideogamesAvailable = false;
    }
    if (querySnapshot.docs.length > 0) {
      await Future.wait(querySnapshot.docs.map((doc) async {
        theVideogamesMap['forYou'] = {'id': 'forYou', 'videogame': 'forYou', 
          'nameForCategory': 'For You', 'data': {}};
        theVideogamesMap['following'] = {'id': 'following', 'videogame': 'following', 
          'nameForCategory': 'Following', 'data': {}};
        theVideogamesMap[doc.data()['id']] = doc.data();
        theVideogamesMap[doc.data()['id']]['data'] = {};
      }));
      lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    } else {
      moreVideogamesAvailable = false;
    }
    isFetching = false;
    hasLoaded = true;
    getForYouPosts();
    setState(() {});
  }

  getMoreVideogamesFromDB() async {
    if (moreVideogamesAvailable == false) {
      return;
    }
    if (isFetching == true) {
      return;
    }
    setState(() => isFetching = true);
    Query theQuery = FirebaseFirestore.instance.collection('videogames')
    //.where('hasData', isEqualTo: true)
    .startAfterDocument(lastDocument)
    //// REMEMBER TO QUERY BY POPULARITY LATER:)
    .limit(12);
    setState(() {});
    QuerySnapshot querySnapshot = await theQuery.get();
    if (querySnapshot.docs.length > 0) {
      await Future.wait(querySnapshot.docs.map((doc) async {
        theVideogamesMap[doc.data()['id']] = doc.data();
        theVideogamesMap[doc.data()['id']]['data'] = {};
      }));
      lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    } else {
      moreVideogamesAvailable = false;
    }
    isFetching = false;
    hasLoaded = true;
    setState(() {});
  }

  getLikedState(postId, userUid,) async {
    bool userHasLiked;
    await DatabaseService(
      docId: postId,
      uid: userUid
    ).hasLikedPost().then((value) {
      if (mounted) {
        setState(() {   
          userHasLiked = value;
        });
      }
    });
    return userHasLiked;
  }

  getFollowingState(postUserUid, postId, userUid) async {
    bool isFollowing;
    await DatabaseService(
      uid: postUserUid
    ).isFollowingUser(userUid).then((value) {
      if (mounted) {
        setState(() {
          isFollowing = value;
        });
      }
    });
    return isFollowing;
  }

  getUserInfo(postUserUid, postId) async {
    Map userInfo = {};
    await DatabaseService(uid: postUserUid).getUserByUidFuture().then((val) async {
      setState(() { 
        //MapsClass.posts[postId]['userInfo'] = val.data();
        userInfo = val.data();
        //theVideogamesMap[id]['data'][postId]['userInfo'] = val.data();
      });
    });
    return userInfo;
    //await loadProfileImgs(postId,);
    //await loadProfileBannerImgs(postId);
  }
 
  getAllPostThings(postUserUid, postId, userUid) async {
    Map userInfo = {};
    bool isFollowing;
    bool userHasLiked;

    await getUserInfo(postUserUid, postId).then((val) {
      userInfo = val;
    });
    await getFollowingState(userUid, postId, postUserUid).then((val) {
      isFollowing = val;
    });
    await getLikedState(postId, userUid).then((val) {
      userHasLiked = val;
    });
    if (userInfo != {} && isFollowing != null && userHasLiked != null) {
      return [userInfo, isFollowing, userHasLiked];
    } else {
      return null;
    }
  }

  getForYouPosts() async {
    setState(() {
      postsAvailable = true;
      gettingMorePosts = true;
      isLoadingNewCat = true;
    });
    final user = Provider.of<CustomUser>(context, listen: false);
    Query theQuery = FirebaseFirestore.instance.collection('posts')
    .orderBy('time', descending: true)
    .orderBy('likes', descending: true)
    .limit(16);
    setState(() {});
    QuerySnapshot querySnapshot = await theQuery.get();
    //MapsClass.posts = {};
    Map prePosts = {};
    if (querySnapshot.docs.length > 0) {
      await Future.wait(querySnapshot.docs.map((doc) async {
        Map aMap = {};
        aMap[doc.data()['id']] = doc.data();
        aMap[doc.data()['id']]['userInfo'] = {};
        prePosts = {...prePosts, ...aMap};

        await getAllPostThings(doc.data()['postedBy'], doc.data()['id'], user.uid).then((val) {
          if (val != null) {
            prePosts[doc.data()['id']]['userInfo'] = val[0];
            prePosts[doc.data()['id']]['isUserFollowing'] = val[1];
            prePosts[doc.data()['id']]['userHasLiked'] = val[2];
          } else {
            prePosts[doc.data()['id']]['error'] = true;
          }
        });
      }));
      MapsClass.posts = {};
      MapsClass.posts = {...MapsClass.posts, ...prePosts};
      lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    } else {
      MapsClass.posts = {};
      postsAvailable = false;
    }
    gettingMorePosts = false;
    isLoadingNewCat = false;
    setState(() {});
  }

  getMoreForYouPosts() async {
    if (postsAvailable == false) {
      return;
    }
    if (gettingMorePosts == true) {
      return;
    }
    final user = Provider.of<CustomUser>(context, listen: false);
    if (mounted) {
      setState(() => gettingMorePosts = true);
    }
    Query theQuery = FirebaseFirestore.instance.collection('posts')
    .orderBy('time', descending: true)
    .orderBy('likes', descending: true)
    .startAfterDocument(lastDocument).limit(16);
    QuerySnapshot querySnapshot = await theQuery.get();
    if (querySnapshot.docs.length <= 16 || querySnapshot.docs.length == 0) {
      setState(() { 
        postsAvailable = false;
      });
    }
    Map prePosts = {};
    if (querySnapshot.docs.length > 0) {
      await Future.wait(querySnapshot.docs.map((doc) async {
        Map aMap = {};
        aMap[doc.data()['id']] = doc.data();
        aMap[doc.data()['id']]['userInfo'] = {};
        prePosts = {...prePosts, ...aMap};

        await getAllPostThings(doc.data()['postedBy'], doc.data()['id'], user.uid).then((val) {
          if (val != null) {
            prePosts[doc.data()['id']]['userInfo'] = val[0];
            prePosts[doc.data()['id']]['isUserFollowing'] = val[1];
            prePosts[doc.data()['id']]['userHasLiked'] = val[2];
          } else {
            prePosts[doc.data()['id']]['error'] = true;
          }
        });
      }));
      //MapsClass.posts = {};
      MapsClass.posts = {...MapsClass.posts, ...prePosts};
      lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    } else {
      //MapsClass.posts = {};
      postsAvailable = false;
    }
    gettingMorePosts = false;
    isLoadingNewCat = false;
    setState(() {});
  }

  getAllUsersUserFollows() async {
    final user = Provider.of<CustomUser>(context, listen: false);
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users')
      .doc(user.uid).collection('following').get();

    if (querySnapshot.docs.length > 0) {
      await Future.wait(querySnapshot.docs.map((doc) async {
        Map theMap = {};
        theMap[doc.data()['following']] = doc.data();
        MapsClass.followedUsers = {...theMap};
      }));
    }
  }

  getFollowingPosts() async {
    setState(() {
      postsAvailable = true;
      gettingMorePosts = true;
      isLoadingNewCat = true;
    });
    await getAllUsersUserFollows();
    final user = Provider.of<CustomUser>(context, listen: false);
    if (MapsClass.followedUsers.isNotEmpty) {
      Query theQuery = FirebaseFirestore.instance.collection('posts')
      .where('postedBy', whereIn: MapsClass.followedUsers.keys.toList())
      .orderBy('time', descending: true)
      .orderBy('likes', descending: true)
      .limit(16);
      setState(() {});
      QuerySnapshot querySnapshot = await theQuery.get();
      //MapsClass.posts = {};
      Map prePosts = {};
      if (querySnapshot.docs.length > 0) {
        await Future.wait(querySnapshot.docs.map((doc) async {
          Map aMap = {};
          aMap[doc.data()['id']] = doc.data();
          aMap[doc.data()['id']]['userInfo'] = {};
          prePosts = {...prePosts, ...aMap};
          await getAllPostThings(doc.data()['postedBy'], doc.data()['id'], user.uid).then((val) {
            //print(val[1]);
            if (val != null) {
              prePosts[doc.data()['id']]['userInfo'] = val[0];
              prePosts[doc.data()['id']]['isUserFollowing'] = val[1];
              prePosts[doc.data()['id']]['userHasLiked'] = val[2];
            } else {
              prePosts[doc.data()['id']]['error'] = true;
            }
          });
          //await getAllPostThings(doc.data()['postedBy'], doc.data()['id'], user.uid);
        }));
        MapsClass.posts = {};
        MapsClass.posts = {...MapsClass.posts, ...prePosts};
        lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
      } else {
        MapsClass.posts = {};
        postsAvailable = false;
      }
      gettingMorePosts = false;
      isLoadingNewCat = false;
      setState(() {});
    } else {
      MapsClass.posts = {};
      postsAvailable = false;
      gettingMorePosts = false;
      isLoadingNewCat = false;
      setState(() {});
    }
  }

  getMoreFollowingPosts() async {
    if (postsAvailable == false) {
      return;
    }
    if (gettingMorePosts == true) {
      return;
    }
    final user = Provider.of<CustomUser>(context, listen: false);
    if (mounted) {
      setState(() => gettingMorePosts = true);
    }
    if (MapsClass.followedUsers.isNotEmpty) {
      Query theQuery = FirebaseFirestore.instance.collection('posts')
      .where('postedBy', whereIn: MapsClass.followedUsers.keys.toList())
      .orderBy('time', descending: true)
      .orderBy('likes', descending: true)
      .startAfterDocument(lastDocument)
      .limit(16);
      setState(() {});
      QuerySnapshot querySnapshot = await theQuery.get();
      //MapsClass.posts = {};
      if (querySnapshot.docs.length <= 16 || querySnapshot.docs.length == 0) {
        setState(() { 
          postsAvailable = false;
        });
      }
      Map prePosts = {};
      if (querySnapshot.docs.length > 0) {
        await Future.wait(querySnapshot.docs.map((doc) async {
          Map aMap = {};
          aMap[doc.data()['id']] = doc.data();
          aMap[doc.data()['id']]['userInfo'] = {};
          prePosts = {...prePosts, ...aMap};
          await getAllPostThings(doc.data()['postedBy'], doc.data()['id'], user.uid).then((val) {
            //print(val[1]);
            if (val != null) {
              prePosts[doc.data()['id']]['userInfo'] = val[0];
              prePosts[doc.data()['id']]['isUserFollowing'] = val[1];
              prePosts[doc.data()['id']]['userHasLiked'] = val[2];
            } else {
              prePosts[doc.data()['id']]['error'] = true;
            }
          });
          //await getAllPostThings(doc.data()['postedBy'], doc.data()['id'], user.uid);
        }));
        //MapsClass.posts = {};
        MapsClass.posts = {...MapsClass.posts, ...prePosts};
        lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
      } else {
        //MapsClass.posts = {};
        postsAvailable = false;
      }
      gettingMorePosts = false;
      isLoadingNewCat = false;
      setState(() {});
    } else {
      MapsClass.posts = {};
      postsAvailable = false;
      gettingMorePosts = false;
      isLoadingNewCat = false;
      setState(() {});
    }
  }

  getCategoryPosts() async {
    setState(() {
      postsAvailable = true;
      gettingMorePosts = true;
      isLoadingNewCat = true;
    });
    final user = Provider.of<CustomUser>(context, listen: false);
    Query theQuery = FirebaseFirestore.instance.collection('posts')
    .where('prediction', isEqualTo: currentSearch.keys.toList()[0])
    .orderBy('time', descending: true)
    .orderBy('likes', descending: true)
    .limit(16);
    setState(() {});
    QuerySnapshot querySnapshot = await theQuery.get();
    Map prePosts = {};
    if (querySnapshot.docs.length > 0) {
      await Future.wait(querySnapshot.docs.map((doc) async {
        Map aMap = {};
        aMap[doc.data()['id']] = doc.data();
        aMap[doc.data()['id']]['userInfo'] = {};
        //print(aMap);
        prePosts = {...prePosts, ...aMap};
        await getAllPostThings(doc.data()['postedBy'], doc.data()['id'], user.uid).then((val) {
          //print(val[1]);
          if (val != null) {
            prePosts[doc.data()['id']]['userInfo'] = val[0];
            prePosts[doc.data()['id']]['isUserFollowing'] = val[1];
            prePosts[doc.data()['id']]['userHasLiked'] = val[2];
          } else {
            prePosts[doc.data()['id']]['error'] = true;
          }
        });
      }));
      MapsClass.posts = {};
      MapsClass.posts = {...MapsClass.posts, ...prePosts};
      lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    } else {
      MapsClass.posts = {};
      postsAvailable = false;
    }
    gettingMorePosts = false;
    isLoadingNewCat = false;
    setState(() {});
  }
  
  getMoreCategoryPosts() async {
    if (postsAvailable == false) {
      return;
    }
    if (gettingMorePosts == true) {
      return;
    }
    final user = Provider.of<CustomUser>(context, listen: false);
    if (mounted) {
      setState(() => gettingMorePosts = true);
    }
    Query theQuery = FirebaseFirestore.instance.collection('posts')
    .where('prediction', isEqualTo: currentSearch.keys.toList()[0])
    .orderBy('time', descending: true)
    .orderBy('likes', descending: true)
    .startAfterDocument(lastDocument)
    .limit(16);
    QuerySnapshot querySnapshot = await theQuery.get();
    if (querySnapshot.docs.length <= 16 || querySnapshot.docs.length == 0) {
      setState(() { 
        postsAvailable = false;
      });
    }
    Map prePosts = {};
    if (querySnapshot.docs.length > 0) {
      await Future.wait(querySnapshot.docs.map((doc) async {
        Map aMap = {};
        aMap[doc.data()['id']] = doc.data();
        aMap[doc.data()['id']]['userInfo'] = {};
        prePosts = {...prePosts, ...aMap};

        await getAllPostThings(doc.data()['postedBy'], doc.data()['id'], user.uid).then((val) {
          if (val != null) {
            prePosts[doc.data()['id']]['userInfo'] = val[0];
            prePosts[doc.data()['id']]['isUserFollowing'] = val[1];
            prePosts[doc.data()['id']]['userHasLiked'] = val[2];
          } else {
            prePosts[doc.data()['id']]['error'] = true;
          }
        });
      }));
      //MapsClass.posts = {};
      MapsClass.posts = {...MapsClass.posts, ...prePosts};
      lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    } else {
      //MapsClass.posts = {};
      postsAvailable = false;
    }
    gettingMorePosts = false;
    isLoadingNewCat = false;
    setState(() {});
  }

  pullToRefreshFunc() async {
    if (currentSearch.keys.toList()[0] != null && currentSearch.isNotEmpty) {
      setState(() => pullToRefresh = true);
      if (currentSearch.keys.toList()[0] == 'forYou') {
        await getForYouPosts();
      } else if (currentSearch.keys.toList()[0] == 'following') {    
        await getFollowingPosts();
      } else {
        await getCategoryPosts();
      }
      setState(() => pullToRefresh = false);
    }
  }
    

  @override
  void initState() {
    super.initState();
    if (moreVideogamesAvailable == true) {
      if (mounted) {
        getVideogamesFromDB();
      }
    }
    _postFeedScrollController.addListener(() {
      double maxScroll = _postFeedScrollController.position.maxScrollExtent;
      double currentScroll = _postFeedScrollController.position.pixels;
      //print(currentScroll);
      double delta = MediaQuery.of(context).size.height * 0.8;
      if (currentScroll < -20) {
        if (!pullToRefresh) {
          pullToRefreshFunc();
        }
      } else if (maxScroll - currentScroll < delta) {
        if (mounted) {
          if (currentSearch.keys.toList()[0] == 'forYou') {
            getMoreForYouPosts();
          } else if (currentSearch.keys.toList()[0] == 'following') {
            getMoreFollowingPosts();
          } else {
            getMoreCategoryPosts();
          }
        }
      }
    });
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.8;
      if (maxScroll - currentScroll < delta) {
        if (mounted) {
          if (moreVideogamesAvailable == true) {
            getMoreVideogamesFromDB();
          }
        }
      }
    });
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   print('salsa');
  // }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _postFeedScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 1 / 1.05,
      child: Stack(
        children: [
          Container(
            color: Colors.transparent
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 56),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: Container(
                  //margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 56),
                  height: MediaQuery.of(context).size.height - 
                  (MediaQuery.of(context).padding.top + 56),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    )
                  ),
                  child: hasLoaded ? 
                  ListView(
                    padding: EdgeInsets.only(top: 18, bottom: 90),
                    physics: AlwaysScrollableScrollPhysics(),
                    controller: _postFeedScrollController,
                    //padding: EdgeInsets.only(bottom: 34),
                    //cacheExtent: 1000,
                    children: [
                      if (pullToRefresh)
                      //!pullToRefresh ? Container() :
                      AnimatedSize(
                        duration: Duration(milliseconds: 500),
                        vsync: this,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: CupertinoActivityIndicator(
                            radius: 14
                          )
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(top: 2, bottom: 8),
                        height: 115,
                        //color: Colors.red,
                        child: ListView.builder(
                          //shrinkWrap: true,
                          controller: _scrollController,
                          itemCount: theVideogamesMap.length,
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          scrollDirection: Axis.horizontal,
                          physics: AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, i) {
                            if (i == 0) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  //margin: EdgeInsets.only(left: 2),
                                  width: 80.08,
                                  height: 110,
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          currentSearch = {};
                                          currentSearch['forYou'] = 'forYou';
                                          getForYouPosts();
                                        });
                                      },
                                      child: Container(
                                        width: 72.8,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.grey[350],
                                        ),
                                        child: Center(
                                          child: Text(
                                            'For You',
                                            style: TextStyle(
                                              color: Colors.grey[800],
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600
                                            )
                                          )
                                        )
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else if (i == 1) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  //margin: EdgeInsets.only(left: 2),
                                  width: 80.08,
                                  height: 110,
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          currentSearch = {};
                                          currentSearch['following'] = 'following';
                                          getFollowingPosts();
                                        });
                                      },
                                      child: Container(
                                        width: 72.8,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.grey[350],
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Following',
                                            style: TextStyle(
                                              color: Colors.grey[800],
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500
                                            )
                                          )
                                        )
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else if (i == theVideogamesMap.length - 2 || i == theVideogamesMap.length - 1) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  //margin: EdgeInsets.only(left: 2),
                                  width: 80.08,
                                  height: 110,
                                  child: Center(
                                    child: GestureDetector(
                                      /*onTap: () {
                                        setState(() {
                                          currentSearch = [];
                                          currentSearch.add('wfnt');
                                          getCategoryPosts();
                                        });
                                      },*/
                                      child: Container(
                                        width: 72.8,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.grey[350],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  //margin: EdgeInsets.only(left: 2),
                                  width: 80.08,
                                  height: 110,
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          currentSearch = {};
                                          currentSearch[theVideogamesMap.values.toList()[i]['videogame']] 
                                          = '${theVideogamesMap.values.toList()[i]['id']}';
                                          //.add(theVideogamesMap.values.toList()[i]['id']);
                                          getCategoryPosts();
                                        });
                                      },
                                      child: Container(
                                        width: 72.8,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          //border: Border.all(color: Colors.deepPurpleAccent, width: 4),
                                          image: DecorationImage(
                                            image: AssetImage(
                                              videogameImages[theVideogamesMap.values.toList()[i]['videogame']]
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      if (isLoadingNewCat == true && pullToRefresh != true) 
                      AnimatedSize(
                        duration: Duration(milliseconds: 500),
                        vsync: this,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: CupertinoActivityIndicator(
                            radius: 14
                          )
                        ),
                      ),
                      if (MapsClass.posts.length == 0 && !isLoadingNewCat)
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            'no posts yet',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                              fontWeight: FontWeight.w600
                            )
                          ),
                        )
                      ),
                      ...MapsClass.posts.values.toList().asMap().entries.map((post) {
                        //if (post['loadedImg'] != null || post['userInfo']['loadedImg'] != null) {
                          int idx = post.key;
                          Map val = post.value;
                          if (idx.isOdd) {
                            return PostMain3(
                              postData: val,
                              getLikeState: getLikedState,
                              getFollowingState: getFollowingState,
                              theCategory: currentSearch.values.toList()[0],
                              key: Key('${val['id']}'),
                              myInfo: widget.userInfo,
                            );
                          } else if (idx.isEven) {
                            return PostMain2(
                              postData: val,
                              getLikeState: getLikedState,
                              getFollowingState: getFollowingState,
                              theCategory: currentSearch.values.toList()[0],
                              key: Key('${val['id']}'),
                              myInfo: widget.userInfo,
                              postId: val['id'],
                            );
                          }
                        // } else {
                        //   return Container();
                        // }
                      }).toList(),
                      if (gettingMorePosts == true && !isLoadingNewCat) 
                        //Container(
                          AnimatedSize(
                            duration: Duration(milliseconds: 500),
                            vsync: this,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: CupertinoActivityIndicator(
                                radius: 14
                              )
                            ),
                          ),
                        //)

                      //: Container(child: Text('no posts'))
                    ],
                  ) : Container()
                )
              ),
            ),
          ),
        ],
      )
    );
  }

  @override
  bool get wantKeepAlive => true;
}
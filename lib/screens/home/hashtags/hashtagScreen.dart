import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:untitled_startup/models/user.dart';
import 'package:untitled_startup/screens/home/main/classes/mapsClass.dart';
import 'package:untitled_startup/screens/home/userProfile/profileGrid.dart';
import 'package:untitled_startup/services/database.dart';

class HashtagScreen extends StatefulWidget {
  final Map hashtagInfo;
  final Map myInfo;
  HashtagScreen({ this.hashtagInfo, this.myInfo});
  @override
  _HashtagScreenState createState() => _HashtagScreenState();
}

class _HashtagScreenState extends State<HashtagScreen> {
  ScrollController _scrollController = ScrollController();
  bool postsAvailable = true;
  bool gettingMorePosts = false;
  DocumentSnapshot lastDocument;


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
        userInfo = val.data();
      });
    });
    return userInfo;
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
  

  getHashtagPosts() async {
    setState(() {
      postsAvailable = true;
      gettingMorePosts = true;
    });
    final user = Provider.of<CustomUser>(context, listen: false);
    Query theQuery = FirebaseFirestore.instance.collection('posts')
    .where('hashtags', arrayContains: widget.hashtagInfo['hashtag'])
    .orderBy('time', descending: true).limit(16);
    setState(() {});
    QuerySnapshot querySnapshot = await theQuery.get();
    print('length is ${querySnapshot.docs.length}');
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
      }));
      //MapsClass.hashtagPosts[''] = {};
      MapsClass.hashtagPosts[widget.hashtagInfo['hashtag']] 
        = {...MapsClass.hashtagPosts[widget.hashtagInfo['hashtag']] , ...prePosts};
      lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    } else {
      //MapsClass.hashtagPosts = {};
      postsAvailable = false;
    }
    gettingMorePosts = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getHashtagPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            //color: Colors.red,
            //margin: EdgeInsets.only(left: widget.statusBar / 2),
            child: Icon(
              Icons.keyboard_arrow_left_rounded,
              color: Colors.grey[800],
              size: 42
            ),
          )
        ),
        titleSpacing: 0.0,
        title: Container(
          child: Text(
            widget.hashtagInfo['hashtag'],
            style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.w800,
              fontSize: 22
            )
          )
        ),
        backgroundColor: Colors.grey[50],
        elevation: 0.0,
      ),
      body: Container(
        //color: Colors.red,
        child: ListView(
          children: [
            Container(
              //color: Colors.yellow,
              margin: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 88,
                      width: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[50],
                        border: Border.all(color: Colors.grey[900], width: 4)
                        //borderRadius: BorderRadius.circular
                      ),
                      child: Center(
                        child: Text(
                          '#',
                          style: TextStyle(
                            fontSize: 45,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[900]
                          )
                        )
                      )
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 6),
                    child: Text(
                      widget.hashtagInfo['hashtag'],
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      )
                    )
                  )
                ],
              )
            ),
            ...MapsClass.hashtagPosts[widget.hashtagInfo['hashtag']].values.toList().map((post) {
              return StaggeredGridView.count(
                padding: EdgeInsets.only(top: 8, left: 6, right: 6),
                crossAxisCount: 4,
                mainAxisSpacing: 6.0,
                primary: false,
                shrinkWrap: true,
                crossAxisSpacing: 6.0,
                children: List.generate(MapsClass.hashtagPosts[widget.hashtagInfo['hashtag']].length, (index) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: MapsClass.hashtagPosts[widget.hashtagInfo['hashtag']]['postImg']
                      )
                    )
                  );
                }),
                staggeredTiles: List.generate(MapsClass.hashtagPosts[widget.hashtagInfo['hashtag']].length, (index) {
                  return StaggeredTile.fit(2);
                }),
              );
            })
          ],
        )
      )
    );
  }
}
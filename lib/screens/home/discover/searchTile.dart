import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled_startup/models/user.dart';
import 'package:untitled_startup/screens/home/hashtags/hashtagScreen.dart';
import 'package:untitled_startup/screens/home/main/classes/mapsClass.dart';
import 'package:untitled_startup/screens/home/userProfile/profiles.dart';
import 'package:untitled_startup/services/cacheClass/cacheManager.dart';
import 'package:untitled_startup/services/database.dart';

class SearchTile extends StatefulWidget {
  final List searchItems;
  final int index;
  final bool hasLoaded;
  final bool isFollowing;
  final Function refresh;
  final Map<String, dynamic> myInfo;
  final bool isHashtag;
  SearchTile({this.index, this.searchItems, this.isFollowing, this.hasLoaded,
  this.refresh, this.myInfo, this.isHashtag});
  @override
  _SearchTileState createState() => _SearchTileState();
}

class _SearchTileState extends State<SearchTile> {
  //bool isFollowing;

  getFollowingState(userUid) async {
    await DatabaseService(
      uid: userUid
    ).isFollowingUser(widget.searchItems[widget.index]['uid'])
    .then((value) {
      if (mounted) {
        setState(() {
          MapsClass.searchedUsers[widget.searchItems[widget.index]['uid']]['isUserFollowing'] = value;
        });
      }
    });
    return MapsClass.searchedUsers[widget.searchItems[widget.index]['uid']]['isUserFollowing'];
    //widget.refresh();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    return GestureDetector(
      onTap: () {
        if (MapsClass.searchedUsers[widget.searchItems[widget.index]['uid']] != null) {
          Navigator.push(
            context, 
            CupertinoPageRoute(
              builder: (context) => Profiles(
                currentIndex: widget.index,
                userInfo: MapsClass.searchedUsers.values.toList()[widget.index],
                maxHeight: MediaQuery.of(context).size.height,
                isFollowing: MapsClass.searchedUsers[widget.searchItems[widget.index]['uid']]['isUserFollowing'],
                //getFollowingState: getFollowingState,
                myInfo: widget.myInfo,
              )
            )
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        color: Colors.grey[50],
        //Colors.grey
        child: Row(
          children: [
            Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                //borderRadius: BorderRadius.circular(62),
                shape: BoxShape.circle,
                color: Colors.grey[350],
                // image: DecorationImage(
                //   image: NetworkImage(
                //     widget.searchItems[widget.index]['profileImg']
                //   ),
                //   fit: BoxFit.cover
                // )
              ),
              child: CachedNetworkImage(
                fadeInDuration: Duration(milliseconds: 50),
                fadeOutDuration: Duration(milliseconds: 50),
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[350],
                    shape: BoxShape.circle,
                  )
                ),
                imageUrl: widget.searchItems[widget.index]['profileImg'],
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
                      )
                    );
                  }
              )
            ),
            Container(
              margin: EdgeInsets.only(left: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      widget.searchItems[widget.index]['name'],
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 17,
                        fontWeight: FontWeight.w700
                      )
                    )
                  ),
                  Container(
                    child: Text(
                      widget.searchItems[widget.index]['username'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 15,
                        fontWeight: FontWeight.w500
                      )
                    )
                  )
                ],
              )
            ),
            const Spacer(),
            widget.searchItems[widget.index]['uid'] == user.uid 
            ? Container()
            : widget.hasLoaded 
            ? GestureDetector(
              onTap: () async {
                if (MapsClass.searchedUsers[widget.searchItems[widget.index]['uid']] != null) {
                  if (MapsClass.searchedUsers[widget.searchItems[widget.index]['uid']]['isUserFollowing'] == false) {
                    MapsClass.searchedUsers[widget.searchItems[widget.index]['uid']]['isUserFollowing'] = true;
                    if (MapsClass.userPosts[widget.searchItems[widget.index]['uid']] != null) {
                      MapsClass.userPosts[widget.searchItems[widget.index]['uid']]['isUserFollowing'] = true;
                    }
                    if (MapsClass.users[widget.searchItems[widget.index]['uid']] != null) {
                      MapsClass.users[widget.searchItems[widget.index]['uid']]['isUserFollowing'] = true;
                    }
                    //follow user
                    Map<String, dynamic> followerMap = {
                      'follower': user.uid,
                    };
                    Map<String, dynamic> followingMap = {
                      'following': widget.searchItems[widget.index]['uid'],
                    };

                    await DatabaseService().batchedFollow(
                      followerMap, user.uid, followingMap, 
                      widget.searchItems[widget.index]['uid'],
                      {'followersCount': FieldValue.increment(1)}, 
                      {'followingCount': FieldValue.increment(1)},
                      user.uid,
                      widget.searchItems[widget.index]['uid']
                    );
                    getFollowingState(user.uid).then((val) {
                      MapsClass.searchedUsers[widget.searchItems[widget.index]['uid']]['isUserFollowing'] = val;
                      if (MapsClass.posts.isNotEmpty || MapsClass.posts != null) {
                        var postsQuery = MapsClass.posts.values.toList().where((val) => val['postedBy'] == widget.searchItems[widget.index]['uid']).toList();
                        //var postUsersQuery = MapsClass.userPosts.keys.toList().where((key) => key == widget.postdata['postedBy']).toList();
                        //print(postsQuery);
                        if (postsQuery.isNotEmpty || postsQuery != null) {
                          Future.wait(postsQuery.map((post) async {
                            MapsClass.posts[post['id']]['isUserFollowing'] = val;
                          }));
                        }
                      }
                      if (MapsClass.userPosts[widget.searchItems[widget.index]['uid']] != null) {
                        MapsClass.userPosts[widget.searchItems[widget.index]['uid']]['isUserFollowing'] = val;
                      }
                      if (MapsClass.users[widget.searchItems[widget.index]['uid']] != null) {
                        MapsClass.users[widget.searchItems[widget.index]['uid']]['isUserFollowing'] = val;
                      }
                    });

                  } else if (MapsClass.searchedUsers[widget.searchItems[widget.index]['uid']]['isUserFollowing'] == true) {
                    MapsClass.searchedUsers[widget.searchItems[widget.index]['uid']]['isUserFollowing'] = false;
                    if (MapsClass.userPosts[widget.searchItems[widget.index]['uid']] != null) {
                      MapsClass.userPosts[widget.searchItems[widget.index]['uid']]['isUserFollowing'] = false;
                    }
                    if (MapsClass.users[widget.searchItems[widget.index]['uid']] != null) {
                      MapsClass.users[widget.searchItems[widget.index]['uid']]['isUserFollowing'] = false;
                    }
                    //unfollow user
                    await DatabaseService().batchedUnfollow(
                      user.uid, widget.searchItems[widget.index]['uid'],
                      {'followersCount': FieldValue.increment(-1)}, 
                      {'followingCount': FieldValue.increment(-1)},
                      user.uid,
                      widget.searchItems[widget.index]['uid']
                    );

                    getFollowingState(user.uid).then((val) {
                      MapsClass.searchedUsers[widget.searchItems[widget.index]['uid']]['isUserFollowing'] = val;
                      if (MapsClass.posts.isNotEmpty || MapsClass.posts != null) {
                        var postsQuery = MapsClass.posts.values.toList().where((val) => val['postedBy'] == widget.searchItems[widget.index]['uid']).toList();
                        //var postUsersQuery = MapsClass.userPosts.keys.toList().where((key) => key == widget.postdata['postedBy']).toList();
                        //print(postsQuery);
                        if (postsQuery.isNotEmpty || postsQuery != null) {
                          Future.wait(postsQuery.map((post) async {
                            MapsClass.posts[post['id']]['isUserFollowing'] = val;
                          }));
                        }
                      }
                      if (MapsClass.userPosts[widget.searchItems[widget.index]['uid']] != null) {
                        MapsClass.userPosts[widget.searchItems[widget.index]['uid']]['isUserFollowing'] = val;
                      }
                      if (MapsClass.users[widget.searchItems[widget.index]['uid']] != null) {
                        MapsClass.users[widget.searchItems[widget.index]['uid']]['isUserFollowing'] = val;
                      }
                    });
                  }
                }
              },
              child: MapsClass.searchedUsers[widget.searchItems[widget.index]['uid']]['isUserFollowing'] == true ?
                Container(
                  height: 32,
                  width: 105,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[700], width: 1.5)
                  ),
                  child: Center(
                    child: Text(
                      'Following',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 16,
                        fontWeight: FontWeight.w700
                      )
                    ),
                  )
                ) : Container(
                  height: 32,
                  width: 105,
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Center(
                    child: Text(
                      'Follow',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700
                      )
                    ),
                  )
                ),
            ) : Container(
              height: 32,
              width: 105,
              decoration: BoxDecoration(
                color: Colors.grey[350],
                borderRadius: BorderRadius.circular(12)
              ),
            )
          ],
        )
      ),
    );
  }
}
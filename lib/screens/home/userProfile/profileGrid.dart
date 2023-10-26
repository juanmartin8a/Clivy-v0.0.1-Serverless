//import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:untitled_startup/screens/home/userProfile/profileGridTile.dart';
//import 'package:untitled_startup/screens/home/main/postData.dart';
//import 'package:untitled_startup/screens/home/userProfile/profilePostList.dart';

class ProfileGrid extends StatefulWidget {
  final Map<dynamic, dynamic> profilePosts;
  final Map<String, dynamic> profileUserInfo;
  final Map<String, dynamic> myInfo;
  final Function getLikeState;
  final Function getFollowingState;
  final Function scrollTo;
  final bool comesFromProfiles;
  final bool morePostsAvailable;
  final bool hasLoaded;
  //final List<GlobalKey> theGlobalKeys;
  ProfileGrid({this.profilePosts, this.profileUserInfo, this.scrollTo,
  this.comesFromProfiles, this.morePostsAvailable, this.hasLoaded, this.myInfo,
  this.getLikeState, this.getFollowingState});
  @override
  _ProfileGridState createState() => _ProfileGridState();
}

class _ProfileGridState extends State<ProfileGrid> with AutomaticKeepAliveClientMixin {
  AutoScrollController _scrollController;
  ValueNotifier<int> theTappedIndex = ValueNotifier<int>(0);
  bool started = false;

  Map positionMap = {};

  int selectedIndex;
  bool pushed = false;

  final isPushed = ValueNotifier<bool>(false);

  int theIdx = 0;

  void scrollToIndex(index) {
    _scrollController.scrollToIndex(index, 
    preferPosition: AutoScrollPosition.begin, duration: Duration(milliseconds: 600), );
  }

  void refresh(index) {
    setState(() {
      selectedIndex = index;
      theIdx = index;
    });
  }

  void refreshState() {
    setState(() {
      
    });
  }

  void changePushedBool(trueOrFalse) {
    //setState(() {
      //pushed = trueOrFalse;
      WidgetsBinding.instance.addPostFrameCallback((_){
        isPushed.value = trueOrFalse;
      });
      //print(pushed);
    //});
  }

  Widget noPostsYet = GestureDetector(
    child: Container(
      margin: EdgeInsets.only(top: 12),
      height: 35,
      width: 130,
      decoration: BoxDecoration(
        color: Colors.tealAccent[400],
        borderRadius: BorderRadius.circular(40)
      ),
      child: Center(
        child: Text(
          'Add a Post',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 16,
            fontWeight: FontWeight.w700
          )
        ),
      )
    ),
  );
 
  @override
  void initState() {
    super.initState();
    _scrollController = AutoScrollController(axis: Axis.vertical);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: /*CustomScrollView(
        slivers: [*/
        widget.hasLoaded ?
          widget.profilePosts != null ?
            widget.profilePosts.isNotEmpty ?
            ValueListenableBuilder(
              valueListenable: isPushed, 
              builder: (context, value, _) {
                return StaggeredGridView.count(
                  padding: EdgeInsets.only(top: 8, left: 6, right: 6),
                  crossAxisCount: 4,
                  mainAxisSpacing: 6.0,
                  primary: false,
                  shrinkWrap: true,
                  crossAxisSpacing: 6.0,
                  children: List.generate(widget.profilePosts.length, (index) {
                    //print(value);
                    //print(index);
                    return Builder(
                      builder: (context) {
                        final renderObject = context.findRenderObject() as RenderBox;
                        final offsetY = renderObject?.localToGlobal(Offset.zero)?.dy ?? 0;
                        double statusBar = MediaQuery.of(context).padding.top;
                        double theRealOffsetY = offsetY - (statusBar + 56 + 50);
                        //print('$index: $theRealOffsetY');
                        if (theRealOffsetY > 0) {
                          if (!positionMap.containsKey(index)) {
                            positionMap[index] = theRealOffsetY;
                          }
                        }
                        //print(index);
                        //print(positionMap);
                        return ProfileGridTile(
                          scrollController: _scrollController,
                          theTappedIndex: theTappedIndex,
                          theOtherIdx: theIdx,
                          index: index,
                          refresh: refresh,
                          theProfilePosts: widget.profilePosts,
                          scrollTo: widget.scrollTo,
                          profileUserInfo: widget.profileUserInfo,
                          positionMap: positionMap,
                          scrollToIndex: scrollToIndex,
                          theProfilePost: widget.profilePosts.values.toList()[index],
                          comesFromProfiles: true,//widget.comesFromProfiles == true ? true : false,
                          selectedIndex: selectedIndex,
                          pushed: value,
                          changeBool: changePushedBool,
                          myInfo: widget.myInfo,
                          getFollowingState: widget.getFollowingState,
                          getLikeState: widget.getLikeState,
                          refreshState: refreshState,
                          key: Key(widget.profilePosts.values.toList()[index]['id']),
                        );
                      }
                    );
                  }),
                  staggeredTiles: List.generate(widget.profilePosts.length, (index) {
                    return StaggeredTile.fit(2);
                  }),
                );
              }
            ) : Container(
              //color: Colors.red,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 70),
                  child: Column(
                    children: [
                      Text(
                        'No posts yet...',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15,
                          fontWeight: FontWeight.w600
                        )
                      ),
                      // widget.comesFromProfiles 
                      // ? Container()
                      // : noPostsYet
                    ],
                  )
                )
              ),
          ) : Container(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: EdgeInsets.only(top: 70),
                child: Column(
                  children: [
                    Text(
                      'No posts yet...',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 15,
                        fontWeight: FontWeight.w600
                      )
                    ),
                    // widget.comesFromProfiles 
                    // ? Container()
                    // : noPostsYet
                  ],
                )
              )
            ),
          )
        : Container()
        //]
      //)
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

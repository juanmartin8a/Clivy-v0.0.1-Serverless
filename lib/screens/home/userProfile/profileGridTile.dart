import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:untitled_startup/screens/home/userProfile/profilePostList.dart';
import 'package:flutter/material.dart';
import 'package:untitled_startup/services/cacheClass/cacheManager.dart';

class ProfileGridTile extends StatefulWidget {
  final Function scrollToIndex;
  final ValueNotifier<int> theTappedIndex;
  final ValueNotifier<bool> isPushed;
  final int theOtherIdx;
  final int index;
  final Function refresh;
  final Map<dynamic, dynamic> theProfilePosts;
  final Function scrollTo;
  final Map<String, dynamic> profileUserInfo;
  final Map<String, dynamic> myInfo;
  final Function getLikeState;
  final Function getFollowingState;
  final Map positionMap;
  final AutoScrollController scrollController;
  final Map<String, dynamic> theProfilePost;
  final bool comesFromProfiles;
  final int selectedIndex;
  final bool pushed;
  final Function changeBool;
  final Function refreshState;
  ProfileGridTile({this.theTappedIndex, this.index, this.refresh, this.scrollTo,
  this.scrollToIndex, this.theProfilePost, this.profileUserInfo, this.positionMap,
  this.scrollController, this.theProfilePosts, this.comesFromProfiles, 
  this.selectedIndex, this.pushed, this.changeBool, this.myInfo, this.getFollowingState,
  this.getLikeState, this.theOtherIdx, this.isPushed, this.refreshState, Key key}) : super(key: key);
  @override
  _ProfileGridTileState createState() => _ProfileGridTileState();
}

class _ProfileGridTileState extends State<ProfileGridTile> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (sapo) {
        widget.scrollToIndex(widget.index);
      },
      onTapUp: (toro) {
        widget.theTappedIndex.value = widget.index;
        widget.refresh(widget.index);
        //setState(() {
          //selectedIndex = widget.index;
        //});
        Timer(
          Duration(milliseconds: 200),
          () {
            Navigator.push(
              context,
              PageRouteBuilder(
                fullscreenDialog: true,
                barrierColor: Colors.black38,
                opaque: false,
                reverseTransitionDuration: Duration(milliseconds: 180),
                transitionDuration: Duration(milliseconds: 550),
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
                pageBuilder: (context, anim1, anim2) => ProfilePostList(
                  profilePosts: widget.theProfilePosts,
                  index: widget.index,
                  profileUserInfo: widget.profileUserInfo,
                  scrollController: widget.scrollController,
                  maxHeight: MediaQuery.of(context).size.height,
                  maxWidth: MediaQuery.of(context).size.width,
                  scrollToIndex: widget.scrollToIndex,
                  scrollTo: widget.scrollTo,
                  positionMap: widget.positionMap,
                  refresh: widget.refresh,
                  comesFromProfiles: widget.comesFromProfiles == true ? true : false,
                  myInfo: widget.myInfo,
                  getFollowingState: widget.getFollowingState,
                  getLikeState: widget.getLikeState,
                  refreshState: widget.refreshState
                )
              )
            );//.whenComplete(() {
              //widget.scrollTo(positionMap[index]);
            //});
          }
        ); 
        Timer(
          Duration(milliseconds: 570),
          () {
            widget.scrollTo(widget.positionMap[widget.index]);
          }
        );
        //}
      },
      child: AspectRatio(
        //key: theGlobalKeys[index],
        aspectRatio: widget.theProfilePost['postDims'][0] / widget.theProfilePost['postDims'][1],
        child: Builder(
          builder: (BuildContext context) {
            return widget.pushed == true ?
              widget.selectedIndex != widget.index ? 
              Hero(
                transitionOnUserGestures: true,
                tag: 
                // widget.comesFromProfiles == true ?
                // 'profiles_${widget.theProfilePost['id']}' :
                'profile_${widget.theProfilePost['id']}',
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[350],
                    borderRadius: BorderRadius.circular(12),
                    // image: DecorationImage(
                    //   image: NetworkImage(
                    //     widget.theProfilePost['postImg']
                    //   ),
                    //   fit: BoxFit.cover,
                    // ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      fadeInDuration: Duration(milliseconds: 10),
                      fadeOutDuration: Duration(milliseconds: 10),
                      placeholder: (context, url) => Container(color: Colors.grey[350]),
                      imageUrl: widget.theProfilePost['postImg'],
                      fit: BoxFit.cover,
                      cacheManager: CustomCacheManager.instance,
                    )
                  )
                ),
                flightShuttleBuilder:
                (flightContext, animation, direction, fromcontext, toContext) {
                  widget.changeBool(direction == HeroFlightDirection.push);
                  final Hero toHero = toContext.widget;
                  return direction == HeroFlightDirection.push
                    ? ScaleTransition(
                      scale: animation.drive(
                        Tween<double>(
                          begin: 1.00,
                          end: 1.00,
                        ).chain(
                          CurveTween(
                            curve: Curves.decelerate),
                        ),
                      ),
                      child: toHero.child,
                    )
                    : SizeTransition(
                      sizeFactor: animation,
                      child: toHero.child,
                    );
                },
                placeholderBuilder: (context, size, widgetPlaceholder) {
                  final Hero toHero = context.widget;
                  if (widget.selectedIndex == widget.index) {
                    return Container(
                      height: size.height,
                      width: size.width,
                      //color: Colors.red,
                      //child: toHero.child
                    );
                  } else {
                    return Container(
                      height: size.height,
                      width: size.width,
                      //color: Colors.blue,
                      child: toHero.child
                    );
                  }
                },
              ) : Opacity(
                opacity: widget.pushed == true ? 0 : 1,
                child: Hero(
                  transitionOnUserGestures: true,
                  tag: 'profile_${widget.theProfilePost['id']}',
                  child: Container(
                    decoration: BoxDecoration(
                      //color: Colors.grey[350],
                      borderRadius: BorderRadius.circular(12),
                      // image: DecorationImage(
                      //   image: NetworkImage(
                      //     widget.theProfilePost['postImg']
                      //   ),
                      //   fit: BoxFit.cover,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        fadeInDuration: Duration(milliseconds: 10),
                        fadeOutDuration: Duration(milliseconds: 10),
                        placeholder: (context, url) => Container(color: Colors.grey[350]),
                        imageUrl: widget.theProfilePost['postImg'],
                        fit: BoxFit.cover,
                        cacheManager: CustomCacheManager.instance,
                      ),
                    )
                  ),
                  flightShuttleBuilder:
                  (flightContext, animation, direction, fromcontext, toContext) {
                    widget.changeBool(direction == HeroFlightDirection.push);
                    final Hero toHero = toContext.widget;
                    return direction == HeroFlightDirection.push
                      ? ScaleTransition(
                        scale: animation.drive(
                          Tween<double>(
                            begin: 1.00,
                            end: 1.00,
                          ).chain(
                            CurveTween(
                              curve: Curves.decelerate),
                          ),
                        ),
                        child: toHero.child,
                      )
                      : SizeTransition(
                        sizeFactor: animation,
                        child: toHero.child,
                      );
                  },
                  placeholderBuilder: (context, size, widgetPlaceholder) {
                    final Hero toHero = context.widget;
                    //print('2 -- idx: ${widget.index}; tag: $toHero');
                    //print(2);
                    // if (widget.selectedIndex == widget.index) {
                    //   return Container(
                    //     height: size.height,
                    //     width: size.width,
                    //     //color: Colors.green,
                    //     child: toHero.child
                    //   );
                    // } else {
                    //   return Container(
                    //     height: size.height,
                    //     width: size.width,
                    //     //olor: Colors.red,
                    //     //child: toHero.child
                    //   );
                    // }
                    return Container(
                      height: size.height,
                      width: size.width,
                      color: Colors.transparent,
                      child: toHero.child
                    );
                  },
                ),
              ) : Hero(
                transitionOnUserGestures: true,
                tag: 'profile_${widget.theProfilePost['id']}',
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[350],
                    borderRadius: BorderRadius.circular(12),
                    // image: DecorationImage(
                    //   image: NetworkImage(
                    //     widget.theProfilePost['postImg']
                    //   ),
                    //   fit: BoxFit.cover,
                    // ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      fadeInDuration: Duration(milliseconds: 10),
                      fadeOutDuration: Duration(milliseconds: 10),
                      placeholder: (context, url) => Container(color: Colors.grey[350]),
                      imageUrl: widget.theProfilePost['postImg'],
                      fit: BoxFit.cover,
                      cacheManager: CustomCacheManager.instance,
                    ),
                  )
                ),
                flightShuttleBuilder: (flightContext, animation, direction, fromcontext, toContext) {
                  widget.changeBool(direction == HeroFlightDirection.push);
                  final Hero toHero = toContext.widget;
                  return direction == HeroFlightDirection.push
                    ? ScaleTransition(
                      scale: animation.drive(
                        Tween<double>(
                          begin: 1.00,
                          end: 1.00,
                        ).chain(
                          CurveTween(
                            curve: Curves.decelerate),
                        ),
                      ),
                      child: toHero.child,
                    )
                    : SizeTransition(
                      sizeFactor: animation,
                      child: toHero.child,
                    );
                },
                // placeholderBuilder: (context, size, widgetPlaceholder) {
                //   final Hero toHero = context.widget;
                //   print('3 -- idx: ${widget.index}; tag: $toHero');
                //   //print(3);
                //   return Container(
                //     height: size.height,
                //     width: size.width,
                //     color: Colors.yellow,
                //     //child: toHero.child
                //   );
                // },
              );
          },
          //valueListenable: widget.theTappedIndex,
        )
      ),
    );
  }
}
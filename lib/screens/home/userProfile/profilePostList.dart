import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:untitled_startup/screens/home/main/classes/mapsClass.dart';
import 'package:untitled_startup/screens/home/main2/postMain2.dart';
import 'package:visibility_detector/visibility_detector.dart';
//import 'package:indexed_list_view/indexed_list_view.dart';

class ProfilePostList extends StatefulWidget {
  final Map<dynamic, dynamic> profilePosts;
  final int index;
  final Map<String, dynamic> profileUserInfo;
  final Map<String, dynamic> myInfo;
  final AutoScrollController scrollController;
  final Function getLikeState;
  final Function getFollowingState;
  final double maxHeight;
  final double maxWidth;
  final Function scrollToIndex;
  final Function scrollTo;
  final Map positionMap;
  final Function refresh;
  final bool comesFromProfiles;
  final Function refreshState;
  ProfilePostList({this.profilePosts, this.profileUserInfo, this.index, 
  this.maxHeight, this.maxWidth, this.scrollController, this.scrollToIndex, 
  this.scrollTo, this.positionMap, this.refresh, this.comesFromProfiles, this.myInfo,
  this.getFollowingState, this.getLikeState, this.refreshState});
  @override
  _ProfilePostListState createState() => _ProfilePostListState();
}

class _ProfilePostListState extends State<ProfilePostList> with TickerProviderStateMixin {
  AnimationController _closeControllerScale;
  Animation _closeAnimationScale;
  final theKey = GlobalKey();

  double _initPointVertical;
  double _initPointHoriz;
  double _theRealInitPointVertical;
  double _theRealInitPointHoriz;
  // Calculate vertical distance.
  double _verticalDistance;

  double _borderRadius = 30;

  bool _canPop = false;
  int _visibleIndex;
  //bool _opactity;

  bool startAnim = false;

  Map theMapForVisiblePosts = {};

  @override
  void initState() {
    //widget.scrollToIndex(widget.index);
    _visibleIndex = widget.index;
    super.initState();
    //_isTop = true;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Scrollable.ensureVisible(theKey.currentContext);
      //setState(() {});
    });
    _closeControllerScale =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _closeAnimationScale = Tween<double>(begin: 1.0, end: 0.65)
    .animate(_closeControllerScale)
    ..addListener(() {
      setState(() {});
    });

    /*_positionTopController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _positionTopAnim = Tween<double>(begin: 0.0, end: widget.maxHeight)
    .animate(_positionTopController)
    ..addListener(() {
      setState(() {});
    });*/

    super.initState();
  }

  @override
  void dispose() {
    _closeControllerScale.dispose();
    //_positionTopController.dispose();
    super.dispose();
  }

  double _horizontalDistance = 0;
  bool pointerUp = false;
  //bool pointerUpTop = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedPositioned(
          top: _verticalDistance,//_positionTopAnim.value,
          left: _horizontalDistance,
          //right: 0.0,
          duration: pointerUp ? Duration(milliseconds: 120) : Duration(milliseconds: 10),
          child: Transform.scale(
            scale: _closeAnimationScale.value,
            child: Container(
              height: MediaQuery.of(context).size.height,//* (0.5 + _closeAnimationHeight.value),
              width: MediaQuery.of(context).size.width,// * (0.7 + _closeAnimationWidth.value),
              child: Listener(
                onPointerDown: (opm) {
                  _initPointVertical = opm.position.dy;
                  _initPointHoriz = opm.position.dx;
                  _theRealInitPointVertical = opm.position.dy;
                  _theRealInitPointHoriz = opm.position.dx;
                },
                onPointerUp: (opm) {
                  //setState(() {});
                  startAnim = false;
                  if (_canPop != true) {
                    _closeControllerScale.reverse();
                    pointerUp = true;
                    _horizontalDistance = 0.0;
                    _verticalDistance = 0.0;
                    //_positionTopController.reverse();
                    Timer(
                      Duration(milliseconds: 120),
                      () {
                        setState(() {
                          pointerUp = false;
                        });
                      }
                    );
                  } else if (_canPop == true) {
                    //_closeControllerScale.fling(velocity: 1).then((_) {
                      //_heightController.reverse();
                      Navigator.of(context).pop();
                    //});
                  }
                },
                onPointerMove: (opm) {
                  if (widget.scrollController.offset <= 0) {
                    if (opm.delta.dx > 0 && opm.delta.dy > 0) {
                      startAnim = true;
                    }
                  } else if (widget.scrollController.offset > 0) {
                    //print(_initPointHoriz);
                    if ((- _initPointHoriz + opm.position.dx) >= 25
                      && (- _initPointVertical + opm.position.dy) < 12
                      && (- _initPointVertical + opm.position.dy) > 0 
                    ) {
                      if (startAnim == false) {
                        _theRealInitPointVertical = opm.position.dy;
                        _theRealInitPointHoriz = opm.position.dx;
                        _horizontalDistance = 0;//= opm.position.dx;
                        _verticalDistance = 0; //= opm.position.dy;
                      }
                      startAnim = true;
                    }
                  }
                  if (startAnim == true) {
                    _verticalDistance = -_theRealInitPointVertical + opm.position.dy;
                    _horizontalDistance =  - _theRealInitPointHoriz + opm.position.dx;
                    if (_verticalDistance < 0) {
                      _verticalDistance = 0;
                    }
                    if (_verticalDistance >= 0) {
                      // scroll up
                      //if (widget.scrollController.offset <= 0) {
                        double scrollPorcentageBorderRadius =
                          ((_verticalDistance - 0.0) * 1) / (widget.maxHeight * 0.35 - 0.0);
                        double scrollPorcentage =
                          ((_verticalDistance - 0.0) * 1) / (widget.maxHeight - 0.0);
                        if (scrollPorcentage > 0.15) {
                          _canPop = true;
                        } else {
                          _canPop = false;
                        }
                        //print(scrollPorcentage);
                        setState(() {
                          _borderRadius = 30 * (scrollPorcentageBorderRadius);
                        });
                        _closeControllerScale.animateTo(scrollPorcentage,
                          duration: Duration(milliseconds: 0),
                          curve: Curves.linear
                        );
                        /*_positionTopController.animateTo(_scaleValueVertical,
                          duration: Duration(milliseconds: 0),
                          curve: Curves.linear
                        );*/
                        //print(_positionLeftAnim.value);
                      //}
                    }
                  } else {
                    //_isTop = false;
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_borderRadius),
                  child: Scaffold(
                      appBar: PreferredSize(
                        preferredSize: Size.fromHeight(56),
                        child: AppBar(
                          automaticallyImplyLeading: false,
                          elevation: 0.0,
                          backgroundColor: Colors.grey[50],
                          leading: Transform.scale(
                            scale: 2,
                            child: IconButton(
                              onPressed: () => Navigator.of(context).pop(),//widget.onClose(),
                              icon: Icon(Icons.keyboard_arrow_left_rounded, color: Colors.grey[800])
                            ),
                          ),
                          title: Container(
                            child: Text(
                              'Posts',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 22,
                                fontWeight: FontWeight.w700
                              )
                            )
                          ),
                        ),
                      ),
                      body: Container(
                        child: SingleChildScrollView(
                          controller: widget.scrollController,
                          physics: startAnim ? NeverScrollableScrollPhysics() : null,
                          padding: EdgeInsets.only(bottom: 34),
                          child: Column(
                            children: [
                              ...MapsClass.userPosts[widget.profileUserInfo['uid']]['posts'].values.toList().asMap().entries.map((element) {
                              //...widget.profilePosts.values.toList().asMap().entries.map((element) {
                                int idx = element.key;
                                Map val = element.value;
                                if (idx == _visibleIndex) {
                                  return VisibilityDetector(
                                    key: Key(idx.toString()), 
                                    child: Container(
                                      key: theKey,
                                      child: PostMain2(
                                        postData: val,//widget.profilePosts.values.toList()[index],
                                        getLikeState: widget.getLikeState,
                                        getFollowingState: widget.getFollowingState,
                                        myInfo: widget.myInfo,
                                        key: Key('profile_${val['id']}'),
                                        comesFromProfile: true,
                                        theCategory: widget.profileUserInfo['uid'],
                                        postId: MapsClass.userPosts[widget.profileUserInfo['uid']]['posts'].values.toList()[_visibleIndex]['id']
                                      ),
                                    ),
                                    onVisibilityChanged: (VisibilityInfo info) {
                                      //var visiblePercentage = info.visibleFraction;
                                      //print(visiblePercentage);
                                      theMapForVisiblePosts[idx] = info.visibleFraction;
                                      if (info.visibleFraction == 1) {
                                        setState(() {
                                          _visibleIndex = idx;
                                          //print(_visibleIndex);
                                        });
                                        Timer(
                                          Duration(milliseconds:  100),
                                          () {
                                            widget.scrollTo(widget.positionMap[_visibleIndex]);
                                            //print('hey');
                                          }
                                        );
                                        widget.refresh(_visibleIndex);
                                      }
                                    },
                                  );
                                } else {
                                  return VisibilityDetector(
                                    key: Key(idx.toString()), 
                                    child: PostMain2(
                                      postData: val,//widget.profilePosts.values.toList()[index],
                                      getLikeState: widget.getLikeState,
                                      getFollowingState: widget.getFollowingState,
                                      myInfo: widget.myInfo,
                                      key: Key('profile_${val['id']}'),
                                      comesFromProfile: true,
                                      theCategory: widget.profileUserInfo['uid'],
                                      postId: MapsClass.userPosts[widget.profileUserInfo['uid']]['posts'].values.toList()[_visibleIndex]['id']
                                    ),
                                    onVisibilityChanged: (VisibilityInfo info) {
                                      //var visiblePercentage = info.visibleFraction;
                                      //print(visiblePercentage);
                                      theMapForVisiblePosts[idx] = info.visibleFraction;
                                      if (info.visibleFraction == 1) {
                                        setState(() {
                                          _visibleIndex = idx;
                                          //print(_visibleIndex);
                                        });
                                        Timer(
                                          Duration(milliseconds:  100),
                                          () {
                                            widget.scrollTo(widget.positionMap[_visibleIndex]);
                                            //print('hey');
                                          }
                                        );
                                        widget.refresh(_visibleIndex);
                                      }
                                    },
                                  );
                                }
                              }).toList(),
                            ],
                          )
                        )
                      )
                    ),
                ),
              //),
              ),
            )
          ),
        ),
      ]
    );
  }
}
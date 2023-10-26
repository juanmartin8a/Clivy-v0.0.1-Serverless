import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:untitled_startup/models/user.dart';
import 'package:untitled_startup/screens/bottomNavBar.dart';
import 'package:untitled_startup/screens/home/chat/chat.dart';
import 'package:untitled_startup/screens/home/main/classes/mapsClass.dart';
import 'package:untitled_startup/screens/home/main2/main3.dart';
import 'package:untitled_startup/screens/home/upload/uploadPostScreen.dart';
import 'package:untitled_startup/screens/home/userProfile/profile.dart';
import 'package:untitled_startup/services/database.dart';

import 'discover/discoverScreen.dart';
import 'discover/searchBar.dart';

class Home2 extends StatefulWidget {
  final double maxWidth;
  final double maxHeight;
  final double statusBar;
  Home2({this.maxWidth, this.maxHeight, this.statusBar});
  @override
  _Home2State createState() => _Home2State();
}

class _Home2State extends State<Home2> with SingleTickerProviderStateMixin {
  //TabController _tabController;
  //AnimationController _animController;
  PageController _pageController = PageController(viewportFraction: 1.05, initialPage: 1);
  int currentIndex = 1;
  double extentPorcentage = 0.0;
  double topRadius = 0.0;
  double colorOpacity = 0.0; 
  double currentPagePos = 0.0;
  double titleOpacity = 1;
  double profilePagePos;

  AnimationController _theSearchAnim;
  Animation<double> _searchBarWidth;
  Animation<double> _closeWidth;
  Animation<double> _theSearchScreen;
  Animation<double> _searchBarHeight;
  bool isAnimComplete;

  TextEditingController _searchController = TextEditingController();
  String searchString = '';

  Animatable<Color> background;
  double colorIndex = 1;


  //List<DocumentSnapshot> searchItems = [];

  getSearchItems() async {
    final user = Provider.of<CustomUser>(context, listen: false);
    if (searchString.length <= 0) {
      setState(() {
        MapsClass.searchedUsers = {};
      });
      return;
    }
    Query theQuery = FirebaseFirestore.instance.collection('users')
    .where('userNameIndex', arrayContains: searchString).limit(30);
    setState(() {});
    QuerySnapshot querySnapshot = await theQuery.get();
    //print('length is ${querySnapshot.docs.length}');
    MapsClass.searchedUsers = {};
    if (querySnapshot.docs.isNotEmpty && querySnapshot.docs.length > 0)  {
      Future.wait(querySnapshot.docs.map((doc) async {
        MapsClass.searchedUsers[doc.data()['uid']] = doc.data();
        if (MapsClass.searchedUsers[doc.data()['uid']] != null) {
          getFollowingState(user.uid, doc.data()['uid']);
        }
      }));
    } else {
      setState(() {});
    }
  }
  getFollowingState(myUid, userUid) async {
    if (MapsClass.searchedUsers[userUid] != null) {
      await DatabaseService(
        uid: myUid
      ).isFollowingUser(userUid).then((value) {
        if (MapsClass.searchedUsers[userUid] != null) {
          if (mounted) {
            setState(() {
              MapsClass.searchedUsers[userUid]['isUserFollowing'] = value;
            });
          }
        }
      });
      if (MapsClass.searchedUsers[userUid] != null) {
        return MapsClass.searchedUsers[userUid]['isUserFollowing'];
      }
    }
  }

  void refreshSearch(String searchString2) {
    setState(() {
      searchString = searchString2;
    });
  }

  void refreshAnim(bool animComplete) {
    setState(() {
      isAnimComplete = animComplete;
    });
  }

  void refreshArray() {
    setState(() {
      MapsClass.searchedUsers = {};
    });
  }


  addPostBottomSheet(Map<String, dynamic> myInfo) {
    double statusBar = MediaQuery.of(context).padding.top;
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      //backgroundColor: Colors.black,
      barrierColor: Colors.black38,
      builder: (context) {
        return UploadPostScreen(
          statusBar: statusBar,
          myInfo: myInfo
        );
      }
    );
  }

  @override
  void initState() {
    super.initState();
    _theSearchAnim = AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _searchBarWidth = Tween<double>(
      begin: 32,
      end: widget.maxWidth - 56
    ).animate(_theSearchAnim)
    ..addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    _searchBarHeight = Tween<double>(
      begin: 32,
      end: 42
    ).animate(_theSearchAnim)
    ..addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    _closeWidth = Tween<double>(
      begin: 0,
      end: 32
    ).animate(_theSearchAnim)
    ..addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    _theSearchScreen = Tween<double>(
      begin: 0,
      end: widget.maxHeight - 56 - widget.statusBar
    ).animate(_theSearchAnim)
    ..addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      background = TweenSequence<Color>([
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: Colors.greenAccent[700],
            end: Colors.tealAccent[700],
          ),
        ),
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: Colors.tealAccent[700],
            end: Colors.deepPurpleAccent[400],
          ),
        ),
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: Colors.deepPurpleAccent[400],
            end: Colors.blue[400],
          ),
        ),
      ]);
      setState(() {});
    });
  }

  animateToPageBottomNavBar(int index) {
    _pageController.animateToPage(
      index, 
      duration: Duration(milliseconds: 300),
      curve: Curves.decelerate
    );
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: StreamBuilder<DocumentSnapshot>(
          stream: DatabaseService(uid: user.uid).getUserByUid(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasData) {
              Map<String, dynamic> userInfo = snapshot.data.data();
              return Container(
                color: Colors.blue,
                child: Stack(
                  children: [
                    Container(
                      color: Colors.indigo
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          colorIndex = _pageController.hasClients ? _pageController.page / 3 : 0.33;
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              color: background.evaluate(AlwaysStoppedAnimation(colorIndex)),
                            ),
                            child: child,
                          );
                        },
                        child: 
                        NotificationListener<ScrollUpdateNotification>(
                          onNotification: (notification) {
                            //print(_pageController.hasClients ? _pageController.page / 3 : 0.33);
                            setState(() {
                              double preTitleOpacity = _pageController.hasClients ? _pageController.page / 3 : 0.33;
                              titleOpacity = ((preTitleOpacity - 0.0)*1) 
                              / ( 0.33 -  0.0);
                              if (titleOpacity >= 1.0) {
                                titleOpacity = 1.0;
                              } else if (titleOpacity <= 0.0) {
                                 titleOpacity = 0.0;
                              }
                              //print(titleOpacity);
                              //currentPagePos = _pageController.position.pixels;
                              profilePagePos = _pageController.position.maxScrollExtent;
                              currentPagePos = ((_pageController.position.pixels - _pageController.position.maxScrollExtent * 0.70)*1) 
                              / (_pageController.position.maxScrollExtent - _pageController.position.maxScrollExtent * 0.70);
                              double currentPagePosFake = ((_pageController.position.pixels - _pageController.position.maxScrollExtent * 0.70)*1) 
                              / (_pageController.position.maxScrollExtent - _pageController.position.maxScrollExtent * 0.70);
                              if (currentPagePos < 0.0) {
                                currentPagePos = 0.0;
                              } else if (currentPagePosFake >= 1.0 && currentPagePosFake < 2.0) {
                                currentPagePos = 1.0 - (currentPagePosFake - 1);
                                //print(currentPagePos);
                              } else if (currentPagePos > 2.0) {
                                currentPagePos = 0.0;
                              }
                            });
                            //print(currentPagePos);
                          },
                          child: PageView(
                            controller: _pageController,
                            clipBehavior: Clip.none,
                            physics: ClampingScrollPhysics(),
                            onPageChanged: (index) {
                              //print(Scrollable.of(context).position.pixels);
                              setState(() {
                                currentIndex = index;
                                //print(_pageController.position.pixels);
                              });
                            },
                            children: [
                              Chat(
                                userInfo: userInfo,
                                key: Key('chat')
                              ),
                              Main3(
                                userInfo: userInfo,
                                key: Key('main')
                              ),
                              Profile(
                                currentIndex: currentIndex,
                                currentPagePos: currentPagePos,
                                userInfo: userInfo,
                                key: Key('profile')
                              )
                            ],
                          ),
                        )
                      )
                      //Main3()
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: EdgeInsets.only(
                          bottom: 34 // iphone home bar size
                        ),
                        width: 250,
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(230),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[600].withOpacity(0.3),
                              spreadRadius: 4,
                              blurRadius: 12,
                              offset: Offset(0, 0), // changes position of shadow
                            ),
                          ],
                        ),
                        child: BottomNavBar(
                          scrollToPage: animateToPageBottomNavBar,
                          currentPage: currentIndex
                        )
                      )
                    ),
                    Positioned(
                      right: 12,
                      left: 12,
                      child: Opacity(
                        opacity: (1 - titleOpacity),
                        child: Opacity(
                          opacity: (1 - currentPagePos),
                          child: Container(
                            height: 45,
                            width: 32,
                            //color: Colors.red,
                            margin: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                child: Text(
                                  'Chat',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800
                                  )
                                )
                              )
                            )
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      left: 12,
                      child: Opacity(
                        opacity: titleOpacity,
                        child: Opacity(
                          opacity: (1 - currentPagePos),
                          child: Container(
                            height: 45,
                            width: 32,
                            //color: Colors.red,
                            margin: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                child: Text(
                                  'Untitled',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800
                                  )
                                )
                              )
                            )
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: (1 - currentPagePos) == 0 ? false : true,
                      child: Positioned(
                        right: 52,
                        left: 12,
                        child: Opacity(
                          opacity: (1 - currentPagePos),
                          child: Container(
                            height: 45,
                            width: 32,
                            //color: Colors.red,
                            margin: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top,
                              //right: 5,
                            ),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  addPostBottomSheet(userInfo);
                                },
                                child: Container(
                                  height: 32,
                                  width: 32,
                                  decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      shape: BoxShape.circle
                                    ),
                                  child: Center(
                                    child: Container(
                                      child: Icon(
                                        CupertinoIcons.plus
                                      )
                                    ),
                                  ),
                                ),
                              )
                            )
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: (1 - currentPagePos) == 0 ? false : true,
                      child: Positioned(
                        right: 12,
                        left: 12,
                        child: Opacity(
                          opacity: (1 - currentPagePos),
                          child: Container(
                            height: 45,
                            //color: Colors.red,
                            margin: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top,
                              //right: 5,
                            ),
                            child: SearchBar(
                              isAnimComplete: isAnimComplete,
                              theSearchAnim: _theSearchAnim,
                              searchBarWidth: _searchBarWidth,
                              searchBarHeight: _searchBarHeight,
                              closeWidth: _closeWidth,
                              theSearchController: _searchController,
                              getSearchItems: getSearchItems,
                              refreshSearch: refreshSearch,
                              refreshAnim: refreshAnim,
                              //refreshArray: refreshArray,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: _theSearchScreen.value,
                        child: DiscoverScreen(
                          searchString: searchString,
                          searchItems: MapsClass.searchedUsers.values.toList(),
                          myInfo: userInfo,
                        )
                      )
                    ),
                  ],
                )
              );
            } else {
              return Container();
            }
          }
        )
      ),
    );
  }
}
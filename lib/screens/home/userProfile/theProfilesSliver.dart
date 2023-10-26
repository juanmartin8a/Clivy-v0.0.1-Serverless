import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:untitled_startup/screens/home/settings/settings.dart';
import 'package:untitled_startup/services/cacheClass/cacheManager.dart';

class ProfilesSliverDelegate extends SliverPersistentHeaderDelegate {
  final double sliverHeaderHeight;
  final double statusBar;
  final Map<String, dynamic> userInfo;
  final bool isMyProfile;
  final BuildContext theContext;
  ProfilesSliverDelegate({this.sliverHeaderHeight, this.statusBar, this.userInfo,
  this.isMyProfile, @required this.theContext});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {

    double shrinkOffsetPorcentage = ((shrinkOffset - 0.0) * 1) / (sliverHeaderHeight - 0.0);
    double usernameOpacity = ((shrinkOffsetPorcentage - 0.0) * 1) / (0.50 - 0.0);
    if (usernameOpacity > 1.0) {
      usernameOpacity = 1;
    }
    double leftMargin = 18 * (1 - usernameOpacity);
    double theWhiteHeight = 0.15 * usernameOpacity;
    double theFontSize = 3 * usernameOpacity;
    double theBorders = 3 * (1-usernameOpacity);
    double headerOpacity = 0.0;
    if (usernameOpacity == 1) {
      headerOpacity = ((shrinkOffsetPorcentage - 0.5) * 1) / (0.55 - 0.5);
      if (headerOpacity > 1) {
        headerOpacity = 1;
      }
    }
      //TODOimplement build
      return Container(
        color: Colors.grey[50].withOpacity(headerOpacity),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * (0.15 - theWhiteHeight)
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular((45 * (1 - usernameOpacity))),
                    topRight: Radius.circular((45 * (1 - usernameOpacity)))
                  )
                )
                //height: 45
              )
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.only(top: statusBar),
                child: Container(
                  height: 100,
                  //color: Colors.red,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          //color: Colors.red,
                          border: Border.all(color: Colors.grey[50], width: 3 + theBorders)
                        ),
                        margin: EdgeInsets.only(left: 24 + (leftMargin)),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            width: 88,
                            height: 88,
                            fadeInDuration: Duration(milliseconds: 10),
                            fadeOutDuration: Duration(milliseconds: 10),
                            errorWidget: (context, url, error) => Container(color: Colors.grey[350]),
                            placeholder: (context, url) => Container(color: Colors.grey[350]),
                            imageUrl: userInfo['profileImg'],
                            fit: BoxFit.cover,
                            cacheManager: CustomCacheManager.instance,
                            imageBuilder: (context, imageProvider) {
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover
                                  )
                                  //borderRadius: BorderRadius.circular()
                                ),
                              );
                            },
                          ),
                        )
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: EdgeInsets.only(left: 2 * (1 - usernameOpacity), top: 6 * (1 - usernameOpacity)),
                          width: MediaQuery.of(context).size.width - (100 + 24 + (leftMargin)),
                          //color: Colors.blue,
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      userInfo != null
                                      ? Container(
                                        child: Text(
                                          '${userInfo['name']}',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey[850],
                                            fontSize: 17 + theFontSize,
                                            fontWeight: FontWeight.w800,
                                          )
                                        ),
                                      ) : Container(
                                        height: 20,
                                        width: 65,
                                        color: Colors.grey[350]
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          margin: EdgeInsets.only(right: 32 * (1 - usernameOpacity)),
                                          //color: Colors.red,
                                          child: !isMyProfile 
                                          ? Container(
                                            padding: EdgeInsets.symmetric(horizontal: 2),
                                            child: Icon(
                                              Icons.more_horiz_rounded, 
                                              color: Colors.grey[850],
                                              size: 32,
                                            ),
                                          ) : Popover(
                                            direction: PopoverDirection.right,
                                            barrierColor: Colors.black12,
                                            backgroundColor: Colors.grey[50],
                                            //arrowDxOffset: 20,
                                            arrowHeight: 12,
                                            arrowWidth: 24,
                                            transitionDuration: Duration(milliseconds: 150),
                                            child: 
                                            GestureDetector(
                                              onTap: () {},
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 2),
                                                child: Icon(
                                                  Icons.more_horiz_rounded, 
                                                  color: Colors.grey[850],
                                                  size: 32,
                                                ),
                                              ),
                                            ),
                                            bodyBuilder: (context) {
                                              return SizedBox(
                                                //color: Colors.red,
                                                width: 130,
                                                height: 50,
                                                  //padding: EdgeInsets.all(8),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.of(context).pop();
                                                      Navigator.push(
                                                        context,
                                                        CupertinoPageRoute(
                                                          builder: (context) => Settings(
                                                            userInfo: userInfo,
                                                          )
                                                        )
                                                      );
                                                    },
                                                    child: Container(
                                                      //color: Colors.blue,
                                                      padding: EdgeInsets.symmetric(vertical: 15),
                                                      child: Center(
                                                        child: Text(
                                                          'Settings',
                                                          style: TextStyle(
                                                            color: Colors.grey[850],
                                                            fontSize: 17,
                                                            fontWeight: FontWeight.w600
                                                          )
                                                        )
                                                      ),
                                                    ),
                                                  )
                                                );
                                            },
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                              ),
                              Align(
                                alignment: Alignment.bottomLeft,
                                  child: Opacity(
                                    opacity: 1 - usernameOpacity,
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 15),
                                      child: userInfo != null ? Text(
                                        '${userInfo['username']}',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          
                                        )
                                      ) : Container(height: 17, width: 65, color:Colors.grey[350])
                                    ),
                                  ),
                              )
                            ],
                          )
                        ),
                      ),
                    ]
                  ),
                ),
              ),
            ),
            isMyProfile 
            ? Container()
            : Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  height: 56,
                  width: 64,
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.scale(
                      scale: 2,
                      child: Icon(
                        Icons.keyboard_arrow_left_rounded,
                        color: usernameOpacity > 0.4 ? Colors.grey[800] : Colors.white,
                      ),
                    ),
                  )
                ),
              )
            ),
          ],
        )
      );
    }
  
    @override
    // TODOimplement maxExtent
    double get maxExtent => sliverHeaderHeight;
  
    @override
    // TODOimplement minExtent
    double get minExtent => 56 + statusBar;
  
    @override
    bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    // TODOimplement shouldRebuild
    return true;
  }
}
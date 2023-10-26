import 'package:flutter/material.dart';
import 'package:untitled_startup/screens/home/classes/tabbarIndicator.dart';
import 'dart:ui' as ui;


class MainSliverDelegate extends SliverPersistentHeaderDelegate{
  final double statusBar;
  final double maxHeight;
  final double minHeight;
  final double minPorcentage;
  final TabController tabController;
  final Function refresh;
  MainSliverDelegate({this.statusBar, this.maxHeight, this.minHeight, 
  this.tabController, this.minPorcentage, this.refresh});

  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    //print(overlapsContent);
      double shrinkOffsetPorcentage = ((shrinkOffset - 0.0) * 1) / ((maxHeight - minHeight) - 0.0);
      double theRealPorcentage = ((shrinkOffsetPorcentage - 0.0) * 1) / (1 - 0.0);
      if (theRealPorcentage > 1) {
        theRealPorcentage = 1;
      }
      //print(minPorcentage);
      //double theWhiteHeight = (0.15 - minPorcentage) * theRealPorcentage;
      double borderRadiusPorcentage = 0.0;
      borderRadiusPorcentage = (1 - theRealPorcentage);
      if (borderRadiusPorcentage < 0.4) {
        borderRadiusPorcentage = 0.4;
      }
      //double theRealShrinkOffset = shrinkOffset - (statusBar + 45);
      //double bodyMarginMax = (10 + (45 * 0.6));
      //refresh(theWhiteHeight);
      return Visibility(
        visible: true,
        child: Container(
          height: maxHeight,
          //padding: EdgeInsets.only(top: statusBar + 45),
          margin: EdgeInsets.only(top: 11),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              //color: Colors.blue,
              height: 55,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.grey[50].withOpacity(0.88),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(45 * (borderRadiusPorcentage)), 
                  topRight: Radius.circular(45 * (borderRadiusPorcentage))
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    spreadRadius: 0.1,
                    blurRadius: 3,
                    offset: Offset(0, -4), // changes position of shadow
                  ),
                ],
              ),
              child: Visibility(
                visible: true,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(45 * (borderRadiusPorcentage)), 
                    topRight: Radius.circular(45 * (borderRadiusPorcentage))
                  ),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(
                      sigmaX: 4,
                      sigmaY: 3,
                    ),
                    child: Center(
                      child: Container(
                        //color: Colors.red,
                        height: 55,
                        width: 212,
                        child: TabBar(    
                          labelPadding: EdgeInsets.symmetric(horizontal: 8),
                          indicator: MD2Indicator(
                            indicatorSize: MD2IndicatorSize.normal,
                            indicatorHeight: 8.0,
                            indicatorColor: Colors.grey[700],
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          //labelColor: Color(0xff1967d2),
                          //unselectedLabelColor: Color(0xff5f6368),  
                          controller: tabController,
                          tabs: [
                            Container(
                              child: Text(
                                'Following',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700
                                )
                              )
                            ),
                            Container(
                              child: Text(
                                'For You',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700
                                )
                              )
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ),
      );
  }
  
  @override
  double get maxExtent => maxHeight - (statusBar + 45);

  @override
  double get minExtent => minHeight - (statusBar + 45);

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

}
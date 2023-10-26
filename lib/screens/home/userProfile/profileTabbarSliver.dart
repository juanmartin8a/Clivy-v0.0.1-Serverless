import 'package:flutter/material.dart';
import 'package:untitled_startup/screens/home/classes/tabbarIndicator.dart';

class ProfileTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  ProfileTabBarDelegate({this.tabController});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
      return Container(
        color: Colors.grey[50],
        height: 50,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 250,
            height: 50,
            child: TabBar(    
              labelPadding: EdgeInsets.symmetric(horizontal: 8),
              indicator: MD2Indicator(
                indicatorSize: MD2IndicatorSize.normal,
                indicatorHeight: 6.0,
                indicatorColor: Colors.grey[700],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              //labelColor: Color(0xff1967d2),
              //unselectedLabelColor: Color(0xff5f6368),  
              controller: tabController,
              tabs: [
                Container(
                  child: Text(
                    'Posts',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                      fontWeight: FontWeight.w700
                    )
                  )
                ),
                Container(
                  child: Text(
                    'Nothing',
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
      );
    }
  
    @override
    double get maxExtent => 50;
  
    @override
    double get minExtent => 50;
  
    @override
    bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

}
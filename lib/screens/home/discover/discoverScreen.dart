import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled_startup/models/user.dart';
import 'package:untitled_startup/screens/home/discover/searchTile.dart';
import 'package:untitled_startup/screens/home/main/classes/mapsClass.dart';
import 'package:untitled_startup/services/database.dart';

class DiscoverScreen extends StatefulWidget {
  final double maxWidth;
  final double maxHeight;
  final double statusBar;
  final String searchString;
  final List searchItems;
  final Map<String, dynamic> myInfo;
  DiscoverScreen({this.maxWidth, this.maxHeight, this.statusBar, 
  this.searchString, this.searchItems, this.myInfo});
  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  ScrollController scrollController = ScrollController();

  List theVideogameImagesArray = [
    'assets/images/amongUs.jpg',
    'assets/images/apexLegends.jpg',
    'assets/images/battlefront2.jpg',
    'assets/images/coldWar.jpg',
    'assets/images/modernWarfare.jpg',
    'assets/images/CounterStrike.jpg',
    'assets/images/cyberpunk2077.jpg',
    'assets/images/Dota2.jpg',
    'assets/images/FIFA.jpg',
    'assets/images/Fortnite.jpg',
    'assets/images/GTA.jpg',
    'assets/images/LOL.jpg',
    'assets/images/Madden.jpg',
    'assets/images/Minecraft.jpg',
    'assets/images/NBA.jpg',
    'assets/images/Overwatch.jpg',
    'assets/images/Rainbows.jpg',
    'assets/images/RocketL.jpg',
    'assets/images/Rust.jpg',
    'assets/images/VALORANT.jpg',
    'assets/images/Warzone.jpg',
    'assets/images/WoW.jpg',
  ];

  @override
  void initState() {
    super.initState();
    //getSearchItems();
    scrollController.addListener(() {
      double maxScroll = scrollController.position.maxScrollExtent;
      double currentScroll = scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if (maxScroll - currentScroll < delta) {
        //getMoreSearchItems();
      }
    });
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(45 * 0.4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          //borderRadius: BorderRadius.circular(45 * 0.4)
        ),
        child: widget.searchString != '' ? ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.only(
                  left: 6, 
                  top: 16,
                  bottom: 6,
                  right: 6
                ),
                child: Text(
                  'Results',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 18,
                    fontWeight: FontWeight.w700
                  )
                )
              ),
            ),
            Container(
              child: ListView.builder(
                shrinkWrap: true,
                //controller: scrollController,
                itemCount: widget.searchString.startsWith('#') 
                  ? MapsClass.searchedHashtags.length
                  : MapsClass.searchedUsers.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  // if (widget.searchString.startsWith('#')) {
                  //   return MapsClass.searchedHashtags.length > 0 ? SearchTile(
                  //     searchItems: MapsClass.searchedHashtags.values.toList(),
                  //     index: index,
                  //     //isFollowing: MapsClass.searchedHashtags[widget.searchItems[index]['uid']]['isUserFollowing'],
                  //     //hasLoaded: MapsClass.searchedHashtags[widget.searchItems[index]['uid']]['isUserFollowing'] != null ? true : false,
                  //     myInfo: widget.myInfo,
                  //     refresh: refresh,
                  //     isHashtag: true,
                  //     //getFollowingState: getFollowingState,
                  //   ) : Container();
                  // }
                  return MapsClass.searchedUsers.length > 0 ? SearchTile(
                    searchItems: MapsClass.searchedUsers.values.toList(),
                    index: index,
                    isFollowing: MapsClass.searchedUsers[widget.searchItems[index]['uid']]['isUserFollowing'],
                    hasLoaded: MapsClass.searchedUsers[widget.searchItems[index]['uid']]['isUserFollowing'] != null ? true : false,
                    myInfo: widget.myInfo,
                    refresh: refresh,
                    isHashtag: false,
                    //getFollowingState: getFollowingState,
                  ) : Container();
                },
              )
            )
          ],
        ) : Container(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 6, 
                      top: 12,
                      bottom: 6,
                      right: 6
                    ),
                    child: Text(
                      'Videogames',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 16,
                        fontWeight: FontWeight.w700
                      )
                    )
                  ),
                ),
                Container(
                  height: 110,
                  //padding: EdgeInsets.symmetric(
                    //vertical: 5,
                  //),
                  //color: Colors.red,
                  child: ListView.builder(
                    //shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    //padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          margin: EdgeInsets.only(left: 2),
                          width: 84.8,
                          height: 115,
                          //color: Colors.red,
                          //padding: EdgeInsets.symmetric(
                            //horizontal: 6,
                            //vertical: 7.5,
                          //),
                          child: Center(
                            child: Container(
                              width: 72.8,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                //border: Border.all(color: Colors.deepPurpleAccent, width: 4),
                                image: DecorationImage(
                                  image: AssetImage(
                                    theVideogameImagesArray[index]
                                  ),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey[600].withOpacity(0.82),
                                    spreadRadius: 0.5,
                                    blurRadius: 3.5,
                                    offset: Offset(2, 0), // changes position of shadow
                                  ),
                                ]
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: theVideogameImagesArray.length,
                  ),
                )
              ],
            )
          ),
        )
      ),
    );
  }
}
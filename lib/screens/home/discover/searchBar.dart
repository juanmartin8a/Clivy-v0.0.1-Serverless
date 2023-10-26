import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled_startup/screens/home/main/classes/mapsClass.dart';

class SearchBar extends StatefulWidget {
  final bool isAnimComplete;
  final AnimationController theSearchAnim;
  final Animation<double> searchBarWidth;
  final Animation<double> searchBarHeight;
  final Animation<double> closeWidth;
  final TextEditingController theSearchController;
  final Function getSearchItems;
  final Function refreshSearch;
  final Function refreshAnim;
  final Function refreshArray;
  SearchBar({this.isAnimComplete, this.searchBarWidth, this.closeWidth, 
  this.theSearchAnim, this.searchBarHeight, this.theSearchController,
  this.getSearchItems,this.refreshSearch, this.refreshAnim, this.refreshArray});
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.red,
      height: widget.searchBarHeight.value,
      //width: widget.searchBarWidth.value,
      /*margin: EdgeInsets.only(
        left: 12,
        right: 12,
      ),*/
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          height: widget.searchBarHeight.value,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  if (widget.isAnimComplete == false || widget.isAnimComplete == null) {
                    widget.theSearchAnim.forward().whenComplete(() {
                      setState(() {
                        widget.refreshAnim(true);
                        //isAnimComplete = true;
                      });
                    });
                  }
                },
                child: Container(
                  height: widget.searchBarHeight.value,
                  width: widget.searchBarWidth.value,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(widget.searchBarHeight.value),
                    //shape: BoxShape.circle
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 32,
                        width: 32,
                        //color: Colors.red,
                        //padding: EdgeInsets.all(5.5),
                        child: Center(
                          child: Icon(
                            Icons.search_rounded,
                            color: Colors.grey[800],
                            size: 24
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          //margin: EdgeInsets.symmetric(horizontal: 4),
                          //color: Colors.blue,
                          //height:
                          /*decoration: BoxDecoration(
                            color: Colors.grey[350],
                            borderRadius: BorderRadius.circular(40)
                          ),*/
                          child: TextField(
                            keyboardType: TextInputType.text,
                            controller: widget.theSearchController,
                            autocorrect: false,
                            onChanged: (values) {
                              setState(() {
                                widget.refreshSearch(
                                  values.toLowerCase()
                                );
                                //MapsClass.searchedUsers = {};
                                //searchString = values;
                              });
                              widget.getSearchItems();
                              widget.theSearchController.selection = TextSelection.fromPosition(
                                TextPosition(
                                  offset: widget.theSearchController.text.length
                                )
                              );
                            },
                            cursorHeight: 20,
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 17,
                              //height: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                            //scrollPadding: EdgeInsets.symmetric(vertical: 0),
                            decoration: InputDecoration(
                              //contentPadding: EdgeInsets.symmetric(horizontal: 5),
                              //isDense: true,
                              border: InputBorder.none,
                              //counter: SizedBox.shrink(),
                              //counterText: '',
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 17,
                                //height: 1.2,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        )
                      )
                    ],
                  )
                ),
              ),
              GestureDetector(
                onTap: () {
                  widget.theSearchAnim.reverse().whenComplete(() {
                    //List<DocumentSnapshot> refreshArray = [];
                    setState(() {
                      widget.refreshAnim(false);
                      //isAnimComplete = false;
                      widget.theSearchController.text = '';
                      widget.refreshSearch('');
                      //widget.refreshArray();
                      //searchString = '';
                      //searchItems = [];
                    });
                    
                  });
                },
                child: Container(
                  //color: Colors.red,
                  height: 32,
                  width: widget.closeWidth.value,
                  child: Center(
                    child: widget.closeWidth.value <= 0 
                    ? Container(height: 0, width: 0)
                    : Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 30
                    ),
                  )
                ),
              )
            ],
          )
        )
      ),
    );
  }
}
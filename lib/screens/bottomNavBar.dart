import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavBar extends StatefulWidget {
  final int currentPage;
  final Function scrollToPage;
  BottomNavBar({this.currentPage, this.scrollToPage});
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              widget.scrollToPage(0);
            },
            child: Container(
              height: 50,
              width: 50,
              child: Center(
                child: AnimatedContainer(
                  duration: Duration(seconds: 2),
                  child: Icon(
                    CupertinoIcons.bubble_left_fill,
                    color: widget.currentPage == 0 ? Colors.grey[100] : Colors.grey[600],
                    size:  widget.currentPage == 0 ? 26.0 + 8.0 : 26.0
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              widget.scrollToPage(1);
            },
            child: Container(
              height: 50,
              width: 50,
              child: Center(
                 child: AnimatedContainer(
                  duration: Duration(seconds: 2),
                  child: Icon(
                    Icons.home_rounded,
                    color: widget.currentPage == 1 ? Colors.grey[100] : Colors.grey[600],
                    size: widget.currentPage == 1 ? 34.0 + 8.0 : 34.0
                  )
                ),
              ),
            )
          ),
          GestureDetector(
            onTap: () {
              widget.scrollToPage(2);
            },
            child: Container(
              //color: Colors.red,
              height: 50,
              width: 50,
              child: Center(
                child: AnimatedContainer(
                  duration: Duration(seconds: 2),
                  child: FaIcon(
                    FontAwesomeIcons.solidUser,
                    color: widget.currentPage == 2 ? Colors.grey[100] : Colors.grey[600],
                    size:  widget.currentPage == 2 ? 22.0 + 8.0 : 22.0
                  ),
                ),
              ),
            ),
          )
        ],
      )
    );
  }
}

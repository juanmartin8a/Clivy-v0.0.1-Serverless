import 'dart:io';
import 'package:flutter/material.dart';
import 'package:untitled_startup/screens/home/upload/videogames.dart';

class PostSettings extends StatefulWidget {
  final Map<String, dynamic> videogameCategories;
  final Map<String, dynamic> videogameImages;
  final bool commentsEnabled;
  final Function refresh;
  final String videogame;
  final List theCategories;
  final Function videogameRefresh;
  final File imageFile;
  final Function scrollToPage;
  PostSettings({this.commentsEnabled, this.refresh, this.videogameCategories,
  this.videogameImages, this.videogame, this.theCategories, this.videogameRefresh,
  this.imageFile, this.scrollToPage});
  @override
  _PostSettingsState createState() => _PostSettingsState();
}

class _PostSettingsState extends State<PostSettings>  with SingleTickerProviderStateMixin {
  AnimationController animController;
  var alignAnimation;
  var colorAnimation;
  bool commentsEnabled;
  bool isAnimating = false;
  bool isRunOnce = false;
  bool goesForward = false;
  String theVideogame;


  void refreshAgain(String newTheVideogame) {
    setState(() {
      theVideogame = newTheVideogame;
      print(theVideogame);
    });
  }

  @override
  void initState() {
    print(widget.commentsEnabled);
    super.initState();
    theVideogame = widget.videogame;
    commentsEnabled = widget.commentsEnabled;
    animController = AnimationController(
      vsync: this, 
      duration: Duration(milliseconds: 200)
    );
    alignAnimation = AlignmentTween(
      begin: commentsEnabled == true ? Alignment.centerRight : Alignment.centerLeft,
      end: commentsEnabled == true ? Alignment.centerLeft : Alignment.centerRight,
    ).animate(CurvedAnimation(
      parent: animController,
      curve: Curves.decelerate
    ))
    ..addListener(() {
      setState(() {});
    });
    colorAnimation = ColorTween(
      begin: commentsEnabled == true ? Colors.lightGreenAccent[700] : Colors.grey[350],
      end: commentsEnabled == true ? Colors.grey[350] : Colors.lightGreenAccent[700],
    ).animate(animController)
    ..addListener(() {
      setState(() {});
    });
    animController.addStatusListener((status) {
      print(status);
    });
  }

  @override
  void dispose() {
    super.dispose();
    animController.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 12),
            padding: EdgeInsets.symmetric(vertical: 8,),
            decoration: BoxDecoration(
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Text(
                    'Enable Comments',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                      fontWeight: FontWeight.w600
                    )
                  )
                ),
                GestureDetector(
                  onTap: () {
                    if (isRunOnce == false && isAnimating == false) {
                      isAnimating = true;
                      animController.forward().whenComplete(() {
                        setState(() {
                          isRunOnce = true;
                          goesForward = true;
                          if (commentsEnabled == true) {
                            commentsEnabled = false;
                          } else {
                            commentsEnabled = true;
                          }
                          widget.refresh(commentsEnabled);
                          isAnimating = false;
                        });
                      });
                    } else if (isRunOnce == true && isAnimating == false) {
                      if (goesForward == true && isAnimating == false) {
                        isAnimating = true;
                        animController.reverse().whenComplete(() {
                          setState(() {
                            goesForward = false;
                            if (commentsEnabled == true) {
                              commentsEnabled = false;
                            } else {
                              commentsEnabled = true;
                            }
                            widget.refresh(commentsEnabled);
                            isAnimating = false;
                          });
                        });
                      } else if (goesForward == false && isAnimating == false) {
                        isAnimating = true;
                        animController.forward().whenComplete(() {
                          setState(() {
                            goesForward = true;
                            if (commentsEnabled == true) {
                              commentsEnabled = false;
                            } else {
                              commentsEnabled = true;
                            }
                            widget.refresh(commentsEnabled);
                            isAnimating = false;
                          });
                        });
                      }
                    }
                  },
                  child: Container(
                    height: 28,
                    width: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: colorAnimation.value,
                    ),
                    child: Align(
                      alignment: alignAnimation.value,
                      child: Container(
                        height: 26,
                        width: 26,
                        margin: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle
                        )
                      ),
                    )
                  ),
                )
              ],
            )
          ),
          GestureDetector(
            onTap: () {
              widget.scrollToPage();
            },
            child: Container(
              //margin: EdgeInsets.only(top: 12),
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                //borderRadius: BorderRadius.circular(12),
                //color: Colors.red,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      'Videogames',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      )
                    )
                  ),
                  Container(
                    child: Row(
                      children: [
                        Container(
                          width: 41.6,
                          height: 56,
                          //padding: EdgeInsets.all
                          decoration: prevImage(context)
                        ),
                        Container(
                          child: Icon(
                            Icons.keyboard_arrow_right_rounded,
                            color: Colors.grey[700],
                            size: 28,
                          )
                        )
                      ]
                    )
                  )
                ],
              )
            ),
          ),
        ]
      ),
    );
  }

  prevImage(BuildContext context) {
    if (theVideogame == 'Other' || theVideogame == '' || theVideogame == 'None') {
      return BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8 * 0.8),
      );
    } else {
      return BoxDecoration(
        color: Colors.grey[350],
        borderRadius: BorderRadius.circular(8 * 0.8),
        image: DecorationImage(
          image: AssetImage(
            widget.videogameImages[theVideogame]
          )
        )
      );
    }
  }

}
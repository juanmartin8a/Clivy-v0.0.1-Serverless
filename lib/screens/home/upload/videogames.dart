import 'dart:io';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class VideogameSelection extends StatefulWidget {
  final Map<String, dynamic> videogameCategories;
  final Map<String, dynamic> videogameImages;
  final String videogame;
  final List theCategories;
  final Function videogameRefresh;
  final Function refreshSettings;
  final bool comesFromSettings;
  final File imageFile;
  VideogameSelection({this.videogameImages, this.videogameCategories, this.theCategories,
  this.videogame, this.videogameRefresh, this.comesFromSettings, this.refreshSettings,
  this.imageFile});
  @override
  _VideogameSelectionState createState() => _VideogameSelectionState();
}

class _VideogameSelectionState extends State<VideogameSelection> with SingleTickerProviderStateMixin {
  List selectedGame = [];
  int selectedIndex;
  AnimationController animController;
  Animation<double> indexPaddingLeft;
  Animation<double> indexPaddingRight;

  warningOverlay(BuildContext context) {
    showOverlayNotification((context) {
      return Material(
        child: GestureDetector(
          onPanUpdate: (details) {
            if (details.delta.dy < 0) {
              OverlaySupportEntry.of(context).dismiss();
            }
          },
          child: Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 8,
              right: 8
            ),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.85),
              borderRadius: BorderRadius.circular(16)
            ),
            width: MediaQuery.of(context).size.width,
            child: Container(
              //color: Colors.yellow,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //Expanded(
                    //flex: 1,
                    //alignment: Alignment.centerLeft,
                    Container(
                      //width: 52,
                      //height: 70,
                      //padding: EdgeInsets.all
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.redAccent[700],
                        size: 28,
                      )
                    ),
                  //),
                  Expanded(
                    //flex: 8,
                    //alignment: Alignment.centerLeft,
                    child: Container(
                      //color: Colors.blue,
                      margin: EdgeInsets.only(left: 12, right: 12),
                      child: Text(
                          'No file found, please choose an image or video to post first.',
                          //maxLines: 3,
                          //softWrap: true,
                          style: TextStyle(
                            color: Colors.red[50],
                            fontSize: 15,
                            fontWeight: FontWeight.w400
                          ),
                        )
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      OverlaySupportEntry.of(context).dismiss();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      child: Text(
                        'Go back',
                        style: TextStyle(
                          color: Colors.yellow[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline
                        ),
                      )
                    ),
                  )
                ],
              ),
            )
            //height: 90,
          ),
        ),
      );
    }, duration: Duration(milliseconds: 5000));
  }

  @override
  void initState() {
    super.initState();
    if (widget.videogame != '') {
      selectedGame.add(widget.videogame);
    }
    animController = AnimationController(vsync: this, duration: Duration(milliseconds: 320));
    indexPaddingLeft = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem(tween: Tween<double>(begin: 12, end: 2), weight: 45),
      TweenSequenceItem(tween: Tween<double>(begin: 2, end: 22), weight: 45),
      TweenSequenceItem(tween: Tween<double>(begin:22, end: 7), weight: 45),
      TweenSequenceItem(tween: Tween<double>(begin: 7, end: 17), weight: 45),
      TweenSequenceItem(tween: Tween<double>(begin: 17, end: 12), weight: 45)
    ]).animate(animController)
    ..addListener(() {
      setState(() {});
    });
    indexPaddingRight = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem(tween: Tween<double>(begin: 12, end: 22), weight: 45),
      TweenSequenceItem(tween: Tween<double>(begin: 22, end: 2), weight: 45),
      TweenSequenceItem(tween: Tween<double>(begin:2, end: 17), weight: 45),
      TweenSequenceItem(tween: Tween<double>(begin: 17, end: 7), weight: 45),
      TweenSequenceItem(tween: Tween<double>(begin: 7, end: 12), weight: 45)
    ]).animate(animController)
    ..addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    //print(widget.videogameCategories.length);
    return Container(
        child: ListView.builder(
          itemCount: selectedGame.isNotEmpty 
          ? widget.videogameCategories.length + 1
          : widget.videogameCategories.length,
          physics: AlwaysScrollableScrollPhysics(),
          controller: ScrollController(),
          itemBuilder: (context, index) {
            List theVideogameList = widget.videogameCategories.keys.toList();
            int theIndex = selectedGame.isNotEmpty ? index - 1 : index;
            if (selectedGame.isNotEmpty) {
              if (index == 0) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 12,
                      right: 12, 
                      bottom: 12,
                      top: 12
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[400] ,width: 0.8)
                      )
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 70,
                          decoration: widget.videogameImages[selectedGame[0]] != 'none' 
                          ? BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: AssetImage(
                                widget.videogameImages[selectedGame[0]]
                              ),
                              fit: BoxFit.cover
                            )
                          ) : BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[350]
                          )
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 8),
                          child: widget.videogameImages[selectedGame[0]] != 'none'
                          ? Text(
                            '${theVideogameList.where((i) => i == selectedGame[0]).toList()[0]}',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800]
                            )
                          ) : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${theVideogameList.where((i) => i == selectedGame[0]).toList()[0]}',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800]
                                )
                              ),
                              theVideogameList.where((i) => i == selectedGame[0]).toList()[0] == 'Other' ? Text(
                                'Other videogame not in list',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[600]
                                )
                              ) : Text(
                                'No videogame content',//'Post does not have videogame content',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[600]
                                )
                              )
                            ],
                          )
                        ),
                      ],
                    )
                  ),
                );
              }
            }
            return Container(
              //width: 200,
              child: GestureDetector(
                onTap: () {
                  if (widget.imageFile != null) {
                    setState(() {
                      selectedGame.clear();
                      selectedGame.add(theVideogameList[theIndex]);
                    });
                    widget.videogameRefresh(selectedGame[0]);
                    if (widget.comesFromSettings == true) {
                      print(selectedGame[0]);
                      widget.refreshSettings(selectedGame[0]);
                    }
                  } else {
                    warningOverlay(context);
                    //if (selectedGame.isNotEmpty) {
                      setState(() {
                        selectedIndex = theIndex;
                      });
                    // } else if (selectedGame.isEmpty) {
                    //   setState(() {
                    //     selectedIndex = index;
                    //   });
                    // }
                    animController.forward().whenComplete(() {
                      animController.reset();
                    });
                    print(index);
                  }
                },
                child: Container(
                  color: Colors.grey[50],
                  padding: EdgeInsets.only(
                    right: selectedIndex == theIndex ? indexPaddingRight.value  : 12,
                    left: selectedIndex == theIndex ? indexPaddingLeft.value : 12,
                    top: 6,
                    bottom: 6
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 70,
                        decoration: widget.videogameImages[theVideogameList[theIndex]] != 'none' 
                        ? BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: AssetImage(
                              widget.videogameImages[theVideogameList[theIndex]]
                            ),
                            fit: BoxFit.cover
                          )
                        ) : BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[350]
                        )
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 8),
                        child: widget.videogameImages[theVideogameList[theIndex]] != 'none'
                        ? Text(
                          '${theVideogameList[theIndex]}',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800]
                          )
                        ) : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${theVideogameList[theIndex]}',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800]
                              )
                            ),
                            theVideogameList[theIndex] == 'Other' ? Text(
                              'Other videogame not in list',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600]
                              )
                            ) : Text(
                              'No videogame content',//'Post does not have videogame content',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600]
                              )
                            )
                          ],
                        )
                      ),
                      const Spacer(),
                      Container(
                        //margin: EdgeInsets.only(right: 12),
                        width: 27,
                        height: 27,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: !selectedGame.contains(theVideogameList[theIndex]) ? Colors.grey[400] : Colors.blue, 
                            width: 2,
                          ),
                          color: !selectedGame.contains(theVideogameList[theIndex]) ? Colors.grey[50] : Colors.blue,
                        ),
                        child: !selectedGame.contains(theVideogameList[theIndex]) ? Container() : Icon(
                          Icons.check_rounded, 
                          color: Colors.white, 
                          size: 20
                        )
                      )
                    ],
                  )
                ),
              ),
            );
          },
        )
      //)
    );
  }
}
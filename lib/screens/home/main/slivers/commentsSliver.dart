import 'package:flutter/material.dart';

class CommentsSliverDelegate extends SliverPersistentHeaderDelegate {
  final double statusBar;
  final double maxHeight;
  final double fileHeight;
  final double fileWidth;
  final String filePath;
  CommentsSliverDelegate({this.statusBar, this.fileWidth, this.fileHeight, 
  this.maxHeight, this.filePath});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
      double shrinkOffsetPorcentage = ((shrinkOffset - 0.0) * 1) / ((maxHeight) - 0.0);
      if (shrinkOffsetPorcentage >= 1.0) {
        shrinkOffsetPorcentage = 1.0;
      }
      double theRealPorcentage = ((shrinkOffsetPorcentage - 0.0) * 1) / (0.72 - 0.0);
      if (theRealPorcentage > 1) {
        theRealPorcentage = 1;
      }
      double forTheFile = ((shrinkOffsetPorcentage - 0.0) * 1) / (0.68 - 0.0);
      if (forTheFile > 1) {
        forTheFile = 1;
      }
      double borderRadius = 12 * (1 - theRealPorcentage);
      if (borderRadius < 6) {
        borderRadius = 6;
      }
      //double theActualShrinkOffset = (maxHeight + 56 + statusBar) - (56 + statusBar);
      //print('the paur is $theActualShrinkOffset - $shrinkOffset');
      //double finalAlignment = 0.5 * (1 - shrinkOffsetPorcentage);
      //double 
      //print(shrinkOffsetPorcentage);
      //print(shrinkOffset);
      //print(shrinkOffsetPorcentage);
      return Container(
        decoration: shrinkOffsetPorcentage == 1 ? BoxDecoration(
          color: Colors.grey[50],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ) : BoxDecoration(
          color: Colors.grey[50],
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                height: 56,
                margin: EdgeInsets.only(top: statusBar),
                child: Row(
                  children: [
                    Transform.scale(
                      scale: 2,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.keyboard_arrow_left_rounded, 
                          color: Colors.grey[800],
                          //size: 32
                        ),
                      )
                    ),
                    const Spacer(),
                    Container(
                      margin: EdgeInsets.only(right: 24),
                      child: Text(
                        'Comments',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w700
                        )
                      ),
                    ),
                    //const Spacer(),
                  ],
                )
              )
            ),
            Align(
              alignment: FractionalOffset(0.0, 0.5),//FractionalOffset(finalAlignment, 0.5),
              child: Container(
                //color: Colors.red,
                margin: EdgeInsets.only(
                  top: statusBar + (56 * (1 - forTheFile)),
                  left: 48, 
                  right: 48
                ),
                padding: EdgeInsets.all(2),
                //color: Colors.red,
                child: AspectRatio(
                  aspectRatio: fileWidth / fileHeight,
                  child: Container(
                    //margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[350],
                      borderRadius: BorderRadius.circular(12 - (12 - borderRadius)),
                      image: DecorationImage(
                        image: NetworkImage(
                          filePath
                        ),
                        fit: BoxFit.cover
                      )
                    ),
                  ),
                ),
              )   
            ),
          ]
        )
      );
    }
  
    @override
    double get maxExtent => maxHeight + 56 + statusBar;
  
    @override
    double get minExtent => 56 + statusBar;
  
    @override
    bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

}
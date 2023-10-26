import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class PredictionOverlay extends StatefulWidget {
  final double statusBar;
  final String image;
  final String label;
  final Function goToSettings;
  PredictionOverlay({this.statusBar, this.image, this.label, this.goToSettings});
  @override
  _PredictionOverlayState createState() => _PredictionOverlayState();
}

class _PredictionOverlayState extends State<PredictionOverlay> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: GestureDetector(
        onPanUpdate: (details) {
          if (details.delta.dy < 0) {
            //null;
            OverlaySupportEntry.of(context).dismiss();
          } 
        },
        child: Container(
          margin: EdgeInsets.only(
            top: widget.statusBar,
            left: 8,
            right: 8
          ),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(16)
          ),
          width: MediaQuery.of(context).size.width,
          child: Container(
            //margin: EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Row(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 52,
                          height: 70,
                          //padding: EdgeInsets.all
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(widget.image),
                              fit: BoxFit.cover
                            ),
                            borderRadius: BorderRadius.circular(8)
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(left: 12),
                          child: Text(
                            '${widget.label}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600
                            ),
                          )
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    widget.goToSettings();
                    OverlaySupportEntry.of(context).dismiss();
                  },
                  child: Container(
                    child: Text(
                      'change',
                      style: TextStyle(
                        color: Colors.yellow[600],
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline
                      ),
                    )
                  ),
                )
              ],
            )
          )
        ),
      )
    );
  }
}
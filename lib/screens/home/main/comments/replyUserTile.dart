import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:untitled_startup/services/cacheClass/cacheManager.dart';

class ReplyUserInfo extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  final Function cancelReply;
  ReplyUserInfo({this.userInfo, this.cancelReply});
  @override
  _ReplyUserInfoState createState() => _ReplyUserInfoState();
}

class _ReplyUserInfoState extends State<ReplyUserInfo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 6),
      //color: Colors.red,
      height: 54,
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[350],
            ),
            child: CachedNetworkImage(
              fadeInDuration: Duration(milliseconds: 10),
              fadeOutDuration: Duration(milliseconds: 10),
              placeholder: (context, url) => Container(color: Colors.grey[350]),
              imageUrl: widget.userInfo['profileImg'],
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
                  ),
                );
              },
            )
          ),
          Expanded(
            child: Container(
              //color: Colors.blue,
              margin: EdgeInsets.only(left: 6),
              child: Column(
                //mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 1),
                    child: Text(
                      //'${widget.theCommentsList.data()['likes']}likes•${widget.timeAgo}',
                      'Reply',
                      //'${widget.theCommentsList.data()['likes']} likes   ${widget.timeAgo}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        //height: 0.5
                      )
                    ),
                  ),
                  Container(
                    child: Text(
                      '${widget.userInfo['username']}',
                       style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 0.95
                      ),
                    )
                  ),
                  //Spacer()
                ],
              )
            ),
          ),
          //const Spacer(),
          Center(
            child: GestureDetector(
              onTap: () {
                widget.cancelReply();
              },
              child: Container(
                //color: Colors.blue,
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.grey[700],
                  size: 22
                )
              ),
            )
          )
        ],
      ),
    );
  }
}
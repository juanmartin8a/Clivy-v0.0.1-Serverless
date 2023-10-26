import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:untitled_startup/services/cacheClass/cacheManager.dart';

class InGroupChatTile extends StatefulWidget {
  final String message;
  final bool isSendByMe;
  final String theProfileImg;
  final String userName;
  final Map messageInfo;
  InGroupChatTile({this.isSendByMe, this.message, this.theProfileImg,
  this.userName, this.messageInfo});
  @override
  _InGroupChatTileState createState() => _InGroupChatTileState();
}

class _InGroupChatTileState extends State<InGroupChatTile> {
  @override
  Widget build(BuildContext context) {
    var flexible = Flexible(
      child: Container(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.blueGrey[700],
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: widget.isSendByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                widget.isSendByMe ? 'Me' : '${widget.userName.split(' ')[0]}',
                style: TextStyle(
                  color: widget.isSendByMe ? Colors.deepOrangeAccent : Colors.greenAccent[400].withOpacity(0.80),
                  fontSize: 15,
                  fontWeight: FontWeight.w600
                )
              ),
              Text(
                '${widget.message}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600
                )
              )
            ],
          )
        ),
      ),
    );
    var container = Container(
      margin: EdgeInsets.only(
        left: widget.isSendByMe ? 6 : 0,
        right: widget.isSendByMe ? 0 : 6,
      ),
      height: 45,
      width: 45,
      decoration:  BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[350],
        /*image: DecorationImage(
          image: NetworkImage(
            widget.theProfileImg
          ),
          fit: BoxFit.cover
        )*/
      ),
      child: CachedNetworkImage(
        fadeInDuration: Duration(milliseconds: 20),
        fadeOutDuration: Duration(milliseconds: 20),
        placeholder: (context, url) => Container(
          decoration: BoxDecoration(
            color: Colors.grey[350],
            shape: BoxShape.circle
          )
        ),
        imageUrl: widget.theProfileImg,
        fit: BoxFit.cover,
        cacheManager: CustomCacheManager.instance,
        imageBuilder: (context, imageProvider) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[350],
              shape: BoxShape.circle,
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover
              )
            )
          );
        }
      )
    );
    var hasBeenSentIcon = Container(
      child: widget.messageInfo['newMessage'] == true 
      ? widget.messageInfo['hasbeenSend'] == false 
      ? Container(
        padding: EdgeInsets.all(8),
        child: Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 24
        )
      )
      : Container()
      : Container()
    );
    var hasBeenSentText = Container(
      child: widget.messageInfo['newMessage'] == true 
      ? widget.messageInfo['hasbeenSend'] == false 
      ? Container(
        child: Text(
          'Could not send message',
          style: TextStyle(
            color: Colors.red,
            fontSize: 15,
            fontWeight: FontWeight.w500
          )
        )
      )
      : Container()
      : Container()
    );
    return Align(
      alignment: widget.isSendByMe ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        margin: EdgeInsets.symmetric(vertical: 6),
        child: widget.messageInfo['newMessage'] != true 
        ? Row(
          mainAxisAlignment: widget.isSendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            widget.isSendByMe ? flexible : container,
            widget.isSendByMe ? container : flexible
          ],
        )
        : Column(
          crossAxisAlignment: widget.isSendByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: widget.isSendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                widget.isSendByMe ? flexible : container,
                widget.isSendByMe ? container : flexible,
                widget.isSendByMe 
                ? widget.messageInfo['hasbeenSend'] == false
                ? hasBeenSentIcon
                : Container()
                : Container() 
              ],
            ),
            widget.messageInfo['hasbeenSend'] == false 
            ? Container(
              margin: EdgeInsets.only(top: 2),
              child: hasBeenSentText
            )
            : Container()
          ],
        ),
      )
    );
  }
}
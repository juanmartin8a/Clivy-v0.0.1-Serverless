import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaggedUsersList extends StatefulWidget {
  final DocumentSnapshot theTaggedUser;
  //final TextEditingController theCommentController;
  //final String theWord;
  final Function theAutoCompleteFunction;
  TaggedUsersList({this.theTaggedUser, this.theAutoCompleteFunction});
  @override
  _TaggedUsersListState createState() => _TaggedUsersListState();
}

class _TaggedUsersListState extends State<TaggedUsersList> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.theAutoCompleteFunction(
          widget.theTaggedUser.data()['username'],
          widget.theTaggedUser.data()['uid']
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        color: Colors.grey[50],
        //Colors.grey
        child: Row(
          children: [
            Container(
              height: 65,
              width: 65,
              decoration: BoxDecoration(
                //borderRadius: BorderRadius.circular(62),
                shape: BoxShape.circle,
                color: Colors.grey[350],
                image: DecorationImage(
                  image: NetworkImage(
                    widget.theTaggedUser.data()['profileImg']
                  ),
                  fit: BoxFit.cover
                )
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      widget.theTaggedUser.data()['name'],
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 16,
                        fontWeight: FontWeight.w700
                      )
                    )
                  ),
                  Container(
                    child: Text(
                      widget.theTaggedUser.data()['username'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 15,
                        fontWeight: FontWeight.w500
                      )
                    )
                  )
                ],
              )
            ),
          ]
        )
      )
    );
  }
}
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class EditProfileTextFields extends StatefulWidget {
  //final Map<String, dynamic> userInfo;
  final Function refresh;
  final TextEditingController nameController;
  final TextEditingController usernameController;
  final TextEditingController bioController;
  EditProfileTextFields({this.bioController, this.nameController, 
  this.usernameController, this.refresh});
  @override
  _EditProfileTextFieldsState createState() => _EditProfileTextFieldsState();
}

class _EditProfileTextFieldsState extends State<EditProfileTextFields> {
  TextEditingController nameController;
  TextEditingController usernameController;
  TextEditingController bioController;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 116,
                  //color: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 7),
                  child: Text(
                    'Name',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 19,
                      fontWeight: FontWeight.w600
                    )
                  )
                ),
                Expanded(
                  //width: 4,
                  child: Container(
                    height: 35,
                    padding: EdgeInsets.only(left: 8, bottom: 0),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.grey[500], width: 0.8)
                      ),
                      //color: Colors.red,
                    ),
                    child: TextField(
                      autocorrect: false,
                      controller: widget.nameController,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 18,
                        //height: 2,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLength: 18,
                      onChanged: (values) {
                        setState(() {
                          widget.refresh();
                        });
                      },
                      buildCounter: (BuildContext context, { int currentLength, int maxLength, bool isFocused }) => null,
                      //scrollPadding: EdgeInsets.symmetric(vertical: 0),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 7),
                        //heigh
                        isDense: true,
                        border: InputBorder.none,
                        //counter: SizedBox.shrink(),
                        //counterText: '',
                        hintText: 'Name...',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 18,
                          //height: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ),
                )
              ],
            )
          ),
          Container(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 116,
                  padding: EdgeInsets.symmetric(vertical: 7),
                  child: Text(
                    'Username',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 19,
                      fontWeight: FontWeight.w600
                    )
                  )
                ),
                Expanded(
                  //width: 4,
                  child: Container(
                    height: 35,
                    padding: EdgeInsets.only(left: 8, bottom: 0),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.grey[500], width: 0.8)
                      ),
                      //color: Colors.red,
                    ),
                    child: TextField(
                      autocorrect: false,
                      controller: widget.usernameController,
                      textCapitalization: TextCapitalization.none,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLength: 18,
                      onChanged: (values) {
                        setState(() {
                          widget.refresh();
                        });
                      },
                      buildCounter: (BuildContext context, { int currentLength, int maxLength, bool isFocused }) => null,
                      //scrollPadding: EdgeInsets.symmetric(vertical: 0),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 7),
                        //heigh
                        isDense: true,
                        border: InputBorder.none,
                        //counter: SizedBox.shrink(),
                        //counterText: '',
                        hintText: 'Username...',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 18,
                          //height: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ),
                )
              ],
            )
          ),
          Container(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  //color: Colors.red,
                  width: 116,
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    'Bio',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 19,
                      fontWeight: FontWeight.w600
                    )
                  )
                ),
                Expanded(
                  //width: 4,
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: 35,
                      maxHeight: 80
                    ),
                    padding: EdgeInsets.only(left: 8, bottom: 0),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.grey[500], width: 0.8)
                      ),
                      //color: Colors.yellow,
                    ),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      controller: widget.bioController,
                      autocorrect: false,
                      maxLines: 4,
                      minLines: 1,
                      maxLength: 120,
                      onChanged: (values) {
                        setState(() {
                          widget.refresh();
                        });
                      },
                      buildCounter: (BuildContext context, { int currentLength, int maxLength, bool isFocused }) => null,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 18,
                        //height: 2,
                        fontWeight: FontWeight.w600,
                      ),
                      //scrollPadding: EdgeInsets.symmetric(vertical: 0),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 6),
                        isDense: true,
                        border: InputBorder.none,
                        //counter: SizedBox.shrink(),
                        //counterText: '',
                        hintText: 'Add a bio...',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 18,
                          //height: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  )
                )
              ],
            )
          ),

        ]
      )
    );
  }
}
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class CreateChatInfo extends StatefulWidget {
  final bool hasSelectedItems;
  final Function groupName;
  final Function groupImg;
  CreateChatInfo({this.hasSelectedItems, this.groupName, this.groupImg});
  @override
  _CreateChatInfoState createState() => _CreateChatInfoState();
}

class _CreateChatInfoState extends State<CreateChatInfo> {
  TextEditingController groupNameController = TextEditingController();
  String groupName = '';

  bool isLoading = false;
  File imageFile;

  void pickFiles(BuildContext context) async {
    //var pickedFile = await picker.getVideo(source: ImageSource.gallery);
    FilePickerResult pickedFile = await FilePicker.platform.pickFiles(type: FileType.image);
    //print(pickedFile);
    print(pickedFile.files);
    setState(() {
      if (pickedFile != null) {
        isLoading = true;
        imageFile = File(pickedFile.files.first.path);
        widget.groupImg(imageFile);
        //uploadImage(context);
        //initialize();
      } else {
        print('No file selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.hasSelectedItems ? true : false,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6
        ),
        color: Colors.grey[50],
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                pickFiles(context);
              },
              child: Container(
                height: 58,
                width: 58,
                decoration: imageFile == null ? BoxDecoration(
                  //borderRadius: BorderRadius.circular(62),
                  shape: BoxShape.circle,
                  color: Colors.grey[350],
                ) : BoxDecoration(
                  //borderRadius: BorderRadius.circular(62),
                  shape: BoxShape.circle,
                  color: Colors.grey[350],
                  image: DecorationImage(
                    image: FileImage(
                      imageFile
                    ),
                    fit: BoxFit.cover
                  )
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 6),
                child: TextField(
                  keyboardType: TextInputType.text,
                  controller: groupNameController,
                  autocorrect: false,
                  onChanged: (values) {
                    setState(() {
                      //refreshSearch(values);
                      groupName = values;
                      widget.groupName(groupName);
                    });
                    //getSearchItems();
                    groupNameController.selection = TextSelection.fromPosition(
                      TextPosition(
                        offset: groupNameController.text.length
                      )
                    );
                  },
                  //cursorHeight: 22,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 18,
                    height: 1.4,
                    fontWeight: FontWeight.w800,
                  ),
                  //scrollPadding: EdgeInsets.symmetric(vertical: 0),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 6,),
                    isDense: true,
                    border: InputBorder.none,
                    //counter: SizedBox.shrink(),
                    //counterText: '',
                    hintText: 'Group Name',
                    hintStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 18,
                      height: 1.4,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              ),
            ),
          ]
        )
      ),
    );
  }
}
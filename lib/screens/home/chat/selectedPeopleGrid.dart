import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SelectedPeopleGrid extends StatefulWidget {
  final List<dynamic> selectedUsers;
  final bool hasSelectedItems;
  final Function removeSelectedItem;
  SelectedPeopleGrid({this.selectedUsers, this.hasSelectedItems, this.removeSelectedItem}); 
  @override
  _SelectedPeopleGridState createState() => _SelectedPeopleGridState();
}

class _SelectedPeopleGridState extends State<SelectedPeopleGrid> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.hasSelectedItems ? true : false,
      child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4
          ),
          //color: Colors.red,
          child: StaggeredGridView.count(
            padding: EdgeInsets.zero,
            crossAxisCount: 11,
            shrinkWrap: true,
            //mainAxisSpacing: 6.0,
            primary: false,
            //crossAxisSpacing: 6.0,
            //crossAxisSpacing: 160,
            //childAspectRatio: 3,
            children: List.generate(widget.selectedUsers.length, (index) {
              return GestureDetector(
                onDoubleTap: () {
                  widget.removeSelectedItem(widget.selectedUsers[index].data()['uid']);
                },
                child: Container(
                  margin: EdgeInsets.all(3),
                  //padding: EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Center(
                    child: Text(
                      widget.selectedUsers[index].data()['name'],
                      //'hdbcajkhsdbckjyarcvkajhsdbckjqadyb ckjdhsbjk vsd'
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.2,
                        fontWeight: FontWeight.w600
                      )
                    ),
                  )
                ),
              );
            }),
            staggeredTiles: List.generate(widget.selectedUsers.length, (index) {
              if (widget.selectedUsers[index].data()['name'].length > 10) {
                return StaggeredTile.count(4, 1);
              } else {
                return StaggeredTile.count(3, 1);
              }
            })
          )
        ),
    );
  }
}
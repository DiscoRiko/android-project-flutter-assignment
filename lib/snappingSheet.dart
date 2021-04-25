import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/auth_repository.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:file_picker/file_picker.dart';

import 'manageSavedSuggestions.dart';

class MySnappingSheet extends StatefulWidget {
  final Function _buildSuggestions;
  MySnappingSheet(this._buildSuggestions);

  @override
  _MySnappingSheetState createState() => _MySnappingSheetState();
}

class _MySnappingSheetState extends State<MySnappingSheet> {
  final _snappingSheetController = SnappingSheetController();
  final List<SnappingPosition> _snappingPositions = [
    SnappingPosition.factor(
        positionFactor: 0.0,
        snappingDuration: Duration(milliseconds: 1200),
        snappingCurve: Curves.elasticInOut,
        grabbingContentOffset: 1),
    SnappingPosition.factor(
        positionFactor: 0.2,
        snappingDuration: Duration(milliseconds: 1200),
        snappingCurve: Curves.elasticInOut,
        grabbingContentOffset: 0)
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthRepository>(
      builder: (context, authenticator, _) => SnappingSheet(
        child: widget._buildSuggestions(),
        controller: _snappingSheetController,
        snappingPositions: _snappingPositions,
        grabbingHeight: 75,
        grabbing: _buildGrabbing(authenticator),
        sheetBelow: _buildSheetBelow(authenticator),
      ),
    );
  }

  InkWell _buildGrabbing(AuthRepository authenticator) {
    return InkWell(
        child: Container(
          child: Row(
            children: [
              Text("Welcome back, ${authenticator.user!.email}"),
              Icon(Icons.keyboard_arrow_up),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
          color: Colors.grey,
          padding: const EdgeInsets.only(left: 16),
        ),
        onTap: () {
          setState(() {
            _snappingSheetController.currentSnappingPosition ==
                    _snappingPositions[0]
                ? _snappingSheetController
                    .snapToPosition(_snappingPositions[1])
                : _snappingSheetController
                    .snapToPosition(_snappingPositions[0]);
          });
        },
      );
  }

  SnappingSheetContent _buildSheetBelow(AuthRepository authenticator) {
    final ManageSavedSuggestions manager =
    Provider.of<ManageSavedSuggestions>(context);

    return SnappingSheetContent(
        sizeBehavior: SheetSizeStatic(size: 70),
        draggable: true,
        child: Container(
            child: Container(
              child: Row(
                children: [
                  CircleAvatar(radius: 35, backgroundImage: NetworkImage(manager.avatar_url)),
                  Column(children: [
                    Text(authenticator.user!.email!),
                    ElevatedButton(
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform.pickFiles();
                          if(result != null) {
                            String file_path = result.files.single.path!;
                            manager.uploadFile(file_path);
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                                content: Text(
                                    "No image selected"), backgroundColor: Colors.red));
                          }
                        },
                        child: Text("Change avater"))
                  ], mainAxisAlignment: MainAxisAlignment.center)
                ],
                mainAxisAlignment: MainAxisAlignment.start,
              ),
              padding: const EdgeInsets.only(left: 16),
              alignment: Alignment.topCenter,
            ),
            alignment: Alignment.topCenter,
            color: Colors.white),);
  }

}

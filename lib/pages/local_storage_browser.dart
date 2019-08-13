import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kodproject/custom/KBar.dart';
import 'package:kodproject/custom/pop.dart';
import 'package:kodproject/life/life_state.dart';
import '../file/file_utils.dart';
import 'package:path/path.dart';

class LocalStorageList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LocalStorageState();
  }
}

class LocalStorageState extends LifeState<LocalStorageList> {
  List<File> _files = [];
  List<File> _directorys = [];
  Directory _currentDirectory;

  @override
  void onStart() {
    super.onStart();
    _getFolderList();
  }

  _getFolderList() async {
    Directory directory = await getSdcardDirectory();

    if (directory != null) {
      var localFiles = directory.listSync();
      List<File> locaDirectory = [];
      localFiles.forEach((file) {
        FileSystemEntity.isDirectorySync(file.path);
        locaDirectory.add(file);
      });
      setState(() {
        _directorys = locaDirectory;
        _currentDirectory = directory;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var path = "";
    if (_currentDirectory != null) {
      path = _currentDirectory.path;
    }
    return Scaffold(
      appBar: KAppBar.getFilePathTreeBar(context, "选择文件存放目录",path),
      body: Center(
          child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[

          ListView.builder(
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return _FolderItem(_directorys[index]);
            },
            itemCount: _directorys.length,
          )
        ],
      )),
    );
  }
}

class _FolderItem extends StatelessWidget {
  const _FolderItem(this._item);

  final File _item;

  @override
  Widget build(BuildContext context) {
    var fileName = basename(_item.path);
    return InkWell(
        onTap: () {
//          Navigator.push(context, MaterialPageRoute(builder: (context) {
////            return ChildPage(childName: basename(_item.path), childPath: _item.path);
//          }));
        },
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(20),
                child: Icon(
                  Icons.folder,
                  color: Colors.blue[500],
                )),
            Expanded(
              child: Text(
                fileName,
                style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
            )
          ],
        ));
  }
}

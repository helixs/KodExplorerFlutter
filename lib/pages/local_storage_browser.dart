import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
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
  bool _reMax;
  ScrollController _controller = ScrollController();

  @override
  void onStart() {
    super.onStart();
    _getFolderList();
  }

  @override
  void everyFrame() {
    super.everyFrame();
    print("everyFrame1:${_controller.position.pixels}");
    print("everyFrame2:${_controller.position.maxScrollExtent}");
    if(_reMax&&_controller.position.pixels<_controller.position.maxScrollExtent){
       _controller.jumpTo(_controller.position.maxScrollExtent);
       _reMax = false;
    }
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

  List<Directory> getParentDirectory(
      List<Directory> directorys, Directory directory) {
    if (directorys == null) {
      directorys = [];
    }
    if (directory == null) {
      return directorys;
    }
    directorys.add(directory);
    if (directory.path == "/") {
      return directorys;
    }
    return getParentDirectory(directorys, directory.parent);
  }

  Widget _getListPaths(Directory currentDirectory) {
    List<Directory> directorys =
        getParentDirectory(null, currentDirectory).reversed.toList();
    _reMax = true;

    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(5.0),
        height: 40.0,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          controller: _controller,
          itemBuilder: (BuildContext context, int index) {
            return PathTreeItem(
              directorys[index],
              index == 0,
              onPathCallback: (directory) {
                Pop.showToast(context, directory.path);
              },
            );
          },
          itemCount: directorys.length,
        ));
  }

  @override
  Widget build(BuildContext context) {
    var path = "";
    if (_currentDirectory != null) {
      path = _currentDirectory.path;
    }
    var listPaths = _getListPaths(_currentDirectory);

    return Scaffold(
      appBar: KAppBar.getFilePathTreeBar(context, "选择文件存放目录", listPaths, path),
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

typedef PathClickCallBack = void Function(Directory directory);

class PathTreeItem extends StatelessWidget {
  final Directory _pathDirectory;
  final bool isStart;
  final PathClickCallBack onPathCallback;

  const PathTreeItem(this._pathDirectory, this.isStart, {this.onPathCallback});

  @override
  Widget build(BuildContext context) {
    var childs = <Widget>[];
    if (!isStart) {
      var icon = Icon(
        Icons.keyboard_arrow_right,
        color: Colors.white,
      );
      childs.add(icon);
    }
    var text = Text(
      basename(_pathDirectory.path),
      style: TextStyle(
          fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.w600),
    );
    childs.add(text);

    return InkWell(
      onTap: () {
        onPathCallback(_pathDirectory);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: childs,
      ),
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

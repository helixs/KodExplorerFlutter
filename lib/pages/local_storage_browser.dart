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
  List<Directory> _directorys = [];
  Directory _currentDirectory;
  Directory _mRootDirectory;
  bool _reMax;
  ScrollController _controller = ScrollController();

  @override
  void onStart() {
    super.onStart();
    _initFolder();
  }

  @override
  void everyFrame() {
    super.everyFrame();
    if (_reMax &&
        _controller.position.pixels < _controller.position.maxScrollExtent) {
      _controller.jumpTo(_controller.position.maxScrollExtent);
      _reMax = false;
    }
  }

  _initFolder() async {
    _mRootDirectory = await getSdcardRootDirectory();
    Directory appDirectory = await getAppStorageDirectory();

    _getCurrentFolderList(appDirectory);
  }

  _getCurrentFolderList(Directory directory) async {
    if (directory != null) {
      List<FileSystemEntity> localFiles = directory.listSync();
      List<Directory> locaDirectory = [];
      localFiles.forEach((file) {
        if (FileSystemEntity.isDirectorySync(file.path)) {
          locaDirectory.add(Directory(file.path));
        }
      });
      locaDirectory.sort((a,b){
        String aName = basename(a.path).toUpperCase();
        String bName = basename(b.path).toUpperCase();
        return aName.compareTo(bName);

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
    if (_mRootDirectory != null && _mRootDirectory.path == directory.path) {
      return directorys;
    }
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
                if (_currentDirectory.path != directory.path) {
                  _getCurrentFolderList(directory);
                }
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
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return _FolderItem(_directorys[index],onPathCallback: (directory)=>_getCurrentFolderList(directory) ,);
              },
              itemCount: _directorys.length,
            ),
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
      var text = Text(
        basename(_pathDirectory.path),
        style: TextStyle(
            fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.w600),
      );
      childs.add(text);
    }else{
      var icon = Icon(
        Icons.phone_android,
        color: Colors.white,
      );
      childs.add(icon);
    }

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
  const _FolderItem(this._item,{@required this.onPathCallback});

  final Directory _item;
  final PathClickCallBack onPathCallback;

  @override
  Widget build(BuildContext context) {
    var fileName = basename(_item.path);
    return InkWell(
        onTap: () {
          onPathCallback(_item);
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

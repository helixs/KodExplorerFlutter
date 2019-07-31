import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'custom/file_info_pop.dart';
import 'file/file_type_util.dart';
import 'model/file_path_res_entity.dart';
import 'network/net_work_catch.dart';
import 'pop.dart';
import 'package:kodproject/network/httpmanager.dart';

import 'life/life_state.dart';

class ChildPage extends StatefulWidget {
  final String childName;
  final String childPath;

  const ChildPage({Key key, @required this.childName, @required this.childPath})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChildPageState();
  }
}

class ChildPageState extends LifeState<ChildPage> {
  List<FilePathResFolderlist> _folderList = [];
  List<FilePathResFilelist> _fileList = [];

  @override
  void onStart() {
    super.onStart();
    requestNetWorkOfState(
        () async {
          return await KAPI.getFilePathList(widget.childPath);
        },
        this,
        successFun: (FilePathRes filePathRes) {
          setState(() {
            _folderList = filePathRes.folderList;
            _fileList = filePathRes.fileList;
          });
        },
        isShowLoading: true);
  }

//  _getFilePathData() async {
//    ;
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.childName),
      ),
      body: Center(
          child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
              child: ListView.builder(
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              if (index < _folderList.length) {
                return FolderItem(_folderList[index]);
              } else {
                return FileItem(_fileList[index - _folderList.length]);
              }
            },
            itemCount: _folderList.length + _fileList.length,
          ))
        ],
      )),
    );
  }
}

class FolderItem extends StatelessWidget {
  const FolderItem(this._item);

  final FilePathResFolderlist _item;

  @override
  Widget build(BuildContext context) {

    return InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ChildPage(childName: _item.name, childPath: _item.path);
          }));
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
                _item.name,
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

class FileItem extends StatefulWidget {
  const FileItem(this._item);

  final FilePathResFilelist _item;

  @override
  State<StatefulWidget> createState() {
    return FileItemState();
  }
}

class FileItemState extends LifeState<FileItem> {
  _getFileInfo(String path) async {
    var currentItem = {"type": "file", "path": path};
    var dataArr = [currentItem];
    return await KAPI.getFilePathInfo(dataArr);
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    FileType type =FileTypeUtil.getFileType(widget._item.ext);
    IconData iconData =FileTypeUtil.getIconData(type);
    return InkWell(
        onLongPress: () {
          requestNetWorkOfState(
              () async {
                return await _getFileInfo(widget._item.path);
              },
              this,
              successFun: (fileInfo) {
                _launchURL(fileInfo.downloadPath);
              },
              isShowLoading: true);
        },
        onTap: () {
          requestNetWorkOfState(
              () async {
                return await _getFileInfo(widget._item.path);
              },
              this,
              successFun: (fileInfo) {
                _launchURL(fileInfo.downloadPath);
                FileInfoPop.showFileInfoDialog(context, fileInfo);
              },
              isShowLoading: true);
        },
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(20),
                child: Icon(
                  iconData,
                  color: Colors.blue[500],
                )),
            Expanded(
              child: Text(
                widget._item.name,
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

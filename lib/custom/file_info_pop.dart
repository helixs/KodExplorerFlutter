import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:kodproject/life/life_state.dart';
import 'package:kodproject/model/file_path_info_entity.dart';
import 'package:flutter/services.dart';
import 'package:kodproject/pages/local_storage_browser.dart';
import 'package:kodproject/storage/KData.dart';
import '../custom/Buttons.dart';
import '../tools/permission_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kodproject/custom/pop.dart';

//文件详细信息弹窗
class FileInfoPop {
  static const int OPEN_LOCAL = 1;
  static const int DOWNLOAD = 2;
  static show(BuildContext context, FilePathInfoRes filePathInfoRes) async {
    return await showDialog(
        context: context,
        builder: (context) => Dialog(
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: _FileInfoWidget.create(filePathInfoRes)),
            ));
  }
}

class _FileInfoWidget extends StatelessWidget {
  final List<FileKVInfo> _items;

  _FileInfoWidget.create(FilePathInfoRes _filePathInfo)
      : _items = _filePathInfo.toItemDesc();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text("文件信息"),
        ListView.builder(
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return _FileInfoItem(_items[index]);
            },
            itemCount: _items.length),
        Row(
          children: <Widget>[
            Expanded(
              child: Buttons.getGeneralRaisedButton("外部在线打开", onPressed: () {
                Navigator.pop(context, FileInfoPop.OPEN_LOCAL);
              }),
            ),
            Expanded(
              child: Buttons.getGeneralRaisedButton("下载", onPressed: () {
                Navigator.pop(context, FileInfoPop.DOWNLOAD);
              }),
            )

          ],
        )
      ],
    );
  }
}

class _FileInfoItem extends StatelessWidget {
  final FileKVInfo _kvInfo;

  _FileInfoItem(this._kvInfo, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var downloadPress;
    if (_kvInfo.isDownloadUrl) {
      downloadPress = () {
        Clipboard.setData(new ClipboardData(text: _kvInfo.value));
        Pop.showToast(context, "链接已经复制到剪贴板");
      };
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Expanded(
          child: Container(
            margin: EdgeInsets.all(5),
            child: Text(_kvInfo.key, textAlign: TextAlign.right),
          ),
          flex: 1,
        ),
        Expanded(
          child: Container(
              margin: EdgeInsets.all(5),
              child: InkWell(
                  onLongPress: downloadPress,
                  child: Text(_kvInfo.value,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 5,
                      textAlign: TextAlign.left))),
          flex: 3,
        ),
      ],
    );
  }
}

class DownloadFilePrepareDialog {
  static show(BuildContext context, FilePathInfoRes filePathInfoRes) {
    showDialog(
        context: context,
        builder: (context) => Dialog(
                child: Padding(
              padding: EdgeInsets.all(10),
              child: _DownloadInfoWidget(
                  filePathInfoRes.downloadPath, filePathInfoRes.name),
            )));
  }
}

class _DownloadInfoWidget extends StatefulWidget {
  final String _downloadUrl;
  final String _fileName;

  const _DownloadInfoWidget(this._downloadUrl, this._fileName);

  @override
  State<StatefulWidget> createState() {
    return _DownloadPathState();
  }
}

class _DownloadPathState extends LifeState<_DownloadInfoWidget> {
  //下载地址
  final TextEditingController _addressController = new TextEditingController();

  //文件名称
  final TextEditingController _fileNameController = new TextEditingController();

  //下载目录
  final TextEditingController _localPathController =
      new TextEditingController();

  @override
  void initState() {
    super.initState();
    initDownload();
  }

  initDownload() async {
    String downloadPath = await KStorage.getDefaultDownloadPath();
    if (downloadPath != null && downloadPath != "") {
      _localPathController.text = downloadPath;
    }
  }

  openLocalStorageList() async {
    bool checked = await checkLocalPermission(PermissionGroup.storage);
    if (checked) {
      var directory =
          await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return LocalStorageList(_localPathController.text);
      }));
      if (directory != null && directory is Directory) {
        _localPathController.text = directory.path;
        KStorage.setDefaultDownloadPath(directory.path);
      }
    } else {
      openAppSetting();
    }
  }

  download()async{
    var ss = await FlutterDownloader.enqueue(url: _addressController.text,savedDir:_localPathController.text);

    Pop.showToast(context, ss.toString());
  }

  @override
  Widget build(BuildContext context) {
    _addressController.text = widget._downloadUrl;
    _fileNameController.text = widget._fileName;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "新任务",
          style: TextStyle(fontSize: 16.0, color: Colors.blue),
        ),
        TextField(
          //自动对焦
          autofocus: true,
          //外观
          decoration: InputDecoration(
            labelText: "下载地址",
            contentPadding: EdgeInsets.all(10),
            hintText: "请输入要下载的地址",
          ),
          controller: _addressController,
        ),
        TextFormField(
            //自动对焦
            autofocus: true,
            //外观
            decoration: InputDecoration(
              labelText: "文件名称",
              contentPadding: EdgeInsets.all(10),
              hintText: "如果不填为默认名称",
            ),
            controller: _fileNameController),
        InkWell(
          onTap: openLocalStorageList,
          child: TextField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            //自动对焦
            enabled: false,
            autofocus: true,
            //外观
            decoration: InputDecoration(
              labelText: "添加下载目录",
              contentPadding: EdgeInsets.all(10),
              hintText: "添加下载目录",
            ),
            controller: _localPathController,
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Buttons.getGeneralRaisedButton("下载",
                  onPressed:download),
            )
          ],
        )
      ],
    );
  }
}

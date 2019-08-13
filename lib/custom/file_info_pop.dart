import 'package:flutter/material.dart';
import 'package:kodproject/model/file_path_info_entity.dart';
import 'package:flutter/services.dart';
import 'package:kodproject/pages/local_storage_browser.dart';
import '../custom/Buttons.dart';
import '../tools/permission_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kodproject/custom/pop.dart';

//文件详细信息弹窗
class FileInfoPop {
  static showFileInfoDialog(
      BuildContext context, FilePathInfoRes filePathInfoRes) {
    showDialog(
        context: context,
        builder: (context) => Dialog(
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: _FileInfoWidget(filePathInfoRes.toItemDesc())),
            ));
  }
}

class _FileInfoWidget extends StatelessWidget {
//  final FilePathInfoRes _filePathInfo;
  final List<FileKVInfo> _items;

  const _FileInfoWidget(this._items, {Key key}) : super(key: key);

//  _items = this._filePathInfo.toItemDesc();
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
              child: Buttons.getGeneralRaisedButton("下载", onPressed: () async {

                    bool checked=await checkLocalPermission(PermissionGroup.storage);
                    if(checked){
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                            return LocalStorageList();
                          }));
                    }else{
                      openAppSetting();
                    }
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

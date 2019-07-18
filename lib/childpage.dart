import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'model/file_path_res_entity.dart';
import 'pop.dart';
import 'httpmanager.dart';

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
  List<FilePathResFolderlist> _fileFolderList = [];
  @override
  void onStart() {
    super.onStart();
    _getFilePathData();
  }
  void _getFilePathData() async{
    Pop.showLoading(context);
    try {
      FilePathRes filePathRes = await KAPI.getFilePathList(widget.childPath);
      _fileFolderList = filePathRes.folderList;
    }catch(e){
      Pop.showToast(context, e.message);
    }finally{
      Pop.dissLoading(context);
    }
  }
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
          ListView.builder(
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
                  return FolderItem(_fileFolderList[index]);
            },
//                itemCount: _fileList.length,
          )
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
    return ListTile(
      title: Text(_item.name,style:TextStyle(color:Colors.black,fontWeight: FontWeight.w600) ,),
      leading: new Icon(

        Icons.folder,
        color: Colors.blue[500],
      ),
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ChildPage(childName: _item.name,childPath:_item.path);
        }));
      },
    );
  }
}

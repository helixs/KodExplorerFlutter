import 'package:flutter/material.dart';
import 'package:kodproject/pop.dart';
import 'package:toast/toast.dart';
import 'childpage.dart';
import 'custom/KBar.dart';
import 'package:kodproject/network/httpmanager.dart';
import 'life/life_state.dart';
import 'model/file_tree_res_entity.dart';

class HomePage extends StatefulWidget {
  final String title = "主页";

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends LifeState<HomePage>  {
  List<FileTreeResData> _fileList = [];

  void getFiles() async {
    Pop.showLoading(context);
    try {
      var treeList = await KAPI.getFileTree();
      setState(() {
        _fileList = treeList;
      });
    } catch (e) {
      Toast.show(e.message, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } finally {
      Pop.dissLoading(context);
    }
  }

  @override
  void onStart() {
    super.onStart();
    getFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KAppBar.getSettingBar(context,widget.title),
      body: Center(
          child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          ListView.builder(
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return FileItem(_fileList[index]);
              },
              itemCount: _fileList.length,
             )
        ],
      )),
    );
  }
}

class FileItem extends StatelessWidget {
  const FileItem(this._item);

  final FileTreeResData _item;

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

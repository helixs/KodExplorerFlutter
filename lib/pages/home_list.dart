import 'package:flutter/material.dart';
import 'package:kodproject/account/account_util.dart';
import 'package:kodproject/custom/pop.dart';
import 'package:kodproject/pages/childpage.dart';
import '../custom/KBar.dart';
import 'package:kodproject/network/httpmanager.dart';
import '../life/life_state.dart';
import '../model/file_tree_res_entity.dart';
import '../network/net_work_catch.dart';
import 'download_list.dart';

class HomePage extends StatefulWidget {
  final String title = "主页";

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

enum HomeBody{
  //文件管理
  FILES,
  //下载管理
  DOWNLOADS,
  //设置
  SETTING


}

class _HomePageState extends LifeState<HomePage> {
  List<FileTreeResData> _fileList = [];


  @override
  void onStart() {
    super.onStart();
    requestNetWorkOfState(KAPI.getFileTree, this, successFun: (treeList) {
      setState(() {
        _fileList = treeList;
      });
    }, isShowLoading: true);
  }

  get _drawer => Drawer(
          child: ListView(
        padding: EdgeInsets.all(0),
        children: <Widget>[
          _accountHeader, // 可在这里替换自定义的header
          ListTile(
            title: Text('下载管理'),
            leading: new CircleAvatar(
              child: new Icon(Icons.school),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return DownloadManagerListPage();
              }));
            },
          ),
          ListTile(
            title: Text('设置'),
            leading: new CircleAvatar(
              child: new Icon(Icons.settings,semanticLabel: "111",),
            ),
            onTap: () {
//                Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('退出账号'),
            leading: new CircleAvatar(
              child: new Icon(Icons.exit_to_app),
            ),
            onTap: () {
              AccountUtil.logout(context);
            },
          ),
        ],
      ));

  get _accountHeader => UserAccountsDrawerHeader(
        accountName: Text("helloworld"),
        accountEmail: Text("xxx@gmail.com"),
        currentAccountPicture: CircleAvatar(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KAppBar.getDefaultBar(context, widget.title),
      drawer: _drawer,
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
      title: Text(
        _item.name,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
      ),
      leading: new Icon(
        Icons.folder,
        color: Colors.blue[500],
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ChildPage(childName: _item.name, childPath: _item.path);
        }));
      },
    );
  }
}

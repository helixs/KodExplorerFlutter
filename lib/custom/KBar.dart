import 'package:flutter/material.dart';

import 'package:kodproject/pages/setting.dart';

class KAppBar{
  static AppBar getSettingBar(BuildContext buildContext,String titleName,{VoidCallback settingPress}){
    if(settingPress==null&&buildContext!=null){
      settingPress = (){
        Navigator.push(buildContext, MaterialPageRoute(builder: (context){
          return SettingPage();
        }));
      };
    }
    return AppBar(
      title: Text(titleName),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.settings,color: Colors.white,),
          onPressed: settingPress,
        )
      ],
    );
  }
  static AppBar getFilePathTreeBar(BuildContext buildContext,String titleName,Widget widget,String path,{VoidCallback confirm}){

    return AppBar(
      title: Text(titleName),
      actions: <Widget>[
        IconButton(icon: Icon(Icons.check,color: Colors.white,), onPressed: confirm),
        IconButton(icon: Icon(Icons.clear,color: Colors.white,), onPressed: ()=>Navigator.of(buildContext).pop())
      ],
      bottom:PreferredSize(child: widget, preferredSize: Size.fromHeight(40.0)) ,
    );
  }
}


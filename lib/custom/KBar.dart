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
  static AppBar getFilePathTreeBar(BuildContext buildContext,String titleName,Widget widget,String path,{VoidCallback settingPress}){

    return AppBar(
      title: Text(titleName),
      actions: <Widget>[
        Text("确定")
      ],
      bottom:PreferredSize(child: widget, preferredSize: Size.fromHeight(40.0)) ,
    );
  }
}


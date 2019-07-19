import 'package:flutter/material.dart';

import '../setting.dart';

class KAppBar{
  final String titleName;

  KAppBar(this.titleName);
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
}


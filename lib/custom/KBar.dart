import 'package:flutter/material.dart';

class KAppBar{
  final String titleName;

  KAppBar(this.titleName);
  static AppBar getSettingBar(String titleName,{VoidCallback settingPress,BuildContext buildContext}){
    if(settingPress==null&&buildContext!=null){
      settingPress = (){
        //setting
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


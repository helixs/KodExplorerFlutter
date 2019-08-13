import 'package:flutter/material.dart';

import '../custom/KBar.dart';
import 'package:kodproject/pages/loginpage.dart';

class SettingPage extends StatelessWidget {
  _logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) {
      return LoginPage();
    }), (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KAppBar.getSettingBar(context, "设置"),
      body: Center(
          child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              //展开
              Expanded(
                child: RaisedButton(
                  color: Colors.blue,
                  padding: EdgeInsets.all(15.0),
                  highlightColor: Colors.blue[700],
                  colorBrightness: Brightness.dark,
                  child: Text("退出"),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  onPressed:(){ _logout(context);},
                ),
              )
            ],
          )
        ],
      )),
    );
  }
}

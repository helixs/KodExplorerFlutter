import 'package:flutter/material.dart';

class Buttons{
  static RaisedButton getGeneralRaisedButton(String text, {VoidCallback onPressed}) {
    return RaisedButton(
      color: Colors.blue,
      padding: EdgeInsets.all(15.0),
      highlightColor: Colors.blue[700],
      colorBrightness: Brightness.dark,
      splashColor: Colors.grey,
      child: Text(text),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      onPressed: onPressed,
    );
  }

}

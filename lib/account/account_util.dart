import 'package:flutter/material.dart';
import 'package:kodproject/pages/loginpage.dart';
class AccountUtil{
  static logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) {
          return LoginPage();
        }), (Route<dynamic> route) => false);
  }
}
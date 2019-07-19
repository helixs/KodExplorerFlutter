import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'home_list.dart';
import 'package:kodproject/network/httpmanager.dart';
import 'KData.dart';
import 'pop.dart';
import 'package:toast/toast.dart';

//
//可道云登录
//by xmcf
//
class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //地址
  TextEditingController _addressController = new TextEditingController();

  //用户名
  TextEditingController _usernameController = new TextEditingController();

  //密码
  TextEditingController _passwdController = new TextEditingController();

  GlobalKey _formKey = new GlobalKey<FormState>();
  String errorMsg = "";

  void _validationUserInfo() async {
    String address = _addressController.text;
    String username = _usernameController.text;
    String passwd = _passwdController.text;
    Pop.showLoading(context);
    await KStorage.setAddress(address);
    try {
      String token =(await KAPI.login(username, passwd));
      await KStorage.setToken(token);
      Pop.dissLoading(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
        return HomePage();
      }));
    } catch(e){
      Toast.show(e.message,context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
      Pop.dissLoading(context);
    }finally{

    }
  }
  @override
  void initState() {
    KStorage.getKodAddress().then((address){
      _addressController.text = address??"";
    });
    KStorage.setToken("");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("登录"),
      ),
      body: Center(
          child: Form(
        key: _formKey, //设置globalKey，用于后面获取FormState
        autovalidate: true, //开启自动校验
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
                //自动对焦
                autofocus: true,
                //外观
                decoration: InputDecoration(
                    labelText: "kod地址",
                    contentPadding: EdgeInsets.all(10),
                    hintText: "https://192.168.0.1/kod",
                    prefix: Icon(Icons.airplanemode_active)),
                controller: _addressController,
                validator: (v) {
                  return v.trim().length > 0 ? null : "地址不能为空";
                }),
            TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                    labelText: "用户名",
                    contentPadding: EdgeInsets.all(10),
                    hintText: "用户名或邮箱",
                    prefix: Icon(Icons.person)),
                controller: _usernameController,
                validator: (v) {
                  return v.trim().length > 0 ? null : "用户名不能为空";
                }),
            TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                    labelText: "密码",
                    contentPadding: EdgeInsets.all(10),
                    hintText: "您的登录密码",
                    prefix: Icon(Icons.lock)),
                obscureText: true,
                controller: _passwdController,
                validator: (v) {
                  return v.trim().length > 5 ? null : "密码不能少于6位";
                }),
            Padding(
                padding: const EdgeInsets.only(top: 28.0),
                child: Row(
                  children: <Widget>[
                    //展开
                    Expanded(
                      child: RaisedButton(
                        color: Colors.blue,
                        padding: EdgeInsets.all(15.0),
                        highlightColor: Colors.blue[700],
                        colorBrightness: Brightness.dark,
                        splashColor: Colors.grey,
                        child: Text("登录"),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        onPressed: () {
                          if ((_formKey.currentState as FormState).validate()) {
                            //验证通过提交数据
                            _validationUserInfo();
                          }
                        },
                      ),
                    )
                  ],
                ))
          ],
        ),
      )),
    );
  }
}

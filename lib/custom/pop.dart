import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Pop {
  static bool isShowLoding = false;
  static BuildContext _showContext;

  static snackShow(BuildContext context, String msg) {
    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text(msg),
    ));
  }

  static showToast(BuildContext context, String msg) {
    Toast.show(msg, context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  static showDialogMsg(BuildContext context, String msg) {
    showDialog(
        // 设置点击 dialog 外部不取消 dialog，默认能够取消
        barrierDismissible: true,
        context: context,
        builder: (context) => AlertDialog(
              title: Text('提示'),
              titleTextStyle: TextStyle(color: Colors.purple),
              // 标题文字样式
              content: Text(msg),
              contentTextStyle: TextStyle(color: Colors.green),
              // 内容文字样式
              elevation: 8.0,
              // 投影的阴影高度
              semanticLabel: 'Label',
              // 这个用于无障碍下弹出 dialog 的提示
              shape: Border.all(),
              // dialog 的操作按钮，actions 的个数尽量控制不要过多，否则会溢出 `Overflow`
//          actions: <Widget>[
              // 点击增加显示的值
//            FlatButton(onPressed: increase, child: Text('点我增加')),
              // 点击减少显示的值
//            FlatButton(onPressed: decrease, child: Text('点我减少')),
              // 点击关闭 dialog，需要通过 Navigator 进行操作
//            FlatButton(onPressed: () => Navigator.pop(context),
//                child: Text('你点我试试.')),
//          ],
            ));
  }

  static showLoading(BuildContext context) {
    if (isShowLoding) {
      return;
    }
    if (_showContext != null) {
      return;
    }
    isShowLoding = true;
    _showContext = context;
    showDialog(
        // 设置点击 dialog 外部不取消 dialog，默认能够取消
        barrierDismissible: false,
        context: context,
        builder: (context) => Dialog(
            backgroundColor: Colors.white,
            child: Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(10),
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(),
                  ),
                  Container(
                    child: Text("内容加载中"),
                  )
                ],
              ),
            ))).then((result) {
      isShowLoding = false;
      _showContext = null;
    });
  }

  static void dissLoading(BuildContext context) {
    if (_showContext == null || _showContext != context) {
      _showContext = null;
      return;
    }

    if (isShowLoding) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    isShowLoding = false;
  }

  static showWebDialog(BuildContext context, String url) {
    if (isShowLoding) {
      return;
    }
    isShowLoding = true;

    showDialog(
        // 设置点击 dialog 外部不取消 dialog，默认能够取消
        barrierDismissible: false,
        context: context,
        builder: (context) => Dialog(
            backgroundColor: Colors.white,
            child: Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Text("错误信息加载中"),
                  ),
                  Container(
                      height: 500,
                      child: WebView(
                        initialUrl: url,
                        javascriptMode: JavascriptMode.unrestricted,
                      ))
                ],
              ),
            ))).then((result) {
      isShowLoding = false;
    });
  }
}

import 'dart:io';
import 'dart:core';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kodproject/model/file_path_info_entity.dart';
import 'package:kodproject/tools/Log.dart';
import 'package:kodproject/storage/KData.dart';
import 'package:kodproject/model/res_model.dart';
import 'package:kodproject/model/file_tree_res_entity.dart';
import 'package:kodproject/model/file_path_res_entity.dart';

class _KHttpManager {
  // 工厂模式
  factory _KHttpManager() => _getInstance();

  static _KHttpManager get instance => _getInstance();
  static _KHttpManager _instance;
  Dio dio;

  _KHttpManager._internal() {
    dio = new Dio();
    // 配置dio实例
    dio.options.connectTimeout = 30000; //5s
    dio.options.receiveTimeout = 10000;
    dio.interceptors
      ..add(InterceptorsWrapper(onRequest: (RequestOptions options) {
        options.baseUrl = GlobalData.instance.kodAddress;
        options.headers["accept-language"] = "accept-language: zh-CN,zh;q=0.9";
        options.queryParameters["HTTP_X_PLATFORM"]  = Platform.operatingSystem;
        if (GlobalData.instance.userToken != null &&
            GlobalData.instance.userToken.isNotEmpty) {
          options.queryParameters["accessToken"] =
              GlobalData.instance.userToken;
        }

      }))
      ..add(KInterceptor.getLogInterceptor());
  }

  static _KHttpManager _getInstance() {
    if (_instance == null) {
      _instance = new _KHttpManager._internal();
    }
    return _instance;
  }

  static get<T>(String path,
      {Map<String, dynamic> queryMap, Options options}) async {
    return await _KHttpManager.instance.request<T>(
        path, _checkOptions("GET", options)..queryParameters = queryMap);
  }

  static post<T>(String path,
      {Map queryMap, dynamic data, Options options}) async {
    return await _KHttpManager.instance.request(
        path,
        _checkOptions("POST", options)
          ..queryParameters = queryMap
          ..data = data);
  }

  static postFormUrlencoded<T>(String path,
      {Map queryMap, dynamic data, Options options,BuildContext context}) async {
    if(options==null){
      options =RequestOptions();
    }
//    options.headers[HttpHeaders.contentTypeHeader] = "application/x-www-form-urlencoded";
    options.contentType = ContentType.parse("application/x-www-form-urlencoded");
    return await post<T>(path,
        queryMap: queryMap, data: data, options: options);
  }

  request<T>(path, Options option, {body}) async {
    Response response;
    try {
      response = await dio.request(path, data: body, options: option);
      if (response.data is Map) {
        BaseRes result = BaseRes.fromJson(response.data);
        if (result.code) {
          return result.data;
        } else {
          throw KCodeException(result.data as String);
        }
      } else {
        throw KCodeException("返回信息格式有误");
      }
    } on DioError catch (e) {
      switch (e.type) {
        case DioErrorType.CONNECT_TIMEOUT:
          throw KNetException(NetCodeMsg.CONNECT_TIMEOUT);
          break;
        case DioErrorType.SEND_TIMEOUT:
          throw KNetException(NetCodeMsg.SEND_TIMEOUT);
          break;
        case DioErrorType.RECEIVE_TIMEOUT:
          throw KNetException(NetCodeMsg.RECEIVE_TIMEOUT);
          break;
        case DioErrorType.RESPONSE:
          throw KNetException(NetCodeMsg.CONNECT_TIMEOUT + "\n" + e.message);
          break;
        case DioErrorType.CANCEL:
          throw KNetException("请求取消");
          break;
        case DioErrorType.DEFAULT:
          throw KNetException("其他错误" + "\n" + e.message);
          break;
      }
    }
  }
}

RequestOptions _checkOptions(method, options) {
  if (options == null) {
    options = new RequestOptions();
  }
  options.method = method;
  return options;
}

abstract class KException implements Exception {
  final String message;

  KException(this.message);
}

class KCodeException extends KException {
  KCodeException(String message) : super(message);
}

class KNetException extends KException {
  KNetException(String message) : super(message);
}

class NetCodeMsg {
  static const CONNECT_TIMEOUT = "连接服务器超时";
  static const SEND_TIMEOUT = "请求发送数据超时";
  static const RECEIVE_TIMEOUT = "服务器返回数据超时";
  static const RESPONSE = "服务器出错";
  static const CANCEL = "取消操作";
}

class KInterceptor {
  static InterceptorsWrapper getLogInterceptor() {
    return InterceptorsWrapper(onRequest: (RequestOptions options) {
      Log.v("\n================== 请求数据 ==========================");
      Log.v("url = ${options.uri.toString()}");
      Log.v("headers = ${options.headers}");
      Log.v("contentType = ${options.contentType}");
      Log.v("params = ${options.data}");
    }, onResponse: (Response response) {
      Log.v("\n================== 响应数据 ==========================");
      Log.v("code = ${response.statusCode}");
      Log.v("data = ${response.data}");
      Log.v("\n");
    }, onError: (DioError e) {
      Log.v("\n================== 错误响应数据 ======================");
      Log.v("type = ${e.type}");
      Log.v("message = ${e.message}");
      Log.v("stackTrace = ${e.stackTrace}");
      Log.v("stackTrace = ${e.request.uri.toString()}");
      Log.v("\n");
    });
  }
}

class KAPI {
  //登录
  static Future<String> login(String username, String password,{BuildContext context}) async {

    var result = await _KHttpManager.get<String>("/?user/loginSubmit",
        queryMap: {
          "isAjax": "1",
          "getToken": "1",
          "name": username,
          "password": password
        });
    return result as String;
  }

  //获取初始文件目录树
  static Future<List<FileTreeResData>> getFileTree() async {
    var result = await _KHttpManager.get<List<FileTreeResData>>(
        "/?explorer/treeList",
        queryMap: {
          "app": "explorer",
          "type": "init",
        });
    var items = new List<FileTreeResData>();
    (result as List).forEach((v) {
      items.add(new FileTreeResData.fromJson(v));
    });
    return items;
  }

  //根据文件路径获取文件列表
  static Future<FilePathRes> getFilePathList(String path) async {
    var result =
        await _KHttpManager.get<FilePathRes>("/?explorer/pathList", queryMap: {
      "path": path,
      "app": "explorer",
    });
    return FilePathRes.fromJson(result);
  }

  //根据 文件夹/文件 获取其信息
  static Future<FilePathInfoRes> getFilePathInfo(
      dataArr,{BuildContext context}) async {
//    var map = Map<String, List<Map<String, String>>>();

//    map["dataArr"] = dataArr;
//    print();
//    print(Uri.encodeQueryComponent(json.encode(map)));
    String encodeQuery = "dataArr=${Uri.encodeQueryComponent(json.encode(dataArr))}";
//    print(encodeQuery);
    var result = await _KHttpManager.postFormUrlencoded<FilePathInfoRes>(
        "/?explorer/pathInfo",
        data:  encodeQuery);

    return FilePathInfoRes.fromJson(result);
  }
}

class KAPICallback {}

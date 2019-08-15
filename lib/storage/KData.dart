import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:common_utils/common_utils.dart';

class GlobalData {
  String userToken;
  String kodAddress;

  // 工厂模式
  factory GlobalData() => _getInstance();

  static GlobalData get instance => _getInstance();
  static GlobalData _instance;

  GlobalData._internal() {
    LogUtil.init(isDebug:true,tag:"kod_logger");
  }

  static init() async {
    if (_instance == null) {
      _instance = new GlobalData._internal();
    }
    _instance.userToken = await KStorage.getToken();
    _instance.kodAddress = await KStorage.getKodAddress();
  }

  static GlobalData _getInstance() {
    if (_instance == null) {
      _instance = GlobalData._internal();
    }
    return _instance;
  }
}

class KStorage {
  static const String _TOKEN = "accessToken";
  static const String _KOD_ADDRESS = "kodAddress";
  static const String _KOD_DWONLOAD_PATH = "download_path";

  static getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = (prefs.getString(_TOKEN));
    return accessToken;
  }
  static setToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_TOKEN,token);
    GlobalData.instance.userToken = token;
  }
  static Future<String> getKodAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = (prefs.getString(_KOD_ADDRESS));
    return accessToken;
  }
  static setAddress(String address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_KOD_ADDRESS,address);
    GlobalData.instance.kodAddress = address;
  }
  static Future<String> getDefaultDownloadPath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = (prefs.getString(_KOD_DWONLOAD_PATH));
    return accessToken;
  }
  static setDefaultDownloadPath(String address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_KOD_DWONLOAD_PATH,address);
  }
}

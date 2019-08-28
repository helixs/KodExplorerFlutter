import 'dart:io';

import 'package:flutter/material.dart';
import '../plugin/file_path_provider.dart';

Future<Directory> getSdcardRootDirectory() async{
  if(Platform.isAndroid){
    return  await getExternalStorageDirectory();
  }
  return null;
}
Future<Directory> getAppStorageDirectory() async{
  if(Platform.isAndroid){
    return  await getStorageDirectory();
  }
  return null;

}

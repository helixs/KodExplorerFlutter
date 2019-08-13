import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

Future<Directory> getSdcardDirectory() async{
  if(Platform.isAndroid){
    return  await getExternalStorageDirectory();
  }
  return null;
}
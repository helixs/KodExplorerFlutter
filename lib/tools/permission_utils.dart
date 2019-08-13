import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:io';

Future<bool> checkLocalPermission(PermissionGroup permissionGroup) async {
  if (Platform.isAndroid) {
    PermissionStatus status = await PermissionHandler()
        .checkPermissionStatus(permissionGroup);
    switch (status) {
      case PermissionStatus.granted:
        //同意
        return true;
      case PermissionStatus.denied:
        //
       return  await requestPermission(permissionGroup);
      case PermissionStatus.disabled:

        return await requestPermission(permissionGroup);
    }
  }
  return false;
}


Future<bool> requestPermission(PermissionGroup permissionGroup) async{
  Map<PermissionGroup, PermissionStatus> permissionStatuses = await PermissionHandler()
      .requestPermissions([permissionGroup]);
  return permissionStatuses[permissionGroup] ==
      PermissionStatus.granted;
}

Future<bool> openAppSetting() async{
  return await PermissionHandler().openAppSettings();
}
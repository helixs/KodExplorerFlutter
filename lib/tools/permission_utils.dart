import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:io';

Future<bool> checkLocalPermission(Permission permission) async {
  if (Platform.isAndroid) {
    PermissionStatus status = await Permission.storage.status;
    switch (status) {
      case PermissionStatus.granted:
        //同意
        return true;
      case PermissionStatus.denied:
        //
        return await requestPermission(permission);
      default:
        return false;
    }
  }
  return false;
}

Future<bool> requestPermission(Permission permission) async {
  PermissionStatus permissionStatuses =
      await permission.request();
  return permissionStatuses == PermissionStatus.granted;
}


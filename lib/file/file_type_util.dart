import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:core';
import 'dart:convert';
import 'package:kodproject/tools/string_util.dart';

enum FileType { NONE, VIDEO, DOCUMENT, MUSIC, IMG }

class FileTypeUtil {
  static FileType getFileType(String ext) {
    if (StringUtil.isEmpty(ext)) {
      return FileType.NONE;
    }
    Iterator<String> iterator = documents.iterator;
    while (iterator.moveNext()) {
      if (iterator.current == ext) {
        return FileType.DOCUMENT;
      }
    }
    iterator = videos.iterator;
    while (iterator.moveNext()) {
      if (iterator.current == ext) {
        return FileType.VIDEO;
      }
    }
    iterator = musics.iterator;
    while (iterator.moveNext()) {
      if (iterator.current == ext) {
        return FileType.MUSIC;
      }
    }
    iterator = musics.iterator;
    while (iterator.moveNext()) {
      if (iterator.current == ext) {
        return FileType.IMG;
      }
    }
    return FileType.NONE;
  }

  static IconData getIconData(FileType fileType) {
    switch(fileType){
      case FileType.NONE:
        return Icons.book;
      case FileType.MUSIC:
        return Icons.music_note;
      case FileType.IMG:
        return Icons.image;
      case FileType.DOCUMENT:
        return Icons.content_paste;
      case FileType.VIDEO:
        return Icons.video_library;
    }
  }
}

List<String> documents = [
  "txt",
  "doc",
  "docx",
  "xls",
  "htm",
  "html",
  "jsp",
  "rtf",
  "wpd",
  "pdf",
  "ppt"
];
List<String> videos = [
  "mp4",
  "avi",
  "mov",
  "wmv",
  "asf",
  "navi",
  "3gp",
  "mkv",
  "f4v",
  "rmvb",
  "webm"
];
List<String> musics = [
  "mp3",
  "wma",
  "wav",
  "mod",
  "ra",
  "cd",
  "md",
  "asf",
  "aac",
  "vqf",
  "ape",
  "mid",
  "ogg"
];
List<String> imgs = [
  "bmp",
  "jpg",
  "jpeg",
  "png",
  "tiff",
  "gif",
  "pcx",
  "tga",
  "exif",
  "fpx",
  "svg",
  "psd",
  "cdr",
  "pcd",
  "dxf",
  "ufo",
  "eps",
  "ai",
  "raw",
  "wmf"
];

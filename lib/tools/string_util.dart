import 'dart:core';

class StringUtil {
  static bool isEmpty(String msg) {
    if (msg == null) {
      return true;
    }
    if (msg == "") {
      return true;
    }
    return false;
  }
}

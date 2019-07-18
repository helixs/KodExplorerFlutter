/**
 * @Author: thl
 * @GitHub: https://github.com/Sky24n
 * @Description: Widget Util.
 * @Date: 2018/9/29
 */

/// Log Util.
class Log {
  static const String _TAG_DEF = "kod_log";
  static const int MAX_LENGTH =1000;

  static bool debuggable = true; //是否是debug模式,true: log v 不输出.
  static String TAG = _TAG_DEF;

  static void init({bool isDebug = false, String tag = _TAG_DEF}) {
    debuggable = isDebug;
    TAG = tag;
  }

  static void e(Object object, {String tag}) {
    _printLog(tag, '  e  ', object);
  }

  static void v(Object object, {String tag}) {
    if (debuggable) {
      _printLog(tag, '  v  ', object);
    }
  }

  static void _printLog(String tag, String stag, Object object) {
    StringBuffer sb = new StringBuffer();
    sb.write((tag == null || tag.isEmpty) ? TAG : tag);
    sb.write(stag);
    sb.write(object);
    String log = sb.toString();
    int allLength = log.length;
    int currentLength = 0;
    do {
      if (currentLength >= allLength) {
        break;
      }
      if (allLength - currentLength <= MAX_LENGTH) {
        print(log.substring(currentLength, allLength));
        break;
      }
      if (allLength - currentLength > MAX_LENGTH) {
        int newCurrent = currentLength + MAX_LENGTH;
        print(log.substring(currentLength, newCurrent));
        currentLength = newCurrent;
      }
    } while (true);
  }
}

class CalcSize {
  static const KB = 1024;
  static const MB = 1024 * 1024;
  static const GB = 1024 * 1024 * 1024;

  static String getSizeToString(int size,bool hasUnit) {
    if (size < KB) {
      return "$size${hasUnit?"Bytes":""}";
    } else if (size >= KB && size < MB) {
      return "${(size / KB).toStringAsFixed(2)}${hasUnit?"Kb":""}";
    } else if (size >= MB && size < GB) {
      return "${(size / MB).toStringAsFixed(2)}${hasUnit?"Mb":""}";
    } else {
      return "${(size / GB).toStringAsFixed(2)}${hasUnit?"Gb":""}";
    }
  }
}

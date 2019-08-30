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
  ///按照对比排列
  static String getRatioBySize(int size,int allSize,bool hasUnit) {

    if (allSize < KB) {
      return "$size/$allSize${hasUnit?"Bytes":""}";
    } else if (allSize >= KB && allSize < MB) {
      return "${(size / KB).toStringAsFixed(2)}/${(allSize / KB).toStringAsFixed(2)}${hasUnit?"Kb":""}";
    } else if (allSize >= MB && allSize < GB) {
      return "${(size / MB).toStringAsFixed(2)}/${(allSize / MB).toStringAsFixed(2)}${hasUnit?"Mb":""}";
    } else {
      return "${(size / GB).toStringAsFixed(2)}/${(allSize / GB).toStringAsFixed(2)}${hasUnit?"Gb":""}";
    }
  }

}

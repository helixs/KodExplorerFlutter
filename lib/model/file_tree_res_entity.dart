class FileTreeResData {
  String ext;
  String path;
  bool isParent;
  List<FileTreeChildRes> children;
  String name;
  String menuType;
  String type;
  bool open;

  FileTreeResData(
      {this.ext,
      this.path,
      this.isParent,
      this.children,
      this.name,
      this.menuType,
      this.type,
      this.open});

  FileTreeResData.fromJson(Map<String, dynamic> json) {
    ext = json['ext'];
    path = json['path'];
    isParent = json['isParent'];
    if (json['children'] != null) {
      children = new List<FileTreeChildRes>();
      (json['children'] as List).forEach((v) {
        children.add(new FileTreeChildRes.fromJson(v));
      });
    }
    name = json['name'];
    menuType = json['menuType'];
    type = json['type'];
    open = json['open'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ext'] = this.ext;
    data['path'] = this.path;
    data['isParent'] = this.isParent;
    if (this.children != null) {
      data['children'] = this.children.map((v) => v.toJson()).toList();
    }
    data['name'] = this.name;
    data['menuType'] = this.menuType;
    data['type'] = this.type;
    data['open'] = this.open;
    return data;
  }
}

class FileTreeChildRes {
  String mode;
  String path;
  int atime;
  bool isParent;
  String name;
  int ctime;
  String type;
  int mtime;
  int isReadable;
  int isWriteable;

  FileTreeChildRes(
      {this.mode,
      this.path,
      this.atime,
      this.isParent,
      this.name,
      this.ctime,
      this.type,
      this.mtime,
      this.isReadable,
      this.isWriteable});

  FileTreeChildRes.fromJson(Map<String, dynamic> json) {
    mode = json['mode'];
    path = json['path'];
    atime = json['atime'];
    isParent = json['isParent'];
    name = json['name'];
    ctime = json['ctime'];
    type = json['type'];
    mtime = json['mtime'];
    isReadable = json['isReadable'];
    isWriteable = json['isWriteable'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mode'] = this.mode;
    data['path'] = this.path;
    data['atime'] = this.atime;
    data['isParent'] = this.isParent;
    data['name'] = this.name;
    data['ctime'] = this.ctime;
    data['type'] = this.type;
    data['mtime'] = this.mtime;
    data['isReadable'] = this.isReadable;
    data['isWriteable'] = this.isWriteable;
    return data;
  }
}

class FilePathRes {
  String thisPath; //当前路径
  String pathReadWrite; //当前路径可读写状态 writeable:可读写;readeable:只读
  FilePathResUserspace userSpace; //用户存储空间状况:sizeMax:
  List<FilePathResFolderlist> folderList;
  List<FilePathResFilelist> fileList;
  FilePathResInfo info;

  FilePathRes(
      {this.thisPath,
      this.pathReadWrite,
      this.userSpace,
      this.folderList,
      this.fileList,
      this.info});

  FilePathRes.fromJson(Map<String, dynamic> json) {
    thisPath = json['thisPath'];
    pathReadWrite = json['pathReadWrite'];
    userSpace = json['userSpace'] != null
        ? new FilePathResUserspace.fromJson(json['userSpace'])
        : null;
    if (json['folderList'] != null) {
      folderList = new List<FilePathResFolderlist>();
      (json['folderList'] as List).forEach((v) {
        folderList.add(new FilePathResFolderlist.fromJson(v));
      });
    }
    if (json['fileList'] != null) {
      fileList = new List<FilePathResFilelist>();
      (json['fileList'] as List).forEach((v) {
        fileList.add(new FilePathResFilelist.fromJson(v));
      });
    }
    info = json['info'] != null
        ? new FilePathResInfo.fromJson(json['info'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['thisPath'] = this.thisPath;
    data['pathReadWrite'] = this.pathReadWrite;
    if (this.userSpace != null) {
      data['userSpace'] = this.userSpace.toJson();
    }
    if (this.folderList != null) {
      data['folderList'] = this.folderList.map((v) => v.toJson()).toList();
    }
    if (this.fileList != null) {
      data['fileList'] = this.fileList.map((v) => v.toJson()).toList();
    }
    if (this.info != null) {
      data['info'] = this.info.toJson();
    }
    return data;
  }
}

class FilePathResUserspace {
  int sizeUse; //用户空间大小(单位GB,0则不限制)
  String sizeMax; //用户已使用空间大小(单位B)

  FilePathResUserspace({this.sizeUse, this.sizeMax});

  FilePathResUserspace.fromJson(Map<String, dynamic> json) {
    sizeUse = json['sizeUse'];
    sizeMax = json['sizeMax'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sizeUse'] = this.sizeUse;
    data['sizeMax'] = this.sizeMax;
    return data;
  }
}

class FilePathResFolderlist {
  String mode; //系统读写权限
  String path; //路径
  int atime; //最后访问时间
  bool isParent; //是否含有子文件或文件夹
  String name; //文件夹名称
  int ctime; //创建时间
  String type; //类型
  int mtime; //最后修改时间
  bool isReadable; //是否可读
  bool isWriteable; //是否可写

  FilePathResFolderlist(
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

  FilePathResFolderlist.fromJson(Map<String, dynamic> json) {
    mode = json['mode'];
    path = json['path'];
    atime = json['atime'];
    isParent = json['isParent'];
    name = json['name'];
    ctime = json['ctime'];
    type = json['type'];
    mtime = json['mtime'];
    var read = json['isReadable'];
    if(read is int){
      if(read==1){
        isReadable  =true;
      }else{
        isReadable = false;
      }
    }else if (read is bool){
      isReadable = read;
    }else{
      isReadable=false;
    }
    var write = json['isWriteable'];
    if(write is int){
      if(read==1){
        isWriteable  =true;
      }else{
        isWriteable = false;
      }
    }else if (write is bool){
      isWriteable = write;
    }else{
      isWriteable=false;
    }
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

class FilePathResFilelist {
  String ext; //扩展名
  String mode; //系统读写权限
  String path; //文件路径
  int atime; //最后访问时间
  bool isParent; //是否含有子文件或文件夹
  int size; //文件大小,单位Byte
  String name; //文件名称
  int ctime; //创建时间
  String type; //类型
  int mtime; //最后修改时间
  int isReadable; //是否可读
  int isWriteable; //是否可写

  FilePathResFilelist(
      {this.ext,
      this.mode,
      this.path,
      this.atime,
      this.isParent,
      this.size,
      this.name,
      this.ctime,
      this.type,
      this.mtime,
      this.isReadable,
      this.isWriteable});

  FilePathResFilelist.fromJson(Map<String, dynamic> json) {
    ext = json['ext'];
    mode = json['mode'];
    path = json['path'];
    atime = json['atime'];
    isParent = json['isParent'];
    size = json['size'];
    name = json['name'];
    ctime = json['ctime'];
    type = json['type'];
    mtime = json['mtime'];
    isReadable = json['isReadable'];
    isWriteable = json['isWriteable'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ext'] = this.ext;
    data['mode'] = this.mode;
    data['path'] = this.path;
    data['atime'] = this.atime;
    data['isParent'] = this.isParent;
    data['size'] = this.size;
    data['name'] = this.name;
    data['ctime'] = this.ctime;
    data['type'] = this.type;
    data['mtime'] = this.mtime;
    data['isReadable'] = this.isReadable;
    data['isWriteable'] = this.isWriteable;
    return data;
  }
}

class FilePathResInfo {
  String role;
  String name;
  String id;
  String pathType;

  FilePathResInfo({this.role, this.name, this.id, this.pathType});

  FilePathResInfo.fromJson(Map<String, dynamic> json) {
    role = json['role'];
    name = json['name'];
    id = json['id'];
    pathType = json['pathType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['role'] = this.role;
    data['name'] = this.name;
    data['id'] = this.id;
    data['pathType'] = this.pathType;
    return data;
  }
}

class FilePathInfoRes {
	//扩展名
	String ext;
	////最后访问时间
	int atime;
	String fileMd5;
	//类型 file/folder
	String type;
	//最后修改时间
	int mtime;
	//系统读写权限
	String mode;
	String path;
	//单位Byte
	int size;
	//下载路径
	String downloadPath;
	String name;
	//创建时间
	int ctime;
	int isReadable;
	int isWriteable;

	FilePathInfoRes({this.ext, this.atime, this.fileMd5, this.type, this.mtime, this.mode, this.path, this.size, this.downloadPath, this.name, this.ctime, this.isReadable, this.isWriteable});

	FilePathInfoRes.fromJson(Map<String, dynamic> json) {
		ext = json['ext'];
		atime = json['atime'];
		fileMd5 = json['fileMd5'];
		type = json['type'];
		mtime = json['mtime'];
		mode = json['mode'];
		path = json['path'];
		size = json['size'];
		downloadPath = json['downloadPath'];
		name = json['name'];
		ctime = json['ctime'];
		isReadable = json['isReadable'];
		isWriteable = json['isWriteable'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['ext'] = this.ext;
		data['atime'] = this.atime;
		data['fileMd5'] = this.fileMd5;
		data['type'] = this.type;
		data['mtime'] = this.mtime;
		data['mode'] = this.mode;
		data['path'] = this.path;
		data['size'] = this.size;
		data['downloadPath'] = this.downloadPath;
		data['name'] = this.name;
		data['ctime'] = this.ctime;
		data['isReadable'] = this.isReadable;
		data['isWriteable'] = this.isWriteable;
		return data;
	}
}

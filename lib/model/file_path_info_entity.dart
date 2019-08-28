
import 'package:kodproject/tools/calc_size.dart';

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
		List<FileKVInfo> toItemDesc() {
		List<FileKVInfo> kvs= [];
//		final Map<String, dynamic> data = new Map<String, dynamic>();
//		data['ext'] = this.ext;
		kvs.add(FileKVInfo('名称',this.name));
		kvs.add(FileKVInfo('外链地址\n(长按复制)',this.downloadPath,isDownloadUrl: true));

//		data['创建时间'] = this.ctime.toString();
			kvs.add(FileKVInfo('大小',CalcSize.getSizeToString(size,true)));
			kvs.add(FileKVInfo('创建时间',_getTime(this.ctime)));
			kvs.add(FileKVInfo('修改时间',_getTime(this.mtime)));
			kvs.add(FileKVInfo('最后访问',_getTime(this.atime)));
			kvs.add(FileKVInfo('文件md5',this.fileMd5));
			kvs.add(FileKVInfo('文件路径',this.path.toString()));
//		data['修改时间'] = this.mtime.toString();
//		data['最后访问时间'] = this.atime.toString();
//		data['文件md5'] = this.fileMd5;
//		data['type'] = this.type;

//		data['mode'] = this.mode;
//		data['文件路径'] = this.path;

//		data['name'] = this.name;

//		data['isReadable'] = this.isReadable;
//		data['isWriteable'] = this.isWriteable;
//		data['isWriteable'] = this.isWriteable;
		return kvs;
	}
	String _getTime(int t) {
		var time=DateTime.fromMillisecondsSinceEpoch(t*1000);
		return "${time.year}/${_twoDigits(time.month)}/${_twoDigits(time.day)} ${_twoDigits(time.hour)}:${_twoDigits(time.minute)}:${_twoDigits(time.second)}";
	}
	static String _twoDigits(int n) {
		if (n >= 10) return "$n";
		return "0$n";
	}
}
class FileKVInfo{
	bool isDownloadUrl;
	final String key;
	final String value;

  FileKVInfo(this.key, this.value,{this.isDownloadUrl=false});
}

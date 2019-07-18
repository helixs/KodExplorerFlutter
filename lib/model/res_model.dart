
class BaseRes{
  bool code;
  dynamic data;
  double useTime;

  BaseRes({this.code, this.data, this.useTime});

  BaseRes.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    data = json['data'];
    useTime = json['use_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['data'] = this.data;
    data['use_time'] = this.useTime;
    return data;
  }

}

class B extends Js{
  B.fromJson() : super.fromJson();

}
abstract class Js{
  Js.fromJson();
}
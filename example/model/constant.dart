import 'package:shelf_easy/shelf_easy.dart';

///
///常量
///
class Constant extends DbBaseModel {
  ///性别：男性
  static const int sexMale = 101;

  ///性别：女性
  static const int sexFemale = 102;

  ///性别：未知
  static const int sexUnknow = 103;

  static const Map<String, Map<int, String>> constMap = {
    'zh': {
      101: '男',
      102: '女',
      103: '未知',
    },
    'en': {
      101: 'Male',
      102: 'Female',
      103: 'Unknow',
    },
  };

  Constant();

  factory Constant.fromString(String data) {
    return Constant.fromJson(jsonDecode(data.substring(data.indexOf('(') + 1, data.lastIndexOf(')'))));
  }

  factory Constant.fromJson(Map<String, dynamic> map) {
    return Constant();
  }

  @override
  String toString() {
    return 'Constant(${jsonEncode(toJson())})';
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  Map<String, dynamic> toKValues() {
    return {};
  }

  @override
  void updateByJson(Map<String, dynamic> map, {Constant? parser}) {}

  @override
  void updateByKValues(Map<String, dynamic> map) {}
}

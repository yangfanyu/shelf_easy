import 'package:shelf_easy/shelf_easy.dart';

///
///没有字段类
///
class Empty extends DbBaseModel {
  Empty();

  factory Empty.fromString(String data) {
    return Empty.fromJson(jsonDecode(data.substring(data.indexOf('(') + 1, data.lastIndexOf(')'))));
  }

  factory Empty.fromJson(Map<String, dynamic> map) {
    return Empty();
  }

  @override
  String toString() {
    return 'Empty(${jsonEncode(toJson())})';
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
  void updateByJson(Map<String, dynamic> map, {Empty? parser}) {}

  @override
  void updateByKValues(Map<String, dynamic> map) {}
}

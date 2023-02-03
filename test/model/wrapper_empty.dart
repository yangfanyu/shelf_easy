import 'package:shelf_easy/shelf_easy.dart';
import 'empty.dart';

///
///无字段包装类
///
class WrapperEmpty extends DbBaseModel {
  WrapperEmpty();

  factory WrapperEmpty.fromString(String data) {
    return WrapperEmpty.fromJson(jsonDecode(data.substring(data.indexOf('(') + 1, data.lastIndexOf(')'))));
  }

  factory WrapperEmpty.fromJson(Map<String, dynamic> map) {
    return WrapperEmpty();
  }

  @override
  String toString() {
    return 'WrapperEmpty(${jsonEncode(toJson())})';
  }

  @override
  Map<String, dynamic> toJson() {
    return {'type': WrapperEmpty, 'args': {}};
  }

  @override
  Map<String, dynamic> toKValues() {
    return {};
  }

  @override
  void updateByJson(Map<String, dynamic> map, {WrapperEmpty? parser}) {}

  @override
  void updateByKValues(Map<String, dynamic> map) {}

  @override
  Empty buildTarget() {
    return Empty();
  }
}

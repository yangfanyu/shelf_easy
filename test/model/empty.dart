import 'package:shelf_easy/shelf_easy.dart';

///
///没有字段类
///
class Empty extends DbBaseModel {
  Empty();

  factory Empty.fromJson(Map<String, dynamic> map) {
    return Empty();
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }

  void updateFields(Map<String, dynamic> map, {Empty? parser}) {}
}

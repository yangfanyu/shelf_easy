import 'package:shelf_easy/src/db/db_base.dart';

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

  void update(Map<String, dynamic> map) {}
}

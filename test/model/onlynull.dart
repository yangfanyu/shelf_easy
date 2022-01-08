import 'package:shelf_easy/src/db/db_base.dart';

///
///没有字段类
///
class OnlyNull extends DbBaseModel {
  ///
  String? test1;

  ///
  String? test2;

  OnlyNull({
    this.test1,
    this.test2,
  });

  factory OnlyNull.fromJson(Map<String, dynamic> map) {
    return OnlyNull(
      test1: map['test1'],
      test2: map['test2'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'test1': DbQueryField.convertToBaseType(test1),
      'test2': DbQueryField.convertToBaseType(test2),
    };
  }

  void updateFields(Map<String, dynamic> map) {
    final parser = OnlyNull.fromJson(map);
    if (map.containsKey('test1')) test1 = parser.test1;
    if (map.containsKey('test2')) test2 = parser.test2;
  }
}

class OnlyNullDirty {
  final Map<String, dynamic> data = {};
  set test1(String value) => data['test1'] = DbQueryField.convertToBaseType(value);
  set test2(String value) => data['test2'] = DbQueryField.convertToBaseType(value);
}

class OnlyNullQuery {
  static const $tableName = 'onlynull';
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get test1 => DbQueryField('test1');
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get test2 => DbQueryField('test2');
}

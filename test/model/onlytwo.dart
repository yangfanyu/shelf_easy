import 'package:shelf_easy/src/db/db_base.dart';

///
///只有两个字段类
///
class OnlyTwo extends DbBaseModel {
  ///
  String test1;

  ///
  String test2;

  OnlyTwo({
    String? test1,
    String? test2,
  })  : test1 = test1 ?? '',
        test2 = test2 ?? '';

  factory OnlyTwo.fromJson(Map<String, dynamic> map) {
    return OnlyTwo(
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

  void update(Map<String, dynamic> map) {
    final parser = OnlyTwo.fromJson(map);
    if (map['test1'] != null) test1 = parser.test1;
    if (map['test2'] != null) test2 = parser.test2;
  }
}

class OnlyTwoDirty {
  final Map<String, dynamic> data = {};
  set test1(String value) => data['test1'] = DbQueryField.convertToBaseType(value);
  set test2(String value) => data['test2'] = DbQueryField.convertToBaseType(value);
}

class OnlyTwoQuery {
  static const $tableName = 'onlytwo';
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get test1 => DbQueryField('test1');
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get test2 => DbQueryField('test2');
}

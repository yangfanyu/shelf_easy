import 'package:shelf_easy/src/db/db_base.dart';

///
///只有一个字段类
///
class OnlyOne extends DbBaseModel {
  ///
  String test1;

  OnlyOne({
    String? test1,
  }) : test1 = test1 ?? '';

  factory OnlyOne.fromJson(Map<String, dynamic> map) {
    return OnlyOne(
      test1: map['test1'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'test1': DbQueryField.convertToBaseType(test1),
    };
  }

  void update(Map<String, dynamic> map) {
    final parser = OnlyOne.fromJson(map);
    if (map['test1'] != null) test1 = parser.test1;
  }
}

class OnlyOneDirty {
  final Map<String, dynamic> data = {};
  set test1(String value) => data['test1'] = DbQueryField.convertToBaseType(value);
}

class OnlyOneQuery {
  static const $tableName = 'onlyone';
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get test1 => DbQueryField('test1');
}

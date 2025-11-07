import 'dart:convert';

import 'package:shelf_easy/shelf_easy.dart';

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
  }) : test1 = test1 ?? '',
       test2 = test2 ?? '';

  factory OnlyTwo.fromString(String data) {
    return OnlyTwo.fromJson(jsonDecode(data.substring(data.indexOf('(') + 1, data.lastIndexOf(')'))));
  }

  factory OnlyTwo.fromJson(Map<String, dynamic> map) {
    return OnlyTwo(
      test1: DbQueryField.tryParseString(map['test1']),
      test2: DbQueryField.tryParseString(map['test2']),
    );
  }

  @override
  String toString() {
    return 'OnlyTwo(${jsonEncode(toJson())})';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'test1': DbQueryField.toBaseType(test1),
      'test2': DbQueryField.toBaseType(test2),
    };
  }

  @override
  Map<String, dynamic> toKValues() {
    return {
      'test1': test1,
      'test2': test2,
    };
  }

  @override
  void updateByJson(Map<String, dynamic> map, {OnlyTwo? parser}) {
    parser = parser ?? OnlyTwo.fromJson(map);
    if (map.containsKey('test1')) test1 = parser.test1;
    if (map.containsKey('test2')) test2 = parser.test2;
  }

  @override
  void updateByKValues(Map<String, dynamic> map) {
    if (map.containsKey('test1')) test1 = map['test1'];
    if (map.containsKey('test2')) test2 = map['test2'];
  }
}

class OnlyTwoDirty {
  final Map<String, dynamic> data = {};

  ///
  set test1(String value) => data['test1'] = DbQueryField.toBaseType(value);

  ///
  set test2(String value) => data['test2'] = DbQueryField.toBaseType(value);
}

class OnlyTwoQuery {
  static const $tableName = 'onlytwo';

  ///
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get test1 => DbQueryField('test1');

  ///
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get test2 => DbQueryField('test2');
}

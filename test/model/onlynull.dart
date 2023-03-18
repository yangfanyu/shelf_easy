import 'dart:convert';

import 'package:shelf_easy/shelf_easy.dart';

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

  factory OnlyNull.fromString(String data) {
    return OnlyNull.fromJson(jsonDecode(data.substring(data.indexOf('(') + 1, data.lastIndexOf(')'))));
  }

  factory OnlyNull.fromJson(Map<String, dynamic> map) {
    return OnlyNull(
      test1: DbQueryField.tryParseString(map['test1']),
      test2: DbQueryField.tryParseString(map['test2']),
    );
  }

  @override
  String toString() {
    return 'OnlyNull(${jsonEncode(toJson())})';
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
  void updateByJson(Map<String, dynamic> map, {OnlyNull? parser}) {
    parser = parser ?? OnlyNull.fromJson(map);
    if (map.containsKey('test1')) test1 = parser.test1;
    if (map.containsKey('test2')) test2 = parser.test2;
  }

  @override
  void updateByKValues(Map<String, dynamic> map) {
    if (map.containsKey('test1')) test1 = map['test1'];
    if (map.containsKey('test2')) test2 = map['test2'];
  }
}

class OnlyNullDirty {
  final Map<String, dynamic> data = {};

  ///
  set test1(String value) => data['test1'] = DbQueryField.toBaseType(value);

  ///
  set test2(String value) => data['test2'] = DbQueryField.toBaseType(value);
}

class OnlyNullQuery {
  static const $tableName = 'onlynull';

  ///
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get test1 => DbQueryField('test1');

  ///
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get test2 => DbQueryField('test2');
}

import 'dart:convert';

import 'package:shelf_easy/shelf_easy.dart';
import 'package:shelf_easy/shelf_deps.dart' show ObjectId;

///
///团队类
///
class Team extends DbBaseModel {
  ///
  ///标志
  ///
  ObjectId _id;

  ///
  ///姓名
  ///
  String name;

  static const Map<String, Map<String, String?>> fieldMap = {
    'zh': {
      '_id': null,
      'name': '姓名',
    },
    'en': {
      '_id': null,
      'name': 'Name',
    },
  };

  ///
  ///标志
  ///
  ObjectId get id => _id;

  Team({
    ObjectId? id,
    String? name,
  }) : _id = id ?? ObjectId(),
       name = name ?? '名称';

  factory Team.fromString(String data) {
    return Team.fromJson(jsonDecode(data.substring(data.indexOf('(') + 1, data.lastIndexOf(')'))));
  }

  factory Team.fromJson(Map<String, dynamic> map) {
    return Team(
      id: DbQueryField.tryParseObjectId(map['_id']),
      name: DbQueryField.tryParseString(map['name']),
    );
  }

  @override
  String toString() {
    return 'Team(${jsonEncode(toJson())})';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '_id': DbQueryField.toBaseType(_id),
      'name': DbQueryField.toBaseType(name),
    };
  }

  @override
  Map<String, dynamic> toKValues() {
    return {
      '_id': _id,
      'name': name,
    };
  }

  @override
  void updateByJson(Map<String, dynamic> map, {Team? parser}) {
    parser = parser ?? Team.fromJson(map);
    if (map.containsKey('_id')) _id = parser._id;
    if (map.containsKey('name')) name = parser.name;
  }

  @override
  void updateByKValues(Map<String, dynamic> map) {
    if (map.containsKey('_id')) _id = map['_id'];
    if (map.containsKey('name')) name = map['name'];
  }
}

class TeamField {
  ///
  ///标志
  ///
  static const String id = '_id';

  ///
  ///姓名
  ///
  static const String name = 'name';
}

class TeamDirty {
  final Map<String, dynamic> data = {};

  ///
  ///标志
  ///
  set id(ObjectId value) => data['_id'] = DbQueryField.toBaseType(value);

  ///
  ///姓名
  ///
  set name(String value) => data['name'] = DbQueryField.toBaseType(value);
}

class TeamQuery {
  static const $tableName = 'teams';

  static Set<DbQueryField> get $secrecyFieldsExclude {
    return {
      id..exclude(),
    };
  }

  ///
  ///标志
  ///
  static DbQueryField<ObjectId, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get id => DbQueryField('_id');

  ///
  ///姓名
  ///
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get name => DbQueryField('name');
}

extension TeamStringExtension on String {
  String get trsTeamField => Team.fieldMap[EasyLocale.languageCode]?[this] ?? this;

  String trsTeamFieldByCode(String code) => Team.fieldMap[code]?[this] ?? this;
}

import 'dart:convert';

import 'package:shelf_easy/shelf_easy.dart';
import 'package:shelf_easy/shelf_deps.dart' show ObjectId;

import 'constant.dart';
import 'location.dart';

///
///用户
///
class User extends DbBaseModel {
  ///唯一标志
  ObjectId _id;

  ///账号
  String no;

  ///密码
  String pwd;

  ///性别
  int sex;

  ///年龄
  int age;

  ///当前位置
  Location? location;

  ///位置列表
  List<Location>? locationList;

  ///位置集合
  Map<int, Location>? locationMap;

  ///创建时间
  int _time;

  ///唯一标志
  ObjectId get id => _id;

  ///创建时间
  int get time => _time;

  User({
    ObjectId? id,
    String? no,
    String? pwd,
    int? sex,
    int? age,
    this.location,
    this.locationList,
    this.locationMap,
    int? time,
  })  : _id = id ?? ObjectId(),
        no = no ?? '',
        pwd = pwd ?? '',
        sex = sex ?? Constant.sexUnknow,
        age = age ?? 18,
        _time = time ?? DateTime.now().millisecondsSinceEpoch;

  factory User.fromString(String data) {
    return User.fromJson(jsonDecode(data.substring(data.indexOf('(') + 1, data.lastIndexOf(')'))));
  }

  factory User.fromJson(Map<String, dynamic> map) {
    return User(
      id: DbQueryField.tryParseObjectId(map['_id']),
      no: DbQueryField.tryParseString(map['no']),
      pwd: DbQueryField.tryParseString(map['pwd']),
      sex: DbQueryField.tryParseInt(map['sex']),
      age: DbQueryField.tryParseInt(map['age']),
      location: map['location'] is Map ? Location.fromJson(map['location']) : map['location'],
      locationList: (map['locationList'] as List?)?.map((v) => Location.fromJson(v)).toList(),
      locationMap: (map['locationMap'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseInt(k), Location.fromJson(v))),
      time: DbQueryField.tryParseInt(map['_time']),
    );
  }

  @override
  String toString() {
    return 'User(${jsonEncode(toJson())})';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '_id': DbQueryField.toBaseType(_id),
      'no': DbQueryField.toBaseType(no),
      'pwd': DbQueryField.toBaseType(pwd),
      'sex': DbQueryField.toBaseType(sex),
      'age': DbQueryField.toBaseType(age),
      'location': DbQueryField.toBaseType(location),
      'locationList': DbQueryField.toBaseType(locationList),
      'locationMap': DbQueryField.toBaseType(locationMap),
      '_time': DbQueryField.toBaseType(_time),
    };
  }

  @override
  Map<String, dynamic> toKValues() {
    return {
      '_id': _id,
      'no': no,
      'pwd': pwd,
      'sex': sex,
      'age': age,
      'location': location,
      'locationList': locationList,
      'locationMap': locationMap,
      '_time': _time,
    };
  }

  @override
  void updateByJson(Map<String, dynamic> map, {User? parser}) {
    parser = parser ?? User.fromJson(map);
    if (map.containsKey('_id')) _id = parser._id;
    if (map.containsKey('no')) no = parser.no;
    if (map.containsKey('pwd')) pwd = parser.pwd;
    if (map.containsKey('sex')) sex = parser.sex;
    if (map.containsKey('age')) age = parser.age;
    if (map.containsKey('location')) location = parser.location;
    if (map.containsKey('locationList')) locationList = parser.locationList;
    if (map.containsKey('locationMap')) locationMap = parser.locationMap;
    if (map.containsKey('_time')) _time = parser._time;
  }

  @override
  void updateByKValues(Map<String, dynamic> map) {
    if (map.containsKey('_id')) _id = map['_id'];
    if (map.containsKey('no')) no = map['no'];
    if (map.containsKey('pwd')) pwd = map['pwd'];
    if (map.containsKey('sex')) sex = map['sex'];
    if (map.containsKey('age')) age = map['age'];
    if (map.containsKey('location')) location = map['location'];
    if (map.containsKey('locationList')) locationList = map['locationList'];
    if (map.containsKey('locationMap')) locationMap = map['locationMap'];
    if (map.containsKey('_time')) _time = map['_time'];
  }
}

class UserDirty {
  final Map<String, dynamic> data = {};

  ///唯一标志
  set id(ObjectId value) => data['_id'] = DbQueryField.toBaseType(value);

  ///账号
  set no(String value) => data['no'] = DbQueryField.toBaseType(value);

  ///密码
  set pwd(String value) => data['pwd'] = DbQueryField.toBaseType(value);

  ///性别
  set sex(int value) => data['sex'] = DbQueryField.toBaseType(value);

  ///年龄
  set age(int value) => data['age'] = DbQueryField.toBaseType(value);

  ///当前位置
  set location(Location value) => data['location'] = DbQueryField.toBaseType(value);

  ///位置列表
  set locationList(List<Location> value) => data['locationList'] = DbQueryField.toBaseType(value);

  ///位置集合
  set locationMap(Map<int, Location> value) => data['locationMap'] = DbQueryField.toBaseType(value);

  ///创建时间
  set time(int value) => data['_time'] = DbQueryField.toBaseType(value);
}

class UserQuery {
  static const $tableName = 'user';

  static Set<DbQueryField> get $secrecyFieldsExclude {
    return {
      pwd..exclude(),
    };
  }

  ///唯一标志
  static DbQueryField<ObjectId, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get id => DbQueryField('_id');

  ///账号
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get no => DbQueryField('no');

  ///密码
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get pwd => DbQueryField('pwd');

  ///性别
  static DbQueryField<int, int, DBUnsupportArrayOperate> get sex => DbQueryField('sex');

  ///年龄
  static DbQueryField<int, int, DBUnsupportArrayOperate> get age => DbQueryField('age');

  ///当前位置
  static DbQueryField<Location, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get location => DbQueryField('location');

  ///位置列表
  static DbQueryField<List<Location>, DBUnsupportNumberOperate, Location> get locationList => DbQueryField('locationList');

  ///位置集合
  static DbQueryField<Map<int, Location>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get locationMap => DbQueryField('locationMap');

  ///创建时间
  static DbQueryField<int, int, DBUnsupportArrayOperate> get time => DbQueryField('_time');
}

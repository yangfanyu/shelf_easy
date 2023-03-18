import 'dart:convert';

import 'package:shelf_easy/shelf_easy.dart';
import 'package:shelf_easy/shelf_deps.dart' show ObjectId;

import 'address.dart';

///
///用户类
///
class User extends DbBaseModel {
  ///男性
  static const int sexMale = 1;

  ///女性
  static const int sexFemale = 2;

  static const Map<String, Map<int, String>> constMap = {
    'zh': {
      1: 'null',
      2: 'null',
    },
    'en': {
      1: 'null',
      2: 'null',
    },
  };

  ///
  ///标志
  ///
  ObjectId _id;

  ///
  ///姓名
  ///
  String name;

  ///年龄
  int age;

  ///RMB
  double rmb;

  ///密码
  String pwd;

  ///归属地址
  Address address;

  ///备用地址
  Address? addressBak;

  ///权限列表
  List<int> accessList;

  ///通讯地址
  List<Address> addressList;

  ///好友id列表
  List<ObjectId> friendList;

  ///测试复杂类型
  Map<int, Map<ObjectId, Address>> ageObjectIdAddressMap;

  ///
  ///标志
  ///
  ObjectId get id => _id;

  ///
  ///非序列化字段
  ///
  String $pingying = '';

  User({
    ObjectId? id,
    String? name,
    int? age,
    double? rmb,
    String? pwd,
    Address? address,
    this.addressBak,
    List<int>? accessList,
    List<Address>? addressList,
    List<ObjectId>? friendList,
    Map<int, Map<ObjectId, Address>>? ageObjectIdAddressMap,
  })  : _id = id ?? ObjectId(),
        name = name ?? '名称',
        age = age ?? 10,
        rmb = rmb ?? 100,
        pwd = pwd ?? '12345678',
        address = address ?? Address(),
        accessList = accessList ?? [],
        addressList = addressList ?? [],
        friendList = friendList ?? [],
        ageObjectIdAddressMap = ageObjectIdAddressMap ?? {};

  factory User.fromString(String data) {
    return User.fromJson(jsonDecode(data.substring(data.indexOf('(') + 1, data.lastIndexOf(')'))));
  }

  factory User.fromJson(Map<String, dynamic> map) {
    return User(
      id: DbQueryField.tryParseObjectId(map['_id']),
      name: DbQueryField.tryParseString(map['name']),
      age: DbQueryField.tryParseInt(map['age']),
      rmb: DbQueryField.tryParseDouble(map['rmb']),
      pwd: DbQueryField.tryParseString(map['pwd']),
      address: map['address'] is Map ? Address.fromJson(map['address']) : map['address'],
      addressBak: map['addressBak'] is Map ? Address.fromJson(map['addressBak']) : map['addressBak'],
      accessList: (map['accessList'] as List?)?.map((v) => DbQueryField.parseInt(v)).toList(),
      addressList: (map['addressList'] as List?)?.map((v) => Address.fromJson(v)).toList(),
      friendList: (map['friendList'] as List?)?.map((v) => DbQueryField.parseObjectId(v)).toList(),
      ageObjectIdAddressMap: (map['ageObjectIdAddressMap'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseInt(k), (v as Map).map((k, v) => MapEntry(DbQueryField.parseObjectId(k), Address.fromJson(v))))),
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
      'name': DbQueryField.toBaseType(name),
      'age': DbQueryField.toBaseType(age),
      'rmb': DbQueryField.toBaseType(rmb),
      'pwd': DbQueryField.toBaseType(pwd),
      'address': DbQueryField.toBaseType(address),
      'addressBak': DbQueryField.toBaseType(addressBak),
      'accessList': DbQueryField.toBaseType(accessList),
      'addressList': DbQueryField.toBaseType(addressList),
      'friendList': DbQueryField.toBaseType(friendList),
      'ageObjectIdAddressMap': DbQueryField.toBaseType(ageObjectIdAddressMap),
    };
  }

  @override
  Map<String, dynamic> toKValues() {
    return {
      '_id': _id,
      'name': name,
      'age': age,
      'rmb': rmb,
      'pwd': pwd,
      'address': address,
      'addressBak': addressBak,
      'accessList': accessList,
      'addressList': addressList,
      'friendList': friendList,
      'ageObjectIdAddressMap': ageObjectIdAddressMap,
    };
  }

  @override
  void updateByJson(Map<String, dynamic> map, {User? parser}) {
    parser = parser ?? User.fromJson(map);
    if (map.containsKey('_id')) _id = parser._id;
    if (map.containsKey('name')) name = parser.name;
    if (map.containsKey('age')) age = parser.age;
    if (map.containsKey('rmb')) rmb = parser.rmb;
    if (map.containsKey('pwd')) pwd = parser.pwd;
    if (map.containsKey('address')) address = parser.address;
    if (map.containsKey('addressBak')) addressBak = parser.addressBak;
    if (map.containsKey('accessList')) accessList = parser.accessList;
    if (map.containsKey('addressList')) addressList = parser.addressList;
    if (map.containsKey('friendList')) friendList = parser.friendList;
    if (map.containsKey('ageObjectIdAddressMap')) ageObjectIdAddressMap = parser.ageObjectIdAddressMap;
  }

  @override
  void updateByKValues(Map<String, dynamic> map) {
    if (map.containsKey('_id')) _id = map['_id'];
    if (map.containsKey('name')) name = map['name'];
    if (map.containsKey('age')) age = map['age'];
    if (map.containsKey('rmb')) rmb = map['rmb'];
    if (map.containsKey('pwd')) pwd = map['pwd'];
    if (map.containsKey('address')) address = map['address'];
    if (map.containsKey('addressBak')) addressBak = map['addressBak'];
    if (map.containsKey('accessList')) accessList = map['accessList'];
    if (map.containsKey('addressList')) addressList = map['addressList'];
    if (map.containsKey('friendList')) friendList = map['friendList'];
    if (map.containsKey('ageObjectIdAddressMap')) ageObjectIdAddressMap = map['ageObjectIdAddressMap'];
  }
}

class UserDirty {
  final Map<String, dynamic> data = {};

  ///
  ///标志
  ///
  set id(ObjectId value) => data['_id'] = DbQueryField.toBaseType(value);

  ///
  ///姓名
  ///
  set name(String value) => data['name'] = DbQueryField.toBaseType(value);

  ///年龄
  set age(int value) => data['age'] = DbQueryField.toBaseType(value);

  ///RMB
  set rmb(double value) => data['rmb'] = DbQueryField.toBaseType(value);

  ///密码
  set pwd(String value) => data['pwd'] = DbQueryField.toBaseType(value);

  ///归属地址
  set address(Address value) => data['address'] = DbQueryField.toBaseType(value);

  ///备用地址
  set addressBak(Address value) => data['addressBak'] = DbQueryField.toBaseType(value);

  ///权限列表
  set accessList(List<int> value) => data['accessList'] = DbQueryField.toBaseType(value);

  ///通讯地址
  set addressList(List<Address> value) => data['addressList'] = DbQueryField.toBaseType(value);

  ///好友id列表
  set friendList(List<ObjectId> value) => data['friendList'] = DbQueryField.toBaseType(value);

  ///测试复杂类型
  set ageObjectIdAddressMap(Map<int, Map<ObjectId, Address>> value) => data['ageObjectIdAddressMap'] = DbQueryField.toBaseType(value);
}

class UserQuery {
  static const $tableName = 'user';

  static Set<DbQueryField> get $secrecyFieldsExclude {
    return {
      id..exclude(),
      age..exclude(),
      rmb..exclude(),
      pwd..exclude(),
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

  ///年龄
  static DbQueryField<int, int, DBUnsupportArrayOperate> get age => DbQueryField('age');

  ///RMB
  static DbQueryField<double, double, DBUnsupportArrayOperate> get rmb => DbQueryField('rmb');

  ///密码
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get pwd => DbQueryField('pwd');

  ///归属地址
  static DbQueryField<Address, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get address => DbQueryField('address');

  ///备用地址
  static DbQueryField<Address, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get addressBak => DbQueryField('addressBak');

  ///权限列表
  static DbQueryField<List<int>, DBUnsupportNumberOperate, int> get accessList => DbQueryField('accessList');

  ///通讯地址
  static DbQueryField<List<Address>, DBUnsupportNumberOperate, Address> get addressList => DbQueryField('addressList');

  ///好友id列表
  static DbQueryField<List<ObjectId>, DBUnsupportNumberOperate, ObjectId> get friendList => DbQueryField('friendList');

  ///测试复杂类型
  static DbQueryField<Map<int, Map<ObjectId, Address>>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get ageObjectIdAddressMap => DbQueryField('ageObjectIdAddressMap');
}

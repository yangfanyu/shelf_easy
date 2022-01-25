import 'package:shelf_easy/shelf_easy.dart';
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
  })  : _id = id ?? ObjectId(),
        name = name ?? '名称',
        age = age ?? 10,
        rmb = rmb ?? 100,
        pwd = pwd ?? '12345678',
        address = address ?? Address(),
        accessList = accessList ?? [],
        addressList = addressList ?? [],
        friendList = friendList ?? [];

  factory User.fromJson(Map<String, dynamic> map) {
    return User(
      id: map['_id'] is String ? ObjectId.fromHexString(map['_id']) : map['_id'],
      name: map['name'],
      age: map['age'],
      rmb: map['rmb'],
      pwd: map['pwd'],
      address: map['address'] is Map ? Address.fromJson(map['address']) : map['address'],
      addressBak: map['addressBak'] is Map ? Address.fromJson(map['addressBak']) : map['addressBak'],
      accessList: (map['accessList'] as List?)?.map((v) => v as int).toList(),
      addressList: (map['addressList'] as List?)?.map((v) => Address.fromJson(v)).toList(),
      friendList: (map['friendList'] as List?)?.map((v) => v is String ? ObjectId.fromHexString(v) : v as ObjectId).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '_id': DbQueryField.convertToBaseType(_id),
      'name': DbQueryField.convertToBaseType(name),
      'age': DbQueryField.convertToBaseType(age),
      'rmb': DbQueryField.convertToBaseType(rmb),
      'pwd': DbQueryField.convertToBaseType(pwd),
      'address': DbQueryField.convertToBaseType(address),
      'addressBak': DbQueryField.convertToBaseType(addressBak),
      'accessList': DbQueryField.convertToBaseType(accessList),
      'addressList': DbQueryField.convertToBaseType(addressList),
      'friendList': DbQueryField.convertToBaseType(friendList),
    };
  }

  void updateFields(Map<String, dynamic> map, {User? parser}) {
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
  }
}

class UserDirty {
  final Map<String, dynamic> data = {};

  ///
  ///标志
  ///
  set id(ObjectId value) => data['_id'] = DbQueryField.convertToBaseType(value);

  ///
  ///姓名
  ///
  set name(String value) => data['name'] = DbQueryField.convertToBaseType(value);

  ///年龄
  set age(int value) => data['age'] = DbQueryField.convertToBaseType(value);

  ///RMB
  set rmb(double value) => data['rmb'] = DbQueryField.convertToBaseType(value);

  ///密码
  set pwd(String value) => data['pwd'] = DbQueryField.convertToBaseType(value);

  ///归属地址
  set address(Address value) => data['address'] = DbQueryField.convertToBaseType(value);

  ///备用地址
  set addressBak(Address value) => data['addressBak'] = DbQueryField.convertToBaseType(value);

  ///权限列表
  set accessList(List<int> value) => data['accessList'] = DbQueryField.convertToBaseType(value);

  ///通讯地址
  set addressList(List<Address> value) => data['addressList'] = DbQueryField.convertToBaseType(value);

  ///好友id列表
  set friendList(List<ObjectId> value) => data['friendList'] = DbQueryField.convertToBaseType(value);
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
}

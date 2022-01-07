import 'package:bson/bson.dart';
import 'package:shelf_easy/src/db/db_base.dart';
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

  User({
    ObjectId? id,
    String? name,
    int? age,
    double? rmb,
    String? pwd,
    Address? address,
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
      'accessList': DbQueryField.convertToBaseType(accessList),
      'addressList': DbQueryField.convertToBaseType(addressList),
      'friendList': DbQueryField.convertToBaseType(friendList),
    };
  }

  void updateFields(Map<String, dynamic> map) {
    final parser = User.fromJson(map);
    if (map['_id'] != null) _id = parser._id;
    if (map['name'] != null) name = parser.name;
    if (map['age'] != null) age = parser.age;
    if (map['rmb'] != null) rmb = parser.rmb;
    if (map['pwd'] != null) pwd = parser.pwd;
    if (map['address'] != null) address = parser.address;
    if (map['accessList'] != null) accessList = parser.accessList;
    if (map['addressList'] != null) addressList = parser.addressList;
    if (map['friendList'] != null) friendList = parser.friendList;
  }
}

class UserDirty {
  final Map<String, dynamic> data = {};
  set id(ObjectId value) => data['_id'] = DbQueryField.convertToBaseType(value);
  set name(String value) => data['name'] = DbQueryField.convertToBaseType(value);
  set age(int value) => data['age'] = DbQueryField.convertToBaseType(value);
  set rmb(double value) => data['rmb'] = DbQueryField.convertToBaseType(value);
  set pwd(String value) => data['pwd'] = DbQueryField.convertToBaseType(value);
  set address(Address value) => data['address'] = DbQueryField.convertToBaseType(value);
  set accessList(List<int> value) => data['accessList'] = DbQueryField.convertToBaseType(value);
  set addressList(List<Address> value) => data['addressList'] = DbQueryField.convertToBaseType(value);
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

  static DbQueryField<ObjectId, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get id => DbQueryField('_id');
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get name => DbQueryField('name');
  static DbQueryField<int, int, DBUnsupportArrayOperate> get age => DbQueryField('age');
  static DbQueryField<double, double, DBUnsupportArrayOperate> get rmb => DbQueryField('rmb');
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get pwd => DbQueryField('pwd');
  static DbQueryField<Address, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get address => DbQueryField('address');
  static DbQueryField<List<int>, DBUnsupportNumberOperate, int> get accessList => DbQueryField('accessList');
  static DbQueryField<List<Address>, DBUnsupportNumberOperate, Address> get addressList => DbQueryField('addressList');
  static DbQueryField<List<ObjectId>, DBUnsupportNumberOperate, ObjectId> get friendList => DbQueryField('friendList');
}

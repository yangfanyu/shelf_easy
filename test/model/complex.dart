import 'package:bson/bson.dart';
import 'package:shelf_easy/src/db/db_base.dart';
import 'address.dart';

///
///复杂字段类
///
class Complex extends DbBaseModel {
  ///
  ObjectId _id;

  ///
  int baseInt;

  ///
  double baseDouble;

  ///
  num baseNum;

  ///
  bool baseBool;

  ///
  String baseString;

  ///
  Address baseAddress;

  ///
  ObjectId baseObjectId;

  ///
  List<int> listInt;

  ///
  List<double> listDouble;

  ///
  List<num> listNum;

  ///
  List<bool> listBool;

  ///
  List<String> listString;

  ///
  List<Address> listAddress;

  ///
  List<ObjectId> listObjectId;

  ///
  Map<String, int> mapInt;

  ///
  Map<String, double> mapDouble;

  ///
  Map<String, num> mapNum;

  ///
  Map<String, bool> mapBool;

  ///
  Map<String, String> mapString;

  ///
  Map<String, Address> mapAddress;

  ///
  Map<String, ObjectId> mapObjectId;

  ///
  List<List<Map<String, Map<String, List<Map<String, double>>>>>> listListMapMapListMapDouble;

  ///
  List<List<Map<String, Map<String, List<Map<String, Address>>>>>> listListMapMapListMapAddress;

  ///
  List<List<Map<String, Map<String, List<Map<String, ObjectId>>>>>> listListMapMapListMapObjectId;

  ///
  Map<String, Map<String, List<List<Map<String, List<double>>>>>> mapMapListListMapListDouble;

  ///
  Map<String, Map<String, List<List<Map<String, List<Address>>>>>> mapMapListListMapListAddress;

  ///
  Map<String, Map<String, List<List<Map<String, List<ObjectId>>>>>> mapMapListListMapListObjectId;

  ///
  ObjectId get id => _id;

  Complex({
    ObjectId? id,
    int? baseInt,
    double? baseDouble,
    num? baseNum,
    bool? baseBool,
    String? baseString,
    Address? baseAddress,
    ObjectId? baseObjectId,
    List<int>? listInt,
    List<double>? listDouble,
    List<num>? listNum,
    List<bool>? listBool,
    List<String>? listString,
    List<Address>? listAddress,
    List<ObjectId>? listObjectId,
    Map<String, int>? mapInt,
    Map<String, double>? mapDouble,
    Map<String, num>? mapNum,
    Map<String, bool>? mapBool,
    Map<String, String>? mapString,
    Map<String, Address>? mapAddress,
    Map<String, ObjectId>? mapObjectId,
    List<List<Map<String, Map<String, List<Map<String, double>>>>>>? listListMapMapListMapDouble,
    List<List<Map<String, Map<String, List<Map<String, Address>>>>>>? listListMapMapListMapAddress,
    List<List<Map<String, Map<String, List<Map<String, ObjectId>>>>>>? listListMapMapListMapObjectId,
    Map<String, Map<String, List<List<Map<String, List<double>>>>>>? mapMapListListMapListDouble,
    Map<String, Map<String, List<List<Map<String, List<Address>>>>>>? mapMapListListMapListAddress,
    Map<String, Map<String, List<List<Map<String, List<ObjectId>>>>>>? mapMapListListMapListObjectId,
  })  : _id = id ?? ObjectId(),
        baseInt = baseInt ?? 1,
        baseDouble = baseDouble ?? 2,
        baseNum = baseNum ?? 3,
        baseBool = baseBool ?? true,
        baseString = baseString ?? '',
        baseAddress = baseAddress ?? Address(),
        baseObjectId = baseObjectId ?? ObjectId(),
        listInt = listInt ?? [],
        listDouble = listDouble ?? [],
        listNum = listNum ?? [],
        listBool = listBool ?? [],
        listString = listString ?? [],
        listAddress = listAddress ?? [],
        listObjectId = listObjectId ?? [],
        mapInt = mapInt ?? {},
        mapDouble = mapDouble ?? {},
        mapNum = mapNum ?? {},
        mapBool = mapBool ?? {},
        mapString = mapString ?? {},
        mapAddress = mapAddress ?? {},
        mapObjectId = mapObjectId ?? {},
        listListMapMapListMapDouble = listListMapMapListMapDouble ?? [],
        listListMapMapListMapAddress = listListMapMapListMapAddress ?? [],
        listListMapMapListMapObjectId = listListMapMapListMapObjectId ?? [],
        mapMapListListMapListDouble = mapMapListListMapListDouble ?? {},
        mapMapListListMapListAddress = mapMapListListMapListAddress ?? {},
        mapMapListListMapListObjectId = mapMapListListMapListObjectId ?? {};

  factory Complex.fromJson(Map<String, dynamic> map) {
    return Complex(
      id: map['_id'] is String ? ObjectId.fromHexString(map['_id']) : map['_id'],
      baseInt: map['baseInt'],
      baseDouble: map['baseDouble'],
      baseNum: map['baseNum'],
      baseBool: map['baseBool'],
      baseString: map['baseString'],
      baseAddress: map['baseAddress'] is Map ? Address.fromJson(map['baseAddress']) : map['baseAddress'],
      baseObjectId: map['baseObjectId'] is String ? ObjectId.fromHexString(map['baseObjectId']) : map['baseObjectId'],
      listInt: (map['listInt'] as List?)?.map((v) => v as int).toList(),
      listDouble: (map['listDouble'] as List?)?.map((v) => v as double).toList(),
      listNum: (map['listNum'] as List?)?.map((v) => v as num).toList(),
      listBool: (map['listBool'] as List?)?.map((v) => v as bool).toList(),
      listString: (map['listString'] as List?)?.map((v) => v as String).toList(),
      listAddress: (map['listAddress'] as List?)?.map((v) => Address.fromJson(v)).toList(),
      listObjectId: (map['listObjectId'] as List?)?.map((v) => v is String ? ObjectId.fromHexString(v) : v as ObjectId).toList(),
      mapInt: (map['mapInt'] as Map?)?.map((k, v) => MapEntry(k as String, v as int)),
      mapDouble: (map['mapDouble'] as Map?)?.map((k, v) => MapEntry(k as String, v as double)),
      mapNum: (map['mapNum'] as Map?)?.map((k, v) => MapEntry(k as String, v as num)),
      mapBool: (map['mapBool'] as Map?)?.map((k, v) => MapEntry(k as String, v as bool)),
      mapString: (map['mapString'] as Map?)?.map((k, v) => MapEntry(k as String, v as String)),
      mapAddress: (map['mapAddress'] as Map?)?.map((k, v) => MapEntry(k as String, Address.fromJson(v))),
      mapObjectId: (map['mapObjectId'] as Map?)?.map((k, v) => MapEntry(k as String, v is String ? ObjectId.fromHexString(v) : v as ObjectId)),
      listListMapMapListMapDouble: (map['listListMapMapListMapDouble'] as List?)?.map((v) => (v as List).map((v) => (v as Map).map((k, v) => MapEntry(k as String, (v as Map).map((k, v) => MapEntry(k as String, (v as List).map((v) => (v as Map).map((k, v) => MapEntry(k as String, v as double))).toList()))))).toList()).toList(),
      listListMapMapListMapAddress: (map['listListMapMapListMapAddress'] as List?)?.map((v) => (v as List).map((v) => (v as Map).map((k, v) => MapEntry(k as String, (v as Map).map((k, v) => MapEntry(k as String, (v as List).map((v) => (v as Map).map((k, v) => MapEntry(k as String, Address.fromJson(v)))).toList()))))).toList()).toList(),
      listListMapMapListMapObjectId: (map['listListMapMapListMapObjectId'] as List?)?.map((v) => (v as List).map((v) => (v as Map).map((k, v) => MapEntry(k as String, (v as Map).map((k, v) => MapEntry(k as String, (v as List).map((v) => (v as Map).map((k, v) => MapEntry(k as String, v is String ? ObjectId.fromHexString(v) : v as ObjectId))).toList()))))).toList()).toList(),
      mapMapListListMapListDouble: (map['mapMapListListMapListDouble'] as Map?)?.map((k, v) => MapEntry(k as String, (v as Map).map((k, v) => MapEntry(k as String, (v as List).map((v) => (v as List).map((v) => (v as Map).map((k, v) => MapEntry(k as String, (v as List).map((v) => v as double).toList()))).toList()).toList())))),
      mapMapListListMapListAddress: (map['mapMapListListMapListAddress'] as Map?)?.map((k, v) => MapEntry(k as String, (v as Map).map((k, v) => MapEntry(k as String, (v as List).map((v) => (v as List).map((v) => (v as Map).map((k, v) => MapEntry(k as String, (v as List).map((v) => Address.fromJson(v)).toList()))).toList()).toList())))),
      mapMapListListMapListObjectId: (map['mapMapListListMapListObjectId'] as Map?)?.map((k, v) => MapEntry(k as String, (v as Map).map((k, v) => MapEntry(k as String, (v as List).map((v) => (v as List).map((v) => (v as Map).map((k, v) => MapEntry(k as String, (v as List).map((v) => v is String ? ObjectId.fromHexString(v) : v as ObjectId).toList()))).toList()).toList())))),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '_id': DbQueryField.convertToBaseType(_id),
      'baseInt': DbQueryField.convertToBaseType(baseInt),
      'baseDouble': DbQueryField.convertToBaseType(baseDouble),
      'baseNum': DbQueryField.convertToBaseType(baseNum),
      'baseBool': DbQueryField.convertToBaseType(baseBool),
      'baseString': DbQueryField.convertToBaseType(baseString),
      'baseAddress': DbQueryField.convertToBaseType(baseAddress),
      'baseObjectId': DbQueryField.convertToBaseType(baseObjectId),
      'listInt': DbQueryField.convertToBaseType(listInt),
      'listDouble': DbQueryField.convertToBaseType(listDouble),
      'listNum': DbQueryField.convertToBaseType(listNum),
      'listBool': DbQueryField.convertToBaseType(listBool),
      'listString': DbQueryField.convertToBaseType(listString),
      'listAddress': DbQueryField.convertToBaseType(listAddress),
      'listObjectId': DbQueryField.convertToBaseType(listObjectId),
      'mapInt': DbQueryField.convertToBaseType(mapInt),
      'mapDouble': DbQueryField.convertToBaseType(mapDouble),
      'mapNum': DbQueryField.convertToBaseType(mapNum),
      'mapBool': DbQueryField.convertToBaseType(mapBool),
      'mapString': DbQueryField.convertToBaseType(mapString),
      'mapAddress': DbQueryField.convertToBaseType(mapAddress),
      'mapObjectId': DbQueryField.convertToBaseType(mapObjectId),
      'listListMapMapListMapDouble': DbQueryField.convertToBaseType(listListMapMapListMapDouble),
      'listListMapMapListMapAddress': DbQueryField.convertToBaseType(listListMapMapListMapAddress),
      'listListMapMapListMapObjectId': DbQueryField.convertToBaseType(listListMapMapListMapObjectId),
      'mapMapListListMapListDouble': DbQueryField.convertToBaseType(mapMapListListMapListDouble),
      'mapMapListListMapListAddress': DbQueryField.convertToBaseType(mapMapListListMapListAddress),
      'mapMapListListMapListObjectId': DbQueryField.convertToBaseType(mapMapListListMapListObjectId),
    };
  }

  void update(Map<String, dynamic> map) {
    final parser = Complex.fromJson(map);
    if (map['_id'] != null) _id = parser._id;
    if (map['baseInt'] != null) baseInt = parser.baseInt;
    if (map['baseDouble'] != null) baseDouble = parser.baseDouble;
    if (map['baseNum'] != null) baseNum = parser.baseNum;
    if (map['baseBool'] != null) baseBool = parser.baseBool;
    if (map['baseString'] != null) baseString = parser.baseString;
    if (map['baseAddress'] != null) baseAddress = parser.baseAddress;
    if (map['baseObjectId'] != null) baseObjectId = parser.baseObjectId;
    if (map['listInt'] != null) listInt = parser.listInt;
    if (map['listDouble'] != null) listDouble = parser.listDouble;
    if (map['listNum'] != null) listNum = parser.listNum;
    if (map['listBool'] != null) listBool = parser.listBool;
    if (map['listString'] != null) listString = parser.listString;
    if (map['listAddress'] != null) listAddress = parser.listAddress;
    if (map['listObjectId'] != null) listObjectId = parser.listObjectId;
    if (map['mapInt'] != null) mapInt = parser.mapInt;
    if (map['mapDouble'] != null) mapDouble = parser.mapDouble;
    if (map['mapNum'] != null) mapNum = parser.mapNum;
    if (map['mapBool'] != null) mapBool = parser.mapBool;
    if (map['mapString'] != null) mapString = parser.mapString;
    if (map['mapAddress'] != null) mapAddress = parser.mapAddress;
    if (map['mapObjectId'] != null) mapObjectId = parser.mapObjectId;
    if (map['listListMapMapListMapDouble'] != null) listListMapMapListMapDouble = parser.listListMapMapListMapDouble;
    if (map['listListMapMapListMapAddress'] != null) listListMapMapListMapAddress = parser.listListMapMapListMapAddress;
    if (map['listListMapMapListMapObjectId'] != null) listListMapMapListMapObjectId = parser.listListMapMapListMapObjectId;
    if (map['mapMapListListMapListDouble'] != null) mapMapListListMapListDouble = parser.mapMapListListMapListDouble;
    if (map['mapMapListListMapListAddress'] != null) mapMapListListMapListAddress = parser.mapMapListListMapListAddress;
    if (map['mapMapListListMapListObjectId'] != null) mapMapListListMapListObjectId = parser.mapMapListListMapListObjectId;
  }
}

class ComplexDirty {
  final Map<String, dynamic> data = {};
  set id(ObjectId value) => data['_id'] = DbQueryField.convertToBaseType(value);
  set baseInt(int value) => data['baseInt'] = DbQueryField.convertToBaseType(value);
  set baseDouble(double value) => data['baseDouble'] = DbQueryField.convertToBaseType(value);
  set baseNum(num value) => data['baseNum'] = DbQueryField.convertToBaseType(value);
  set baseBool(bool value) => data['baseBool'] = DbQueryField.convertToBaseType(value);
  set baseString(String value) => data['baseString'] = DbQueryField.convertToBaseType(value);
  set baseAddress(Address value) => data['baseAddress'] = DbQueryField.convertToBaseType(value);
  set baseObjectId(ObjectId value) => data['baseObjectId'] = DbQueryField.convertToBaseType(value);
  set listInt(List<int> value) => data['listInt'] = DbQueryField.convertToBaseType(value);
  set listDouble(List<double> value) => data['listDouble'] = DbQueryField.convertToBaseType(value);
  set listNum(List<num> value) => data['listNum'] = DbQueryField.convertToBaseType(value);
  set listBool(List<bool> value) => data['listBool'] = DbQueryField.convertToBaseType(value);
  set listString(List<String> value) => data['listString'] = DbQueryField.convertToBaseType(value);
  set listAddress(List<Address> value) => data['listAddress'] = DbQueryField.convertToBaseType(value);
  set listObjectId(List<ObjectId> value) => data['listObjectId'] = DbQueryField.convertToBaseType(value);
  set mapInt(Map<String, int> value) => data['mapInt'] = DbQueryField.convertToBaseType(value);
  set mapDouble(Map<String, double> value) => data['mapDouble'] = DbQueryField.convertToBaseType(value);
  set mapNum(Map<String, num> value) => data['mapNum'] = DbQueryField.convertToBaseType(value);
  set mapBool(Map<String, bool> value) => data['mapBool'] = DbQueryField.convertToBaseType(value);
  set mapString(Map<String, String> value) => data['mapString'] = DbQueryField.convertToBaseType(value);
  set mapAddress(Map<String, Address> value) => data['mapAddress'] = DbQueryField.convertToBaseType(value);
  set mapObjectId(Map<String, ObjectId> value) => data['mapObjectId'] = DbQueryField.convertToBaseType(value);
  set listListMapMapListMapDouble(List<List<Map<String, Map<String, List<Map<String, double>>>>>> value) => data['listListMapMapListMapDouble'] = DbQueryField.convertToBaseType(value);
  set listListMapMapListMapAddress(List<List<Map<String, Map<String, List<Map<String, Address>>>>>> value) => data['listListMapMapListMapAddress'] = DbQueryField.convertToBaseType(value);
  set listListMapMapListMapObjectId(List<List<Map<String, Map<String, List<Map<String, ObjectId>>>>>> value) => data['listListMapMapListMapObjectId'] = DbQueryField.convertToBaseType(value);
  set mapMapListListMapListDouble(Map<String, Map<String, List<List<Map<String, List<double>>>>>> value) => data['mapMapListListMapListDouble'] = DbQueryField.convertToBaseType(value);
  set mapMapListListMapListAddress(Map<String, Map<String, List<List<Map<String, List<Address>>>>>> value) => data['mapMapListListMapListAddress'] = DbQueryField.convertToBaseType(value);
  set mapMapListListMapListObjectId(Map<String, Map<String, List<List<Map<String, List<ObjectId>>>>>> value) => data['mapMapListListMapListObjectId'] = DbQueryField.convertToBaseType(value);
}

class ComplexQuery {
  static const $tableName = 'complex';
  static DbQueryField<ObjectId, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get id => DbQueryField('_id');
  static DbQueryField<int, int, DBUnsupportArrayOperate> get baseInt => DbQueryField('baseInt');
  static DbQueryField<double, double, DBUnsupportArrayOperate> get baseDouble => DbQueryField('baseDouble');
  static DbQueryField<num, num, DBUnsupportArrayOperate> get baseNum => DbQueryField('baseNum');
  static DbQueryField<bool, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get baseBool => DbQueryField('baseBool');
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get baseString => DbQueryField('baseString');
  static DbQueryField<Address, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get baseAddress => DbQueryField('baseAddress');
  static DbQueryField<ObjectId, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get baseObjectId => DbQueryField('baseObjectId');
  static DbQueryField<List<int>, DBUnsupportNumberOperate, int> get listInt => DbQueryField('listInt');
  static DbQueryField<List<double>, DBUnsupportNumberOperate, double> get listDouble => DbQueryField('listDouble');
  static DbQueryField<List<num>, DBUnsupportNumberOperate, num> get listNum => DbQueryField('listNum');
  static DbQueryField<List<bool>, DBUnsupportNumberOperate, bool> get listBool => DbQueryField('listBool');
  static DbQueryField<List<String>, DBUnsupportNumberOperate, String> get listString => DbQueryField('listString');
  static DbQueryField<List<Address>, DBUnsupportNumberOperate, Address> get listAddress => DbQueryField('listAddress');
  static DbQueryField<List<ObjectId>, DBUnsupportNumberOperate, ObjectId> get listObjectId => DbQueryField('listObjectId');
  static DbQueryField<Map<String, int>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get mapInt => DbQueryField('mapInt');
  static DbQueryField<Map<String, double>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get mapDouble => DbQueryField('mapDouble');
  static DbQueryField<Map<String, num>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get mapNum => DbQueryField('mapNum');
  static DbQueryField<Map<String, bool>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get mapBool => DbQueryField('mapBool');
  static DbQueryField<Map<String, String>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get mapString => DbQueryField('mapString');
  static DbQueryField<Map<String, Address>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get mapAddress => DbQueryField('mapAddress');
  static DbQueryField<Map<String, ObjectId>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get mapObjectId => DbQueryField('mapObjectId');
  static DbQueryField<List<List<Map<String, Map<String, List<Map<String, double>>>>>>, DBUnsupportNumberOperate, List<Map<String, Map<String, List<Map<String, double>>>>>> get listListMapMapListMapDouble => DbQueryField('listListMapMapListMapDouble');
  static DbQueryField<List<List<Map<String, Map<String, List<Map<String, Address>>>>>>, DBUnsupportNumberOperate, List<Map<String, Map<String, List<Map<String, Address>>>>>> get listListMapMapListMapAddress => DbQueryField('listListMapMapListMapAddress');
  static DbQueryField<List<List<Map<String, Map<String, List<Map<String, ObjectId>>>>>>, DBUnsupportNumberOperate, List<Map<String, Map<String, List<Map<String, ObjectId>>>>>> get listListMapMapListMapObjectId => DbQueryField('listListMapMapListMapObjectId');
  static DbQueryField<Map<String, Map<String, List<List<Map<String, List<double>>>>>>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get mapMapListListMapListDouble => DbQueryField('mapMapListListMapListDouble');
  static DbQueryField<Map<String, Map<String, List<List<Map<String, List<Address>>>>>>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get mapMapListListMapListAddress => DbQueryField('mapMapListListMapListAddress');
  static DbQueryField<Map<String, Map<String, List<List<Map<String, List<ObjectId>>>>>>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get mapMapListListMapListObjectId => DbQueryField('mapMapListListMapListObjectId');
}

import 'package:shelf_easy/shelf_easy.dart';
import 'address.dart';

///
///复杂字段类
///
class Complex extends DbBaseModel {
  ///Field _id
  ObjectId _id;

  ///Field baseInt
  int baseInt;

  ///Field baseDouble
  double baseDouble;

  ///Field baseNum
  num baseNum;

  ///Field baseBool
  bool baseBool;

  ///Field baseString
  String baseString;

  ///Field baseAddress
  Address baseAddress;

  ///Field baseObjectId
  ObjectId baseObjectId;

  ///Field baseJsonWraper
  DbJsonWraper baseJsonWraper;

  ///Field listInt
  List<int> listInt;

  ///Field listDouble
  List<double> listDouble;

  ///Field listNum
  List<num> listNum;

  ///Field listBool
  List<bool> listBool;

  ///Field listString
  List<String> listString;

  ///Field listAddress
  List<Address> listAddress;

  ///Field listObjectId
  List<ObjectId> listObjectId;

  ///Field mapInt
  Map<String, int> mapInt;

  ///Field mapDouble
  Map<String, double> mapDouble;

  ///Field mapNum
  Map<String, num> mapNum;

  ///Field mapBool
  Map<String, bool> mapBool;

  ///Field mapString
  Map<String, String> mapString;

  ///Field mapAddress
  Map<String, Address> mapAddress;

  ///Field mapObjectId
  Map<String, ObjectId> mapObjectId;

  ///Field map2Int
  Map<int, int> map2Int;

  ///Field map2Double
  Map<int, double> map2Double;

  ///Field map2Num
  Map<int, num> map2Num;

  ///Field map2Bool
  Map<int, bool> map2Bool;

  ///Field map2String
  Map<int, String> map2String;

  ///Field map2Address
  Map<int, Address> map2Address;

  ///Field map2ObjectId
  Map<int, ObjectId> map2ObjectId;

  ///Field map3Int
  Map<double, int> map3Int;

  ///Field map3Double
  Map<double, double> map3Double;

  ///Field map3Num
  Map<double, num> map3Num;

  ///Field map3Bool
  Map<double, bool> map3Bool;

  ///Field map3String
  Map<double, String> map3String;

  ///Field map3Address
  Map<double, Address> map3Address;

  ///Field map3ObjectId
  Map<double, ObjectId> map3ObjectId;

  ///Field map4Int
  Map<bool, int> map4Int;

  ///Field map4Double
  Map<bool, double> map4Double;

  ///Field map4Num
  Map<bool, num> map4Num;

  ///Field map4Bool
  Map<bool, bool> map4Bool;

  ///Field map4String
  Map<bool, String> map4String;

  ///Field map4Address
  Map<bool, Address> map4Address;

  ///Field map4ObjectId
  Map<bool, ObjectId> map4ObjectId;

  ///Field map5Int
  Map<ObjectId, int> map5Int;

  ///Field map5Double
  Map<ObjectId, double> map5Double;

  ///Field map5Num
  Map<ObjectId, num> map5Num;

  ///Field map5Bool
  Map<ObjectId, bool> map5Bool;

  ///Field map5String
  Map<ObjectId, String> map5String;

  ///Field map5Address
  Map<ObjectId, Address> map5Address;

  ///Field map5ObjectId
  Map<ObjectId, ObjectId> map5ObjectId;

  ///Field map6Int
  Map<Address, int> map6Int;

  ///Field map6Double
  Map<Address, double> map6Double;

  ///Field map6Num
  Map<Address, num> map6Num;

  ///Field map6Bool
  Map<Address, bool> map6Bool;

  ///Field map6String
  Map<Address, String> map6String;

  ///Field map6Address
  Map<Address, Address> map6Address;

  ///Field map6ObjectId
  Map<Address, ObjectId> map6ObjectId;

  ///Field listListMapMapListMapDouble
  List<List<Map<String, Map<String, List<Map<String, double>>>>>> listListMapMapListMapDouble;

  ///Field listListMapMapListMapAddress
  List<List<Map<String, Map<String, List<Map<String, Address>>>>>> listListMapMapListMapAddress;

  ///Field listListMapMapListMapObjectId
  List<List<Map<String, Map<String, List<Map<String, ObjectId>>>>>> listListMapMapListMapObjectId;

  ///Field mapMapListListMapListDouble
  Map<String, Map<String, List<List<Map<String, List<double>>>>>> mapMapListListMapListDouble;

  ///Field mapMapListListMapListAddress
  Map<String, Map<String, List<List<Map<String, List<Address>>>>>> mapMapListListMapListAddress;

  ///Field mapMapListListMapListObjectId
  Map<String, Map<String, List<List<Map<String, List<ObjectId>>>>>> mapMapListListMapListObjectId;

  ///Field _id
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
    DbJsonWraper? baseJsonWraper,
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
    Map<int, int>? map2Int,
    Map<int, double>? map2Double,
    Map<int, num>? map2Num,
    Map<int, bool>? map2Bool,
    Map<int, String>? map2String,
    Map<int, Address>? map2Address,
    Map<int, ObjectId>? map2ObjectId,
    Map<double, int>? map3Int,
    Map<double, double>? map3Double,
    Map<double, num>? map3Num,
    Map<double, bool>? map3Bool,
    Map<double, String>? map3String,
    Map<double, Address>? map3Address,
    Map<double, ObjectId>? map3ObjectId,
    Map<bool, int>? map4Int,
    Map<bool, double>? map4Double,
    Map<bool, num>? map4Num,
    Map<bool, bool>? map4Bool,
    Map<bool, String>? map4String,
    Map<bool, Address>? map4Address,
    Map<bool, ObjectId>? map4ObjectId,
    Map<ObjectId, int>? map5Int,
    Map<ObjectId, double>? map5Double,
    Map<ObjectId, num>? map5Num,
    Map<ObjectId, bool>? map5Bool,
    Map<ObjectId, String>? map5String,
    Map<ObjectId, Address>? map5Address,
    Map<ObjectId, ObjectId>? map5ObjectId,
    Map<Address, int>? map6Int,
    Map<Address, double>? map6Double,
    Map<Address, num>? map6Num,
    Map<Address, bool>? map6Bool,
    Map<Address, String>? map6String,
    Map<Address, Address>? map6Address,
    Map<Address, ObjectId>? map6ObjectId,
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
        baseObjectId = baseObjectId ?? ObjectId.fromHexString('000000000000000000000000'),
        baseJsonWraper = baseJsonWraper ?? DbJsonWraper(),
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
        map2Int = map2Int ?? {},
        map2Double = map2Double ?? {},
        map2Num = map2Num ?? {},
        map2Bool = map2Bool ?? {},
        map2String = map2String ?? {},
        map2Address = map2Address ?? {},
        map2ObjectId = map2ObjectId ?? {},
        map3Int = map3Int ?? {},
        map3Double = map3Double ?? {},
        map3Num = map3Num ?? {},
        map3Bool = map3Bool ?? {},
        map3String = map3String ?? {},
        map3Address = map3Address ?? {},
        map3ObjectId = map3ObjectId ?? {},
        map4Int = map4Int ?? {},
        map4Double = map4Double ?? {},
        map4Num = map4Num ?? {},
        map4Bool = map4Bool ?? {},
        map4String = map4String ?? {},
        map4Address = map4Address ?? {},
        map4ObjectId = map4ObjectId ?? {},
        map5Int = map5Int ?? {},
        map5Double = map5Double ?? {},
        map5Num = map5Num ?? {},
        map5Bool = map5Bool ?? {},
        map5String = map5String ?? {},
        map5Address = map5Address ?? {},
        map5ObjectId = map5ObjectId ?? {},
        map6Int = map6Int ?? {},
        map6Double = map6Double ?? {},
        map6Num = map6Num ?? {},
        map6Bool = map6Bool ?? {},
        map6String = map6String ?? {},
        map6Address = map6Address ?? {},
        map6ObjectId = map6ObjectId ?? {},
        listListMapMapListMapDouble = listListMapMapListMapDouble ?? [],
        listListMapMapListMapAddress = listListMapMapListMapAddress ?? [],
        listListMapMapListMapObjectId = listListMapMapListMapObjectId ?? [],
        mapMapListListMapListDouble = mapMapListListMapListDouble ?? {},
        mapMapListListMapListAddress = mapMapListListMapListAddress ?? {},
        mapMapListListMapListObjectId = mapMapListListMapListObjectId ?? {};

  factory Complex.fromString(String data) {
    return Complex.fromJson(jsonDecode(data.substring(data.indexOf('(') + 1, data.lastIndexOf(')'))));
  }

  factory Complex.fromJson(Map<String, dynamic> map) {
    return Complex(
      id: DbQueryField.tryParseObjectId(map['_id']),
      baseInt: DbQueryField.tryParseInt(map['baseInt']),
      baseDouble: DbQueryField.tryParseDouble(map['baseDouble']),
      baseNum: DbQueryField.tryParseNum(map['baseNum']),
      baseBool: DbQueryField.tryParseBool(map['baseBool']),
      baseString: DbQueryField.tryParseString(map['baseString']),
      baseAddress: map['baseAddress'] is Map ? Address.fromJson(map['baseAddress']) : map['baseAddress'],
      baseObjectId: DbQueryField.tryParseObjectId(map['baseObjectId']),
      baseJsonWraper: map['baseJsonWraper'] is Map ? DbJsonWraper.fromJson(map['baseJsonWraper']) : map['baseJsonWraper'],
      listInt: (map['listInt'] as List?)?.map((v) => DbQueryField.parseInt(v)).toList(),
      listDouble: (map['listDouble'] as List?)?.map((v) => DbQueryField.parseDouble(v)).toList(),
      listNum: (map['listNum'] as List?)?.map((v) => DbQueryField.parseNum(v)).toList(),
      listBool: (map['listBool'] as List?)?.map((v) => DbQueryField.parseBool(v)).toList(),
      listString: (map['listString'] as List?)?.map((v) => DbQueryField.parseString(v)).toList(),
      listAddress: (map['listAddress'] as List?)?.map((v) => Address.fromJson(v)).toList(),
      listObjectId: (map['listObjectId'] as List?)?.map((v) => DbQueryField.parseObjectId(v)).toList(),
      mapInt: (map['mapInt'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseString(k), DbQueryField.parseInt(v))),
      mapDouble: (map['mapDouble'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseString(k), DbQueryField.parseDouble(v))),
      mapNum: (map['mapNum'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseString(k), DbQueryField.parseNum(v))),
      mapBool: (map['mapBool'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseString(k), DbQueryField.parseBool(v))),
      mapString: (map['mapString'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseString(k), DbQueryField.parseString(v))),
      mapAddress: (map['mapAddress'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseString(k), Address.fromJson(v))),
      mapObjectId: (map['mapObjectId'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseString(k), DbQueryField.parseObjectId(v))),
      map2Int: (map['map2Int'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseInt(k), DbQueryField.parseInt(v))),
      map2Double: (map['map2Double'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseInt(k), DbQueryField.parseDouble(v))),
      map2Num: (map['map2Num'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseInt(k), DbQueryField.parseNum(v))),
      map2Bool: (map['map2Bool'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseInt(k), DbQueryField.parseBool(v))),
      map2String: (map['map2String'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseInt(k), DbQueryField.parseString(v))),
      map2Address: (map['map2Address'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseInt(k), Address.fromJson(v))),
      map2ObjectId: (map['map2ObjectId'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseInt(k), DbQueryField.parseObjectId(v))),
      map3Int: (map['map3Int'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseDouble(k), DbQueryField.parseInt(v))),
      map3Double: (map['map3Double'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseDouble(k), DbQueryField.parseDouble(v))),
      map3Num: (map['map3Num'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseDouble(k), DbQueryField.parseNum(v))),
      map3Bool: (map['map3Bool'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseDouble(k), DbQueryField.parseBool(v))),
      map3String: (map['map3String'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseDouble(k), DbQueryField.parseString(v))),
      map3Address: (map['map3Address'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseDouble(k), Address.fromJson(v))),
      map3ObjectId: (map['map3ObjectId'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseDouble(k), DbQueryField.parseObjectId(v))),
      map4Int: (map['map4Int'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseBool(k), DbQueryField.parseInt(v))),
      map4Double: (map['map4Double'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseBool(k), DbQueryField.parseDouble(v))),
      map4Num: (map['map4Num'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseBool(k), DbQueryField.parseNum(v))),
      map4Bool: (map['map4Bool'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseBool(k), DbQueryField.parseBool(v))),
      map4String: (map['map4String'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseBool(k), DbQueryField.parseString(v))),
      map4Address: (map['map4Address'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseBool(k), Address.fromJson(v))),
      map4ObjectId: (map['map4ObjectId'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseBool(k), DbQueryField.parseObjectId(v))),
      map5Int: (map['map5Int'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseObjectId(k), DbQueryField.parseInt(v))),
      map5Double: (map['map5Double'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseObjectId(k), DbQueryField.parseDouble(v))),
      map5Num: (map['map5Num'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseObjectId(k), DbQueryField.parseNum(v))),
      map5Bool: (map['map5Bool'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseObjectId(k), DbQueryField.parseBool(v))),
      map5String: (map['map5String'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseObjectId(k), DbQueryField.parseString(v))),
      map5Address: (map['map5Address'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseObjectId(k), Address.fromJson(v))),
      map5ObjectId: (map['map5ObjectId'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseObjectId(k), DbQueryField.parseObjectId(v))),
      map6Int: (map['map6Int'] as Map?)?.map((k, v) => MapEntry(Address.fromString(k), DbQueryField.parseInt(v))),
      map6Double: (map['map6Double'] as Map?)?.map((k, v) => MapEntry(Address.fromString(k), DbQueryField.parseDouble(v))),
      map6Num: (map['map6Num'] as Map?)?.map((k, v) => MapEntry(Address.fromString(k), DbQueryField.parseNum(v))),
      map6Bool: (map['map6Bool'] as Map?)?.map((k, v) => MapEntry(Address.fromString(k), DbQueryField.parseBool(v))),
      map6String: (map['map6String'] as Map?)?.map((k, v) => MapEntry(Address.fromString(k), DbQueryField.parseString(v))),
      map6Address: (map['map6Address'] as Map?)?.map((k, v) => MapEntry(Address.fromString(k), Address.fromJson(v))),
      map6ObjectId: (map['map6ObjectId'] as Map?)?.map((k, v) => MapEntry(Address.fromString(k), DbQueryField.parseObjectId(v))),
      listListMapMapListMapDouble: (map['listListMapMapListMapDouble'] as List?)?.map((v) => (v as List).map((v) => (v as Map).map((k, v) => MapEntry(DbQueryField.parseString(k), (v as Map).map((k, v) => MapEntry(DbQueryField.parseString(k), (v as List).map((v) => (v as Map).map((k, v) => MapEntry(DbQueryField.parseString(k), DbQueryField.parseDouble(v)))).toList()))))).toList()).toList(),
      listListMapMapListMapAddress: (map['listListMapMapListMapAddress'] as List?)?.map((v) => (v as List).map((v) => (v as Map).map((k, v) => MapEntry(DbQueryField.parseString(k), (v as Map).map((k, v) => MapEntry(DbQueryField.parseString(k), (v as List).map((v) => (v as Map).map((k, v) => MapEntry(DbQueryField.parseString(k), Address.fromJson(v)))).toList()))))).toList()).toList(),
      listListMapMapListMapObjectId: (map['listListMapMapListMapObjectId'] as List?)?.map((v) => (v as List).map((v) => (v as Map).map((k, v) => MapEntry(DbQueryField.parseString(k), (v as Map).map((k, v) => MapEntry(DbQueryField.parseString(k), (v as List).map((v) => (v as Map).map((k, v) => MapEntry(DbQueryField.parseString(k), DbQueryField.parseObjectId(v)))).toList()))))).toList()).toList(),
      mapMapListListMapListDouble: (map['mapMapListListMapListDouble'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseString(k), (v as Map).map((k, v) => MapEntry(DbQueryField.parseString(k), (v as List).map((v) => (v as List).map((v) => (v as Map).map((k, v) => MapEntry(DbQueryField.parseString(k), (v as List).map((v) => DbQueryField.parseDouble(v)).toList()))).toList()).toList())))),
      mapMapListListMapListAddress: (map['mapMapListListMapListAddress'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseString(k), (v as Map).map((k, v) => MapEntry(DbQueryField.parseString(k), (v as List).map((v) => (v as List).map((v) => (v as Map).map((k, v) => MapEntry(DbQueryField.parseString(k), (v as List).map((v) => Address.fromJson(v)).toList()))).toList()).toList())))),
      mapMapListListMapListObjectId: (map['mapMapListListMapListObjectId'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseString(k), (v as Map).map((k, v) => MapEntry(DbQueryField.parseString(k), (v as List).map((v) => (v as List).map((v) => (v as Map).map((k, v) => MapEntry(DbQueryField.parseString(k), (v as List).map((v) => DbQueryField.parseObjectId(v)).toList()))).toList()).toList())))),
    );
  }

  @override
  String toString() {
    return 'Complex(${jsonEncode(toJson())})';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '_id': DbQueryField.toBaseType(_id),
      'baseInt': DbQueryField.toBaseType(baseInt),
      'baseDouble': DbQueryField.toBaseType(baseDouble),
      'baseNum': DbQueryField.toBaseType(baseNum),
      'baseBool': DbQueryField.toBaseType(baseBool),
      'baseString': DbQueryField.toBaseType(baseString),
      'baseAddress': DbQueryField.toBaseType(baseAddress),
      'baseObjectId': DbQueryField.toBaseType(baseObjectId),
      'baseJsonWraper': DbQueryField.toBaseType(baseJsonWraper),
      'listInt': DbQueryField.toBaseType(listInt),
      'listDouble': DbQueryField.toBaseType(listDouble),
      'listNum': DbQueryField.toBaseType(listNum),
      'listBool': DbQueryField.toBaseType(listBool),
      'listString': DbQueryField.toBaseType(listString),
      'listAddress': DbQueryField.toBaseType(listAddress),
      'listObjectId': DbQueryField.toBaseType(listObjectId),
      'mapInt': DbQueryField.toBaseType(mapInt),
      'mapDouble': DbQueryField.toBaseType(mapDouble),
      'mapNum': DbQueryField.toBaseType(mapNum),
      'mapBool': DbQueryField.toBaseType(mapBool),
      'mapString': DbQueryField.toBaseType(mapString),
      'mapAddress': DbQueryField.toBaseType(mapAddress),
      'mapObjectId': DbQueryField.toBaseType(mapObjectId),
      'map2Int': DbQueryField.toBaseType(map2Int),
      'map2Double': DbQueryField.toBaseType(map2Double),
      'map2Num': DbQueryField.toBaseType(map2Num),
      'map2Bool': DbQueryField.toBaseType(map2Bool),
      'map2String': DbQueryField.toBaseType(map2String),
      'map2Address': DbQueryField.toBaseType(map2Address),
      'map2ObjectId': DbQueryField.toBaseType(map2ObjectId),
      'map3Int': DbQueryField.toBaseType(map3Int),
      'map3Double': DbQueryField.toBaseType(map3Double),
      'map3Num': DbQueryField.toBaseType(map3Num),
      'map3Bool': DbQueryField.toBaseType(map3Bool),
      'map3String': DbQueryField.toBaseType(map3String),
      'map3Address': DbQueryField.toBaseType(map3Address),
      'map3ObjectId': DbQueryField.toBaseType(map3ObjectId),
      'map4Int': DbQueryField.toBaseType(map4Int),
      'map4Double': DbQueryField.toBaseType(map4Double),
      'map4Num': DbQueryField.toBaseType(map4Num),
      'map4Bool': DbQueryField.toBaseType(map4Bool),
      'map4String': DbQueryField.toBaseType(map4String),
      'map4Address': DbQueryField.toBaseType(map4Address),
      'map4ObjectId': DbQueryField.toBaseType(map4ObjectId),
      'map5Int': DbQueryField.toBaseType(map5Int),
      'map5Double': DbQueryField.toBaseType(map5Double),
      'map5Num': DbQueryField.toBaseType(map5Num),
      'map5Bool': DbQueryField.toBaseType(map5Bool),
      'map5String': DbQueryField.toBaseType(map5String),
      'map5Address': DbQueryField.toBaseType(map5Address),
      'map5ObjectId': DbQueryField.toBaseType(map5ObjectId),
      'map6Int': DbQueryField.toBaseType(map6Int),
      'map6Double': DbQueryField.toBaseType(map6Double),
      'map6Num': DbQueryField.toBaseType(map6Num),
      'map6Bool': DbQueryField.toBaseType(map6Bool),
      'map6String': DbQueryField.toBaseType(map6String),
      'map6Address': DbQueryField.toBaseType(map6Address),
      'map6ObjectId': DbQueryField.toBaseType(map6ObjectId),
      'listListMapMapListMapDouble': DbQueryField.toBaseType(listListMapMapListMapDouble),
      'listListMapMapListMapAddress': DbQueryField.toBaseType(listListMapMapListMapAddress),
      'listListMapMapListMapObjectId': DbQueryField.toBaseType(listListMapMapListMapObjectId),
      'mapMapListListMapListDouble': DbQueryField.toBaseType(mapMapListListMapListDouble),
      'mapMapListListMapListAddress': DbQueryField.toBaseType(mapMapListListMapListAddress),
      'mapMapListListMapListObjectId': DbQueryField.toBaseType(mapMapListListMapListObjectId),
    };
  }

  @override
  Map<String, dynamic> toKValues() {
    return {
      '_id': _id,
      'baseInt': baseInt,
      'baseDouble': baseDouble,
      'baseNum': baseNum,
      'baseBool': baseBool,
      'baseString': baseString,
      'baseAddress': baseAddress,
      'baseObjectId': baseObjectId,
      'baseJsonWraper': baseJsonWraper,
      'listInt': listInt,
      'listDouble': listDouble,
      'listNum': listNum,
      'listBool': listBool,
      'listString': listString,
      'listAddress': listAddress,
      'listObjectId': listObjectId,
      'mapInt': mapInt,
      'mapDouble': mapDouble,
      'mapNum': mapNum,
      'mapBool': mapBool,
      'mapString': mapString,
      'mapAddress': mapAddress,
      'mapObjectId': mapObjectId,
      'map2Int': map2Int,
      'map2Double': map2Double,
      'map2Num': map2Num,
      'map2Bool': map2Bool,
      'map2String': map2String,
      'map2Address': map2Address,
      'map2ObjectId': map2ObjectId,
      'map3Int': map3Int,
      'map3Double': map3Double,
      'map3Num': map3Num,
      'map3Bool': map3Bool,
      'map3String': map3String,
      'map3Address': map3Address,
      'map3ObjectId': map3ObjectId,
      'map4Int': map4Int,
      'map4Double': map4Double,
      'map4Num': map4Num,
      'map4Bool': map4Bool,
      'map4String': map4String,
      'map4Address': map4Address,
      'map4ObjectId': map4ObjectId,
      'map5Int': map5Int,
      'map5Double': map5Double,
      'map5Num': map5Num,
      'map5Bool': map5Bool,
      'map5String': map5String,
      'map5Address': map5Address,
      'map5ObjectId': map5ObjectId,
      'map6Int': map6Int,
      'map6Double': map6Double,
      'map6Num': map6Num,
      'map6Bool': map6Bool,
      'map6String': map6String,
      'map6Address': map6Address,
      'map6ObjectId': map6ObjectId,
      'listListMapMapListMapDouble': listListMapMapListMapDouble,
      'listListMapMapListMapAddress': listListMapMapListMapAddress,
      'listListMapMapListMapObjectId': listListMapMapListMapObjectId,
      'mapMapListListMapListDouble': mapMapListListMapListDouble,
      'mapMapListListMapListAddress': mapMapListListMapListAddress,
      'mapMapListListMapListObjectId': mapMapListListMapListObjectId,
    };
  }

  @override
  void updateByJson(Map<String, dynamic> map, {Complex? parser}) {
    parser = parser ?? Complex.fromJson(map);
    if (map.containsKey('_id')) _id = parser._id;
    if (map.containsKey('baseInt')) baseInt = parser.baseInt;
    if (map.containsKey('baseDouble')) baseDouble = parser.baseDouble;
    if (map.containsKey('baseNum')) baseNum = parser.baseNum;
    if (map.containsKey('baseBool')) baseBool = parser.baseBool;
    if (map.containsKey('baseString')) baseString = parser.baseString;
    if (map.containsKey('baseAddress')) baseAddress = parser.baseAddress;
    if (map.containsKey('baseObjectId')) baseObjectId = parser.baseObjectId;
    if (map.containsKey('baseJsonWraper')) baseJsonWraper = parser.baseJsonWraper;
    if (map.containsKey('listInt')) listInt = parser.listInt;
    if (map.containsKey('listDouble')) listDouble = parser.listDouble;
    if (map.containsKey('listNum')) listNum = parser.listNum;
    if (map.containsKey('listBool')) listBool = parser.listBool;
    if (map.containsKey('listString')) listString = parser.listString;
    if (map.containsKey('listAddress')) listAddress = parser.listAddress;
    if (map.containsKey('listObjectId')) listObjectId = parser.listObjectId;
    if (map.containsKey('mapInt')) mapInt = parser.mapInt;
    if (map.containsKey('mapDouble')) mapDouble = parser.mapDouble;
    if (map.containsKey('mapNum')) mapNum = parser.mapNum;
    if (map.containsKey('mapBool')) mapBool = parser.mapBool;
    if (map.containsKey('mapString')) mapString = parser.mapString;
    if (map.containsKey('mapAddress')) mapAddress = parser.mapAddress;
    if (map.containsKey('mapObjectId')) mapObjectId = parser.mapObjectId;
    if (map.containsKey('map2Int')) map2Int = parser.map2Int;
    if (map.containsKey('map2Double')) map2Double = parser.map2Double;
    if (map.containsKey('map2Num')) map2Num = parser.map2Num;
    if (map.containsKey('map2Bool')) map2Bool = parser.map2Bool;
    if (map.containsKey('map2String')) map2String = parser.map2String;
    if (map.containsKey('map2Address')) map2Address = parser.map2Address;
    if (map.containsKey('map2ObjectId')) map2ObjectId = parser.map2ObjectId;
    if (map.containsKey('map3Int')) map3Int = parser.map3Int;
    if (map.containsKey('map3Double')) map3Double = parser.map3Double;
    if (map.containsKey('map3Num')) map3Num = parser.map3Num;
    if (map.containsKey('map3Bool')) map3Bool = parser.map3Bool;
    if (map.containsKey('map3String')) map3String = parser.map3String;
    if (map.containsKey('map3Address')) map3Address = parser.map3Address;
    if (map.containsKey('map3ObjectId')) map3ObjectId = parser.map3ObjectId;
    if (map.containsKey('map4Int')) map4Int = parser.map4Int;
    if (map.containsKey('map4Double')) map4Double = parser.map4Double;
    if (map.containsKey('map4Num')) map4Num = parser.map4Num;
    if (map.containsKey('map4Bool')) map4Bool = parser.map4Bool;
    if (map.containsKey('map4String')) map4String = parser.map4String;
    if (map.containsKey('map4Address')) map4Address = parser.map4Address;
    if (map.containsKey('map4ObjectId')) map4ObjectId = parser.map4ObjectId;
    if (map.containsKey('map5Int')) map5Int = parser.map5Int;
    if (map.containsKey('map5Double')) map5Double = parser.map5Double;
    if (map.containsKey('map5Num')) map5Num = parser.map5Num;
    if (map.containsKey('map5Bool')) map5Bool = parser.map5Bool;
    if (map.containsKey('map5String')) map5String = parser.map5String;
    if (map.containsKey('map5Address')) map5Address = parser.map5Address;
    if (map.containsKey('map5ObjectId')) map5ObjectId = parser.map5ObjectId;
    if (map.containsKey('map6Int')) map6Int = parser.map6Int;
    if (map.containsKey('map6Double')) map6Double = parser.map6Double;
    if (map.containsKey('map6Num')) map6Num = parser.map6Num;
    if (map.containsKey('map6Bool')) map6Bool = parser.map6Bool;
    if (map.containsKey('map6String')) map6String = parser.map6String;
    if (map.containsKey('map6Address')) map6Address = parser.map6Address;
    if (map.containsKey('map6ObjectId')) map6ObjectId = parser.map6ObjectId;
    if (map.containsKey('listListMapMapListMapDouble')) listListMapMapListMapDouble = parser.listListMapMapListMapDouble;
    if (map.containsKey('listListMapMapListMapAddress')) listListMapMapListMapAddress = parser.listListMapMapListMapAddress;
    if (map.containsKey('listListMapMapListMapObjectId')) listListMapMapListMapObjectId = parser.listListMapMapListMapObjectId;
    if (map.containsKey('mapMapListListMapListDouble')) mapMapListListMapListDouble = parser.mapMapListListMapListDouble;
    if (map.containsKey('mapMapListListMapListAddress')) mapMapListListMapListAddress = parser.mapMapListListMapListAddress;
    if (map.containsKey('mapMapListListMapListObjectId')) mapMapListListMapListObjectId = parser.mapMapListListMapListObjectId;
  }

  @override
  void updateByKValues(Map<String, dynamic> map) {
    if (map.containsKey('_id')) _id = map['_id'];
    if (map.containsKey('baseInt')) baseInt = map['baseInt'];
    if (map.containsKey('baseDouble')) baseDouble = map['baseDouble'];
    if (map.containsKey('baseNum')) baseNum = map['baseNum'];
    if (map.containsKey('baseBool')) baseBool = map['baseBool'];
    if (map.containsKey('baseString')) baseString = map['baseString'];
    if (map.containsKey('baseAddress')) baseAddress = map['baseAddress'];
    if (map.containsKey('baseObjectId')) baseObjectId = map['baseObjectId'];
    if (map.containsKey('baseJsonWraper')) baseJsonWraper = map['baseJsonWraper'];
    if (map.containsKey('listInt')) listInt = map['listInt'];
    if (map.containsKey('listDouble')) listDouble = map['listDouble'];
    if (map.containsKey('listNum')) listNum = map['listNum'];
    if (map.containsKey('listBool')) listBool = map['listBool'];
    if (map.containsKey('listString')) listString = map['listString'];
    if (map.containsKey('listAddress')) listAddress = map['listAddress'];
    if (map.containsKey('listObjectId')) listObjectId = map['listObjectId'];
    if (map.containsKey('mapInt')) mapInt = map['mapInt'];
    if (map.containsKey('mapDouble')) mapDouble = map['mapDouble'];
    if (map.containsKey('mapNum')) mapNum = map['mapNum'];
    if (map.containsKey('mapBool')) mapBool = map['mapBool'];
    if (map.containsKey('mapString')) mapString = map['mapString'];
    if (map.containsKey('mapAddress')) mapAddress = map['mapAddress'];
    if (map.containsKey('mapObjectId')) mapObjectId = map['mapObjectId'];
    if (map.containsKey('map2Int')) map2Int = map['map2Int'];
    if (map.containsKey('map2Double')) map2Double = map['map2Double'];
    if (map.containsKey('map2Num')) map2Num = map['map2Num'];
    if (map.containsKey('map2Bool')) map2Bool = map['map2Bool'];
    if (map.containsKey('map2String')) map2String = map['map2String'];
    if (map.containsKey('map2Address')) map2Address = map['map2Address'];
    if (map.containsKey('map2ObjectId')) map2ObjectId = map['map2ObjectId'];
    if (map.containsKey('map3Int')) map3Int = map['map3Int'];
    if (map.containsKey('map3Double')) map3Double = map['map3Double'];
    if (map.containsKey('map3Num')) map3Num = map['map3Num'];
    if (map.containsKey('map3Bool')) map3Bool = map['map3Bool'];
    if (map.containsKey('map3String')) map3String = map['map3String'];
    if (map.containsKey('map3Address')) map3Address = map['map3Address'];
    if (map.containsKey('map3ObjectId')) map3ObjectId = map['map3ObjectId'];
    if (map.containsKey('map4Int')) map4Int = map['map4Int'];
    if (map.containsKey('map4Double')) map4Double = map['map4Double'];
    if (map.containsKey('map4Num')) map4Num = map['map4Num'];
    if (map.containsKey('map4Bool')) map4Bool = map['map4Bool'];
    if (map.containsKey('map4String')) map4String = map['map4String'];
    if (map.containsKey('map4Address')) map4Address = map['map4Address'];
    if (map.containsKey('map4ObjectId')) map4ObjectId = map['map4ObjectId'];
    if (map.containsKey('map5Int')) map5Int = map['map5Int'];
    if (map.containsKey('map5Double')) map5Double = map['map5Double'];
    if (map.containsKey('map5Num')) map5Num = map['map5Num'];
    if (map.containsKey('map5Bool')) map5Bool = map['map5Bool'];
    if (map.containsKey('map5String')) map5String = map['map5String'];
    if (map.containsKey('map5Address')) map5Address = map['map5Address'];
    if (map.containsKey('map5ObjectId')) map5ObjectId = map['map5ObjectId'];
    if (map.containsKey('map6Int')) map6Int = map['map6Int'];
    if (map.containsKey('map6Double')) map6Double = map['map6Double'];
    if (map.containsKey('map6Num')) map6Num = map['map6Num'];
    if (map.containsKey('map6Bool')) map6Bool = map['map6Bool'];
    if (map.containsKey('map6String')) map6String = map['map6String'];
    if (map.containsKey('map6Address')) map6Address = map['map6Address'];
    if (map.containsKey('map6ObjectId')) map6ObjectId = map['map6ObjectId'];
    if (map.containsKey('listListMapMapListMapDouble')) listListMapMapListMapDouble = map['listListMapMapListMapDouble'];
    if (map.containsKey('listListMapMapListMapAddress')) listListMapMapListMapAddress = map['listListMapMapListMapAddress'];
    if (map.containsKey('listListMapMapListMapObjectId')) listListMapMapListMapObjectId = map['listListMapMapListMapObjectId'];
    if (map.containsKey('mapMapListListMapListDouble')) mapMapListListMapListDouble = map['mapMapListListMapListDouble'];
    if (map.containsKey('mapMapListListMapListAddress')) mapMapListListMapListAddress = map['mapMapListListMapListAddress'];
    if (map.containsKey('mapMapListListMapListObjectId')) mapMapListListMapListObjectId = map['mapMapListListMapListObjectId'];
  }
}

class ComplexDirty {
  final Map<String, dynamic> data = {};

  ///Field _id
  set id(ObjectId value) => data['_id'] = DbQueryField.toBaseType(value);

  ///Field baseInt
  set baseInt(int value) => data['baseInt'] = DbQueryField.toBaseType(value);

  ///Field baseDouble
  set baseDouble(double value) => data['baseDouble'] = DbQueryField.toBaseType(value);

  ///Field baseNum
  set baseNum(num value) => data['baseNum'] = DbQueryField.toBaseType(value);

  ///Field baseBool
  set baseBool(bool value) => data['baseBool'] = DbQueryField.toBaseType(value);

  ///Field baseString
  set baseString(String value) => data['baseString'] = DbQueryField.toBaseType(value);

  ///Field baseAddress
  set baseAddress(Address value) => data['baseAddress'] = DbQueryField.toBaseType(value);

  ///Field baseObjectId
  set baseObjectId(ObjectId value) => data['baseObjectId'] = DbQueryField.toBaseType(value);

  ///Field baseJsonWraper
  set baseJsonWraper(DbJsonWraper value) => data['baseJsonWraper'] = DbQueryField.toBaseType(value);

  ///Field listInt
  set listInt(List<int> value) => data['listInt'] = DbQueryField.toBaseType(value);

  ///Field listDouble
  set listDouble(List<double> value) => data['listDouble'] = DbQueryField.toBaseType(value);

  ///Field listNum
  set listNum(List<num> value) => data['listNum'] = DbQueryField.toBaseType(value);

  ///Field listBool
  set listBool(List<bool> value) => data['listBool'] = DbQueryField.toBaseType(value);

  ///Field listString
  set listString(List<String> value) => data['listString'] = DbQueryField.toBaseType(value);

  ///Field listAddress
  set listAddress(List<Address> value) => data['listAddress'] = DbQueryField.toBaseType(value);

  ///Field listObjectId
  set listObjectId(List<ObjectId> value) => data['listObjectId'] = DbQueryField.toBaseType(value);

  ///Field mapInt
  set mapInt(Map<String, int> value) => data['mapInt'] = DbQueryField.toBaseType(value);

  ///Field mapDouble
  set mapDouble(Map<String, double> value) => data['mapDouble'] = DbQueryField.toBaseType(value);

  ///Field mapNum
  set mapNum(Map<String, num> value) => data['mapNum'] = DbQueryField.toBaseType(value);

  ///Field mapBool
  set mapBool(Map<String, bool> value) => data['mapBool'] = DbQueryField.toBaseType(value);

  ///Field mapString
  set mapString(Map<String, String> value) => data['mapString'] = DbQueryField.toBaseType(value);

  ///Field mapAddress
  set mapAddress(Map<String, Address> value) => data['mapAddress'] = DbQueryField.toBaseType(value);

  ///Field mapObjectId
  set mapObjectId(Map<String, ObjectId> value) => data['mapObjectId'] = DbQueryField.toBaseType(value);

  ///Field map2Int
  set map2Int(Map<int, int> value) => data['map2Int'] = DbQueryField.toBaseType(value);

  ///Field map2Double
  set map2Double(Map<int, double> value) => data['map2Double'] = DbQueryField.toBaseType(value);

  ///Field map2Num
  set map2Num(Map<int, num> value) => data['map2Num'] = DbQueryField.toBaseType(value);

  ///Field map2Bool
  set map2Bool(Map<int, bool> value) => data['map2Bool'] = DbQueryField.toBaseType(value);

  ///Field map2String
  set map2String(Map<int, String> value) => data['map2String'] = DbQueryField.toBaseType(value);

  ///Field map2Address
  set map2Address(Map<int, Address> value) => data['map2Address'] = DbQueryField.toBaseType(value);

  ///Field map2ObjectId
  set map2ObjectId(Map<int, ObjectId> value) => data['map2ObjectId'] = DbQueryField.toBaseType(value);

  ///Field map3Int
  set map3Int(Map<double, int> value) => data['map3Int'] = DbQueryField.toBaseType(value);

  ///Field map3Double
  set map3Double(Map<double, double> value) => data['map3Double'] = DbQueryField.toBaseType(value);

  ///Field map3Num
  set map3Num(Map<double, num> value) => data['map3Num'] = DbQueryField.toBaseType(value);

  ///Field map3Bool
  set map3Bool(Map<double, bool> value) => data['map3Bool'] = DbQueryField.toBaseType(value);

  ///Field map3String
  set map3String(Map<double, String> value) => data['map3String'] = DbQueryField.toBaseType(value);

  ///Field map3Address
  set map3Address(Map<double, Address> value) => data['map3Address'] = DbQueryField.toBaseType(value);

  ///Field map3ObjectId
  set map3ObjectId(Map<double, ObjectId> value) => data['map3ObjectId'] = DbQueryField.toBaseType(value);

  ///Field map4Int
  set map4Int(Map<bool, int> value) => data['map4Int'] = DbQueryField.toBaseType(value);

  ///Field map4Double
  set map4Double(Map<bool, double> value) => data['map4Double'] = DbQueryField.toBaseType(value);

  ///Field map4Num
  set map4Num(Map<bool, num> value) => data['map4Num'] = DbQueryField.toBaseType(value);

  ///Field map4Bool
  set map4Bool(Map<bool, bool> value) => data['map4Bool'] = DbQueryField.toBaseType(value);

  ///Field map4String
  set map4String(Map<bool, String> value) => data['map4String'] = DbQueryField.toBaseType(value);

  ///Field map4Address
  set map4Address(Map<bool, Address> value) => data['map4Address'] = DbQueryField.toBaseType(value);

  ///Field map4ObjectId
  set map4ObjectId(Map<bool, ObjectId> value) => data['map4ObjectId'] = DbQueryField.toBaseType(value);

  ///Field map5Int
  set map5Int(Map<ObjectId, int> value) => data['map5Int'] = DbQueryField.toBaseType(value);

  ///Field map5Double
  set map5Double(Map<ObjectId, double> value) => data['map5Double'] = DbQueryField.toBaseType(value);

  ///Field map5Num
  set map5Num(Map<ObjectId, num> value) => data['map5Num'] = DbQueryField.toBaseType(value);

  ///Field map5Bool
  set map5Bool(Map<ObjectId, bool> value) => data['map5Bool'] = DbQueryField.toBaseType(value);

  ///Field map5String
  set map5String(Map<ObjectId, String> value) => data['map5String'] = DbQueryField.toBaseType(value);

  ///Field map5Address
  set map5Address(Map<ObjectId, Address> value) => data['map5Address'] = DbQueryField.toBaseType(value);

  ///Field map5ObjectId
  set map5ObjectId(Map<ObjectId, ObjectId> value) => data['map5ObjectId'] = DbQueryField.toBaseType(value);

  ///Field map6Int
  set map6Int(Map<Address, int> value) => data['map6Int'] = DbQueryField.toBaseType(value);

  ///Field map6Double
  set map6Double(Map<Address, double> value) => data['map6Double'] = DbQueryField.toBaseType(value);

  ///Field map6Num
  set map6Num(Map<Address, num> value) => data['map6Num'] = DbQueryField.toBaseType(value);

  ///Field map6Bool
  set map6Bool(Map<Address, bool> value) => data['map6Bool'] = DbQueryField.toBaseType(value);

  ///Field map6String
  set map6String(Map<Address, String> value) => data['map6String'] = DbQueryField.toBaseType(value);

  ///Field map6Address
  set map6Address(Map<Address, Address> value) => data['map6Address'] = DbQueryField.toBaseType(value);

  ///Field map6ObjectId
  set map6ObjectId(Map<Address, ObjectId> value) => data['map6ObjectId'] = DbQueryField.toBaseType(value);

  ///Field listListMapMapListMapDouble
  set listListMapMapListMapDouble(List<List<Map<String, Map<String, List<Map<String, double>>>>>> value) => data['listListMapMapListMapDouble'] = DbQueryField.toBaseType(value);

  ///Field listListMapMapListMapAddress
  set listListMapMapListMapAddress(List<List<Map<String, Map<String, List<Map<String, Address>>>>>> value) => data['listListMapMapListMapAddress'] = DbQueryField.toBaseType(value);

  ///Field listListMapMapListMapObjectId
  set listListMapMapListMapObjectId(List<List<Map<String, Map<String, List<Map<String, ObjectId>>>>>> value) => data['listListMapMapListMapObjectId'] = DbQueryField.toBaseType(value);

  ///Field mapMapListListMapListDouble
  set mapMapListListMapListDouble(Map<String, Map<String, List<List<Map<String, List<double>>>>>> value) => data['mapMapListListMapListDouble'] = DbQueryField.toBaseType(value);

  ///Field mapMapListListMapListAddress
  set mapMapListListMapListAddress(Map<String, Map<String, List<List<Map<String, List<Address>>>>>> value) => data['mapMapListListMapListAddress'] = DbQueryField.toBaseType(value);

  ///Field mapMapListListMapListObjectId
  set mapMapListListMapListObjectId(Map<String, Map<String, List<List<Map<String, List<ObjectId>>>>>> value) => data['mapMapListListMapListObjectId'] = DbQueryField.toBaseType(value);
}

class ComplexQuery {
  static const $tableName = 'complex';

  ///Field _id
  static DbQueryField<ObjectId, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get id => DbQueryField('_id');

  ///Field baseInt
  static DbQueryField<int, int, DBUnsupportArrayOperate> get baseInt => DbQueryField('baseInt');

  ///Field baseDouble
  static DbQueryField<double, double, DBUnsupportArrayOperate> get baseDouble => DbQueryField('baseDouble');

  ///Field baseNum
  static DbQueryField<num, num, DBUnsupportArrayOperate> get baseNum => DbQueryField('baseNum');

  ///Field baseBool
  static DbQueryField<bool, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get baseBool => DbQueryField('baseBool');

  ///Field baseString
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get baseString => DbQueryField('baseString');

  ///Field baseAddress
  static DbQueryField<Address, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get baseAddress => DbQueryField('baseAddress');

  ///Field baseObjectId
  static DbQueryField<ObjectId, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get baseObjectId => DbQueryField('baseObjectId');

  ///Field baseJsonWraper
  static DbQueryField<DbJsonWraper, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get baseJsonWraper => DbQueryField('baseJsonWraper');

  ///Field listInt
  static DbQueryField<List<int>, DBUnsupportNumberOperate, int> get listInt => DbQueryField('listInt');

  ///Field listDouble
  static DbQueryField<List<double>, DBUnsupportNumberOperate, double> get listDouble => DbQueryField('listDouble');

  ///Field listNum
  static DbQueryField<List<num>, DBUnsupportNumberOperate, num> get listNum => DbQueryField('listNum');

  ///Field listBool
  static DbQueryField<List<bool>, DBUnsupportNumberOperate, bool> get listBool => DbQueryField('listBool');

  ///Field listString
  static DbQueryField<List<String>, DBUnsupportNumberOperate, String> get listString => DbQueryField('listString');

  ///Field listAddress
  static DbQueryField<List<Address>, DBUnsupportNumberOperate, Address> get listAddress => DbQueryField('listAddress');

  ///Field listObjectId
  static DbQueryField<List<ObjectId>, DBUnsupportNumberOperate, ObjectId> get listObjectId => DbQueryField('listObjectId');

  ///Field mapInt
  static DbQueryField<Map<String, int>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get mapInt => DbQueryField('mapInt');

  ///Field mapDouble
  static DbQueryField<Map<String, double>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get mapDouble => DbQueryField('mapDouble');

  ///Field mapNum
  static DbQueryField<Map<String, num>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get mapNum => DbQueryField('mapNum');

  ///Field mapBool
  static DbQueryField<Map<String, bool>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get mapBool => DbQueryField('mapBool');

  ///Field mapString
  static DbQueryField<Map<String, String>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get mapString => DbQueryField('mapString');

  ///Field mapAddress
  static DbQueryField<Map<String, Address>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get mapAddress => DbQueryField('mapAddress');

  ///Field mapObjectId
  static DbQueryField<Map<String, ObjectId>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get mapObjectId => DbQueryField('mapObjectId');

  ///Field map2Int
  static DbQueryField<Map<int, int>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map2Int => DbQueryField('map2Int');

  ///Field map2Double
  static DbQueryField<Map<int, double>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map2Double => DbQueryField('map2Double');

  ///Field map2Num
  static DbQueryField<Map<int, num>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map2Num => DbQueryField('map2Num');

  ///Field map2Bool
  static DbQueryField<Map<int, bool>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map2Bool => DbQueryField('map2Bool');

  ///Field map2String
  static DbQueryField<Map<int, String>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map2String => DbQueryField('map2String');

  ///Field map2Address
  static DbQueryField<Map<int, Address>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map2Address => DbQueryField('map2Address');

  ///Field map2ObjectId
  static DbQueryField<Map<int, ObjectId>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map2ObjectId => DbQueryField('map2ObjectId');

  ///Field map3Int
  static DbQueryField<Map<double, int>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map3Int => DbQueryField('map3Int');

  ///Field map3Double
  static DbQueryField<Map<double, double>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map3Double => DbQueryField('map3Double');

  ///Field map3Num
  static DbQueryField<Map<double, num>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map3Num => DbQueryField('map3Num');

  ///Field map3Bool
  static DbQueryField<Map<double, bool>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map3Bool => DbQueryField('map3Bool');

  ///Field map3String
  static DbQueryField<Map<double, String>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map3String => DbQueryField('map3String');

  ///Field map3Address
  static DbQueryField<Map<double, Address>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map3Address => DbQueryField('map3Address');

  ///Field map3ObjectId
  static DbQueryField<Map<double, ObjectId>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map3ObjectId => DbQueryField('map3ObjectId');

  ///Field map4Int
  static DbQueryField<Map<bool, int>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map4Int => DbQueryField('map4Int');

  ///Field map4Double
  static DbQueryField<Map<bool, double>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map4Double => DbQueryField('map4Double');

  ///Field map4Num
  static DbQueryField<Map<bool, num>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map4Num => DbQueryField('map4Num');

  ///Field map4Bool
  static DbQueryField<Map<bool, bool>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map4Bool => DbQueryField('map4Bool');

  ///Field map4String
  static DbQueryField<Map<bool, String>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map4String => DbQueryField('map4String');

  ///Field map4Address
  static DbQueryField<Map<bool, Address>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map4Address => DbQueryField('map4Address');

  ///Field map4ObjectId
  static DbQueryField<Map<bool, ObjectId>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map4ObjectId => DbQueryField('map4ObjectId');

  ///Field map5Int
  static DbQueryField<Map<ObjectId, int>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map5Int => DbQueryField('map5Int');

  ///Field map5Double
  static DbQueryField<Map<ObjectId, double>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map5Double => DbQueryField('map5Double');

  ///Field map5Num
  static DbQueryField<Map<ObjectId, num>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map5Num => DbQueryField('map5Num');

  ///Field map5Bool
  static DbQueryField<Map<ObjectId, bool>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map5Bool => DbQueryField('map5Bool');

  ///Field map5String
  static DbQueryField<Map<ObjectId, String>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map5String => DbQueryField('map5String');

  ///Field map5Address
  static DbQueryField<Map<ObjectId, Address>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map5Address => DbQueryField('map5Address');

  ///Field map5ObjectId
  static DbQueryField<Map<ObjectId, ObjectId>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map5ObjectId => DbQueryField('map5ObjectId');

  ///Field map6Int
  static DbQueryField<Map<Address, int>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map6Int => DbQueryField('map6Int');

  ///Field map6Double
  static DbQueryField<Map<Address, double>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map6Double => DbQueryField('map6Double');

  ///Field map6Num
  static DbQueryField<Map<Address, num>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map6Num => DbQueryField('map6Num');

  ///Field map6Bool
  static DbQueryField<Map<Address, bool>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map6Bool => DbQueryField('map6Bool');

  ///Field map6String
  static DbQueryField<Map<Address, String>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map6String => DbQueryField('map6String');

  ///Field map6Address
  static DbQueryField<Map<Address, Address>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map6Address => DbQueryField('map6Address');

  ///Field map6ObjectId
  static DbQueryField<Map<Address, ObjectId>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get map6ObjectId => DbQueryField('map6ObjectId');

  ///Field listListMapMapListMapDouble
  static DbQueryField<List<List<Map<String, Map<String, List<Map<String, double>>>>>>, DBUnsupportNumberOperate, List<Map<String, Map<String, List<Map<String, double>>>>>> get listListMapMapListMapDouble => DbQueryField('listListMapMapListMapDouble');

  ///Field listListMapMapListMapAddress
  static DbQueryField<List<List<Map<String, Map<String, List<Map<String, Address>>>>>>, DBUnsupportNumberOperate, List<Map<String, Map<String, List<Map<String, Address>>>>>> get listListMapMapListMapAddress => DbQueryField('listListMapMapListMapAddress');

  ///Field listListMapMapListMapObjectId
  static DbQueryField<List<List<Map<String, Map<String, List<Map<String, ObjectId>>>>>>, DBUnsupportNumberOperate, List<Map<String, Map<String, List<Map<String, ObjectId>>>>>> get listListMapMapListMapObjectId => DbQueryField('listListMapMapListMapObjectId');

  ///Field mapMapListListMapListDouble
  static DbQueryField<Map<String, Map<String, List<List<Map<String, List<double>>>>>>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get mapMapListListMapListDouble => DbQueryField('mapMapListListMapListDouble');

  ///Field mapMapListListMapListAddress
  static DbQueryField<Map<String, Map<String, List<List<Map<String, List<Address>>>>>>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get mapMapListListMapListAddress => DbQueryField('mapMapListListMapListAddress');

  ///Field mapMapListListMapListObjectId
  static DbQueryField<Map<String, Map<String, List<List<Map<String, List<ObjectId>>>>>>, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get mapMapListListMapListObjectId => DbQueryField('mapMapListListMapListObjectId');
}

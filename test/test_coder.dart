import 'dart:io';

import 'package:shelf_easy/shelf_easy.dart';

void main() {
  final coder = EasyCoder(
    config: EasyCoderConfig(
      absFolder: '${Directory.current.path}/test/model',
    ),
  );
  coder.generateModel(EasyCoderModelInfo(
    importList: ['address.dart'],
    classDesc: ['', '用户类', ''],
    className: 'User',
    constFields: [
      EasyCoderFieldInfo(type: 'int', name: 'sexMale', desc: ['男性'], defVal: '1'),
      EasyCoderFieldInfo(type: 'int', name: 'sexFemale', desc: ['女性'], defVal: '2'),
    ],
    classFields: [
      EasyCoderFieldInfo(type: 'ObjectId', name: '_id', desc: ['', '标志', ''], secrecy: true),
      EasyCoderFieldInfo(type: 'String', name: 'name', desc: ['', '姓名', ''], defVal: '\'名称\''),
      EasyCoderFieldInfo(type: 'int', name: 'age', desc: ['年龄'], secrecy: true, defVal: '10'),
      EasyCoderFieldInfo(type: 'double', name: 'rmb', desc: ['RMB'], secrecy: true, defVal: '100'),
      EasyCoderFieldInfo(type: 'String', name: 'pwd', desc: ['密码'], secrecy: true, defVal: '\'12345678\''),
      EasyCoderFieldInfo(type: 'Address', name: 'address', desc: ['归属地址']),
      EasyCoderFieldInfo(type: 'Address', name: 'addressBak', desc: ['备用地址'], nullAble: true),
      EasyCoderFieldInfo(type: 'List<int>', name: 'accessList', desc: ['权限列表']),
      EasyCoderFieldInfo(type: 'List<Address>', name: 'addressList', desc: ['通讯地址']),
      EasyCoderFieldInfo(type: 'List<ObjectId>', name: 'friendList', desc: ['好友id列表']),
      EasyCoderFieldInfo(type: 'Map<int, Map<ObjectId, Address>>', name: 'ageObjectIdAddressMap', desc: ['测试复杂类型']),
    ],
    extraFields: [
      EasyCoderFieldInfo(type: 'String', name: '\$pingying', desc: ['', '非序列化字段', '']),
    ],
    constMap: true,
  ));
  coder.generateModel(EasyCoderModelInfo(
    importList: ['location.dart'],
    classDesc: ['', '用户地址类', ''],
    className: 'Address',
    classFields: [
      EasyCoderFieldInfo(type: 'String', name: 'country', desc: ['国家']),
      EasyCoderFieldInfo(type: 'String', name: 'province', desc: ['省份']),
      EasyCoderFieldInfo(type: 'String', name: 'city', desc: ['市']),
      EasyCoderFieldInfo(type: 'String', name: 'area', desc: ['县（区）']),
      EasyCoderFieldInfo(type: 'Location', name: 'location', desc: ['县（区）']),
    ],
  ));
  coder.generateModel(EasyCoderModelInfo(
    importList: [],
    classDesc: ['', '用户位置类', ''],
    className: 'Location',
    classFields: [
      EasyCoderFieldInfo(type: 'double', name: 'latitude', desc: ['纬度']),
      EasyCoderFieldInfo(type: 'double', name: 'longitude', desc: ['经度']),
      EasyCoderFieldInfo(type: 'double', name: 'accuracy', desc: ['精确度']),
    ],
  ));
  coder.generateModel(EasyCoderModelInfo(
    importList: ['address.dart'],
    classDesc: ['', '复杂字段类', ''],
    className: 'Complex',
    classFields: [
      //_id
      EasyCoderFieldInfo(type: 'ObjectId', name: '_id', desc: []),
      //base
      EasyCoderFieldInfo(type: 'int', name: 'baseInt', desc: [], defVal: '1'),
      EasyCoderFieldInfo(type: 'double', name: 'baseDouble', desc: [], defVal: '2'),
      EasyCoderFieldInfo(type: 'num', name: 'baseNum', desc: [], defVal: '3'),
      EasyCoderFieldInfo(type: 'bool', name: 'baseBool', desc: [], defVal: 'true'),
      EasyCoderFieldInfo(type: 'String', name: 'baseString', desc: []),
      EasyCoderFieldInfo(type: 'Address', name: 'baseAddress', desc: []),
      EasyCoderFieldInfo(type: 'ObjectId', name: 'baseObjectId', desc: []),
      EasyCoderFieldInfo(type: 'DbJsonWraper', name: 'baseJsonWraper', desc: []),
      //list
      EasyCoderFieldInfo(type: 'List<int>', name: 'listInt', desc: []),
      EasyCoderFieldInfo(type: 'List<double>', name: 'listDouble', desc: []),
      EasyCoderFieldInfo(type: 'List<num>', name: 'listNum', desc: []),
      EasyCoderFieldInfo(type: 'List<bool>', name: 'listBool', desc: []),
      EasyCoderFieldInfo(type: 'List<String>', name: 'listString', desc: []),
      EasyCoderFieldInfo(type: 'List<Address>', name: 'listAddress', desc: []),
      EasyCoderFieldInfo(type: 'List<ObjectId>', name: 'listObjectId', desc: []),
      //String map
      EasyCoderFieldInfo(type: 'Map<String, int>', name: 'mapInt', desc: []),
      EasyCoderFieldInfo(type: 'Map<String, double>', name: 'mapDouble', desc: []),
      EasyCoderFieldInfo(type: 'Map<String, num>', name: 'mapNum', desc: []),
      EasyCoderFieldInfo(type: 'Map<String, bool>', name: 'mapBool', desc: []),
      EasyCoderFieldInfo(type: 'Map<String, String>', name: 'mapString', desc: []),
      EasyCoderFieldInfo(type: 'Map<String, Address>', name: 'mapAddress', desc: []),
      EasyCoderFieldInfo(type: 'Map<String, ObjectId>', name: 'mapObjectId', desc: []),
      //int map
      EasyCoderFieldInfo(type: 'Map<int, int>', name: 'map2Int', desc: []),
      EasyCoderFieldInfo(type: 'Map<int, double>', name: 'map2Double', desc: []),
      EasyCoderFieldInfo(type: 'Map<int, num>', name: 'map2Num', desc: []),
      EasyCoderFieldInfo(type: 'Map<int, bool>', name: 'map2Bool', desc: []),
      EasyCoderFieldInfo(type: 'Map<int, String>', name: 'map2String', desc: []),
      EasyCoderFieldInfo(type: 'Map<int, Address>', name: 'map2Address', desc: []),
      EasyCoderFieldInfo(type: 'Map<int, ObjectId>', name: 'map2ObjectId', desc: []),
      //double map
      EasyCoderFieldInfo(type: 'Map<double, int>', name: 'map3Int', desc: []),
      EasyCoderFieldInfo(type: 'Map<double, double>', name: 'map3Double', desc: []),
      EasyCoderFieldInfo(type: 'Map<double, num>', name: 'map3Num', desc: []),
      EasyCoderFieldInfo(type: 'Map<double, bool>', name: 'map3Bool', desc: []),
      EasyCoderFieldInfo(type: 'Map<double, String>', name: 'map3String', desc: []),
      EasyCoderFieldInfo(type: 'Map<double, Address>', name: 'map3Address', desc: []),
      EasyCoderFieldInfo(type: 'Map<double, ObjectId>', name: 'map3ObjectId', desc: []),
      //bool map
      EasyCoderFieldInfo(type: 'Map<bool, int>', name: 'map4Int', desc: []),
      EasyCoderFieldInfo(type: 'Map<bool, double>', name: 'map4Double', desc: []),
      EasyCoderFieldInfo(type: 'Map<bool, num>', name: 'map4Num', desc: []),
      EasyCoderFieldInfo(type: 'Map<bool, bool>', name: 'map4Bool', desc: []),
      EasyCoderFieldInfo(type: 'Map<bool, String>', name: 'map4String', desc: []),
      EasyCoderFieldInfo(type: 'Map<bool, Address>', name: 'map4Address', desc: []),
      EasyCoderFieldInfo(type: 'Map<bool, ObjectId>', name: 'map4ObjectId', desc: []),
      //ObjectId map
      EasyCoderFieldInfo(type: 'Map<ObjectId, int>', name: 'map5Int', desc: []),
      EasyCoderFieldInfo(type: 'Map<ObjectId, double>', name: 'map5Double', desc: []),
      EasyCoderFieldInfo(type: 'Map<ObjectId, num>', name: 'map5Num', desc: []),
      EasyCoderFieldInfo(type: 'Map<ObjectId, bool>', name: 'map5Bool', desc: []),
      EasyCoderFieldInfo(type: 'Map<ObjectId, String>', name: 'map5String', desc: []),
      EasyCoderFieldInfo(type: 'Map<ObjectId, Address>', name: 'map5Address', desc: []),
      EasyCoderFieldInfo(type: 'Map<ObjectId, ObjectId>', name: 'map5ObjectId', desc: []),
      //Address map
      EasyCoderFieldInfo(type: 'Map<Address, int>', name: 'map6Int', desc: []),
      EasyCoderFieldInfo(type: 'Map<Address, double>', name: 'map6Double', desc: []),
      EasyCoderFieldInfo(type: 'Map<Address, num>', name: 'map6Num', desc: []),
      EasyCoderFieldInfo(type: 'Map<Address, bool>', name: 'map6Bool', desc: []),
      EasyCoderFieldInfo(type: 'Map<Address, String>', name: 'map6String', desc: []),
      EasyCoderFieldInfo(type: 'Map<Address, Address>', name: 'map6Address', desc: []),
      EasyCoderFieldInfo(type: 'Map<Address, ObjectId>', name: 'map6ObjectId', desc: []),
      //complex
      EasyCoderFieldInfo(type: 'List<List<Map<String, Map<String, List<Map<String, double>>>>>>', name: 'listListMapMapListMapDouble', desc: []),
      EasyCoderFieldInfo(type: 'List<List<Map<String, Map<String, List<Map<String, Address>>>>>>', name: 'listListMapMapListMapAddress', desc: []),
      EasyCoderFieldInfo(type: 'List<List<Map<String, Map<String, List<Map<String, ObjectId>>>>>>', name: 'listListMapMapListMapObjectId', desc: []),
      EasyCoderFieldInfo(type: 'Map<String, Map<String, List<List<Map<String, List<double>>>>>>', name: 'mapMapListListMapListDouble', desc: []),
      EasyCoderFieldInfo(type: 'Map<String, Map<String, List<List<Map<String, List<Address>>>>>>', name: 'mapMapListListMapListAddress', desc: []),
      EasyCoderFieldInfo(type: 'Map<String, Map<String, List<List<Map<String, List<ObjectId>>>>>>', name: 'mapMapListListMapListObjectId', desc: []),
      //unsupport
      // EasyCoderFieldInfo(type: 'int?', name: 'badInt',  desc: []),
      // EasyCoderFieldInfo(type: 'dynamic', name: 'badDynamic',  desc: []),
      // EasyCoderFieldInfo(type: 'Object', name: 'badObject',  desc: []),
      // EasyCoderFieldInfo(type: 'List', name: 'badList',  desc: []),
      // EasyCoderFieldInfo(type: 'Map', name: 'badMap', desc: []),
    ],
  ));
  coder.generateModel(EasyCoderModelInfo(
    importList: [],
    classDesc: ['', '只有一个字段类', ''],
    className: 'OnlyOne',
    classFields: [
      EasyCoderFieldInfo(type: 'String', name: 'test1', desc: ['']),
    ],
  ));
  coder.generateModel(EasyCoderModelInfo(
    importList: [],
    classDesc: ['', '只有两个字段类', ''],
    className: 'OnlyTwo',
    classFields: [
      EasyCoderFieldInfo(type: 'String', name: 'test1', desc: ['']),
      EasyCoderFieldInfo(type: 'String', name: 'test2', desc: ['']),
    ],
  ));
  coder.generateModel(EasyCoderModelInfo(
    importList: [],
    classDesc: ['', '没有字段类', ''],
    className: 'OnlyNull',
    classFields: [
      EasyCoderFieldInfo(type: 'String', name: 'test1', desc: [''], nullAble: true),
      EasyCoderFieldInfo(type: 'String', name: 'test2', desc: [''], nullAble: true),
    ],
  ));
  coder.generateModel(EasyCoderModelInfo(
    importList: [],
    classDesc: ['', '没有字段类', ''],
    className: 'Empty',
  ));
  coder.generateModel(EasyCoderModelInfo(
    outputFile: 'wrapper_location',
    importList: ['location.dart'],
    classDesc: ['', '位置包装类', ''],
    className: 'WrapperLocation',
    classFields: [
      EasyCoderFieldInfo(type: 'double', name: 'latitude', desc: ['纬度']),
      EasyCoderFieldInfo(type: 'double', name: 'longitude', desc: ['经度']),
      EasyCoderFieldInfo(type: 'double', name: 'accuracy', desc: ['精确度']),
    ],
    wrapType: 'Location',
    dirty: false,
    query: false,
  ));
  coder.generateModel(EasyCoderModelInfo(
    outputFile: 'wrapper_empty',
    importList: ['empty.dart'],
    classDesc: ['', '无字段包装类', ''],
    className: 'WrapperEmpty',
    wrapType: 'Empty',
    dirty: false,
    query: false,
  ));
  coder.generateBuilder(
    outputFile: 'wrapper_builder',
  );
}

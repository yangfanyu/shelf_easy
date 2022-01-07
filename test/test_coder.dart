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
    classFields: [
      EasyCoderFieldInfo(type: 'ObjectId', name: '_id', defv: 'ObjectId()', desc: ['', '标志', ''], secrecy: true),
      EasyCoderFieldInfo(type: 'String', name: 'name', defv: '\'名称\'', desc: ['', '姓名', '']),
      EasyCoderFieldInfo(type: 'int', name: 'age', defv: '10', desc: ['年龄'], secrecy: true),
      EasyCoderFieldInfo(type: 'double', name: 'rmb', defv: '100', desc: ['RMB'], secrecy: true),
      EasyCoderFieldInfo(type: 'String', name: 'pwd', defv: '\'12345678\'', desc: ['密码'], secrecy: true),
      EasyCoderFieldInfo(type: 'Address', name: 'address', defv: 'Address()', desc: ['归属地址']),
      EasyCoderFieldInfo(type: 'List<int>', name: 'accessList', defv: '[]', desc: ['权限列表']),
      EasyCoderFieldInfo(type: 'List<Address>', name: 'addressList', defv: '[]', desc: ['通讯地址']),
      EasyCoderFieldInfo(type: 'List<ObjectId>', name: 'friendList', defv: '[]', desc: ['好友id列表']),
    ],
  ));
  coder.generateModel(EasyCoderModelInfo(
    importList: ['location.dart'],
    classDesc: ['', '用户地址类', ''],
    className: 'Address',
    classFields: [
      EasyCoderFieldInfo(type: 'String', name: 'country', defv: '\'\'', desc: ['国家']),
      EasyCoderFieldInfo(type: 'String', name: 'province', defv: '\'\'', desc: ['省份']),
      EasyCoderFieldInfo(type: 'String', name: 'city', defv: '\'\'', desc: ['市']),
      EasyCoderFieldInfo(type: 'String', name: 'area', defv: '\'\'', desc: ['县（区）']),
      EasyCoderFieldInfo(type: 'Location', name: 'location', defv: 'Location()', desc: ['县（区）']),
    ],
  ));
  coder.generateModel(EasyCoderModelInfo(
    importList: [],
    classDesc: ['', '用户位置类', ''],
    className: 'Location',
    classFields: [
      EasyCoderFieldInfo(type: 'double', name: 'latitude', defv: '0', desc: ['纬度']),
      EasyCoderFieldInfo(type: 'double', name: 'longitude', defv: '0', desc: ['经度']),
      EasyCoderFieldInfo(type: 'double', name: 'accuracy', defv: '0', desc: ['精确度']),
    ],
  ));
  coder.generateModel(EasyCoderModelInfo(
    importList: ['address.dart'],
    classDesc: ['', '复杂字段类', ''],
    className: 'Complex',
    classFields: [
      //_id
      EasyCoderFieldInfo(type: 'ObjectId', name: '_id', defv: 'ObjectId()', desc: []),
      //base
      EasyCoderFieldInfo(type: 'int', name: 'baseInt', defv: '1', desc: []),
      EasyCoderFieldInfo(type: 'double', name: 'baseDouble', defv: '2', desc: []),
      EasyCoderFieldInfo(type: 'num', name: 'baseNum', defv: '3', desc: []),
      EasyCoderFieldInfo(type: 'bool', name: 'baseBool', defv: 'true', desc: []),
      EasyCoderFieldInfo(type: 'String', name: 'baseString', defv: '\'\'', desc: []),
      EasyCoderFieldInfo(type: 'Address', name: 'baseAddress', defv: 'Address()', desc: []),
      EasyCoderFieldInfo(type: 'ObjectId', name: 'baseObjectId', defv: 'ObjectId()', desc: []),
      //list
      EasyCoderFieldInfo(type: 'List<int>', name: 'listInt', defv: '[]', desc: []),
      EasyCoderFieldInfo(type: 'List<double>', name: 'listDouble', defv: '[]', desc: []),
      EasyCoderFieldInfo(type: 'List<num>', name: 'listNum', defv: '[]', desc: []),
      EasyCoderFieldInfo(type: 'List<bool>', name: 'listBool', defv: '[]', desc: []),
      EasyCoderFieldInfo(type: 'List<String>', name: 'listString', defv: '[]', desc: []),
      EasyCoderFieldInfo(type: 'List<Address>', name: 'listAddress', defv: '[]', desc: []),
      EasyCoderFieldInfo(type: 'List<ObjectId>', name: 'listObjectId', defv: '[]', desc: []),
      //map
      EasyCoderFieldInfo(type: 'Map<String, int>', name: 'mapInt', defv: '{}', desc: []),
      EasyCoderFieldInfo(type: 'Map<String, double>', name: 'mapDouble', defv: '{}', desc: []),
      EasyCoderFieldInfo(type: 'Map<String, num>', name: 'mapNum', defv: '{}', desc: []),
      EasyCoderFieldInfo(type: 'Map<String, bool>', name: 'mapBool', defv: '{}', desc: []),
      EasyCoderFieldInfo(type: 'Map<String, String>', name: 'mapString', defv: '{}', desc: []),
      EasyCoderFieldInfo(type: 'Map<String, Address>', name: 'mapAddress', defv: '{}', desc: []),
      EasyCoderFieldInfo(type: 'Map<String, ObjectId>', name: 'mapObjectId', defv: '{}', desc: []),
      //complex
      EasyCoderFieldInfo(type: 'List<List<Map<String, Map<String, List<Map<String, double>>>>>>', name: 'listListMapMapListMapDouble', defv: '[]', desc: []),
      EasyCoderFieldInfo(type: 'List<List<Map<String, Map<String, List<Map<String, Address>>>>>>', name: 'listListMapMapListMapAddress', defv: '[]', desc: []),
      EasyCoderFieldInfo(type: 'List<List<Map<String, Map<String, List<Map<String, ObjectId>>>>>>', name: 'listListMapMapListMapObjectId', defv: '[]', desc: []),
      EasyCoderFieldInfo(type: 'Map<String, Map<String, List<List<Map<String, List<double>>>>>>', name: 'mapMapListListMapListDouble', defv: '{}', desc: []),
      EasyCoderFieldInfo(type: 'Map<String, Map<String, List<List<Map<String, List<Address>>>>>>', name: 'mapMapListListMapListAddress', defv: '{}', desc: []),
      EasyCoderFieldInfo(type: 'Map<String, Map<String, List<List<Map<String, List<ObjectId>>>>>>', name: 'mapMapListListMapListObjectId', defv: '{}', desc: []),
      //unsupport
      // EasyCoderFieldInfo(type: 'int?', name: 'badInt', defv: '0', desc: []),
      // EasyCoderFieldInfo(type: 'dynamic', name: 'badDynamic', defv: '0', desc: []),
      // EasyCoderFieldInfo(type: 'Object', name: 'badObject', defv: '0', desc: []),
      // EasyCoderFieldInfo(type: 'List', name: 'badList', defv: '[]', desc: []),
      // EasyCoderFieldInfo(type: 'Map', name: 'badMap', defv: '{}', desc: []),
    ],
  ));
  coder.generateModel(EasyCoderModelInfo(
    importList: [],
    classDesc: ['', '只有一个字段类', ''],
    className: 'OnlyOne',
    classFields: [
      EasyCoderFieldInfo(type: 'String', name: 'test1', defv: '\'\'', desc: ['']),
    ],
  ));
  coder.generateModel(EasyCoderModelInfo(
    importList: [],
    classDesc: ['', '只有两个字段类', ''],
    className: 'OnlyTwo',
    classFields: [
      EasyCoderFieldInfo(type: 'String', name: 'test1', defv: '\'\'', desc: ['']),
      EasyCoderFieldInfo(type: 'String', name: 'test2', defv: '\'\'', desc: ['']),
    ],
  ));
  coder.generateModel(EasyCoderModelInfo(
    importList: [],
    classDesc: ['', '没有字段类', ''],
    className: 'Empty',
    classFields: [],
  ));
}

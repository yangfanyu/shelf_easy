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
    constFields: [],
    classFields: [
      EasyCoderFieldInfo(type: 'String', name: 'country', desc: ['国家']),
      EasyCoderFieldInfo(type: 'String', name: 'province', desc: ['省份']),
      EasyCoderFieldInfo(type: 'String', name: 'city', desc: ['市']),
      EasyCoderFieldInfo(type: 'String', name: 'area', desc: ['县（区）']),
      EasyCoderFieldInfo(type: 'Location', name: 'location', desc: ['县（区）']),
    ],
    extraFields: [],
  ));
  coder.generateModel(EasyCoderModelInfo(
    importList: [],
    classDesc: ['', '用户位置类', ''],
    className: 'Location',
    constFields: [],
    classFields: [
      EasyCoderFieldInfo(type: 'double', name: 'latitude', desc: ['纬度']),
      EasyCoderFieldInfo(type: 'double', name: 'longitude', desc: ['经度']),
      EasyCoderFieldInfo(type: 'double', name: 'accuracy', desc: ['精确度']),
    ],
    extraFields: [],
  ));
  coder.generateModel(EasyCoderModelInfo(
    importList: ['address.dart'],
    classDesc: ['', '复杂字段类', ''],
    className: 'Complex',
    constFields: [],
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
      //list
      EasyCoderFieldInfo(type: 'List<int>', name: 'listInt', desc: []),
      EasyCoderFieldInfo(type: 'List<double>', name: 'listDouble', desc: []),
      EasyCoderFieldInfo(type: 'List<num>', name: 'listNum', desc: []),
      EasyCoderFieldInfo(type: 'List<bool>', name: 'listBool', desc: []),
      EasyCoderFieldInfo(type: 'List<String>', name: 'listString', desc: []),
      EasyCoderFieldInfo(type: 'List<Address>', name: 'listAddress', desc: []),
      EasyCoderFieldInfo(type: 'List<ObjectId>', name: 'listObjectId', desc: []),
      //map
      EasyCoderFieldInfo(type: 'Map<String, int>', name: 'mapInt', desc: []),
      EasyCoderFieldInfo(type: 'Map<String, double>', name: 'mapDouble', desc: []),
      EasyCoderFieldInfo(type: 'Map<String, num>', name: 'mapNum', desc: []),
      EasyCoderFieldInfo(type: 'Map<String, bool>', name: 'mapBool', desc: []),
      EasyCoderFieldInfo(type: 'Map<String, String>', name: 'mapString', desc: []),
      EasyCoderFieldInfo(type: 'Map<String, Address>', name: 'mapAddress', desc: []),
      EasyCoderFieldInfo(type: 'Map<String, ObjectId>', name: 'mapObjectId', desc: []),
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
    extraFields: [],
  ));
  coder.generateModel(EasyCoderModelInfo(
    importList: [],
    classDesc: ['', '只有一个字段类', ''],
    className: 'OnlyOne',
    constFields: [],
    classFields: [
      EasyCoderFieldInfo(type: 'String', name: 'test1', desc: ['']),
    ],
    extraFields: [],
  ));
  coder.generateModel(EasyCoderModelInfo(
    importList: [],
    classDesc: ['', '只有两个字段类', ''],
    className: 'OnlyTwo',
    constFields: [],
    classFields: [
      EasyCoderFieldInfo(type: 'String', name: 'test1', desc: ['']),
      EasyCoderFieldInfo(type: 'String', name: 'test2', desc: ['']),
    ],
    extraFields: [],
  ));
  coder.generateModel(EasyCoderModelInfo(
    importList: [],
    classDesc: ['', '没有字段类', ''],
    className: 'OnlyNull',
    constFields: [],
    classFields: [
      EasyCoderFieldInfo(type: 'String', name: 'test1', desc: [''], nullAble: true),
      EasyCoderFieldInfo(type: 'String', name: 'test2', desc: [''], nullAble: true),
    ],
    extraFields: [],
  ));
  coder.generateModel(EasyCoderModelInfo(
    importList: [],
    classDesc: ['', '没有字段类', ''],
    className: 'Empty',
    constFields: [],
    classFields: [],
    extraFields: [],
  ));
}

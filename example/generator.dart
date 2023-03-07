import 'dart:io';

import 'package:shelf_easy/shelf_easy.dart';

void main() {
  final coder = EasyCoder(
    config: EasyCoderConfig(
      absFolder: '${Directory.current.path}/model',
    ),
  );
  //常量
  coder.generateModel(EasyCoderModelInfo(
    importList: [],
    classDesc: ['', '常量', ''],
    className: 'Constant',
    constFields: [
      EasyCoderFieldInfo(type: 'int', name: 'sexMale', desc: ['性别：男性'], defVal: '101', zhText: '男', enText: 'Male'),
      EasyCoderFieldInfo(type: 'int', name: 'sexFemale', desc: ['性别：女性'], defVal: '102', zhText: '女', enText: 'Female'),
      EasyCoderFieldInfo(type: 'int', name: 'sexUnknow', desc: ['性别：未知'], defVal: '103', zhText: '未知', enText: 'Unknow'),
    ],
    constMap: true,
  ));
  //地址
  coder.generateModel(EasyCoderModelInfo(
    importList: [],
    classDesc: ['', '位置', ''],
    className: 'Location',
    classFields: [
      EasyCoderFieldInfo(type: 'ObjectId', name: '_id', desc: ['唯一标志']),
      EasyCoderFieldInfo(type: 'String', name: 'country', desc: ['国家']),
      EasyCoderFieldInfo(type: 'String', name: 'province', desc: ['省']),
      EasyCoderFieldInfo(type: 'String', name: 'city', desc: ['市']),
      EasyCoderFieldInfo(type: 'String', name: 'district', desc: ['区']),
      EasyCoderFieldInfo(type: 'double', name: 'latitude', desc: ['纬度'], defVal: '16.666666'),
      EasyCoderFieldInfo(type: 'double', name: 'longitude', desc: ['经度'], defVal: '116.666666'),
      EasyCoderFieldInfo(type: 'double', name: 'altitude', desc: ['海拔'], defVal: '1'),
      EasyCoderFieldInfo(type: 'int', name: '_time', desc: ['创建时间'], defVal: 'DateTime.now().millisecondsSinceEpoch'),
    ],
  ));
  //用户
  coder.generateModel(EasyCoderModelInfo(
    importList: ['constant.dart', 'location.dart'],
    classDesc: ['', '用户', ''],
    className: 'User',
    classFields: [
      EasyCoderFieldInfo(type: 'ObjectId', name: '_id', desc: ['唯一标志']),
      EasyCoderFieldInfo(type: 'String', name: 'no', desc: ['账号']),
      EasyCoderFieldInfo(type: 'String', name: 'pwd', desc: ['密码'], secrecy: true),
      EasyCoderFieldInfo(type: 'int', name: 'sex', desc: ['性别'], defVal: 'Constant.sexUnknow'),
      EasyCoderFieldInfo(type: 'int', name: 'age', desc: ['年龄'], defVal: '18'),
      EasyCoderFieldInfo(type: 'Location', name: 'location', desc: ['当前位置'], nullAble: true),
      EasyCoderFieldInfo(type: 'List<Location>', name: 'locationList', desc: ['位置列表'], nullAble: true),
      EasyCoderFieldInfo(type: 'Map<int, Location>', name: 'locationMap', desc: ['位置集合'], nullAble: true),
      EasyCoderFieldInfo(type: 'int', name: '_time', desc: ['创建时间'], defVal: 'DateTime.now().millisecondsSinceEpoch'),
    ],
  ));
  //导出文件
  coder.generateBaseExports();
}

import 'dart:io';

import 'package:shelf_easy/shelf_easy.dart';

void main() {
  //为example生成model桥接库
  // generatorLibraryForModel();

  ///为flutter生成桥接库
  ///这里全生成了，实际情况可以自己去掉不需要的库，只需确保：生成后调用EasyCode.logVmLibrarydErrors无错误打印，且在开发工具里面打开库文件不报错即可。
  generatorLibraryForFlutter();
}

void generatorLibraryForModel() {
  final flutterHome = Platform.environment['FLUTTER_HOME']; //读取环境变量
  final coder = EasyCoder(
    config: EasyCoderConfig(
      absFolder: '${Directory.current.path}/bridge',
    ),
  );
  coder.generateVmLibraries(
    outputFile: 'model_library',
    importList: ['../model/all.dart'],
    className: 'ModelLibrary',
    classDesc: '数据模型',

    ///需要生成桥接类的路径，只有公开的声明才生成桥接类
    libraryPaths: [
      '${Directory.current.path}/model',
      '${Directory.current.path}/../lib/src/db/db_base.dart',
    ],

    ///私有路径不生成桥接类，只是用来查找与复制超类的属性
    privatePaths: [
      '$flutterHome/bin/cache/dart-sdk/lib/core',
    ],

    ///这个用来告诉生成器对应文件下面只需要生成某些类的桥接类
    onlyNeedFileClass: {
      '${Directory.current.path}/../lib/src/db/db_base.dart': ['DbBaseModel'],
    },
  );
  //统一打印生成过程中的错误信息
  coder.logVmLibrarydErrors();
}

void generatorLibraryForFlutter() {
  final flutterHome = Platform.environment['FLUTTER_HOME']; //读取环境变量
  final coder = EasyCoder(
    config: EasyCoderConfig(
      absFolder: '${Directory.current.path}/../../zycloud_widget/lib/src/bridge',
    ),
  );
  coder.generateVmLibraries(
    outputFile: 'flutter_library',
    importList: [
      // 'package:flutter/animation.dart',//重复的导入项
      'package:flutter/cupertino.dart',
      'package:flutter/foundation.dart',
      'package:flutter/gestures.dart',
      'package:flutter/material.dart',
      // 'package:flutter/painting.dart',//重复的导入项
      'package:flutter/physics.dart',
      'package:flutter/rendering.dart',
      'package:flutter/scheduler.dart',
      // 'package:flutter/semantics.dart',//重复的导入项
      'package:flutter/services.dart',
      // 'package:flutter/widgets.dart',//重复的导入项
    ],
    className: 'FlutterLibrary',
    classDesc: 'Flutter library',
    libraryPaths: [
      '$flutterHome/packages/flutter/lib/src/animation',
      '$flutterHome/packages/flutter/lib/src/cupertino',
      '$flutterHome/packages/flutter/lib/src/foundation',
      '$flutterHome/packages/flutter/lib/src/gestures',
      '$flutterHome/packages/flutter/lib/src/material',
      '$flutterHome/packages/flutter/lib/src/painting',
      '$flutterHome/packages/flutter/lib/src/physics',
      '$flutterHome/packages/flutter/lib/src/rendering',
      '$flutterHome/packages/flutter/lib/src/scheduler',
      '$flutterHome/packages/flutter/lib/src/semantics',
      '$flutterHome/packages/flutter/lib/src/services',
      '$flutterHome/packages/flutter/lib/src/widgets',
    ],
    privatePaths: [
      '$flutterHome/bin/cache/dart-sdk/lib',
      '$flutterHome/bin/cache/pkg/sky_engine/lib',
      '$flutterHome/packages/flutter/lib',
    ],
  );
  coder.logVmLibrarydErrors();
}

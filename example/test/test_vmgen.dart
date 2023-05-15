import 'dart:io';

import 'package:shelf_easy/shelf_easy.dart';

void main(List<String> arguments) {
  final targetName = arguments.isEmpty ? 'testlib' : arguments.first;
  switch (targetName) {
    case 'testlib':

      ///为example生成model桥接库
      generateLibraryForModel();
      break;
    case 'flutter':

      ///
      ///为flutter生成flutter的桥接库
      ///
      ///这里全生成了，实际情况可以自己去掉不需要的库，只需确保：
      /// * 生成后调用EasyCode.logVmLibrarydErrors无错误打印
      /// * 且在开发工具里面打开库文件不报错，启动flutter应用正常
      ///
      generateLibraryForFlutter();
      break;
    case 'dartui':

      ///为flutter生成依赖的dart:ui桥接库
      generateLibraryForDartUI();
      break;
    default:
      throw ('Unsupport targetName: $targetName');
  }
}

void generateLibraryForModel() {
  final flutterHome = Platform.environment['FLUTTER_HOME']; //读取环境变量
  final coder = EasyCoder(
    config: EasyCoderConfig(
      logLevel: EasyLogLevel.debug,
      absFolder: '${Directory.current.path}/bridge',
    ),
  );
  coder.generateVmLibraries(
    outputFile: 'model_library',
    importList: ['../model/all.dart'],
    className: 'ModelLibrary',
    classDesc: '测试的数据模型桥接库',

    ///需要生成桥接类的路径，只有公开的声明才生成桥接类
    libraryPaths: [
      '${Directory.current.path}/model',
      '${Directory.current.path}/../lib/src/db/db_base.dart',
      // '${Directory.current.path}/test/test_vmware.dart', //for OuterClass
    ],

    ///私有路径不生成桥接类，只是用来查找与复制超类的属性
    privatePaths: [
      '$flutterHome/bin/cache/dart-sdk/lib',
      // '${Directory.current.path}/../lib/src/vm/vm_object.dart', //for OuterClass
    ],

    ///这个用来告诉生成器对应文件或文件夹下面只需要生成某些类的桥接类
    includePathClass: {
      '${Directory.current.path}/../lib/src/db/db_base.dart': ['DbBaseModel'],
      // '${Directory.current.path}/test/test_vmware.dart': ['OuterClass'], //for OuterClass
    },
  );
  //统一打印生成过程中的错误信息
  coder.logVmLibrarydErrors();
}

void generateLibraryForFlutter() {
  final flutterHome = Platform.environment['FLUTTER_HOME']; //读取环境变量
  final coder = EasyCoder(
    config: EasyCoderConfig(
      logLevel: EasyLogLevel.debug,
      absFolder: '${Directory.current.path}/../../zycloud_widget/lib/src/bridge',
    ),
  );
  coder.generateVmLibraries(
    outputFile: 'flutter_library',
    importList: [
      'import \'dart:ui\' as ui show BoxWidthStyle, BoxHeightStyle;',
      // 'package:flutter/animation.dart', //重复的导入项
      'package:flutter/cupertino.dart',
      'package:flutter/foundation.dart',
      'package:flutter/gestures.dart',
      'package:flutter/material.dart',
      // 'package:flutter/painting.dart', //重复的导入项
      'package:flutter/physics.dart',
      'package:flutter/rendering.dart',
      'package:flutter/scheduler.dart',
      // 'package:flutter/semantics.dart', //重复的导入项
      'package:flutter/services.dart',
      // 'package:flutter/widgets.dart', //重复的导入项
      'package:flutter_localizations/flutter_localizations.dart',
    ],
    className: 'FlutterLibrary',
    classDesc: 'Flutter完整库桥接类',
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
      '$flutterHome/packages/flutter_localizations/lib/src/cupertino_localizations.dart',
      '$flutterHome/packages/flutter_localizations/lib/src/material_localizations.dart',
      '$flutterHome/packages/flutter_localizations/lib/src/widgets_localizations.dart',
    ],
    privatePaths: [
      '$flutterHome/bin/cache/dart-sdk/lib',
      '$flutterHome/bin/cache/pkg/sky_engine/lib',
      '$flutterHome/packages/flutter/lib',
    ],
  );
  coder.logVmLibrarydErrors();
}

void generateLibraryForDartUI() {
  final flutterHome = Platform.environment['FLUTTER_HOME']; //读取环境变量
  final coder = EasyCoder(
    config: EasyCoderConfig(
      logLevel: EasyLogLevel.debug,
      absFolder: '${Directory.current.path}/../../zycloud_widget/lib/src/bridge',
    ),
  );
  coder.generateVmLibraries(
    outputFile: 'dartui_library',
    importList: [
      'dart:ui',
    ],
    className: 'DartUILibrary',
    classDesc: 'Dart的UI库桥接类，与Flutter库分开避免作用域冲突',
    libraryPaths: [
      '$flutterHome/bin/cache/pkg/sky_engine/lib/ui',
    ],
    privatePaths: [
      '$flutterHome/bin/cache/dart-sdk/lib',
      '$flutterHome/bin/cache/pkg/sky_engine/lib',
      '$flutterHome/packages/flutter/lib',
    ],
    excludePathClass: {
      '$flutterHome/bin/cache/pkg/sky_engine/lib/ui': [
        'Codec', //dart核心库已包含
        'Gradient', //fluter库已包含
        'Image', //fluter库已包含
        'decodeImageFromList', //fluter库已包含
        'StrutStyle', //fluter库已包含
        'TextStyle', //fluter库已包含
        'clampDouble', //fluter库已包含
      ],
    },
  );
  coder.logVmLibrarydErrors();
}

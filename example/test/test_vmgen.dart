import 'dart:io';

import 'package:shelf_easy/shelf_easy.dart';

void main(List<String> arguments) {
  final targetName = arguments.isEmpty ? 'test' : arguments.first;
  switch (targetName) {
    case 'dart':

      ///为dart-lang生成核心桥接库，当前兼容dart^3.0.0：
      ///
      ///  dart:async
      ///  dart:collection
      ///  dart:convert
      ///  dart:core
      ///  dart:math
      ///  dart:typed_data
      ///  dart:io
      ///  dart:isolate
      ///
      generateLibraryForDart();
      break;
    case 'model':

      ///为example生成模型桥接库，自定义桥接库的生成只需确保：
      ///
      /// 生成后调用EasyCode.logVmLibrarydErrors无错误打印。
      /// 且在开发工具里面打开库文件不报错，启动应用程序正常即可。
      ///
      generateLibraryForModel();
      break;
    default:
      generateLibraryForDart();
      generateLibraryForModel();
      break;
  }
}

void generateLibraryForDart() {
  final flutterHome = Platform.environment['FLUTTER_HOME']; //读取环境变量
  final coder = EasyCoder(
    config: EasyCoderConfig(
      logLevel: EasyLogLevel.debug,
      absFolder: '${Directory.current.path}/bridge',
    ),
  );
  coder.generateVmLibraries(
    outputFile: 'dart_library',
    importList: [
      'dart:async',
      'dart:collection',
      'dart:convert',
      'dart:core',
      // 'dart:developer', //与math库的log冲突，生产环境也不需要
      'dart:math',
      'dart:typed_data',
      'dart:io',
      'dart:isolate',
    ],
    className: 'DartLibrary',
    classDesc: 'Dart核心库桥接类',
    libraryPaths: [
      '$flutterHome/bin/cache/dart-sdk/lib/async',
      '$flutterHome/bin/cache/dart-sdk/lib/collection',
      '$flutterHome/bin/cache/dart-sdk/lib/convert',
      '$flutterHome/bin/cache/dart-sdk/lib/core',
      // '$flutterHome/bin/cache/dart-sdk/lib/developer',//与math库的log冲突，生产环境也不需要
      '$flutterHome/bin/cache/dart-sdk/lib/math',
      '$flutterHome/bin/cache/dart-sdk/lib/typed_data',
      '$flutterHome/bin/cache/dart-sdk/lib/io',
      '$flutterHome/bin/cache/dart-sdk/lib/isolate',
    ],
    privatePaths: [
      '$flutterHome/bin/cache/dart-sdk/lib/_http',
      '$flutterHome/bin/cache/dart-sdk/lib/internal',
      '${Directory.current.path}/../lib/src/vm/vm_base.dart', //添加字符串的翻译扩展
    ],
  );
  //统一打印生成过程中的错误信息
  coder.logVmLibrarydErrors();
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
      // '${Directory.current.path}/../lib/src/vm/vm_base.dart', //for OuterClass
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

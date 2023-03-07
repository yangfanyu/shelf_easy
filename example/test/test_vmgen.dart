import 'dart:io';

import 'package:shelf_easy/shelf_easy.dart';

void main() {
  generatorLibraryForModel();

  // generatorLibraryForFlutter('animation');
  // generatorLibraryForFlutter('cupertino');
  // generatorLibraryForFlutter('foundation');
  // generatorLibraryForFlutter('gestures');
  // generatorLibraryForFlutter('material');
  // generatorLibraryForFlutter('painting');
  // generatorLibraryForFlutter('physics');
  // generatorLibraryForFlutter('rendering');
  // generatorLibraryForFlutter('scheduler');
  // generatorLibraryForFlutter('semantics');
  // generatorLibraryForFlutter('services');
  // generatorLibraryForFlutter('widgets');
}

void generatorLibraryForModel() {
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
        '/Users/yangfanyu/Library/flutter/bin/cache/dart-sdk/lib/core',
      ],

      ///这个用来告诉生成器对应文件下面只需要生成具体类的列表
      onlyNeedFileClass: {
        '${Directory.current.path}/../lib/src/db/db_base.dart': ['DbBaseModel'],
      });
}

void generatorLibraryForFlutter(String module) {
  final coder = EasyCoder(
    config: EasyCoderConfig(
      absFolder: '/Users/yangfanyu/Project/zycloud_widget/lib/src/bridge/',
    ),
  );
  coder.generateVmLibraries(
    outputFile: '${module}_library',
    importList: ['package:flutter/$module.dart'],
    className: '${EasyCoder.firstUpperCaseName(module)}Library',
    classDesc: 'Flutter $module library',
    libraryPaths: [
      '/Users/yangfanyu/Library/flutter/packages/flutter/lib/src/$module',
    ],
  );
}

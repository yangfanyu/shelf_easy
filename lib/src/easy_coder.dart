import 'dart:io';

import 'easy_class.dart';
import 'vm/vm_parser.dart';

///
///Json序列化的数据模型的生成器、虚拟机桥接类型的生成器
///
class EasyCoder extends EasyLogger {
  ///配置信息
  final EasyCoderConfig _config;

  ///普通模型列表
  final List<EasyCoderModelInfo> _baseList;

  ///包装模型列表
  final List<EasyCoderModelInfo> _wrapList;

  ///桥接模型错误
  final List<List<dynamic>> _vmerrList;

  EasyCoder({required EasyCoderConfig config})
      : _config = config,
        _baseList = [],
        _wrapList = [],
        _vmerrList = [],
        super(
          logger: config.logger,
          logLevel: config.logLevel,
          logTag: config.logTag ?? 'EasyCoder',
          logFilePath: config.logFilePath,
          logFileBackup: config.logFileBackup,
          logFileMaxBytes: config.logFileMaxBytes,
        );

  ///生成数据库模型
  void generateModel(EasyCoderModelInfo modelInfo) {
    final indent = _config.indent;
    final outputPath = '${_config.absFolder}/${modelInfo.outputFile?.toLowerCase() ?? modelInfo.className.toLowerCase()}.dart'; //输入文件路径
    final buffer = StringBuffer();
    //删除旧文件
    try {
      final oldFile = File(outputPath); //旧文件
      if (oldFile.existsSync()) {
        oldFile.deleteSync();
        logDebug(['delete file', outputPath, 'success.']);
      }
    } catch (error, stack) {
      logError(['delete file', outputPath, 'error:', error, '\n', stack]);
    }
    //拼接类内容
    _generateImports(indent, modelInfo, buffer); //import内容
    buffer.write('///${modelInfo.classDesc.join('\n///')}\n'); //类描述信息
    buffer.write('class ${modelInfo.className} extends ${_config.baseClass} {\n'); //类开始
    _generateConstFields(indent, modelInfo, buffer); //常量字段
    _generateFieldDefine(indent, modelInfo, buffer); //成员字段
    _generateConstructor(indent, modelInfo, buffer); //构造函数
    _generateFromStringMethod(indent, modelInfo, buffer); //fromString函数
    _generateFromJsonMethod(indent, modelInfo, buffer); //fromJson函数
    _generateToStringMethod(indent, modelInfo, buffer); //toString函数
    _generateToJsonMethod(indent, modelInfo, buffer); //toJson函数
    _generateToKValuesMethod(indent, modelInfo, buffer); //toKValues函数
    _generateUpdateByJsonMethod(indent, modelInfo, buffer); //updateByJson函数
    _generateUpdateByKValuesMethod(indent, modelInfo, buffer); //updateByKValues函数
    if (modelInfo.wrapType != null) {
      _generateBuildTargetMethod(indent, modelInfo, buffer);
    }
    buffer.write('}\n'); //类结束
    //写入辅助类
    _generateDirtyClass(indent, modelInfo, buffer);
    //查询辅助类
    _generateQueryClass(indent, modelInfo, buffer);
    //写入到文件
    try {
      File(outputPath)
        ..createSync(recursive: true)
        ..writeAsStringSync(buffer.toString());
      logInfo(['write to file', outputPath, 'success.\n']);
    } catch (error, stack) {
      logError(['write to file', outputPath, 'error:', error, '\n', stack]);
    }
    //保存历史记录
    if (modelInfo.wrapType == null) {
      _baseList.add(modelInfo);
    } else {
      _wrapList.add(modelInfo);
    }
  }

  ///生成基本模型导出文件
  void generateBaseExports({String outputFile = 'all'}) {
    final outputPath = '${_config.absFolder}/$outputFile.dart'; //输入文件路径
    final buffer = StringBuffer();
    //删除旧文件
    try {
      final oldFile = File(outputPath); //旧文件
      if (oldFile.existsSync()) {
        oldFile.deleteSync();
        logDebug(['delete file', outputPath, 'success.']);
      }
    } catch (error, stack) {
      logError(['delete file', outputPath, 'error:', error, '\n', stack]);
    }
    if (_baseList.isEmpty) return;
    for (var element in _baseList) {
      final path = '${element.outputFile?.toLowerCase() ?? element.className.toLowerCase()}.dart'; //输入文件路径
      buffer.write('export \'$path\';\n');
    }
    //写入到文件
    try {
      File(outputPath)
        ..createSync(recursive: true)
        ..writeAsStringSync(buffer.toString());
      logInfo(['write to file', outputPath, 'success.\n']);
    } catch (error, stack) {
      logError(['write to file', outputPath, 'error:', error, '\n', stack]);
    }
  }

  ///生成包装模型构建器类
  void generateWrapBuilder({
    String outputFile = 'wrapper_builder',
    List<String> importList = const [],
    String className = 'WrapperBuilder',
    String? wrapBaseClass,
    bool exportFile = true,
  }) {
    final indent = _config.indent;
    final outputPath = '${_config.absFolder}/$outputFile.dart'; //输入文件路径
    final buffer = StringBuffer();
    //删除旧文件
    try {
      final oldFile = File(outputPath); //旧文件
      if (oldFile.existsSync()) {
        oldFile.deleteSync();
        logDebug(['delete file', outputPath, 'success.']);
      }
    } catch (error, stack) {
      logError(['delete file', outputPath, 'error:', error, '\n', stack]);
    }
    if (_wrapList.isEmpty) return;
    //拼接类内容
    buffer.write('import \'package:shelf_easy/shelf_easy.dart\';\n');
    for (var element in importList) {
      buffer.write('import \'$element\';\n');
    }
    buffer.write('\n');
    for (var element in _wrapList) {
      final path = '${element.outputFile?.toLowerCase() ?? element.className.toLowerCase()}.dart'; //输入文件路径
      buffer.write('import \'$path\';\n');
    }
    buffer.write('\n');
    if (exportFile) {
      for (var element in _wrapList) {
        final path = '${element.outputFile?.toLowerCase() ?? element.className.toLowerCase()}.dart'; //输入文件路径
        buffer.write('export \'$path\';\n');
      }
      buffer.write('\n');
    }
    buffer.write('///\n');
    buffer.write('///Parsing class\n');
    buffer.write('///\n');
    buffer.write('class $className {\n'); //类开始
    buffer.write('$indent///Parsing fields\n');
    buffer.write('${indent}static final _recordBuilder = <String, ${_config.baseClass} Function(Map<String, dynamic> map)>{\n');
    for (var element in _wrapList) {
      buffer.write('$indent$indent\'${element.className}\': (Map<String, dynamic> map) => ${element.className}.fromJson(map),\n');
    }
    buffer.write('$indent};\n\n');
    buffer.write('$indent///Parsing method\n');
    buffer.write('${indent}static ${_config.baseClass} buildRecord(Map<String, dynamic> map) => _recordBuilder[map[\'type\']]!(map);\n');
    buffer.write('}\n'); //类结束
    //写入到文件
    try {
      File(outputPath)
        ..createSync(recursive: true)
        ..writeAsStringSync(buffer.toString());
      logInfo(['write to file', outputPath, 'success.\n']);
    } catch (error, stack) {
      logError(['write to file', outputPath, 'error:', error, '\n', stack]);
    }
  }

  ///生成文件夹下的桥接类
  void generateVmLibraries({
    String outputFile = 'bridges_library',
    List<String> importList = const [],
    String className = 'BridgesLibrary',
    String classDesc = 'BridgesLibrary',
    required List<String> libraryPaths,
    List<String> privatePaths = const [],
    List<String> ignoreIssueFiles = const [
      '/dart-sdk/lib/core/null.dart', //忽略原因：非Object子类无需生成，在vmobject.dart中文件已内置。输出结果：不会生成该文件的任何内容，下同
      '/dart-sdk/lib/core/record.dart', //忽略原因：生成的代码在开发工具里面报错，这个类貌似也没什么卵用。
      '/flutter/lib/src/services/dom.dart', //忽略原因：生成的代码在开发工具里面报错，原生flutter环境也不需要。
      '/flutter/lib/src/painting/_network_image_web.dart', //忽略原因：生成的代码在开发工具里面报错，原生flutter环境也不需要。
    ],
    List<String> ignoreProxyObject = const [
      'PlatformSelectableRegionContextMenu.child', //属于dart-sdk库，忽略原因：生成出来的该属性在开发工具报错找不到值，输出结果：PlatformSelectableRegionContextMenu与子类都不会生成标识符为child的VmProxy项，下同
      'PlatformSelectableRegionContextMenu.registerViewFactory', //属于dart-sdk库，忽略原因：生成出来的该属性在开发工具报错找不到值。
      // 'jsonDecode',//忽略顶级VmProxy的写法
    ],
    List<String> ignoreProxyCaller = const [
      'Iterable.forEach', //属于dart-sdk库，忽略原因：Iterable.forEach 应该使用for循环代替。输出结果：Iterable与子类都不会生成forEach对应的Vmproxy的caller属性，下同
      'Map.fromIterable', //属于dart-sdk库，忽略原因：Map.fromIterable 应该使用for循环代替。
      'Radio.new', //属于flutter库，忽略原因：生成出来的该属性在开发工具里面报错范型有问题。
      'RadioListTile.new', //属于flutter库，忽略原因：生成出来的该属性在开发工具里面报错范型有问题。
      'RadioMenuButton.new', //属于flutter库，忽略原因：生成出来的该属性在开发工具里面报错范型有问题。
      'SharedAppData.getValue', //属于flutter库，忽略原因：生成出来的该属性在开发工具里面报错范型有问题。
      'GestureRecognizerFactoryWithHandlers.new', //属于flutter库，忽略原因：生成出来的该属性在开发工具里面报错范型有问题。
      'PaginatedDataTable.new', //属于flutter库，忽略原因：生成出来的该属性在开发工具里面报错默认值无法找到。
      'Autocomplete.new', //属于flutter库，忽略原因：生成出来的该属性在加载时报错范型有问题。
      'RawAutocomplete.new', //属于flutter库，忽略原因：生成出来的该属性在加载时报错范型有问题。
      'WidgetInspectorService.initServiceExtensions', //属于flutter库，忽略原因：生成出来的该属性的某个参数是：带有一个无法生成默认值的参数[callback]的函数。
      // 'jsonDecode',//忽略顶级VmProxy的caller的写法
    ],
    List<String> ignoreExtensionOn = const [
      'Object', //属于dart-sdk库，但是flutter库添加了toJs等不要的扩展
      'Iterable', //属于dart-sdk库，添加出来的扩展属性在开发工具里面报错
    ],
    Map<String, List<String>> includeFileClass = const {}, //某文件只需要指定的类 或 顶级属性
    Map<String, List<String>> excludeFileClass = const {}, //某文件排除掉指定的类 或 顶级属性
    bool genByExternal = true,
  }) {
    final indent = _config.indent;
    final outputPath = '${_config.absFolder}/$outputFile.dart'; //输入文件路径
    final buffer = StringBuffer();
    //删除旧文件
    try {
      final oldFile = File(outputPath); //旧文件
      if (oldFile.existsSync()) {
        oldFile.deleteSync();
        logDebug(['delete file', outputPath, 'success.']);
      }
    } catch (error, stack) {
      logError(['delete file', outputPath, 'error:', error, '\n', stack]);
    }
    //拼接类内容
    buffer.write('// ignore_for_file: unnecessary_constructor_name, deprecated_member_use, invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member\n');
    buffer.write('\n');
    if (genByExternal) buffer.write('import \'package:shelf_easy/shelf_easy.dart\';\n');
    for (var element in importList) {
      if (element.startsWith('import')) {
        buffer.write('$element\n');
      } else {
        buffer.write('import \'$element\';\n');
      }
    }
    if (!genByExternal) buffer.write('import \'vm_object.dart\';\n');
    buffer.write('\n');
    buffer.write('///\n');
    buffer.write('///$classDesc\n');
    buffer.write('///\n');
    buffer.write('class $className {\n'); //类开始

    //start
    final privateDatas = <String, VmParserBirdgeItemData>{}; //私有类数据，用于超类属性的继承
    final functionRefs = <String, VmParserBirdgeItemData>{}; //函数的别名，用于函数参数的替换
    //扫描私有目录，提取全部类作为私有类
    final privateFiles = <File>[];
    for (var element in privatePaths) {
      if (element.endsWith('.dart')) {
        privateFiles.add(File(element));
      } else {
        privateFiles.addAll(Directory(element).listSync(recursive: true).where((e) => e is File && e.path.endsWith('.dart')).map((e) => e as File));
      }
    }
    for (var fileItem in privateFiles) {
      final bridgeResults = VmParser.bridgeSource(fileItem.readAsStringSync(), ignoreExtensionOn: ignoreExtensionOn);
      for (var result in bridgeResults) {
        if (result != null && result.type == VmParserBirdgeItemType.classDeclaration) {
          result.absoluteFilePath = fileItem.path; //复制文件路径
          if (privateDatas.containsKey(result.name)) {
            privateDatas[result.name]!.combineClass(result); //合并同名属性
            logTrace(['merge repeat private class:', result.name, '=>', result.absoluteFilePath]);
          } else {
            privateDatas[result.name] = result;
          }
        } else if (result != null && result.type == VmParserBirdgeItemType.functionTypeAlias) {
          result.absoluteFilePath = fileItem.path; //复制文件路径
          if (functionRefs.containsKey(result.name)) {
            logWarn(['ignore repeat function alias:', result.name, '=>', result.absoluteFilePath]);
          } else {
            functionRefs[result.name] = result;
          }
        }
      }
    }
    //扫描资源目录，提取私有类作为私有类
    final libraryFiles = <File>[];
    for (var element in libraryPaths) {
      if (element.endsWith('.dart')) {
        libraryFiles.add(File(element));
      } else {
        libraryFiles.addAll(Directory(element).listSync(recursive: true).where((e) => e is File && e.path.endsWith('.dart')).map((e) => e as File));
      }
    }
    for (var fileItem in libraryFiles) {
      final bridgeResults = VmParser.bridgeSource(fileItem.readAsStringSync(), ignoreExtensionOn: ignoreExtensionOn);
      for (var result in bridgeResults) {
        if (result != null && result.type == VmParserBirdgeItemType.classDeclaration && result.isPrivate) {
          result.absoluteFilePath = fileItem.path; //复制文件路径
          if (privateDatas.containsKey(result.name)) {
            privateDatas[result.name]!.combineClass(result); //合并同名属性
            logTrace(['merge repeat private class:', result.name, '=>', result.absoluteFilePath]);
          } else {
            privateDatas[result.name] = result;
          }
        } else if (result != null && result.type == VmParserBirdgeItemType.functionTypeAlias) {
          result.absoluteFilePath = fileItem.path; //复制文件路径
          if (functionRefs.containsKey(result.name)) {
            logWarn(['ignore repeat function alias:', result.name, '=>', result.absoluteFilePath]);
          } else {
            functionRefs[result.name] = result;
          }
        }
      }
    }
    //为私有类添加扩展，这样就子类就能复制扩展属性
    privateDatas.forEach((key, item) {
      //合并extension属性
      final extensionItem = privateDatas[VmParserBirdgeItemData.extensionName(item.name)];
      if (extensionItem != null && extensionItem.isExtension) {
        logTrace(['merge extension on ${item.name}:', extensionItem.name, '=>', extensionItem.absoluteFilePath]);
        item.combineClass(extensionItem);
      }
    });
    //扫描资源目录，得到公开class与proxy列表
    final classLibraries = <VmParserBirdgeItemData>[];
    final proxyLibraries = <VmParserBirdgeItemData>[];
    for (var fileItem in libraryFiles) {
      if (ignoreIssueFiles.any((element) => fileItem.path.endsWith(element))) {
        logDebug(['ignore explicit library file =>', fileItem.path]);
      } else {
        final bridgeResults = VmParser.bridgeSource(fileItem.readAsStringSync(), ignoreExtensionOn: ignoreExtensionOn);
        for (var result in bridgeResults) {
          if (result != null && !result.isAtJS && !result.isPrivate && result.type != VmParserBirdgeItemType.functionTypeAlias) {
            if (includeFileClass.containsKey(fileItem.path) && !includeFileClass[fileItem.path]!.contains(result.name)) continue; //忽略
            if (excludeFileClass.containsKey(fileItem.path) && excludeFileClass[fileItem.path]!.contains(result.name)) continue; //忽略
            result.absoluteFilePath = fileItem.path; //复制文件路径
            result.type == VmParserBirdgeItemType.classDeclaration ? classLibraries.add(result) : proxyLibraries.add(result);
          }
        }
      }
    }
    classLibraries.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    proxyLibraries.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    //合并同名的class
    final classUnionDatasMap = <String, VmParserBirdgeItemData>{};
    for (var item in classLibraries) {
      if (classUnionDatasMap.containsKey(item.name)) {
        classUnionDatasMap[item.name]!.combineClass(item); //合并同名属性
        logTrace(['merge repeat library class:', item.name, '=>', item.absoluteFilePath]);
      } else {
        classUnionDatasMap[item.name] = item;
        //合并extension属性
        final extensionItem = privateDatas[VmParserBirdgeItemData.extensionName(item.name)];
        if (extensionItem != null && extensionItem.isExtension) {
          logTrace(['merge extension on ${item.name}:', extensionItem.name, '=>', extensionItem.absoluteFilePath]);
          item.combineClass(extensionItem);
        }
      }
    }
    //生成单个的class代码
    classUnionDatasMap.forEach((key, value) {
      //深度继承全部超类的实例字段
      value.extendsSuper(currentClass: value, publicMap: classUnionDatasMap, pirvateMap: privateDatas, onNotFoundSuperClass: _onVmNotFoundSuperClass);
      //继承构造函数super参数默认值
      value.extendsValue(publicMap: classUnionDatasMap, pirvateMap: privateDatas, onNotFoundClassField: _onVmNotFoundClassField);
      //替换成员函数的参数类型的别名
      value.replaceAlias(functionRefs: functionRefs, onReplaceProxyAlias: _onVmReplaceProxyAlias, onIgnorePrivateArgV: _onVmIgnorePrivateArgV);
      //生成代码
      final fieldName = 'class${firstUpperCaseName(key)}';
      final fieldCode = value.toClassCode(
        indent: indent,
        ignoreProxyObject: ignoreProxyObject,
        ignoreProxyCaller: ignoreProxyCaller,
        onIgnoreProxyObject: _onVmIgnoreProxyObject,
        onIgnoreProxyCaller: _onVmIgnoreProxyCaller,
      );
      buffer.write('$indent///class $key\n');
      buffer.write('${indent}static final $fieldName = $fieldCode\n');
      buffer.write('\n');
    });
    //生成class列表的代码
    buffer.write('$indent///all class list\n');
    if (classUnionDatasMap.isEmpty) {
      buffer.write('${indent}static final libraryClassList = <VmClass>[];\n');
    } else {
      buffer.write('${indent}static final libraryClassList = <VmClass>[\n');
      classUnionDatasMap.forEach((key, value) {
        final fieldName = 'class${firstUpperCaseName(key)}';
        buffer.write('$indent$indent$fieldName,\n');
      });
      buffer.write('$indent];\n');
    }
    buffer.write('\n');
    //合并同名的proxy
    final proxyUnionPartsMap = <String, Set<String>>{};
    for (var item in proxyLibraries) {
      if (ignoreProxyObject.contains(item.name)) {
        _onVmIgnoreProxyObject('', item.name, item.absoluteFilePath);
      } else {
        //替换别名
        item.replaceAlias(functionRefs: functionRefs, onReplaceProxyAlias: _onVmReplaceProxyAlias, onIgnorePrivateArgV: _onVmIgnorePrivateArgV);
        if (proxyUnionPartsMap.containsKey(item.name)) {
          final unionParts = proxyUnionPartsMap[item.name]!;
          item.toProxyCode(
            unionParts: unionParts,
            ignoreProxyCaller: ignoreProxyCaller,
            onIgnoreProxyCaller: _onVmIgnoreProxyCaller,
          ); //合并同名属性
          logTrace(['merge repeat library proxy:', item.name, '=>', item.absoluteFilePath]);
        } else {
          final unionParts = proxyUnionPartsMap[item.name] = {};
          item.toProxyCode(
            unionParts: unionParts,
            ignoreProxyCaller: ignoreProxyCaller,
            onIgnoreProxyCaller: _onVmIgnoreProxyCaller,
          );
        }
      }
    }
    //生成proxy列表的代码
    buffer.write('$indent///all proxy list\n');
    if (proxyUnionPartsMap.isEmpty) {
      buffer.write('${indent}static final libraryProxyList = <VmProxy<void>>[];\n');
    } else {
      buffer.write('${indent}static final libraryProxyList = <VmProxy<void>>[\n');
      proxyUnionPartsMap.forEach((key, value) {
        if (value.isNotEmpty) {
          final identifier = VmParserBirdgeItemData.getIdentifier(key);
          buffer.write('$indent${indent}VmProxy(identifier: \'$identifier\', ${value.join(', ')}),\n');
        }
      });
      buffer.write('$indent];\n');
    }
    //end

    buffer.write('}\n'); //类结束
    //写入到文件
    try {
      File(outputPath)
        ..createSync(recursive: true)
        ..writeAsStringSync(buffer.toString());
      logInfo(['write to file', outputPath, 'success.\n']);
    } catch (error, stack) {
      logError(['write to file', outputPath, 'error:', error, '\n', stack]);
    }
  }

  ///统一打印桥接库生成时的错误
  void logVmLibrarydErrors() {
    if (_vmerrList.isEmpty) {
      logInfo(['No error found.']);
    } else {
      logError(['Total ${_vmerrList.length} error found:']);
      for (var element in _vmerrList) {
        logError(element);
      }
    }
  }

  void _generateImports(String indent, EasyCoderModelInfo modelInfo, StringBuffer buffer) {
    //自动导入模型基类文件
    buffer.write('import \'package:shelf_easy/shelf_easy.dart\';\n');
    //导入自定义文件
    for (var element in modelInfo.importList) {
      buffer.write('import \'$element\';\n');
    }
    buffer.write('\n');
  }

  void _generateConstFields(String indent, EasyCoderModelInfo modelInfo, StringBuffer buffer) {
    for (var element in modelInfo.constFields) {
      if (element.desc.isEmpty) {
        buffer.write('$indent///Field ${element.name}\n');
      } else {
        buffer.write('$indent///${element.desc.join('\n$indent///')}\n');
      }
      buffer.write('${indent}static const ${element.type} ${element.name} = ${element.defVal};\n\n');
    }
    if (modelInfo.constMap && modelInfo.constFields.isNotEmpty) {
      buffer.write('${indent}static const Map<String, Map<int, String>> constMap = {\n');
      buffer.write('$indent$indent\'zh\': {\n');
      for (var element in modelInfo.constFields) {
        buffer.write('$indent$indent$indent${element.defVal}: \'${element.zhText}\',\n');
      }
      buffer.write('$indent$indent},\n');
      buffer.write('$indent$indent\'en\': {\n');
      for (var element in modelInfo.constFields) {
        buffer.write('$indent$indent$indent${element.defVal}: \'${element.enText}\',\n');
      }
      buffer.write('$indent$indent},\n');
      buffer.write('$indent};\n\n');
    }
  }

  void _generateFieldDefine(String indent, EasyCoderModelInfo modelInfo, StringBuffer buffer) {
    final privateFields = <EasyCoderFieldInfo>[];
    for (var element in modelInfo.classFields) {
      if (element.desc.isEmpty) {
        buffer.write('$indent///Field ${element.name}\n');
      } else {
        buffer.write('$indent///${element.desc.join('\n$indent///')}\n');
      }
      if (element.nullAble) {
        buffer.write('$indent${element.type}? ${element.name};\n\n');
      } else {
        buffer.write('$indent${element.type} ${element.name};\n\n');
      }
      if (element.name.startsWith('_')) {
        privateFields.add(element);
      }
    }
    //私有字段生成get函数
    for (var element in privateFields) {
      final publicName = _getFieldPublicName(element.name);
      if (element.desc.isEmpty) {
        buffer.write('$indent///Field ${element.name}\n');
      } else {
        buffer.write('$indent///${element.desc.join('\n$indent///')}\n');
      }
      buffer.write('$indent${element.type} get $publicName => ${element.name};\n\n');
    }
    //扩展字段
    for (var element in modelInfo.extraFields) {
      final publicName = _getFieldPublicName(element.name);
      final defaultValue = _getFieldDefaultValue(element.name, element.type, element.defVal);
      if (element.desc.isEmpty) {
        buffer.write('$indent///Field ${element.name}\n');
      } else {
        buffer.write('$indent///${element.desc.join('\n$indent///')}\n');
      }
      if (element.nullAble) {
        buffer.write('$indent${element.type}? $publicName;\n\n');
      } else {
        buffer.write('$indent${element.type} $publicName = $defaultValue;\n\n');
      }
    }
  }

  void _generateConstructor(String indent, EasyCoderModelInfo modelInfo, StringBuffer buffer) {
    if (modelInfo.classFields.isEmpty) {
      buffer.write('$indent${modelInfo.className}();\n\n');
      return;
    }
    buffer.write('$indent${modelInfo.className}({\n');
    final notNullAbleFields = <EasyCoderFieldInfo>[]; //不可空的字段
    for (var element in modelInfo.classFields) {
      final publicName = _getFieldPublicName(element.name);
      if (element.nullAble) {
        buffer.write('$indent${indent}this.$publicName,\n');
      } else {
        buffer.write('$indent$indent${element.type}? $publicName,\n');
        notNullAbleFields.add(element);
      }
    }
    if (notNullAbleFields.isEmpty) {
      buffer.write('$indent});\n\n');
    } else if (notNullAbleFields.length > 1) {
      buffer.write('$indent})  : ');
    } else {
      buffer.write('$indent}) : ');
    }
    for (var element in notNullAbleFields) {
      final publicName = _getFieldPublicName(element.name);
      final defaultValue = _getFieldDefaultValue(element.name, element.type, element.defVal);
      if (element == notNullAbleFields.last) {
        //需要先判断是否为最后一个字段
        if (notNullAbleFields.length > 1) {
          buffer.write('$indent$indent$indent$indent${element.name} = $publicName ?? $defaultValue;\n\n');
        } else {
          //当总共一个字段时，这也是第一个字段
          buffer.write('${element.name} = $publicName ?? $defaultValue;\n\n');
        }
      } else if (element == notNullAbleFields.first) {
        //能运行到这里说明 notNullAbleFields.length >= 2
        buffer.write('${element.name} = $publicName ?? $defaultValue,\n');
      } else {
        //能运行到这里说明 notNullAbleFields.length >= 3
        buffer.write('$indent$indent$indent$indent${element.name} = $publicName ?? $defaultValue,\n');
      }
    }
  }

  void _generateFromStringMethod(String indent, EasyCoderModelInfo modelInfo, StringBuffer buffer) {
    buffer.write('${indent}factory ${modelInfo.className}.fromString(String data) {\n');
    buffer.write('$indent${indent}return ${modelInfo.className}.fromJson(jsonDecode(data.substring(data.indexOf(\'(\') + 1, data.lastIndexOf(\')\'))));\n');
    buffer.write('$indent}\n\n');
  }

  void _generateFromJsonMethod(String indent, EasyCoderModelInfo modelInfo, StringBuffer buffer) {
    if (modelInfo.classFields.isEmpty) {
      buffer.write('${indent}factory ${modelInfo.className}.fromJson(Map<String, dynamic> map) {\n');
      buffer.write('$indent${indent}return ${modelInfo.className}();\n');
      buffer.write('$indent}\n\n');
      return;
    }
    buffer.write('${indent}factory ${modelInfo.className}.fromJson(Map<String, dynamic> map) {\n');
    if (modelInfo.wrapType != null) {
      buffer.write('$indent${indent}map = map[\'args\'];\n');
    }
    buffer.write('$indent${indent}return ${modelInfo.className}(\n');
    for (var element in modelInfo.classFields) {
      final publicName = _getFieldPublicName(element.name);
      var currType = element.type.replaceAll(' ', ''); //去除全部空格
      if (currType.startsWith('List<') || currType.startsWith('Map<')) {
        //嵌套数据类型
        final prefix = <String>[];
        final suffix = <String>[];
        while (currType.startsWith('List<') || currType.startsWith('Map<')) {
          if (currType.startsWith('List<')) {
            final type = 'List<';
            prefix.add(type);
            suffix.add('>');
            currType = currType.replaceFirst(type, '').replaceFirst('>', '');
          } else if (currType.startsWith('Map<')) {
            final type = currType.substring(0, currType.indexOf(',') + 1);
            prefix.add(type);
            suffix.add('>');
            currType = currType.replaceFirst(type, '').replaceFirst('>', '');
          }
        }
        logTrace(['symbol table =>', element.name, element.type, '=>', prefix, suffix, currType]);
        final prevStr = <String>[];
        final suffStr = <String>[];
        for (var type in prefix) {
          if (prevStr.isEmpty) {
            if (type.startsWith('List<')) {
              prevStr.add('(map[\'${element.name}\'] as List?)?.map((v) => ');
              suffStr.insert(0, ').toList()');
            } else if (type.startsWith('Map<')) {
              final keyType = type.replaceFirst('Map<', '').replaceFirst(',', '');
              final keyTemplate = _config.nestFromJsonKeys[keyType] ?? _config.nestFromJsonKeys[EasyCoderConfig.defaultType]!;
              prevStr.add('(map[\'${element.name}\'] as Map?)?.map((k, v) => MapEntry(${EasyCoderConfig.compileTemplateCode(keyTemplate, 'k', keyType)}, ');
              suffStr.insert(0, '))');
            }
          } else {
            if (type.startsWith('List<')) {
              prevStr.add('(v as List).map((v) => ');
              suffStr.insert(0, ').toList()');
            } else if (type.startsWith('Map<')) {
              final keyType = type.replaceFirst('Map<', '').replaceFirst(',', '');
              final keyTemplate = _config.nestFromJsonKeys[keyType] ?? _config.nestFromJsonKeys[EasyCoderConfig.defaultType]!;
              prevStr.add('(v as Map).map((k, v) => MapEntry(${EasyCoderConfig.compileTemplateCode(keyTemplate, 'k', keyType)}, ');
              suffStr.insert(0, '))');
            }
          }
        }
        final valTemplate = _config.nestFromJsonVals[currType] ?? _config.nestFromJsonVals[EasyCoderConfig.defaultType]!;
        final expression = '${prevStr.join('')}${EasyCoderConfig.compileTemplateCode(valTemplate, 'v', currType)}${suffStr.join('')}';
        logTrace(['expression =>', element.name, element.type, '=>', expression]);
        buffer.write('$indent$indent$indent$publicName: $expression,\n');
      } else {
        //其他数据类型
        final valTemplate = _config.baseFromJsonVals[currType] ?? _config.baseFromJsonVals[EasyCoderConfig.defaultType]!;
        final expression = EasyCoderConfig.compileTemplateCode(valTemplate, 'map[\'${element.name}\']', currType);
        buffer.write('$indent$indent$indent$publicName: $expression,\n');
      }
    }
    buffer.write('$indent$indent);\n');
    buffer.write('$indent}\n\n');
  }

  void _generateToStringMethod(String indent, EasyCoderModelInfo modelInfo, StringBuffer buffer) {
    buffer.write('$indent@override\n');
    buffer.write('${indent}String toString() {\n');
    buffer.write('$indent${indent}return \'${modelInfo.className}(\${jsonEncode(toJson())})\';\n');
    buffer.write('$indent}\n\n');
    return;
  }

  void _generateToJsonMethod(String indent, EasyCoderModelInfo modelInfo, StringBuffer buffer) {
    if (modelInfo.classFields.isEmpty) {
      buffer.write('$indent@override\n');
      buffer.write('${indent}Map<String, dynamic> toJson() {\n');
      if (modelInfo.wrapType != null) {
        buffer.write('$indent${indent}return {\'type\': ${modelInfo.className}, \'args\': {}};\n');
      } else {
        buffer.write('$indent${indent}return {};\n');
      }
      buffer.write('$indent}\n\n');
      return;
    }
    buffer.write('$indent@override\n');
    buffer.write('${indent}Map<String, dynamic> toJson() {\n');
    if (modelInfo.wrapType != null) {
      buffer.write('$indent${indent}return {\n');
      buffer.write('$indent$indent$indent\'type\': \'${modelInfo.className}\',\n');
      buffer.write('$indent$indent$indent\'args\': {\n');
      for (var element in modelInfo.classFields) {
        final valTemplate = _config.fieldsToJsonVals[element.type] ?? _config.fieldsToJsonVals[EasyCoderConfig.defaultType]!;
        final expression = EasyCoderConfig.compileTemplateCode(valTemplate, element.name, element.type);
        buffer.write('$indent$indent$indent$indent\'${element.name}\': $expression,\n');
      }
      buffer.write('$indent$indent$indent},\n');
      buffer.write('$indent$indent};\n');
    } else {
      buffer.write('$indent${indent}return {\n');
      for (var element in modelInfo.classFields) {
        final valTemplate = _config.fieldsToJsonVals[element.type] ?? _config.fieldsToJsonVals[EasyCoderConfig.defaultType]!;
        final expression = EasyCoderConfig.compileTemplateCode(valTemplate, element.name, element.type);
        buffer.write('$indent$indent$indent\'${element.name}\': $expression,\n');
      }
      buffer.write('$indent$indent};\n');
    }
    buffer.write('$indent}\n\n');
  }

  void _generateToKValuesMethod(String indent, EasyCoderModelInfo modelInfo, StringBuffer buffer) {
    if (modelInfo.classFields.isEmpty) {
      buffer.write('$indent@override\n');
      buffer.write('${indent}Map<String, dynamic> toKValues() {\n');
      buffer.write('$indent${indent}return {};\n');
      buffer.write('$indent}\n\n');
      return;
    }
    buffer.write('$indent@override\n');
    buffer.write('${indent}Map<String, dynamic> toKValues() {\n');
    buffer.write('$indent${indent}return {\n');
    for (var element in modelInfo.classFields) {
      buffer.write('$indent$indent$indent\'${element.name}\': ${element.name},\n');
    }
    buffer.write('$indent$indent};\n');
    buffer.write('$indent}\n\n');
  }

  void _generateUpdateByJsonMethod(String indent, EasyCoderModelInfo modelInfo, StringBuffer buffer) {
    if (modelInfo.classFields.isEmpty) {
      buffer.write('$indent@override\n');
      buffer.write('${indent}void updateByJson(Map<String, dynamic> map, {${modelInfo.className}? parser}) {}\n\n');
      return;
    }
    buffer.write('$indent@override\n');
    buffer.write('${indent}void updateByJson(Map<String, dynamic> map, {${modelInfo.className}? parser}) {\n');
    buffer.write('$indent${indent}parser = parser ?? ${modelInfo.className}.fromJson(map);\n');
    for (var element in modelInfo.classFields) {
      buffer.write('$indent${indent}if (map.containsKey(\'${element.name}\')) ${element.name} = parser.${element.name};\n');
    }
    buffer.write('$indent}\n\n');
    return;
  }

  void _generateUpdateByKValuesMethod(String indent, EasyCoderModelInfo modelInfo, StringBuffer buffer) {
    if (modelInfo.classFields.isEmpty) {
      buffer.write('$indent@override\n');
      buffer.write('${indent}void updateByKValues(Map<String, dynamic> map) {}\n');
      return;
    }
    buffer.write('$indent@override\n');
    buffer.write('${indent}void updateByKValues(Map<String, dynamic> map) {\n');
    for (var element in modelInfo.classFields) {
      buffer.write('$indent${indent}if (map.containsKey(\'${element.name}\')) ${element.name} = map[\'${element.name}\'];\n');
    }
    buffer.write('$indent}\n');
    return;
  }

  void _generateBuildTargetMethod(String indent, EasyCoderModelInfo modelInfo, StringBuffer buffer) {
    buffer.write('\n');
    if (modelInfo.classFields.isEmpty) {
      buffer.write('$indent@override\n');
      buffer.write('$indent${modelInfo.wrapType} buildTarget() {\n');
      buffer.write('$indent${indent}return ${modelInfo.wrapType}();\n');
      buffer.write('$indent}\n');
      return;
    }
    buffer.write('$indent@override\n');
    buffer.write('$indent${modelInfo.wrapType} buildTarget() {\n');
    buffer.write('$indent${indent}return ${modelInfo.wrapType}(\n');
    for (var element in modelInfo.classFields) {
      final valTemplate = _config.fieldsToWrapVals[element.type] ?? _config.fieldsToWrapVals[EasyCoderConfig.defaultType]!;
      final expression = EasyCoderConfig.compileTemplateCode(valTemplate, element.name, element.type);
      if (element.wrapFlat) {
        buffer.write('$indent$indent$indent$expression,\n');
      } else {
        buffer.write('$indent$indent$indent${element.name}: $expression,\n');
      }
    }
    buffer.write('$indent$indent);\n');
    buffer.write('$indent}\n');
  }

  void _generateDirtyClass(String indent, EasyCoderModelInfo modelInfo, StringBuffer buffer) {
    if (modelInfo.dirty && modelInfo.classFields.isNotEmpty) {
      buffer.write('\n');
      buffer.write('class ${modelInfo.className}Dirty {\n');
      buffer.write('${indent}final Map<String, dynamic> data = {};\n\n');
      for (var element in modelInfo.classFields) {
        final publicName = _getFieldPublicName(element.name);
        if (element.desc.isEmpty) {
          buffer.write('$indent///Field ${element.name}\n');
        } else {
          buffer.write('$indent///${element.desc.join('\n$indent///')}\n');
        }
        if (element == modelInfo.classFields.last) {
          buffer.write('${indent}set $publicName(${element.type} value) => data[\'${element.name}\'] = DbQueryField.toBaseType(value);\n');
        } else {
          buffer.write('${indent}set $publicName(${element.type} value) => data[\'${element.name}\'] = DbQueryField.toBaseType(value);\n\n');
        }
      }
      buffer.write('}\n');
    }
  }

  void _generateQueryClass(String indent, EasyCoderModelInfo modelInfo, StringBuffer buffer) {
    if (modelInfo.query && modelInfo.classFields.isNotEmpty) {
      buffer.write('\n');
      buffer.write('class ${modelInfo.className}Query {\n');
      buffer.write('${indent}static const \$tableName = \'${modelInfo.className.toLowerCase()}\';\n\n'); //数据表名称
      //保密字段
      final secrecyList = <EasyCoderFieldInfo>[]; //保密字段
      for (var element in modelInfo.classFields) {
        if (element.secrecy) secrecyList.add(element);
      }
      if (secrecyList.isNotEmpty) {
        buffer.write('${indent}static Set<DbQueryField> get \$secrecyFieldsExclude {\n');
        buffer.write('$indent${indent}return {\n');
        for (var element in secrecyList) {
          final publicName = _getFieldPublicName(element.name);
          buffer.write('$indent$indent$indent$publicName..exclude(),\n');
        }
        buffer.write('$indent$indent};\n');
        buffer.write('$indent}\n\n');
      }
      //查询字段
      for (var element in modelInfo.classFields) {
        final publicName = _getFieldPublicName(element.name);
        final currType = element.type.replaceAll(' ', ''); //去除全部空格
        final numType = (currType == 'int' || currType == 'double' || currType == 'num') ? currType : 'DBUnsupportNumberOperate';
        final itemType = currType.startsWith('List<') ? currType.replaceFirst('List<', '').replaceFirst('>', '').replaceAll(',', ', ') : 'DBUnsupportArrayOperate';
        if (element.desc.isEmpty) {
          buffer.write('$indent///Field ${element.name}\n');
        } else {
          buffer.write('$indent///${element.desc.join('\n$indent///')}\n');
        }
        if (element == modelInfo.classFields.last) {
          buffer.write('${indent}static DbQueryField<${element.type}, $numType, $itemType> get $publicName => DbQueryField(\'${element.name}\');\n');
        } else {
          buffer.write('${indent}static DbQueryField<${element.type}, $numType, $itemType> get $publicName => DbQueryField(\'${element.name}\');\n\n');
        }
      }
      buffer.write('}\n');
    }
  }

  String _getFieldPublicName(String name) => name.replaceAll('_', '');

  String _getFieldDefaultValue(String name, String type, String? defVal) {
    if (defVal != null) return defVal;
    final currType = type.trim();
    if (currType == 'int') return '0';
    if (currType == 'double') return '0';
    if (currType == 'num') return '0';
    if (currType == 'bool') return 'false';
    if (currType == 'String') return '\'\'';
    if (currType == 'ObjectId') return name == '_id' ? 'ObjectId()' : 'ObjectId.fromHexString(\'000000000000000000000000\')';
    if (currType.startsWith('List')) return '[]';
    if (currType.startsWith('Map')) return '{}';
    return '$type()';
  }

  void _onVmNotFoundSuperClass(String className, String superName, String classPath) {
    _vmerrList.add(['cannot found super class:', '$className inherit $superName', '=>', classPath]); //添加到错误列表，便于统一打印
  }

  void _onVmNotFoundClassField(String className, String fieldName, String classPath) {
    _vmerrList.add(['cannot found class field:', '$className.$fieldName', '=>', classPath]); //添加到错误列表，便于统一打印
  }

  void _onVmIgnoreProxyObject(String className, String proxyName, String classPath) {
    logDebug(['ignore explicit proxy object:', '$className.$proxyName', '=>', classPath]);
  }

  void _onVmIgnoreProxyCaller(String className, String proxyName, String classPath) {
    logDebug(['ignore explicit proxy caller:', '$className.$proxyName', '=>', classPath]);
  }

  void _onVmReplaceProxyAlias(String className, String proxyName, String paramName, String aliasName, String classPath) {
    logDebug(['replace proxy arg type alias:', '$className.$proxyName', paramName, '->', aliasName, '=>', classPath]);
  }

  void _onVmIgnorePrivateArgV(String className, String proxyName, String paramName, String paramValue, String classPath) {
    logWarn(['ignore proxy named parameter by private default value:', '$className.$proxyName', paramName, '->', paramValue, '=>', classPath]); //这里用warn
  }

  ///将[name]的第一个字母改为大写
  static String firstUpperCaseName(String name) {
    if (name.length <= 1) return name.toUpperCase();
    return '${name[0].toUpperCase()}${name.substring(1)}';
  }
}

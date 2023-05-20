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
  final List<List<dynamic>> _vmwarnList;

  ///桥接模型错误
  final List<List<dynamic>> _vmerrorList;

  EasyCoder({required EasyCoderConfig config})
      : _config = config,
        _baseList = [],
        _wrapList = [],
        _vmwarnList = [],
        _vmerrorList = [],
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
      if (element.startsWith('import')) {
        buffer.write('$element\n');
      } else {
        buffer.write('import \'$element\';\n');
      }
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
    List<String> ignoreIssuePaths = const [
      '/dart-sdk/lib/core/null.dart', //属于dart-sdk库，忽略原因：非Object子类无需生成，在vmobject.dart中文件已内置。输出结果：不会生成前缀或后缀匹配该路径的任何内容，下同
      '/flutter/lib/src/services/dom.dart', //属于flutter库，忽略原因：生成的代码在开发工具里面报错，原生flutter环境也不需要。
      '/flutter/lib/src/widgets/window.dart', //属于flutter库，忽略原因：生成的代码在开发工具里面报错，原生flutter环境也不需要。
      '/flutter/lib/src/cupertino/toggleable.dart', //属于flutter库，忽略原因：ToggleableStateMixin.buildToggleable参数与material不一样。
      '_web.dart', //属于flutter库，忽略原因：生成的代码在开发工具里面报错，原生flutter环境也不需要。macos可执行：find $FLUTTER_HOME/packages/flutter/lib/ -iname "*_web.dart" 查看具体有哪些文件。
    ],
    Map<String, List<String>> ignoreIssueClass = const {}, //进行内容合并或继承与整理时要忽略的依赖库的类或顶级属性
    List<String> ignoreProxyObject = const [
      'Iterable.asNameMap', //属于dart-sdk库，忽略原因：生成出来的该属性在开发工具里面报错找不到该属性。输出结果：Iterable与子类都不会生成标识符为asNameMap的VmProxy项，下同
      'Iterable.byName', //属于dart-sdk库，忽略原因：生成出来的该属性在开发工具里面报错找不到该属性。
      'Iterable.wait', //属于dart-sdk库，忽略原因：生成出来的该属性在开发工具里面报错找不到该属性。
      'PlatformViewController.disposePostFrame', //属于flutter库，忽略原因：生成出来的该属性在开发工具里面报错找不到该属性。
      'ToggleablePainter.isActive', //属于flutter库，忽略原因：生成出来的该属性在开发工具里面报错找不到该属性。
      // 'jsonDecode',//忽略顶级VmProxy的写法
    ],
    List<String> ignoreProxyCaller = const [
      'CupertinoRadio.new', //属于flutter库，忽略原因：生成出来的该属性在开发工具里面报错范型有问题。输出结果：CupertinoRadio与子类都不会生成new对应的Vmproxy的caller属性，下同
      'Radio.new', //属于flutter库，忽略原因：生成出来的该属性在开发工具里面报错范型有问题。
      'Radio.adaptive', //属于flutter库，忽略原因：生成出来的该属性在开发工具里面报错范型有问题。
      'RadioListTile.new', //属于flutter库，忽略原因：生成出来的该属性在开发工具里面报错范型有问题。
      'RadioListTile.adaptive', //属于flutter库，忽略原因：生成出来的该属性在开发工具里面报错范型有问题。
      'RadioMenuButton.new', //属于flutter库，忽略原因：生成出来的该属性在开发工具里面报错范型有问题。
      'SharedAppData.getValue', //属于flutter库，忽略原因：生成出来的该属性在开发工具里面报错范型有问题。
      'GestureRecognizerFactoryWithHandlers.new', //属于flutter库，忽略原因：生成出来的该属性在开发工具里面报错范型有问题。
      'PaginatedDataTable.new', //属于flutter库，忽略原因：生成出来的该属性在开发工具里面报错无法找到[defaultRowsPerPage]默认值。
      'ImageProvider.loadImage', //属于flutter库，忽略原因：生成出来的该属性在开发工具里面报错函数参数的类型不匹配。
      'WidgetInspectorService.initServiceExtensions', //属于flutter库，忽略原因：生成出来的该属性在开发工具里面报错[callback]参数没有默认值。
      'Autocomplete.new', //属于flutter库，忽略原因：生成出来的该属性在编译时报错范型有问题。
      'RawAutocomplete.new', //属于flutter库，忽略原因：生成出来的该属性在编译时报错范型有问题。
      // 'jsonDecode',//忽略顶级VmProxy的caller的写法
    ],
    List<String> ignoreExtensionOn = const [
      'Object', //属于dart-sdk库，但是flutter库添加了toJs等不需要的扩展
      // 'Iterable', //属于dart-sdk库，添加出来的部分属性在开发工具里面报错
    ],
    Map<String, List<String>> includePathClass = const {}, //某文件或文件夹只生成指定的类 或 顶级属性
    Map<String, List<String>> excludePathClass = const {}, //某文件或文件夹不生成指定的类 或 顶级属性
    bool removeNotFoundPrivateParams = true, //当某函数需要生成VmProxy的caller时，但找不到的某参数的私有引用值时：true移除这个参数，false改为必传参数
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
    buffer.write('// ignore_for_file: avoid_function_literals_in_foreach_calls\n');
    buffer.write('// ignore_for_file: deprecated_member_use\n');
    buffer.write('// ignore_for_file: invalid_use_of_internal_member\n');
    buffer.write('// ignore_for_file: invalid_use_of_protected_member\n');
    buffer.write('// ignore_for_file: invalid_use_of_visible_for_testing_member\n');
    buffer.write('// ignore_for_file: unnecessary_constructor_name\n');
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
    final privateNames = <String>{}; //私有值属性，用于函数默认值引用
    final privateDefvs = <String, VmParserBirdgeItemData>{}; //私有值属性，用于函数默认值引用
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
    privateFiles.removeWhere((fileItem) => ignoreIssuePaths.any((element) => fileItem.path.startsWith(element) || fileItem.path.endsWith(element)));
    for (var fileItem in privateFiles) {
      final bridgeResults = VmParser.bridgeSource(fileItem.readAsStringSync(), ignoreExtensionOn: ignoreExtensionOn);
      for (var result in bridgeResults) {
        if (result != null) {
          final ignoreKey = ignoreIssueClass.keys.firstWhere((element) => fileItem.path.startsWith(element), orElse: () => '');
          if (ignoreKey.isNotEmpty && ignoreIssueClass[ignoreKey]!.contains(result.name)) continue; //忽略
        }
        if (result != null && result.isPrivate && result.maybeDefValueForFunction) {
          result.absoluteFilePath = fileItem.path; //复制文件路径
          if (privateDefvs.containsKey(result.name)) {
            logTrace(['ignore repeat private defvs:', result.name, '=>', result.absoluteFilePath]);
          } else {
            privateDefvs[result.name] = result;
          }
        } else if (result != null && result.type == VmParserBirdgeItemType.classDeclaration) {
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
            logTrace(['ignore repeat function alias:', result.name, '=>', result.absoluteFilePath]);
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
    libraryFiles.removeWhere((fileItem) => ignoreIssuePaths.any((element) => fileItem.path.startsWith(element) || fileItem.path.endsWith(element)));
    for (var fileItem in libraryFiles) {
      final bridgeResults = VmParser.bridgeSource(fileItem.readAsStringSync(), ignoreExtensionOn: ignoreExtensionOn);
      for (var result in bridgeResults) {
        if (result != null) {
          final ignoreKey = ignoreIssueClass.keys.firstWhere((element) => fileItem.path.startsWith(element), orElse: () => '');
          if (ignoreKey.isNotEmpty && ignoreIssueClass[ignoreKey]!.contains(result.name)) continue; //忽略
        }
        if (result != null && result.isPrivate && result.maybeDefValueForFunction) {
          result.absoluteFilePath = fileItem.path; //复制文件路径
          if (privateDefvs.containsKey(result.name)) {
            logTrace(['ignore repeat private defvs:', result.name, '=>', result.absoluteFilePath]);
          } else {
            privateDefvs[result.name] = result;
          }
        } else if (result != null && result.type == VmParserBirdgeItemType.classDeclaration && result.isPrivate) {
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
            logTrace(['ignore repeat function alias:', result.name, '=>', result.absoluteFilePath]);
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
      final bridgeResults = VmParser.bridgeSource(fileItem.readAsStringSync(), ignoreExtensionOn: ignoreExtensionOn);
      for (var result in bridgeResults) {
        if (result != null) {
          final includeKey = includePathClass.keys.firstWhere((element) => fileItem.path.startsWith(element), orElse: () => '');
          if (includeKey.isNotEmpty && !includePathClass[includeKey]!.contains(result.name)) continue; //忽略
          final excludeKey = excludePathClass.keys.firstWhere((element) => fileItem.path.startsWith(element), orElse: () => '');
          if (excludeKey.isNotEmpty && excludePathClass[excludeKey]!.contains(result.name)) continue; //忽略
        }
        if (result != null && !result.isAtJS && !result.isPrivate && result.type != VmParserBirdgeItemType.functionTypeAlias) {
          result.absoluteFilePath = fileItem.path; //复制文件路径
          result.type == VmParserBirdgeItemType.classDeclaration ? classLibraries.add(result) : proxyLibraries.add(result);
        }
      }
    }
    classLibraries.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    proxyLibraries.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    //从类中提取私有值
    privateDatas.forEach((key, item) {
      for (var e in item.properties) {
        if (e != null && e.isPrivate && e.maybeDefValueForFunction) {
          if (privateDefvs.containsKey(item.name)) {
            logTrace(['ignore repeat private defvs:', item.name, '=>', item.absoluteFilePath]);
          } else {
            privateDefvs[e.name] = e;
          }
        }
      }
    });
    for (var item in classLibraries) {
      for (var e in item.properties) {
        if (e != null && e.isPrivate && e.maybeDefValueForFunction) {
          if (privateDefvs.containsKey(item.name)) {
            logTrace(['ignore repeat private defvs:', item.name, '=>', item.absoluteFilePath]);
          } else {
            privateDefvs[e.name] = e;
          }
        }
      }
    }
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
      value.replaceAlias(
        privateNames: privateNames,
        privateDefvs: privateDefvs,
        functionRefs: functionRefs,
        ignoreProxyObject: ignoreProxyObject,
        ignoreProxyCaller: ignoreProxyCaller,
        onReplaceProxyAlias: _onVmReplaceProxyAlias,
        onIgnorePrivateArgV: _onVmIgnorePrivateArgV,
        removeNotFoundPrivateParams: removeNotFoundPrivateParams,
      );
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
        item.replaceAlias(
          privateNames: privateNames,
          privateDefvs: privateDefvs,
          functionRefs: functionRefs,
          ignoreProxyObject: ignoreProxyObject,
          ignoreProxyCaller: ignoreProxyCaller,
          onReplaceProxyAlias: _onVmReplaceProxyAlias,
          onIgnorePrivateArgV: _onVmIgnorePrivateArgV,
          removeNotFoundPrivateParams: removeNotFoundPrivateParams,
        );
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
    //生成被引用的私有默认值
    if (privateNames.isNotEmpty) {
      buffer.write('\n');
      buffer.write('$indent///all private values\n');
      for (var name in privateNames) {
        final item = privateDefvs[name];
        if (item != null) {
          if (item.isAnyFunctionType) {
            buffer.write('$indent${item.valueSourceCode != null && item.valueSourceCode!.startsWith('static') ? '' : 'static '}${item.valueSourceCode}\n');
          } else {
            buffer.write('${indent}static ${item.isConst ? 'const' : 'final'} $name = ${item.valueSourceCode};\n');
          }
        }
      }
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
    if (_vmwarnList.isEmpty) {
      logInfo(['No warn found.']);
    } else {
      logWarn(['Total ${_vmwarnList.length} warns found:']);
      for (var element in _vmwarnList) {
        logWarn(element);
      }
    }
    if (_vmerrorList.isEmpty) {
      logInfo(['No error found.']);
    } else {
      logError(['Total ${_vmerrorList.length} errors found:']);
      for (var element in _vmerrorList) {
        logError(element);
      }
    }
  }

  void _generateImports(String indent, EasyCoderModelInfo modelInfo, StringBuffer buffer) {
    //自动导入模型基类文件
    buffer.write('import \'dart:convert\';\n\n');
    buffer.write('import \'package:shelf_easy/shelf_easy.dart\';\n');
    if (modelInfo.hasObjectIdField) {
      buffer.write('import \'package:shelf_easy/shelf_deps.dart\' show ObjectId;\n');
    }
    if (modelInfo.importList.isNotEmpty) {
      buffer.write('\n');
    }
    //导入自定义文件
    for (var element in modelInfo.importList) {
      if (element.startsWith('import')) {
        buffer.write('$element\n');
      } else {
        buffer.write('import \'$element\';\n');
      }
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
    //添加到错误列表，便于统一打印
    _vmerrorList.add(['cannot found super class:', '$className inherit $superName', '=>', classPath]);
  }

  void _onVmNotFoundClassField(String className, String fieldName, String classPath) {
    //添加到警告列表，便于统一打印
    _vmwarnList.add(['cannot found class field:', '$className.$fieldName', '=>', classPath]);
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
    //添加到警告列表，便于统一打印
    _vmwarnList.add(['ignore proxy parameter by private default value:', '$className.$proxyName', paramName, '->', paramValue, '=>', classPath]);
  }

  ///将[name]的第一个字母改为大写
  static String firstUpperCaseName(String name) {
    if (name.length <= 1) return name.toUpperCase();
    return '${name[0].toUpperCase()}${name.substring(1)}';
  }
}

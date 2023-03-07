import 'dart:io';
import 'dart:math';
import 'dart:mirrors';

import 'easy_class.dart';

///
///序列化数据模型生成器
///
class EasyCoder extends EasyLogger {
  ///配置信息
  final EasyCoderConfig _config;

  ///普通模型列表
  final List<EasyCoderModelInfo> _baseList;

  ///包装模型列表
  final List<EasyCoderModelInfo> _wrapList;

  EasyCoder({required EasyCoderConfig config})
      : _config = config,
        _baseList = [],
        _wrapList = [],
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
  void generateWrapBuilder({String outputFile = 'wrapper_builder', List<String> importList = const [], String className = 'WrapBuilder', String? wrapBaseClass, bool exportFile = true}) {
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
}

///
///虚拟机桥接类型生成器
///
class EasyVmGen {
  ///要生成的桥接类型列表
  final List<MapEntry<Type, dynamic>> targetClassList;

  ///要生成的桥接函数列表
  final List<String> targetProxyList;

  ///要忽略生成new函数的类列表
  final List<String> ignoreNews;

  ///要忽略生成的函数列表
  final List<String> ignoreFuncs;

  ///要忽略生成caller的函数列表
  final List<String> ignoreCaller;

  ///全部的生成桥接类型集合
  final Map<String, String> _libraryClassMap;

  ///全部的生成桥接函数集合
  final Map<String, String> _libraryProxyMap;

  ///全部的生成代码的字符串缓冲区
  final StringBuffer _codeBuffer;

  EasyVmGen({
    this.targetClassList = const [],
    this.targetProxyList = const [],
    this.ignoreNews = const ['double', 'num', 'List', 'Enum', 'Function', 'Iterable', 'Iterator', 'Type', 'RegExpMatch'],
    this.ignoreFuncs = const ['>>>'],
    this.ignoreCaller = const ['Set.castFrom'],
  })  : _libraryClassMap = {},
        _libraryProxyMap = {},
        _codeBuffer = StringBuffer();

  ///生成dart基本库包装类型与函数
  void generateBaseLibrary({required String outputFile, required String outputClass}) {
    _codeBuffer.writeln('import \'dart:math\';\n');
    _codeBuffer.writeln('import \'vm_object.dart\';\n');
    _codeBuffer.writeln('///');
    _codeBuffer.writeln('///Dart基本库');
    _codeBuffer.writeln('///');
    _codeBuffer.writeln('class $outputClass {');
    /** 基本类型 **/
    _generateInstance(reflect(int.parse('1')).type, _generateClass(reflectClass(int)));
    _generateInstance(reflect(double.parse('1.0')).type, _generateClass(reflectClass(double)));
    _generateInstance(reflect(num.parse('1.0')).type, _generateClass(reflectClass(num)));
    _generateInstance(reflect(false).type, _generateClass(reflectClass(bool)));
    _generateInstance(reflect('hello').type, _generateClass(reflectClass(String)));
    _generateInstance(reflect(List.from([])).type, _generateClass(reflectClass(List)));
    _generateInstance(reflect(Set.from({})).type, _generateClass(reflectClass(Set)));
    _generateInstance(reflect(Map.from({})).type, _generateClass(reflectClass(Map)));
    /** 对象类型 **/
    _generateInstance(reflect(Runes('a')).type, _generateClass(reflectClass(Runes)));
    _generateInstance(reflect(Symbol('a')).type, _generateClass(reflectClass(Symbol)));
    _generateInstance(reflect(MapEntry('a', 'b')).type, _generateClass(reflectClass(MapEntry)));
    _generateInstance(reflect(Duration()).type, _generateClass(reflectClass(Duration)));
    _generateInstance(reflect(DateTime.now()).type, _generateClass(reflectClass(DateTime)));
    _generateInstance(reflect(StringBuffer()).type, _generateClass(reflectClass(StringBuffer)));
    _generateInstance(reflect(RegExp('a')).type, _generateClass(reflectClass(RegExp)));
    _generateInstance(reflect(Uri()).type, _generateClass(reflectClass(Uri)));
    _generateInstance(reflect(UriData.fromString('a')).type, _generateClass(reflectClass(UriData)));
    _generateInstance(reflect(BigInt.from(1)).type, _generateClass(reflectClass(BigInt)));
    _generateInstance(reflect(Stopwatch()).type, _generateClass(reflectClass(Stopwatch)));
    _generateInstance(reflect(Future(_emptyFunction)).type, _generateClass(reflectClass(Future)));
    _generateInstance(reflect(_emptyFunction).type, _generateClass(reflectClass(Function)));
    /** dart:math里面的对象类型 **/
    _generateInstance(reflect(Random()).type, _generateClass(reflectClass(Random)));
    _generateInstance(reflect(Point(1, 1)).type, _generateClass(reflectClass(Point)));
    _generateInstance(reflect(Rectangle(1, 1, 2, 2)).type, _generateClass(reflectClass(Rectangle)));
    /** 抽象类型 **/
    _generateInstance(reflect(Map.from({}).keys).type, _generateClass(reflectClass(Iterable)));
    _generateInstance(reflect(Map.from({}).keys.iterator).type, _generateClass(reflectClass(Iterator)));
    _generateInstance(reflect(Runes('a').iterator).type, _generateClass(reflectClass(RuneIterator)));
    _generateInstance(reflect(RegExp('1').firstMatch('1')).type, _generateClass(reflectClass(RegExpMatch)));
    /** 底层类型 **/
    _generateInstance(reflect(EasyLogLevel.debug).type, _generateClass(reflectClass(Enum)));
    _generateInstance(reflect(int).type, _generateClass(reflectClass(Type)));
    _generateInstance(reflect(Object()).type, _generateClass(reflectClass(Object))); //上面的类型全部非null值都是Object的子类，所以放在他们后面
    // _generateInstance(reflect(null).type, _generateClass(reflectClass(Null), hardTemplateName: 'dynamic')); // Null a=null; print(a is Object); => false。final b=null; => b type is dynamic 直接用dynamic替代，无需生成
    _generateInstance(reflect(null).type, _generateClass(reflectClass(Null), hardClassName: 'dynamic')); //全部的类型（包括Null类型）都可用dynamic表示，所以放在他们后面
    _generateInstance(reflect(null).type, _generateClass(reflectClass(Null), hardClassName: 'void', noBody: true), noBody: true); //无类型，用于void关键字

    //proxy
    _libraryProxyMap['print'] = 'print';
    _libraryProxyMap['e'] = 'e';
    _libraryProxyMap['ln10'] = 'ln10';
    _libraryProxyMap['ln2'] = 'ln2';
    _libraryProxyMap['log2e'] = 'log2e';
    _libraryProxyMap['log10e'] = 'log10e';
    _libraryProxyMap['pi'] = 'pi';
    _libraryProxyMap['sqrt1_2'] = 'sqrt1_2';
    _libraryProxyMap['sqrt2'] = 'sqrt2';
    _libraryProxyMap['min'] = 'min';
    _libraryProxyMap['max'] = 'max';
    _libraryProxyMap['atan2'] = 'atan2';
    _libraryProxyMap['pow'] = 'pow';
    _libraryProxyMap['sin'] = 'sin';
    _libraryProxyMap['cos'] = 'cos';
    _libraryProxyMap['tan'] = 'tan';
    _libraryProxyMap['acos'] = 'acos';
    _libraryProxyMap['asin'] = 'asin';
    _libraryProxyMap['atan'] = 'atan';
    _libraryProxyMap['sqrt'] = 'sqrt';
    _libraryProxyMap['exp'] = 'exp';
    _libraryProxyMap['log'] = 'log';
    //all
    _generateLibraryList();
    _codeBuffer.writeln('}');
    //写入到文件
    File(outputFile)
      ..createSync(recursive: true)
      ..writeAsStringSync(_codeBuffer.toString());
  }

  ///生成target目标包装类型与函数
  void generateTargetLibrary({required String outputFile, required String outputClass, List<String> importList = const [], String desc = 'Custom'}) {
    _codeBuffer.writeln('import \'package:shelf_easy/shelf_easy.dart\';');

    for (var element in importList) {
      _codeBuffer.writeln('import \'$element\';');
    }
    if (importList.isNotEmpty) _codeBuffer.writeln('');

    _codeBuffer.writeln('///');
    _codeBuffer.writeln('///$desc桥接库');
    _codeBuffer.writeln('///');
    _codeBuffer.writeln('class $outputClass {');

    for (var item in targetClassList) {
      _generateInstance(reflect(item.value).type, _generateClass(reflectClass(item.key)));
    }

    for (var value in targetProxyList) {
      _libraryProxyMap[value] = value;
    }

    //all
    _generateLibraryList();

    _codeBuffer.writeln('}');

    //写入到文件
    File(outputFile)
      ..createSync(recursive: true)
      ..writeAsStringSync(_codeBuffer.toString());
  }

  String _generateClass(ClassMirror target, {String? hardClassName, String? hardTemplateName, bool noBody = false}) {
    final className = hardClassName ?? _geSymbolName(target.simpleName);
    final fieldName = 'class${className[0].toUpperCase()}${className.substring(1)}';
    final templateName = hardTemplateName ?? className;
    if (_libraryClassMap.isNotEmpty) _codeBuffer.writeln('');
    _libraryClassMap[fieldName] = fieldName;
    if (hardClassName == null) {
      _codeBuffer.writeln('  ///类型[$className]');
    } else {
      _codeBuffer.writeln('  ///类型$className');
    }
    _codeBuffer.writeln('  static final $fieldName = VmClass<$templateName>(');
    _codeBuffer.writeln('    identifier: \'$className\',');
    if (noBody) {
      _codeBuffer.writeln('    externalProxyMap: {},');
    } else {
      _codeBuffer.writeln('    externalProxyMap: {');
      _generateClassConstructors(target, className);
      _generateClassProperties(target, className);
    }
    return className;
  }

  void _generateInstance(ClassMirror target, String className, {bool noBody = false}) {
    if (noBody) {
    } else {
      _generateInstanceProperties(target, className);
      _codeBuffer.writeln('    },');
    }
    _codeBuffer.writeln('  );');
  }

  void _generateLibraryList() {
    _codeBuffer.writeln('');
    _codeBuffer.writeln('  ///包装类型列表');
    if (_libraryClassMap.isEmpty) {
      _codeBuffer.writeln('  static final libraryClassList = <VmClass>[];');
    } else {
      _codeBuffer.writeln('  static final libraryClassList = <VmClass>[');
      _libraryClassMap.forEach((key, value) {
        _codeBuffer.writeln('    $value,');
      });
      _codeBuffer.writeln('  ];');
    }

    _codeBuffer.writeln('');
    _codeBuffer.writeln('  ///代理函数列表');
    if (_libraryProxyMap.isEmpty) {
      _codeBuffer.writeln('  static final libraryProxyList = <VmProxy<void>>[];');
    } else {
      _codeBuffer.writeln('  static final libraryProxyList = <VmProxy<void>>[');
      _libraryProxyMap.forEach((key, value) {
        _codeBuffer.writeln('    VmProxy(identifier: \'$key\', externalStaticPropertyReader: () => $value),');
      });
      _codeBuffer.writeln('  ];');
    }
  }

  void _generateClassConstructors(ClassMirror target, String className) {
    final members = target.declarations;
    final membersKeys = members.keys.toList();
    membersKeys.sort((a, b) => a.toString().compareTo(b.toString()));
    // _codeBuffer.writeln('      ///构造函数');
    for (var key in membersKeys) {
      final value = members[key];
      if (value is MethodMirror && !value.isPrivate && value.isConstructor) {
        final conName = _geSymbolName(value.constructorName);
        if (conName.isNotEmpty || !ignoreNews.contains(className)) {
          final keyName = conName.isEmpty ? className : conName;
          final funcName = conName.isEmpty ? 'new' : conName;
          final caller = _callerAnalyzer(className, conName, value, instance: false);
          final wrapper = caller == null ? '' : ', $caller';
          _codeBuffer.writeln('      \'$keyName\': VmProxy(identifier: \'$keyName\', externalStaticPropertyReader: () => $className.$funcName$wrapper),');
          if (conName.isEmpty) {
            _codeBuffer.writeln('      \'new\': VmProxy(identifier: \'new\', externalStaticPropertyReader: () => $className.$funcName$wrapper),');
          }
        }
      }
    }
  }

  void _generateClassProperties(ClassMirror target, String className) {
    final members = target.staticMembers;
    final membersKeys = members.keys.toList();
    membersKeys.sort((a, b) => a.toString().compareTo(b.toString()));
    final memberResults = <String, String>{};
    for (var key in membersKeys) {
      final value = members[key]!;
      if (!value.isPrivate && !value.isSetter && !value.isOperator) {
        final keyName = _geSymbolName(key);
        final caller = _callerAnalyzer(className, keyName, value, instance: false);
        final wrapper = caller == null ? '' : ', $caller';
        if (memberResults.containsKey(keyName)) {
          memberResults[keyName] = '${memberResults[keyName]}, externalStaticPropertyReader: () => $className.$keyName$wrapper';
        } else {
          memberResults[keyName] = 'externalStaticPropertyReader: () => $className.$keyName$wrapper';
        }
      }
    }
    for (var key in membersKeys) {
      final value = members[key]!;
      if (!value.isPrivate && !value.isGetter && !value.isOperator && !value.isRegularMethod) {
        final keyName = _geSymbolName(key);
        if (memberResults.containsKey(keyName)) {
          memberResults[keyName] = '${memberResults[keyName]}, externalStaticPropertyWriter: (value) => $className.$keyName = value';
        } else {
          memberResults[keyName] = 'externalStaticPropertyWriter: (value) => $className.$keyName = value';
        }
      }
    }
    final memberResultsKeys = memberResults.keys.toList();
    memberResultsKeys.sort((a, b) => a.toString().compareTo(b.toString()));
    // _codeBuffer.writeln('      ///静态字段');
    for (var key in memberResultsKeys) {
      final value = memberResults[key]!;
      if (ignoreFuncs.contains(key)) continue;
      _codeBuffer.writeln('      \'$key\': VmProxy(identifier: \'$key\', $value),');
    }
  }

  void _generateInstanceProperties(ClassMirror target, String className) {
    final members = target.instanceMembers;
    final membersKeys = members.keys.toList();
    membersKeys.sort((a, b) => a.toString().compareTo(b.toString()));
    final memberResults = <String, String>{};
    for (var key in membersKeys) {
      final value = members[key]!;
      if (!value.isPrivate && !value.isSetter && !value.isOperator) {
        final keyName = _geSymbolName(key);
        final caller = _callerAnalyzer(className, keyName, value, instance: true);
        final wrapper = caller == null ? '' : ', $caller';
        if (memberResults.containsKey(keyName)) {
          memberResults[keyName] = '${memberResults[keyName]}, externalInstancePropertyReader: (instance) => instance.$keyName$wrapper';
        } else {
          memberResults[keyName] = 'externalInstancePropertyReader: (instance) => instance.$keyName$wrapper';
        }
      }
    }
    for (var key in membersKeys) {
      final value = members[key]!;
      if (!value.isPrivate && !value.isGetter && !value.isOperator && !value.isRegularMethod) {
        final keyName = _geSymbolName(key);
        if (memberResults.containsKey(keyName)) {
          memberResults[keyName] = '${memberResults[keyName]}, externalInstancePropertyWriter: (instance, value) => instance.$keyName = value';
        } else {
          memberResults[keyName] = 'externalInstancePropertyWriter: (instance, value) => instance.$keyName = value';
        }
      }
    }
    final memberResultsKeys = memberResults.keys.toList();
    memberResultsKeys.sort((a, b) => a.toString().compareTo(b.toString()));
    // _codeBuffer.writeln('      ///实例字段');
    for (var key in memberResultsKeys) {
      final value = memberResults[key]!;
      if (ignoreFuncs.contains(key)) continue;
      _codeBuffer.writeln('      \'$key\': VmProxy(identifier: \'$key\', $value),');
    }
  }

  String? _callerAnalyzer(String className, String funcName, MethodMirror value, {required bool instance}) {
    if (ignoreCaller.contains('$className.$funcName')) return null;
    final parameters = value.parameters;
    final needWrapArgs = <String>[];
    //拥有函数作为参数，且这个函数参数的返回值带有模版
    for (var item in parameters) {
      final type = item.type;
      if (type is FunctionTypeMirror && type.returnType.typeArguments.isNotEmpty) {
        needWrapArgs.add(_geSymbolName(item.simpleName));
      }
    }
    if (needWrapArgs.isNotEmpty) {
      final listArgs = <String>[];
      final listArgsWrap = <String, String>{};
      final nameArgs = <String>{};
      final nameArgsWrap = <String, String>{};
      final parameters = value.parameters;
      for (var item in parameters) {
        final itemName = _geSymbolName(item.simpleName);
        if (item.isNamed) {
          final outName = itemName;
          nameArgs.add(outName);
          if (needWrapArgs.contains(itemName)) {
            final itemFunc = item.type as FunctionTypeMirror;
            int i = 0;
            final inNames = itemFunc.parameters.map((e) => 'b${i++}').toList();
            nameArgsWrap[outName] = '(${inNames.join(', ')}) => $outName == null ? null : $outName(${inNames.join(', ')})';
          }
        } else {
          final outName = 'a${listArgs.length}';
          listArgs.add(outName);
          if (needWrapArgs.contains(itemName)) {
            final itemFunc = item.type as FunctionTypeMirror;
            int i = 0;
            final inNames = itemFunc.parameters.map((e) => 'b${i++}').toList();
            listArgsWrap[outName] = '(${inNames.join(', ')}) => $outName == null ? null : $outName(${inNames.join(', ')})';
          }
        }
      }
      final headStr = '${listArgs.join(', ')}${listArgs.isNotEmpty && nameArgs.isNotEmpty ? ',' : ''}${nameArgs.isNotEmpty ? '{' : ''}${nameArgs.join(', ')}${nameArgs.isNotEmpty ? '}' : ''}';
      final bodystr = '$funcName(${listArgs.map((e) => listArgsWrap.containsKey(e) ? listArgsWrap[e] : e).join(', ')}${listArgs.isNotEmpty && nameArgs.isNotEmpty ? ',' : ''}${nameArgs.map((e) => '$e:${nameArgsWrap.containsKey(e) ? nameArgsWrap[e] : e}').join(', ')})';
      if (instance) {
        final wrapper = 'externalInstanceFunctionCaller: ($className instance, $headStr) => instance.$bodystr';
        return wrapper;
      } else {
        final wrapper = 'externalStaticFunctionCaller: ($headStr) => $className${funcName.isEmpty ? '' : '.'}$bodystr';
        return wrapper;
      }
    }
    return null;
  }

  String _geSymbolName(Symbol val) {
    final str = val.toString();
    return str.substring(8, str.length - 2).replaceAll('=', '');
  }

  void _emptyFunction() {}
}

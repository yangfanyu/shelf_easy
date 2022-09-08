import 'dart:io';

import 'easy_class.dart';

///
///代码生成器
///
class EasyCoder extends EasyLogger {
  ///配置信息
  final EasyCoderConfig _config;

  ///历史操作
  final List<EasyCoderModelInfo> _wrapList;

  EasyCoder({required EasyCoderConfig config})
      : _config = config,
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
    if (modelInfo.wrapType != null) {
      _wrapList.add(modelInfo);
    }
  }

  ///生成通用构建器
  void generateBuilder({String? outputFile, List<String> importList = const [], String className = 'WrapBuilder', String? wrapClass, bool exportFile = true}) {
    final indent = _config.indent;
    final outputPath = '${_config.absFolder}/${outputFile?.toLowerCase() ?? className.toLowerCase()}.dart'; //输入文件路径
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
    buffer.write('///Parsing class generated\n');
    buffer.write('class $className {\n'); //类开始
    buffer.write('$indent///Parsing mapdata generated\n');
    buffer.write('${indent}static final _recordBuilder = <String, ${_config.baseClass} Function(Map<String, dynamic> map)>{\n');
    for (var element in _wrapList) {
      buffer.write('$indent$indent\'${element.className}\': (Map<String, dynamic> map) => ${element.className}.fromJson(map),\n');
    }
    buffer.write('$indent};\n\n');
    buffer.write('$indent///Parsing mapdata generated\n');
    buffer.write('${indent}static final _targetBuilder = <String, ${wrapClass ?? _config.baseClass} Function(${_config.baseClass} record)>{\n');
    for (var element in _wrapList) {
      buffer.write('$indent$indent\'${element.className}\': (${_config.baseClass} record) => record.buildTarget(),\n');
    }
    buffer.write('$indent};\n\n');
    buffer.write('$indent///Parsing method generated\n');
    buffer.write('${indent}static ${_config.baseClass} buildRecord(Map<String, dynamic> map) => _recordBuilder[map[\'type\']]!(map);\n\n');
    buffer.write('$indent///Parsing method generated\n');
    buffer.write('${indent}static ${wrapClass ?? _config.baseClass} buildTarget(${_config.baseClass} record) => _targetBuilder[record.runtimeType]!(record);\n');
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
      buffer.write('$indent///${element.desc.join('\n$indent///')}\n');
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
      buffer.write('$indent///${element.desc.join('\n$indent///')}\n');
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
      buffer.write('$indent///${element.desc.join('\n$indent///')}\n');
      buffer.write('$indent${element.type} get $publicName => ${element.name};\n\n');
    }
    //扩展字段
    for (var element in modelInfo.extraFields) {
      final publicName = _getFieldPublicName(element.name);
      final defaultValue = _getFieldDefaultValue(element.name, element.type, element.defVal);
      buffer.write('$indent///${element.desc.join('\n$indent///')}\n');
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
      buffer.write('$indent}\n\n');
      return;
    }
    buffer.write('$indent@override\n');
    buffer.write('$indent${modelInfo.wrapType} buildTarget() {\n');
    buffer.write('$indent${indent}return ${modelInfo.wrapType}(\n');
    for (var element in modelInfo.classFields) {
      final valTemplate = _config.fieldsToWrapVals[element.type] ?? _config.fieldsToWrapVals[EasyCoderConfig.defaultType]!;
      final expression = EasyCoderConfig.compileTemplateCode(valTemplate, element.name, element.type);
      buffer.write('$indent$indent$indent${element.name}: $expression,\n');
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
        buffer.write('$indent///${element.desc.join('\n$indent///')}\n');
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
        buffer.write('$indent///${element.desc.join('\n$indent///')}\n');
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

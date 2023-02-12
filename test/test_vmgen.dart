// ignore_for_file: prefer_function_declarations_over_variables

import 'dart:io';
import 'dart:mirrors';

final codeBuffer = StringBuffer();

final ignoreNews = ['double', 'num', 'Function', 'Iterable', 'Type'];
final ignoreFuncs = ['>>>'];
final libraryMap = <String, String>{};
void main() {
  codeBuffer.writeln('import \'vm_object.dart\';');
  codeBuffer.writeln('///');
  codeBuffer.writeln('///Dart基本库');
  codeBuffer.writeln('///');
  codeBuffer.writeln('class VmLibrary {');

  //int
  final int intVar = 1;
  generateInstance(reflect(intVar).type, generateClass(reflectClass(int)));
  //double
  final double doubleVar = 1.0;
  generateInstance(reflect(doubleVar).type, generateClass(reflectClass(double)));
  //num
  final num numVar = 1.0;
  generateInstance(reflect(numVar).type, generateClass(reflectClass(num)));
  //bool
  final bool boolVar = false;
  generateInstance(reflect(boolVar).type, generateClass(reflectClass(bool)));
  //String
  final String strVar = 'hello';
  generateInstance(reflect(strVar).type, generateClass(reflectClass(String)));
  //List
  final List listVar = [1, 2, 3];
  generateInstance(reflect(listVar).type, generateClass(reflectClass(List)));
  //Set
  final Set setVar = <dynamic>{};
  generateInstance(reflect(setVar).type, generateClass(reflectClass(Set)));
  //Map
  final Map mapVar = <dynamic, dynamic>{};
  generateInstance(reflect(mapVar).type, generateClass(reflectClass(Map)));
  //Runes
  final Runes runesVar = Runes('aaa');
  generateInstance(reflect(runesVar).type, generateClass(reflectClass(Runes)));
  //Symbol
  final Symbol symbolVar = Symbol('aaa');
  generateInstance(reflect(symbolVar).type, generateClass(reflectClass(Symbol)));
  //Function
  final Function functionVar = () {};
  generateInstance(reflect(functionVar).type, generateClass(reflectClass(Function)));
  //Iterable
  final Iterable iterable = mapVar.keys;
  generateInstance(reflect(iterable).type, generateClass(reflectClass(Iterable)));
  //Duration
  final Duration durationVar = Duration();
  generateInstance(reflect(durationVar).type, generateClass(reflectClass(Duration)));
  //DateTime
  final DateTime dateTimeVar = DateTime.now();
  generateInstance(reflect(dateTimeVar).type, generateClass(reflectClass(DateTime)));
  //Future
  final Future futureVar = Future.delayed(Duration.zero);
  generateInstance(reflect(futureVar).type, generateClass(reflectClass(Future)));
  //Object
  final Object objectVar = Object();
  generateInstance(reflect(objectVar).type, generateClass(reflectClass(Object)));
  //Type
  final Type typeVar = int;
  generateInstance(reflect(typeVar).type, generateClass(reflectClass(Type)));
  // //Null
  // final nullVal = null;
  // generateInstance(reflect(nullVal).type, generateClass(reflectClass(Null)));
  //dynamic
  final dynamicVal = null;
  generateInstance(reflect(dynamicVal).type, generateClass(reflectClass(Null), hardName: 'dynamic'));
  //void
  final voidVal = null;
  generateInstance(reflect(voidVal).type, generateClass(reflectClass(Null), hardName: 'void', noBody: true), noBody: true);
  //all
  generateLibraryList();

  codeBuffer.writeln('}');
  codeBuffer.writeln('\n');

  //写入到文件
  File('${Directory.current.path}/lib/src/vm/vm_library.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync(codeBuffer.toString());
}

String generateClass(ClassMirror target, {String? hardName, bool noBody = false}) {
  final className = hardName ?? geSymbolName(target.simpleName);
  final fieldName = 'class${className[0].toUpperCase()}${className.substring(1)}';
  libraryMap[fieldName] = fieldName;
  codeBuffer.writeln('');
  if (hardName == null) {
    codeBuffer.writeln('  ///标准类型[$className]');
  } else {
    codeBuffer.writeln('  ///类型$className');
  }
  codeBuffer.writeln('  static final $fieldName = VmClass<$className>(');
  codeBuffer.writeln('    identifier: \'$className\',');
  codeBuffer.writeln('    externalProxyMap: {');
  if (!noBody) {
    generateClassConstructors(target, className);
    generateClassProperties(target, className);
  }
  return className;
}

void generateInstance(ClassMirror target, String className, {bool noBody = false}) {
  if (!noBody) {
    generateInstanceProperties(target, className);
  }
  codeBuffer.writeln('    },');
  codeBuffer.writeln('  );');
}

void generateLibraryList() {
  codeBuffer.writeln('  ///全部类型列表');
  codeBuffer.writeln('  static final libraryClassList = <VmClass>[');
  libraryMap.forEach((key, value) {
    codeBuffer.writeln('    $value,');
  });
  codeBuffer.writeln('  ];');

  codeBuffer.writeln('  ///代理函数列表');
  codeBuffer.writeln('  static final libraryProxyList = <VmProxy>[');
  codeBuffer.writeln('    VmProxy(identifier: \'print\', externalStaticPropertyReader: () => print),');
  codeBuffer.writeln('  ];');
}

void generateClassConstructors(ClassMirror target, String className) {
  final members = target.declarations;
  final membersKeys = members.keys.toList();
  membersKeys.sort((a, b) => a.toString().compareTo(b.toString()));
  // codeBuffer.writeln('      ///构造函数');
  for (var key in membersKeys) {
    final value = members[key];
    if (value is MethodMirror && !value.isPrivate && value.isConstructor) {
      final conName = geSymbolName(value.constructorName);
      if (conName.isNotEmpty || !ignoreNews.contains(className)) {
        final keyName = conName.isEmpty ? className : conName;
        final funcName = conName.isEmpty ? 'new' : conName;
        codeBuffer.writeln('      \'$keyName\': VmProxy(identifier:\'$keyName\', externalStaticPropertyReader: () => $className.$funcName),');
        if (conName.isEmpty) {
          codeBuffer.writeln('      \'new\': VmProxy(identifier:\'new\', externalStaticPropertyReader: () => $className.$funcName),');
        }
      }
    }
  }
}

void generateClassProperties(ClassMirror target, String className) {
  final members = target.staticMembers;
  final membersKeys = members.keys.toList();
  membersKeys.sort((a, b) => a.toString().compareTo(b.toString()));
  final memberResults = <String, String>{};
  for (var key in membersKeys) {
    final value = members[key]!;
    if (!value.isPrivate && !value.isSetter && !value.isOperator) {
      final keyName = geSymbolName(key);
      if (memberResults.containsKey(keyName)) {
        memberResults[keyName] = '${memberResults[keyName]}, externalStaticPropertyReader: () => $className.$keyName';
      } else {
        memberResults[keyName] = 'externalStaticPropertyReader: () => $className.$keyName';
      }
    }
  }
  for (var key in membersKeys) {
    final value = members[key]!;
    if (!value.isPrivate && !value.isGetter && !value.isOperator && !value.isRegularMethod) {
      final keyName = geSymbolName(key);
      if (memberResults.containsKey(keyName)) {
        memberResults[keyName] = '${memberResults[keyName]}, externalStaticPropertyWriter: (value) => $className.$keyName = value';
      } else {
        memberResults[keyName] = 'externalStaticPropertyWriter: (value) => $className.$keyName = value';
      }
    }
  }
  final memberResultsKeys = memberResults.keys.toList();
  memberResultsKeys.sort((a, b) => a.toString().compareTo(b.toString()));
  // codeBuffer.writeln('      ///静态字段');
  for (var key in memberResultsKeys) {
    final value = memberResults[key]!;
    if (ignoreFuncs.contains(key)) continue;
    codeBuffer.writeln('      \'$key\': VmProxy(identifier:\'$key\', $value),');
  }
}

void generateInstanceProperties(ClassMirror target, String className) {
  final members = target.instanceMembers;
  final membersKeys = members.keys.toList();
  membersKeys.sort((a, b) => a.toString().compareTo(b.toString()));
  final memberResults = <String, String>{};
  for (var key in membersKeys) {
    final value = members[key]!;
    if (!value.isPrivate && !value.isSetter && !value.isOperator) {
      final keyName = geSymbolName(key);
      if (memberResults.containsKey(keyName)) {
        memberResults[keyName] = '${memberResults[keyName]}, externalInstancePropertyReader: (instance) => instance.$keyName';
      } else {
        memberResults[keyName] = 'externalInstancePropertyReader: (instance) => instance.$keyName';
      }
    }
  }
  for (var key in membersKeys) {
    final value = members[key]!;
    if (!value.isPrivate && !value.isGetter && !value.isOperator && !value.isRegularMethod) {
      final keyName = geSymbolName(key);
      if (memberResults.containsKey(keyName)) {
        memberResults[keyName] = '${memberResults[keyName]}, externalInstancePropertyWriter: (instance, value) => instance.$keyName = value';
      } else {
        memberResults[keyName] = 'externalInstancePropertyWriter: (instance, value) => instance.$keyName = value';
      }
    }
  }
  final memberResultsKeys = memberResults.keys.toList();
  memberResultsKeys.sort((a, b) => a.toString().compareTo(b.toString()));
  // codeBuffer.writeln('      ///实例字段');
  for (var key in memberResultsKeys) {
    final value = memberResults[key]!;
    if (ignoreFuncs.contains(key)) continue;
    codeBuffer.writeln('      \'$key\': VmProxy(identifier:\'$key\', $value),');
  }
}

String geSymbolName(Symbol val) {
  final str = val.toString();
  return str.substring(8, str.length - 2).replaceAll('=', '');
}

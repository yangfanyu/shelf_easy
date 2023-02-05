///
///Dart代码模拟类库
///

class VmLibrary {
  ///构造函数访问表
  static final Map<String, Map<String, VmLibraryClassConstructor>> _classConstructorsMap = {};

  ///静态属性访问表
  static final Map<String, Map<String, VmLibraryClassProperty>> _classPropertiesMap = {};

  ///静态函数访问表
  static final Map<String, Map<String, VmLibraryclassFunction>> _classFunctionsMap = {};

  ///实例属性访问表
  static final Map<String, Map<String, Function>> _instancePropertiesMap = {};
  // static final Map<String, Map<String, VmLibraryInstanceProperty>> _instancePropertiesMap = {};

  ///实例函数访问表
  static final Map<String, Map<String, Function>> _instanceFunctionsMap = {};
  // static final Map<String, Map<String, VmLibraryInstanceFunction>> _instanceFunctionsMap = {};

  ///导入外部类
  static void importClass<T>(
    String type, {
    Map<String, VmLibraryClassConstructor> classConstructors = const {},
    Map<String, VmLibraryClassProperty> classProperties = const {},
    Map<String, VmLibraryclassFunction> classFunctions = const {},
    Map<String, VmLibraryInstanceProperty<T>> instanceProperties = const {},
    Map<String, VmLibraryInstanceFunction<T>> instanceFunctions = const {},
  }) {
    _classConstructorsMap[type] = classConstructors;
    _classPropertiesMap[type] = classProperties;
    _classFunctionsMap[type] = classFunctions;
    _instancePropertiesMap[type] = instanceProperties;
    _instanceFunctionsMap[type] = instanceFunctions;
  }

  // ///读取[classType]类的[functionName]构造函数
  // static dynamic applyClassConstructor(String classType, String functionName, List<dynamic>? positionalArguments, [Map<Symbol, dynamic>? namedArguments]) {
  //   final method = _classConstructorsMap[classType]?[functionName];
  //   if (method == null) throw ('Not round class constructor: $classType.$functionName');
  //   return method(positionalArguments, namedArguments);
  // }

  ///读取[classType]类的[propertyName]属性
  static dynamic queryClassProperty(String classType, String propertyName) {
    final method = _classPropertiesMap[classType]?[propertyName];
    if (method == null) throw ('Not round class property: $classType.$propertyName');
    return method();
  }

  ///调用[classType]类的[functionName]方法
  static dynamic applyClassFunction(String classType, String functionName, List<dynamic>? positionalArguments, [Map<Symbol, dynamic>? namedArguments]) {
    final method = _classFunctionsMap[classType]?[functionName] ?? _classConstructorsMap[classType]?[functionName];
    if (method == null) throw ('Not round class function: $classType.$functionName');
    return method(positionalArguments, namedArguments);
  }

  ///读取[classType]类的[instance]实例的[propertyName]属性
  static dynamic queryInstanceProperty(dynamic instance, String classType, String propertyName) {
    final method = _instancePropertiesMap[classType]?[propertyName];
    if (method == null) throw ('Not round instance property: $classType.$propertyName => instance.runtimeType: ${instance.runtimeType}');
    return method(instance);
  }

  ///调用[classType]类的[instance]实例的[functionName]方法
  static dynamic applyInstanceFunction(dynamic instance, String classType, String functionName, List<dynamic>? positionalArguments, [Map<Symbol, dynamic>? namedArguments]) {
    final method = _instanceFunctionsMap[classType]?[functionName];
    if (method == null) throw ('Not round instance function: $classType.$functionName => instance.runtimeType: ${instance.runtimeType}');
    return method(instance, positionalArguments, namedArguments);
  }

  ///导入Dart核心类
  static void importDartCore() {
    _importClassInt();
    _importClassDouble();
    _importClassNum();
    _importClassBool();
    _importClassString();
    _importClassList();
    _importClassSet();
    _importClassMap();
    _importClassRunes();
    _importClassSymbol();
  }

  static void _importClassInt() {
    importClass<int>(
      'int',
      classConstructors: {
        'fromEnvironment': (positionalArguments, [namedArguments]) => Function.apply(int.fromEnvironment, positionalArguments, namedArguments),
      },
      classProperties: {},
      classFunctions: {
        'parse': (positionalArguments, [namedArguments]) => Function.apply(int.parse, positionalArguments, namedArguments),
        'tryParse': (positionalArguments, [namedArguments]) => Function.apply(int.tryParse, positionalArguments, namedArguments),
      },
      instanceProperties: {
        'bitLength': (instance) => instance.bitLength,
        'hashCode': (instance) => instance.hashCode,
        'isEven': (instance) => instance.isEven,
        'isFinite': (instance) => instance.isFinite,
        'isInfinite': (instance) => instance.isInfinite,
        'isNaN': (instance) => instance.isNaN,
        'isNegative': (instance) => instance.isNegative,
        'isOdd': (instance) => instance.isOdd,
        'runtimeType': (instance) => instance.runtimeType,
        'sign': (instance) => instance.sign,
      },
      instanceFunctions: {
        'abs': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.abs, positionalArguments, namedArguments),
        'ceil': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.ceil, positionalArguments, namedArguments),
        'ceilToDouble': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.ceilToDouble, positionalArguments, namedArguments),
        'clamp': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.clamp, positionalArguments, namedArguments),
        'compareTo': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.compareTo, positionalArguments, namedArguments),
        'floor': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.floor, positionalArguments, namedArguments),
        'floorToDouble': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.floorToDouble, positionalArguments, namedArguments),
        'gcd': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.gcd, positionalArguments, namedArguments),
        'modInverse': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.modInverse, positionalArguments, namedArguments),
        'modPow': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.modPow, positionalArguments, namedArguments),
        'noSuchMethod': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.noSuchMethod, positionalArguments, namedArguments),
        'remainder': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.remainder, positionalArguments, namedArguments),
        'round': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.round, positionalArguments, namedArguments),
        'roundToDouble': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.roundToDouble, positionalArguments, namedArguments),
        'toDouble': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toDouble, positionalArguments, namedArguments),
        'toInt': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toInt, positionalArguments, namedArguments),
        'toRadixString': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toRadixString, positionalArguments, namedArguments),
        'toSigned': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toSigned, positionalArguments, namedArguments),
        'toString': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toString, positionalArguments, namedArguments),
        'toStringAsExponential': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toStringAsExponential, positionalArguments, namedArguments),
        'toStringAsFixed': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toStringAsFixed, positionalArguments, namedArguments),
        'toStringAsPrecision': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toStringAsPrecision, positionalArguments, namedArguments),
        'toUnsigned': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toUnsigned, positionalArguments, namedArguments),
        'truncate': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.truncate, positionalArguments, namedArguments),
        'truncateToDouble': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.truncateToDouble, positionalArguments, namedArguments),
      },
    );
  }

  static void _importClassDouble() {
    importClass<double>(
      'double',
      classConstructors: {
        // 'double': (positionalArguments, [namedArguments]) => Function.apply(double.new, positionalArguments, namedArguments),
      },
      classProperties: {
        'infinity': () => double.infinity,
        'maxFinite': () => double.maxFinite,
        'minPositive': () => double.minPositive,
        'nan': () => double.nan,
        'negativeInfinity': () => double.negativeInfinity,
      },
      classFunctions: {
        'parse': (positionalArguments, [namedArguments]) => Function.apply(double.parse, positionalArguments, namedArguments),
        'tryParse': (positionalArguments, [namedArguments]) => Function.apply(double.tryParse, positionalArguments, namedArguments),
      },
      instanceProperties: {
        'hashCode': (instance) => instance.hashCode,
        'isFinite': (instance) => instance.isFinite,
        'isInfinite': (instance) => instance.isInfinite,
        'isNaN': (instance) => instance.isNaN,
        'isNegative': (instance) => instance.isNegative,
        'runtimeType': (instance) => instance.runtimeType,
        'sign': (instance) => instance.sign,
      },
      instanceFunctions: {
        'abs': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.abs, positionalArguments, namedArguments),
        'ceil': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.ceil, positionalArguments, namedArguments),
        'ceilToDouble': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.ceilToDouble, positionalArguments, namedArguments),
        'clamp': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.clamp, positionalArguments, namedArguments),
        'compareTo': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.compareTo, positionalArguments, namedArguments),
        'floor': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.floor, positionalArguments, namedArguments),
        'floorToDouble': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.floorToDouble, positionalArguments, namedArguments),
        'noSuchMethod': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.noSuchMethod, positionalArguments, namedArguments),
        'remainder': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.remainder, positionalArguments, namedArguments),
        'round': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.round, positionalArguments, namedArguments),
        'roundToDouble': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.roundToDouble, positionalArguments, namedArguments),
        'toDouble': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toDouble, positionalArguments, namedArguments),
        'toInt': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toInt, positionalArguments, namedArguments),
        'toString': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toString, positionalArguments, namedArguments),
        'toStringAsExponential': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toStringAsExponential, positionalArguments, namedArguments),
        'toStringAsFixed': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toStringAsFixed, positionalArguments, namedArguments),
        'toStringAsPrecision': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toStringAsPrecision, positionalArguments, namedArguments),
        'truncate': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.truncate, positionalArguments, namedArguments),
        'truncateToDouble': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.truncateToDouble, positionalArguments, namedArguments),
      },
    );
  }

  static void _importClassNum() {
    importClass<num>(
      'num',
      classConstructors: {
        // 'num': (positionalArguments, [namedArguments]) => Function.apply(num.new, positionalArguments, namedArguments),
      },
      classProperties: {},
      classFunctions: {
        'parse': (positionalArguments, [namedArguments]) => Function.apply(num.parse, positionalArguments, namedArguments),
        'tryParse': (positionalArguments, [namedArguments]) => Function.apply(num.tryParse, positionalArguments, namedArguments),
      },
      instanceProperties: {
        'hashCode': (instance) => instance.hashCode,
        'isFinite': (instance) => instance.isFinite,
        'isInfinite': (instance) => instance.isInfinite,
        'isNaN': (instance) => instance.isNaN,
        'isNegative': (instance) => instance.isNegative,
        'runtimeType': (instance) => instance.runtimeType,
        'sign': (instance) => instance.sign,
      },
      instanceFunctions: {
        'abs': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.abs, positionalArguments, namedArguments),
        'ceil': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.ceil, positionalArguments, namedArguments),
        'ceilToDouble': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.ceilToDouble, positionalArguments, namedArguments),
        'clamp': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.clamp, positionalArguments, namedArguments),
        'compareTo': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.compareTo, positionalArguments, namedArguments),
        'floor': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.floor, positionalArguments, namedArguments),
        'floorToDouble': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.floorToDouble, positionalArguments, namedArguments),
        'noSuchMethod': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.noSuchMethod, positionalArguments, namedArguments),
        'remainder': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.remainder, positionalArguments, namedArguments),
        'round': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.round, positionalArguments, namedArguments),
        'roundToDouble': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.roundToDouble, positionalArguments, namedArguments),
        'toDouble': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toDouble, positionalArguments, namedArguments),
        'toInt': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toInt, positionalArguments, namedArguments),
        'toString': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toString, positionalArguments, namedArguments),
        'toStringAsExponential': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toStringAsExponential, positionalArguments, namedArguments),
        'toStringAsFixed': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toStringAsFixed, positionalArguments, namedArguments),
        'toStringAsPrecision': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toStringAsPrecision, positionalArguments, namedArguments),
        'truncate': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.truncate, positionalArguments, namedArguments),
        'truncateToDouble': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.truncateToDouble, positionalArguments, namedArguments),
      },
    );
  }

  static void _importClassBool() {
    importClass<bool>(
      'bool',
      classConstructors: {
        'fromEnvironment': (positionalArguments, [namedArguments]) => Function.apply(bool.fromEnvironment, positionalArguments, namedArguments),
        'hasEnvironment': (positionalArguments, [namedArguments]) => Function.apply(bool.hasEnvironment, positionalArguments, namedArguments),
      },
      classProperties: {},
      classFunctions: {},
      instanceProperties: {
        'hashCode': (instance) => instance.hashCode,
        'runtimeType': (instance) => instance.runtimeType,
      },
      instanceFunctions: {
        'noSuchMethod': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.noSuchMethod, positionalArguments, namedArguments),
        'toString': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toString, positionalArguments, namedArguments),
      },
    );
  }

  static void _importClassString() {
    importClass<String>(
      'String',
      classConstructors: {
        'fromCharCode': (positionalArguments, [namedArguments]) => Function.apply(String.fromCharCode, positionalArguments, namedArguments),
        'fromCharCodes': (positionalArguments, [namedArguments]) => Function.apply(String.fromCharCodes, positionalArguments, namedArguments),
        'fromEnvironment': (positionalArguments, [namedArguments]) => Function.apply(String.fromEnvironment, positionalArguments, namedArguments),
      },
      classProperties: {},
      classFunctions: {},
      instanceProperties: {
        'codeUnits': (instance) => instance.codeUnits,
        'hashCode': (instance) => instance.hashCode,
        'isEmpty': (instance) => instance.isEmpty,
        'isNotEmpty': (instance) => instance.isNotEmpty,
        'length': (instance) => instance.length,
        'runes': (instance) => instance.runes,
        'runtimeType': (instance) => instance.runtimeType,
      },
      instanceFunctions: {
        'allMatches': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.allMatches, positionalArguments, namedArguments),
        'codeUnitAt': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.codeUnitAt, positionalArguments, namedArguments),
        'compareTo': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.compareTo, positionalArguments, namedArguments),
        'contains': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.contains, positionalArguments, namedArguments),
        'endsWith': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.endsWith, positionalArguments, namedArguments),
        'indexOf': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.indexOf, positionalArguments, namedArguments),
        'lastIndexOf': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.lastIndexOf, positionalArguments, namedArguments),
        'matchAsPrefix': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.matchAsPrefix, positionalArguments, namedArguments),
        'noSuchMethod': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.noSuchMethod, positionalArguments, namedArguments),
        'padLeft': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.padLeft, positionalArguments, namedArguments),
        'padRight': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.padRight, positionalArguments, namedArguments),
        'replaceAll': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.replaceAll, positionalArguments, namedArguments),
        'replaceAllMapped': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.replaceAllMapped, positionalArguments, namedArguments),
        'replaceFirst': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.replaceFirst, positionalArguments, namedArguments),
        'replaceFirstMapped': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.replaceFirstMapped, positionalArguments, namedArguments),
        'replaceRange': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.replaceRange, positionalArguments, namedArguments),
        'split': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.split, positionalArguments, namedArguments),
        'splitMapJoin': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.splitMapJoin, positionalArguments, namedArguments),
        'startsWith': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.startsWith, positionalArguments, namedArguments),
        'substring': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.substring, positionalArguments, namedArguments),
        'toLowerCase': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toLowerCase, positionalArguments, namedArguments),
        'toString': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toString, positionalArguments, namedArguments),
        'toUpperCase': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toUpperCase, positionalArguments, namedArguments),
        'trim': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.trim, positionalArguments, namedArguments),
        'trimLeft': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.trimLeft, positionalArguments, namedArguments),
        'trimRight': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.trimRight, positionalArguments, namedArguments),
      },
    );
  }

  static void _importClassList() {
    importClass<List>(
      'List',
      classConstructors: {
        'List': (positionalArguments, [namedArguments]) => Function.apply(List.new, positionalArguments, namedArguments),
        'empty': (positionalArguments, [namedArguments]) => Function.apply(List.empty, positionalArguments, namedArguments),
        'filled': (positionalArguments, [namedArguments]) => Function.apply(List.filled, positionalArguments, namedArguments),
        'from': (positionalArguments, [namedArguments]) => Function.apply(List.from, positionalArguments, namedArguments),
        'generate': (positionalArguments, [namedArguments]) => Function.apply(List.generate, positionalArguments, namedArguments),
        'of': (positionalArguments, [namedArguments]) => Function.apply(List.of, positionalArguments, namedArguments),
        'unmodifiable': (positionalArguments, [namedArguments]) => Function.apply(List.unmodifiable, positionalArguments, namedArguments),
      },
      classProperties: {},
      classFunctions: {
        'castFrom': (positionalArguments, [namedArguments]) => Function.apply(List.castFrom, positionalArguments, namedArguments),
        'copyRange': (positionalArguments, [namedArguments]) => Function.apply(List.copyRange, positionalArguments, namedArguments),
        'writeIterable': (positionalArguments, [namedArguments]) => Function.apply(List.writeIterable, positionalArguments, namedArguments),
      },
      instanceProperties: {
        'first': (instance) => instance.first,
        'hashCode': (instance) => instance.hashCode,
        'isEmpty': (instance) => instance.isEmpty,
        'isNotEmpty': (instance) => instance.isNotEmpty,
        'iterator': (instance) => instance.iterator,
        'last': (instance) => instance.last,
        'length': (instance) => instance.length,
        'reversed': (instance) => instance.reversed,
        'runtimeType': (instance) => instance.runtimeType,
        'single': (instance) => instance.single,
      },
      instanceFunctions: {
        'add': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.add, positionalArguments, namedArguments),
        'addAll': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.addAll, positionalArguments, namedArguments),
        'any': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.any, positionalArguments, namedArguments),
        'asMap': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.asMap, positionalArguments, namedArguments),
        'cast': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.cast, positionalArguments, namedArguments),
        'clear': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.clear, positionalArguments, namedArguments),
        'contains': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.contains, positionalArguments, namedArguments),
        'elementAt': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.elementAt, positionalArguments, namedArguments),
        'every': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.every, positionalArguments, namedArguments),
        'expand': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.expand, positionalArguments, namedArguments),
        'fillRange': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.fillRange, positionalArguments, namedArguments),
        'firstWhere': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.firstWhere, positionalArguments, namedArguments),
        'fold': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.fold, positionalArguments, namedArguments),
        'followedBy': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.followedBy, positionalArguments, namedArguments),
        'forEach': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.forEach, positionalArguments, namedArguments),
        'getRange': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.getRange, positionalArguments, namedArguments),
        'indexOf': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.indexOf, positionalArguments, namedArguments),
        'indexWhere': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.indexWhere, positionalArguments, namedArguments),
        'insert': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.insert, positionalArguments, namedArguments),
        'insertAll': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.insertAll, positionalArguments, namedArguments),
        'join': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.join, positionalArguments, namedArguments),
        'lastIndexOf': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.lastIndexOf, positionalArguments, namedArguments),
        'lastIndexWhere': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.lastIndexWhere, positionalArguments, namedArguments),
        'lastWhere': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.lastWhere, positionalArguments, namedArguments),
        'map': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.map, positionalArguments, namedArguments),
        'noSuchMethod': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.noSuchMethod, positionalArguments, namedArguments),
        'reduce': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.reduce, positionalArguments, namedArguments),
        'remove': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.remove, positionalArguments, namedArguments),
        'removeAt': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.removeAt, positionalArguments, namedArguments),
        'removeLast': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.removeLast, positionalArguments, namedArguments),
        'removeRange': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.removeRange, positionalArguments, namedArguments),
        'removeWhere': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.removeWhere, positionalArguments, namedArguments),
        'replaceRange': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.replaceRange, positionalArguments, namedArguments),
        'retainWhere': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.retainWhere, positionalArguments, namedArguments),
        'setAll': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.setAll, positionalArguments, namedArguments),
        'setRange': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.setRange, positionalArguments, namedArguments),
        'shuffle': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.shuffle, positionalArguments, namedArguments),
        'singleWhere': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.singleWhere, positionalArguments, namedArguments),
        'skip': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.skip, positionalArguments, namedArguments),
        'skipWhile': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.skipWhile, positionalArguments, namedArguments),
        'sort': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.sort, positionalArguments, namedArguments),
        'sublist': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.sublist, positionalArguments, namedArguments),
        'take': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.take, positionalArguments, namedArguments),
        'takeWhile': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.takeWhile, positionalArguments, namedArguments),
        'toList': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toList, positionalArguments, namedArguments),
        'toSet': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toSet, positionalArguments, namedArguments),
        'toString': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toString, positionalArguments, namedArguments),
        'where': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.where, positionalArguments, namedArguments),
        'whereType': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.whereType, positionalArguments, namedArguments),
      },
    );
  }

  static void _importClassSet() {
    importClass<Set>(
      'Set',
      classConstructors: {
        'Set': (positionalArguments, [namedArguments]) => Function.apply(Set.new, positionalArguments, namedArguments),
        'from': (positionalArguments, [namedArguments]) => Function.apply(Set.from, positionalArguments, namedArguments),
        'identity': (positionalArguments, [namedArguments]) => Function.apply(Set.identity, positionalArguments, namedArguments),
        'of': (positionalArguments, [namedArguments]) => Function.apply(Set.of, positionalArguments, namedArguments),
        'unmodifiable': (positionalArguments, [namedArguments]) => Function.apply(Set.unmodifiable, positionalArguments, namedArguments),
      },
      classProperties: {},
      classFunctions: {
        'castFrom': (positionalArguments, [namedArguments]) => Function.apply(Set.castFrom, positionalArguments, namedArguments),
      },
      instanceProperties: {
        'first': (instance) => instance.first,
        'hashCode': (instance) => instance.hashCode,
        'isEmpty': (instance) => instance.isEmpty,
        'isNotEmpty': (instance) => instance.isNotEmpty,
        'iterator': (instance) => instance.iterator,
        'last': (instance) => instance.last,
        'length': (instance) => instance.length,
        'runtimeType': (instance) => instance.runtimeType,
        'single': (instance) => instance.single,
      },
      instanceFunctions: {
        'add': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.add, positionalArguments, namedArguments),
        'addAll': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.addAll, positionalArguments, namedArguments),
        'any': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.any, positionalArguments, namedArguments),
        'cast': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.cast, positionalArguments, namedArguments),
        'clear': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.clear, positionalArguments, namedArguments),
        'contains': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.contains, positionalArguments, namedArguments),
        'containsAll': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.containsAll, positionalArguments, namedArguments),
        'difference': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.difference, positionalArguments, namedArguments),
        'elementAt': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.elementAt, positionalArguments, namedArguments),
        'every': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.every, positionalArguments, namedArguments),
        'expand': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.expand, positionalArguments, namedArguments),
        'firstWhere': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.firstWhere, positionalArguments, namedArguments),
        'fold': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.fold, positionalArguments, namedArguments),
        'followedBy': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.followedBy, positionalArguments, namedArguments),
        'forEach': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.forEach, positionalArguments, namedArguments),
        'intersection': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.intersection, positionalArguments, namedArguments),
        'join': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.join, positionalArguments, namedArguments),
        'lastWhere': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.lastWhere, positionalArguments, namedArguments),
        'lookup': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.lookup, positionalArguments, namedArguments),
        'map': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.map, positionalArguments, namedArguments),
        'noSuchMethod': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.noSuchMethod, positionalArguments, namedArguments),
        'reduce': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.reduce, positionalArguments, namedArguments),
        'remove': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.remove, positionalArguments, namedArguments),
        'removeAll': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.removeAll, positionalArguments, namedArguments),
        'removeWhere': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.removeWhere, positionalArguments, namedArguments),
        'retainAll': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.retainAll, positionalArguments, namedArguments),
        'retainWhere': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.retainWhere, positionalArguments, namedArguments),
        'singleWhere': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.singleWhere, positionalArguments, namedArguments),
        'skip': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.skip, positionalArguments, namedArguments),
        'skipWhile': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.skipWhile, positionalArguments, namedArguments),
        'take': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.take, positionalArguments, namedArguments),
        'takeWhile': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.takeWhile, positionalArguments, namedArguments),
        'toList': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toList, positionalArguments, namedArguments),
        'toSet': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toSet, positionalArguments, namedArguments),
        'toString': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toString, positionalArguments, namedArguments),
        'union': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.union, positionalArguments, namedArguments),
        'where': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.where, positionalArguments, namedArguments),
        'whereType': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.whereType, positionalArguments, namedArguments),
      },
    );
  }

  static void _importClassMap() {
    importClass<Map>(
      'Map',
      classConstructors: {
        'Map': (positionalArguments, [namedArguments]) => Function.apply(Map.new, positionalArguments, namedArguments),
        'from': (positionalArguments, [namedArguments]) => Function.apply(Map.from, positionalArguments, namedArguments),
        'fromEntries': (positionalArguments, [namedArguments]) => Function.apply(Map.fromEntries, positionalArguments, namedArguments),
        'fromIterable': (positionalArguments, [namedArguments]) => Function.apply(Map.fromIterable, positionalArguments, namedArguments),
        'fromIterables': (positionalArguments, [namedArguments]) => Function.apply(Map.fromIterables, positionalArguments, namedArguments),
        'identity': (positionalArguments, [namedArguments]) => Function.apply(Map.identity, positionalArguments, namedArguments),
        'of': (positionalArguments, [namedArguments]) => Function.apply(Map.of, positionalArguments, namedArguments),
        'unmodifiable': (positionalArguments, [namedArguments]) => Function.apply(Map.unmodifiable, positionalArguments, namedArguments),
      },
      classProperties: {},
      classFunctions: {
        'castFrom': (positionalArguments, [namedArguments]) => Function.apply(Map.castFrom, positionalArguments, namedArguments),
      },
      instanceProperties: {
        'entries': (instance) => instance.entries,
        'hashCode': (instance) => instance.hashCode,
        'isEmpty': (instance) => instance.isEmpty,
        'isNotEmpty': (instance) => instance.isNotEmpty,
        'keys': (instance) => instance.keys,
        'length': (instance) => instance.length,
        'runtimeType': (instance) => instance.runtimeType,
        'values': (instance) => instance.values,
      },
      instanceFunctions: {
        'addAll': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.addAll, positionalArguments, namedArguments),
        'addEntries': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.addEntries, positionalArguments, namedArguments),
        'cast': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.cast, positionalArguments, namedArguments),
        'clear': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.clear, positionalArguments, namedArguments),
        'containsKey': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.containsKey, positionalArguments, namedArguments),
        'containsValue': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.containsValue, positionalArguments, namedArguments),
        'forEach': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.forEach, positionalArguments, namedArguments),
        'map': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.map, positionalArguments, namedArguments),
        'noSuchMethod': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.noSuchMethod, positionalArguments, namedArguments),
        'putIfAbsent': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.putIfAbsent, positionalArguments, namedArguments),
        'remove': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.remove, positionalArguments, namedArguments),
        'removeWhere': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.removeWhere, positionalArguments, namedArguments),
        'toString': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toString, positionalArguments, namedArguments),
        'update': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.update, positionalArguments, namedArguments),
        'updateAll': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.updateAll, positionalArguments, namedArguments),
      },
    );
  }

  static void _importClassRunes() {
    importClass<Runes>(
      'Runes',
      classConstructors: {
        'Runes': (positionalArguments, [namedArguments]) => Function.apply(Runes.new, positionalArguments, namedArguments),
      },
      classProperties: {},
      classFunctions: {},
      instanceProperties: {
        'first': (instance) => instance.first,
        'hashCode': (instance) => instance.hashCode,
        'isEmpty': (instance) => instance.isEmpty,
        'isNotEmpty': (instance) => instance.isNotEmpty,
        'iterator': (instance) => instance.iterator,
        'last': (instance) => instance.last,
        'length': (instance) => instance.length,
        'runtimeType': (instance) => instance.runtimeType,
        'single': (instance) => instance.single,
        'string': (instance) => instance.string,
      },
      instanceFunctions: {
        'any': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.any, positionalArguments, namedArguments),
        'cast': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.cast, positionalArguments, namedArguments),
        'contains': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.contains, positionalArguments, namedArguments),
        'elementAt': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.elementAt, positionalArguments, namedArguments),
        'every': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.every, positionalArguments, namedArguments),
        'expand': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.expand, positionalArguments, namedArguments),
        'firstWhere': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.firstWhere, positionalArguments, namedArguments),
        'fold': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.fold, positionalArguments, namedArguments),
        'followedBy': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.followedBy, positionalArguments, namedArguments),
        'forEach': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.forEach, positionalArguments, namedArguments),
        'join': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.join, positionalArguments, namedArguments),
        'lastWhere': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.lastWhere, positionalArguments, namedArguments),
        'map': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.map, positionalArguments, namedArguments),
        'noSuchMethod': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.noSuchMethod, positionalArguments, namedArguments),
        'reduce': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.reduce, positionalArguments, namedArguments),
        'singleWhere': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.singleWhere, positionalArguments, namedArguments),
        'skip': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.skip, positionalArguments, namedArguments),
        'skipWhile': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.skipWhile, positionalArguments, namedArguments),
        'take': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.take, positionalArguments, namedArguments),
        'takeWhile': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.takeWhile, positionalArguments, namedArguments),
        'toList': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toList, positionalArguments, namedArguments),
        'toSet': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toSet, positionalArguments, namedArguments),
        'toString': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toString, positionalArguments, namedArguments),
        'where': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.where, positionalArguments, namedArguments),
        'whereType': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.whereType, positionalArguments, namedArguments),
      },
    );
  }

  static void _importClassSymbol() {
    importClass<Symbol>(
      'Symbol',
      classConstructors: {
        'Symbol': (positionalArguments, [namedArguments]) => Function.apply(Symbol.new, positionalArguments, namedArguments),
      },
      classProperties: {
        'empty': () => Symbol.empty,
        'unaryMinus': () => Symbol.unaryMinus,
      },
      classFunctions: {},
      instanceProperties: {
        'hashCode': (instance) => instance.hashCode,
        'runtimeType': (instance) => instance.runtimeType,
      },
      instanceFunctions: {
        'noSuchMethod': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.noSuchMethod, positionalArguments, namedArguments),
        'toString': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.toString, positionalArguments, namedArguments),
      },
    );
  }
}

///构造函数
typedef VmLibraryClassConstructor = dynamic Function(List<dynamic>? positionalArguments, [Map<Symbol, dynamic>? namedArguments]);

///静态属性
typedef VmLibraryClassProperty = dynamic Function();

///静态函数
typedef VmLibraryclassFunction = dynamic Function(List<dynamic>? positionalArguments, [Map<Symbol, dynamic>? namedArguments]);

///实例属性
typedef VmLibraryInstanceProperty<T> = dynamic Function(T instance);

///实例函数
typedef VmLibraryInstanceFunction<T> = dynamic Function(T instance, List<dynamic>? positionalArguments, [Map<Symbol, dynamic>? namedArguments]);

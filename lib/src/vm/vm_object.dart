import 'vm_keys.dart';

///
///虚拟机抽象类
///
abstract class VmObject {
  ///标识符
  final String identifier;

  const VmObject({required this.identifier});
}

///
///虚拟机类型包装类
///
class VmClass<T> extends VmObject {
  ///是否属于外部导入类型
  final bool isExternal;

  ///外部导入类型的字段代理集合
  final Map<String, VmProxy<T>>? externalProxyMap;

  ///内部定义类型的字段代理集合
  final Map<String, VmProxy<T>>? internalProxyMap;

  const VmClass({
    required super.identifier,
    this.isExternal = true,
    this.externalProxyMap,
    this.internalProxyMap,
  });

  ///被包装的类型
  Type get typeValue => T;

  ///判断指定实例是否匹配该包装类型
  bool isMatched(dynamic instance) => instance is T;

  ///获取该包装类型的指定字段的代理
  VmProxy<T> getProxy(String propertyName) {
    final proxy = isExternal ? (externalProxyMap?[propertyName]) : (internalProxyMap?[propertyName]);
    if (proxy == null) throw ('Not found proxy: $identifier.$propertyName');
    return proxy;
  }

  ///执行该包装类型的静态函数
  dynamic runStaticFunction(String functionName, List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments) => getProxy(functionName).runStaticFunction(positionalArguments, namedArguments);

  ///读取该包装类型的静态属性
  dynamic getStaticProperty(String propertyName) => getProxy(propertyName).getStaticProperty();

  ///设置该包装类型的静态属性
  dynamic setStaticProperty(String propertyName, propertyValue) => getProxy(propertyName).setStaticProperty(propertyValue);

  ///转换为易读的字符串
  @override
  String toString() => 'VmClass<$T> ===> $identifier';

  ///包装类型集合
  static final _libraryMap = <String, VmClass>{};

  ///包装类型列表
  static final _libraryList = <VmClass>[];

  ///添加包装类型
  static void addClass(VmClass vmclass) {
    if (_libraryMap.containsKey(vmclass.identifier)) throw ('Already exists VmClass: ${vmclass.identifier}');
    _libraryMap[vmclass.identifier] = vmclass;
    _libraryList.add(vmclass);
  }

  ///获取指定名称对应的包装类型
  static VmClass getClassByTypeName(String typeName) {
    final vmclass = _libraryMap[typeName];
    if (vmclass == null) throw ('Not found VmClass: $typeName');
    return vmclass;
  }

  ///获取任意非[VmObject]实例[instance]的对应[VmClass]包装类型
  static VmClass getClassByInstance(dynamic instance) {
    if (instance is VmObject) throw ('Instance type cannot be VmObject: ${instance.runtimeType}');
    //先通过运行时字符串类型名查找
    final typeName = instance.runtimeType.toString();
    final vmclass = _libraryMap[typeName];
    if (vmclass != null) return vmclass;
    //再通过_matchClass方法匹配
    for (var item in _libraryList) {
      if (item.isMatched(instance)) return item;
    }
    throw ('Not found VmClass: $typeName');
  }

  ///执行任意非[VmObject]实例[instance]的[functionName]函数
  static dynamic runInstanceFunction(dynamic instance, String functionName, List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments) {
    if (instance is VmObject) throw ('Instance type cannot be VmObject: ${instance.runtimeType}');
    return getClassByInstance(instance).getProxy(functionName).runInstanceFunction(instance, positionalArguments, namedArguments);
  }

  ///读取任意非[VmObject]实例[instance]的[propertyName]属性
  static dynamic getInstanceProperty(dynamic instance, String propertyName) {
    if (instance is VmObject) throw ('Instance type cannot be VmObject: ${instance.runtimeType}');
    return getClassByInstance(instance).getProxy(propertyName).getInstanceProperty(instance);
  }

  ///设置任意非[VmObject]实例[instance]的[propertyName]属性
  static dynamic setInstanceProperty(dynamic instance, String propertyName, dynamic propertyValue) {
    if (instance is VmObject) throw ('Instance type cannot be VmObject: ${instance.runtimeType}');
    return getClassByInstance(instance).getProxy(propertyName).setInstanceProperty(instance, propertyValue);
  }
}

///
///虚拟机字段代理类
///
class VmProxy<T> extends VmObject {
  ///是否属于外部导入类型
  final bool isExternal;

  ///外部导入类型的静态属性读取函数
  final dynamic Function()? externalStaticPropertyReader;

  ///外部导入类型的静态属性写入函数
  final dynamic Function(dynamic value)? externalStaticPropertyWriter;

  ///外部导入类型的实例属性读取函数
  final dynamic Function(T instance)? externalInstancePropertyReader;

  ///外部导入类型的实例属性写入函数
  final dynamic Function(T instance, dynamic value)? externalInstancePropertyWriter;

  ///内部定义类型的静态属性读取函数
  final Map<VmKeys, dynamic>? internalStaticPropertyReader;

  ///内部定义类型的静态属性写入函数
  final Map<VmKeys, dynamic>? internalStaticPropertyWriter;

  ///内部定义类型的实例属性读取函数
  final Map<VmKeys, dynamic>? internalInstancePropertyReader;

  ///内部定义类型的实例属性写入函数
  final Map<VmKeys, dynamic>? internalInstancePropertyWriter;

  VmProxy({
    required super.identifier,
    this.isExternal = true,
    this.externalStaticPropertyReader,
    this.externalStaticPropertyWriter,
    this.externalInstancePropertyReader,
    this.externalInstancePropertyWriter,
    this.internalStaticPropertyReader,
    this.internalStaticPropertyWriter,
    this.internalInstancePropertyReader,
    this.internalInstancePropertyWriter,
  });

  ///执行静态函数
  dynamic runStaticFunction(List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments) {
    if (externalStaticPropertyReader == null) throw ('Not found externalStaticPropertyReader: $identifier');
    return Function.apply(externalStaticPropertyReader!(), positionalArguments, namedArguments);
  }

  ///读取静态属性
  dynamic getStaticProperty() {
    if (externalStaticPropertyReader == null) throw ('Not found externalStaticPropertyReader: $identifier');
    return externalStaticPropertyReader!();
  }

  ///写入静态属性
  dynamic setStaticProperty(dynamic value) {
    if (externalStaticPropertyWriter == null) throw ('Not found externalStaticPropertyWriter: $identifier');
    return externalStaticPropertyWriter!(value);
  }

  ///执行实例函数
  dynamic runInstanceFunction(dynamic instance, List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments) {
    if (instance is VmObject) throw ('Instance type cannot be VmObject: ${instance.runtimeType}');
    if (externalInstancePropertyReader == null) throw ('Not found externalInstancePropertyReader: $identifier => instance.runtimeType is ${instance.runtimeType}');
    return Function.apply(externalInstancePropertyReader!(instance), positionalArguments, namedArguments);
  }

  ///读取实例属性
  dynamic getInstanceProperty(dynamic instance) {
    if (instance is VmObject) throw ('Instance type cannot be VmObject: ${instance.runtimeType}');
    if (externalInstancePropertyReader == null) throw ('Not found externalInstancePropertyReader: $identifier => instance.runtimeType is ${instance.runtimeType}');
    return externalInstancePropertyReader!(instance);
  }

  ///写入实例属性
  dynamic setInstanceProperty(dynamic instance, dynamic value) {
    if (instance is VmObject) throw ('Instance type cannot be VmObject: ${instance.runtimeType}');
    if (externalInstancePropertyWriter == null) throw ('Not found externalInstancePropertyWriter: $identifier => instance.runtimeType is ${instance.runtimeType}');
    return externalInstancePropertyWriter!(instance, value);
  }

  ///转换为易读的字符串
  @override
  String toString() => 'VmProxy<$T> ===> $identifier';
}

///
///虚拟机目标操作类
///
class VmCaller extends VmObject {
  ///要操作的目标实例
  final dynamic _instance;

  ///要操作的目标的函数名
  String get functionName => identifier;

  ///要操作的目标的属性名
  String get propertyname => identifier;

  VmCaller({
    required dynamic target,
    required super.identifier,
  }) : _instance = target;

  ///读取目标的[identifier]属性
  dynamic getProperty() {
    final target = _instance;
    if (target is VmClass) return target.getStaticProperty(identifier);
    if (target is VmProxy) return VmClass.getInstanceProperty(target.getStaticProperty(), identifier);
    if (target is VmCaller) return VmClass.getInstanceProperty(target.getProperty(), identifier);
    if (target is VmHelper) return VmClass.getInstanceProperty(target.fieldValue, identifier);
    if (target is VmSignal) return VmClass.getInstanceProperty(target.signalValue, identifier);
    if (target is VmVariable) return target.getInstanceProperty(identifier);
    if (target is VmFunction) return VmClass.getInstanceProperty(target._template, identifier);
    return VmClass.getInstanceProperty(target, identifier);
  }

  ///设置目标的[identifier]属性
  dynamic setProperty(dynamic value) {
    final target = _instance;
    if (target is VmClass) return target.setStaticProperty(identifier, value);
    if (target is VmProxy) return VmClass.setInstanceProperty(target.getStaticProperty(), identifier, value);
    if (target is VmCaller) return VmClass.setInstanceProperty(target.getProperty(), identifier, value);
    if (target is VmHelper) return VmClass.setInstanceProperty(target.fieldValue, identifier, value);
    if (target is VmSignal) return VmClass.setInstanceProperty(target.signalValue, identifier, value);
    if (target is VmVariable) return target.setInstanceProperty(identifier, value);
    if (target is VmFunction) return VmClass.setInstanceProperty(target._template, identifier, value);
    return VmClass.setInstanceProperty(target, identifier, value);
  }

  ///获取[target]的值
  static dynamic getValue(dynamic target) {
    if (target is VmClass) return target.typeValue; //读取被包装的类型值
    if (target is VmProxy) return target.getStaticProperty(); //读取代理的属性值
    if (target is VmCaller) return target.getProperty(); //读取封装的属性值
    if (target is VmHelper) return target.fieldValue; //读取字段值
    if (target is VmSignal) return target.signalValue; //读取信号值
    if (target is VmVariable) return target._instance; //读取实例值
    if (target is VmFunction) return target._template; //读取模板值
    if (target is VmObject) throw ('Unsupport getValue target: ${target.runtimeType}');
    return target;
  }

  ///设置[target]的值
  static dynamic setValue(dynamic target, dynamic value) {
    if (target is VmCaller) return target.setProperty(value); //设置封装的属性值
    if (target is VmVariable) return target._setValue(value); //设置实例值
    throw ('Unsupport setValue target: ${target.runtimeType} $value');
  }
}

///
///虚拟机声明辅助类
///
class VmHelper extends VmObject {
  ///声明时明确指定的类型如：int、double、bool等
  final String? typeName;

  ///声明时明确指定的类型如果有问号则该值为：'?'，否则为：null
  final String? typeQuestion;

  ///声明的字段名称
  final String fieldName;

  ///声明的字段默认值
  final dynamic fieldValue;

  ///声明的字段是否为命名参数
  final bool isNamedField;

  VmHelper({
    this.typeName,
    this.typeQuestion,
    String? fieldName,
    dynamic fieldValue,
    this.isNamedField = false,
  })  : fieldName = fieldName ?? '___anonymousVmField___',
        fieldValue = VmCaller.getValue(fieldValue),
        super(identifier: '___anonymousVmHelper___');
}

///
///虚拟机运行信号类
///
class VmSignal extends VmObject {
  ///是否为break信号
  final bool isBreak;

  ///是否为return信号
  final bool isReturn;

  ///信号关键字如：break、return等
  final String? keyword;

  ///附带值如：函数返回值等
  final dynamic signalValue;

  ///是否为中断语句信号
  bool get isInterrupt => isBreak || isReturn;

  VmSignal({
    this.isBreak = false,
    this.isReturn = false,
    this.keyword,
    dynamic signalValue,
  })  : signalValue = VmCaller.getValue(signalValue),
        super(identifier: '___anonymousVmSignal___');
}

///
///虚拟机虚拟变量
///
class VmVariable extends VmObject {
  ///声明时是否有late
  final bool isLate;

  ///声明时是否有final
  final bool isFinal;

  ///声明时是否有const
  final bool isConst;

  ///声明时用的关键字如：var、const、final等
  final String? keyword;

  ///声明时明确指定的类型如：int、double、bool等
  final String? typeName;

  ///声明时明确指定的类型如果有问号则该值为：'?'，否则为：null
  final String? typeQuestion;

  ///初始值
  final dynamic initValue;

  ///根据[typeName]与[_instance]推算出来的包装类型
  late final VmClass _vmclass;

  ///对应[_vmclass]包装类型的实例，这个实例不能是[VmObject]的任何子类型
  dynamic _instance;

  VmVariable({
    super.identifier = '___anonymousVariable___',
    this.isLate = false,
    this.isFinal = false,
    this.isConst = false,
    this.keyword,
    this.typeName,
    this.typeQuestion,
    this.initValue,
  }) {
    _setValue(initValue); //先设置实例值
    _vmclass = typeName == null ? VmClass.getClassByInstance(_instance) : VmClass.getClassByTypeName(typeName!); //后推算对应类型
  }

  ///设置实例值
  void _setValue(dynamic val) {
    final v = VmCaller.getValue(val);
    switch (typeName) {
      case 'int':
        _instance = v as int?;
        break;
      case 'double':
        _instance = v is int ? v.toDouble() : v as double?; //使用int值初始化double时，initValue的运行时类型为int，所以进行了转换
        break;
      case 'num':
        _instance = v as num?;
        break;
      case 'bool':
        _instance = v as bool?;
        break;
      case 'String':
        _instance = v as String?;
        break;
      case 'List':
        _instance = v as List?;
        break;
      case 'Map':
        _instance = v as Map?;
        break;
      case 'Set':
        _instance = v is Map ? v.values.toSet() : v as Set?; //扫描器获取初始值时，有可能无法识别类型，这时默认为Map类型，需要再次进行类型转换
        break;
      default:
        _instance = v;
        break;
    }
  }

  ///执行实例的函数
  dynamic runInstanceFunction(String functionName, List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments) => _vmclass.getProxy(functionName).runInstanceFunction(_instance, positionalArguments, namedArguments);

  ///读取实例的属性
  dynamic getInstanceProperty(String propertyName) => _vmclass.getProxy(propertyName).getInstanceProperty(_instance);

  ///设置实例的属性
  dynamic setInstanceProperty(String propertyName, dynamic propertyValue) => _vmclass.getProxy(propertyName).setInstanceProperty(_instance, propertyValue);

  ///将实例作为函数执行
  dynamic apply(List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments) {
    if (_instance is Function) return Function.apply(_instance, positionalArguments, namedArguments);
    throw ('Instance type must be Function: ${_instance.runtimeType}');
  }

  ///转换为易读的字符串
  @override
  String toString() {
    final keyList = <String>[];
    // final defList = <String>[];
    keyList.add('VmVariable');
    keyList.add('===>');
    // if (isLate) defList.add('late');
    // if (isFinal) defList.add('final');
    // if (isConst) defList.add('const');
    // keyList.add('Describe(${defList.join(', ')})');
    // keyList.add('Keyword(${typeName ?? keyword.toString()}${typeQuestion ?? ''})');
    // keyList.add('--->');
    keyList.add('VmClass(${_vmclass.identifier}) $identifier');
    keyList.add('--->');
    keyList.add('${_instance.runtimeType} $_instance');
    return keyList.join(' ');
  }
}

///
///虚拟机函数模版
///
class VmFunction extends VmObject {
  ///声明时是否有get
  final bool isGetter;

  ///声明时是否有set
  final bool isSetter;

  ///声明时是否有async
  final bool isAsynchronous;

  ///声明时明确指定的返回值类型如：int、double、bool等
  final String? returnTypeName;

  ///声明时明确指定的返回值类如果有问号则该值为：'?'，否则为：null
  final String? returnTypeQuestion;

  ///列表参数数量
  final List<VmHelper> listArguments;

  ///命名参数数量
  final List<VmHelper> nameArguments;

  ///函数体语法树
  final Map<VmKeys, dynamic> functionBodyTree;

  ///模板回调监听
  final dynamic Function(List argumentList, VmFunction vmfunction) callbackListener;

  ///对应位置参数数量的模版函数
  late final Function _template;

  VmFunction({
    super.identifier = '___anonymousFunction___',
    this.isGetter = false,
    this.isSetter = false,
    this.isAsynchronous = false,
    this.returnTypeName,
    this.returnTypeQuestion,
    this.listArguments = const [],
    this.nameArguments = const [],
    this.functionBodyTree = const {},
    required this.callbackListener,
  }) {
    _initTemplate();
  }

  ///准备调用该函数所需的参数列表
  List<VmObject> prepareForApply(List? arguments) {
    if (arguments == null) return [];
    final result = <VmObject>[];
    //匹配列表参数
    for (var i = 0; i < listArguments.length; i++) {
      final item = listArguments[i];
      final target = i < arguments.length ? arguments[i] : item.fieldValue; //列表参数按照索引一一对应即可
      if (target is VmFunction) {
        result.add(target._cloneWithIdentifier(item.fieldName));
      } else {
        result.add(VmVariable(typeName: item.typeName, typeQuestion: item.typeQuestion, identifier: item.fieldName, initValue: target));
      }
    }
    //匹配命名参数
    for (var i = 0; i < nameArguments.length; i++) {
      final item = nameArguments[i];
      final index = arguments.indexWhere((e) => e is VmHelper && e.fieldName == item.fieldName); //命名参数按照字段名称进行匹配
      final target = index >= 0 ? (arguments[index] as VmHelper).fieldValue : item.fieldValue;
      if (target is VmFunction) {
        result.add(target._cloneWithIdentifier(item.fieldName));
      } else {
        result.add(VmVariable(typeName: item.typeName, typeQuestion: item.typeQuestion, identifier: item.fieldName, initValue: target));
      }
    }
    return result;
  }

  ///创建以[identifier]为标识符的副本
  VmFunction _cloneWithIdentifier(String identifier) {
    return VmFunction(
      identifier: identifier,
      isGetter: isGetter,
      isSetter: isSetter,
      isAsynchronous: isAsynchronous,
      returnTypeName: returnTypeName,
      returnTypeQuestion: returnTypeQuestion,
      listArguments: listArguments,
      nameArguments: nameArguments,
      functionBodyTree: functionBodyTree,
      callbackListener: callbackListener,
    );
  }

  ///转换为易读的字符串
  @override
  String toString() {
    final keyList = <String>[];
    keyList.add('VmFunction');
    keyList.add('===>');
    keyList.add('${returnTypeName ?? 'void'}${returnTypeQuestion ?? ''}');
    if (isGetter) keyList.add('get');
    if (isSetter) keyList.add('set');
    keyList.add(identifier);
    keyList.add('[${listArguments.map((e) => '${e.typeName}${e.typeQuestion ?? ''} ${e.fieldName}').toList().join(', ')}]');
    keyList.add('{${nameArguments.map((e) => '${e.typeName}${e.typeQuestion ?? ''} ${e.fieldName}${e.fieldValue == null ? '' : ' = ${e.fieldValue}'}').toList().join(', ')}}');
    return keyList.join(' ');
  }

  ///初始化[_template]
  void _initTemplate() {
    switch (listArguments.length) {
      case 0:
        _template = _template0;
        break;
      case 1:
        _template = _template1;
        break;
      case 2:
        _template = _template2;
        break;
      case 3:
        _template = _template3;
        break;
      case 4:
        _template = _template4;
        break;
      case 5:
        _template = _template5;
        break;
      case 6:
        _template = _template6;
        break;
      case 7:
        _template = _template7;
        break;
      case 8:
        _template = _template8;
        break;
      case 9:
        _template = _template9;
        break;
      default:
        throw ('Not found templater: $identifier._template${listArguments.length}');
    }
  }

  dynamic _template0() => callbackListener([], this);

  dynamic _template1(a) => callbackListener([a], this);

  dynamic _template2(a, b) => callbackListener([a, b], this);

  dynamic _template3(a, b, c) => callbackListener([a, b, c], this);

  dynamic _template4(a, b, c, d) => callbackListener([a, b, c, d], this);

  dynamic _template5(a, b, c, d, e) => callbackListener([a, b, c, d, e], this);

  dynamic _template6(a, b, c, d, e, f) => callbackListener([a, b, c, d, e, f], this);

  dynamic _template7(a, b, c, d, e, f, g) => callbackListener([a, b, c, d, e, f, g], this);

  dynamic _template8(a, b, c, d, e, f, g, h) => callbackListener([a, b, c, d, e, f, g, h], this);

  dynamic _template9(a, b, c, d, e, f, g, h, i) => callbackListener([a, b, c, d, e, f, g, h, i], this);
}

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

  ///执行本包装类型的静态函数
  dynamic runStaticFunction(String functionName, List? positionalArguments, Map<Symbol, dynamic>? namedArguments) => _getProxy(functionName).runStaticFunction(positionalArguments, namedArguments);

  ///读取本包装类型的静态属性
  dynamic getStaticProperty(String propertyName) => _getProxy(propertyName).getStaticProperty();

  ///设置本包装类型的静态属性
  dynamic setStaticProperty(String propertyName, propertyValue) => _getProxy(propertyName).setStaticProperty(propertyValue);

  ///转换为容易理解的可读字符串描述
  @override
  String toString() => 'VmClass<$T> ===> $identifier';

  ///判断指定实例是否为本包装类型的实例
  bool _matchClass(dynamic instance) => instance is T;

  ///获取本包装类型的指定字段的代理对象
  VmProxy<T> _getProxy(String propertyName) {
    final proxy = isExternal ? (externalProxyMap?[propertyName]) : (internalProxyMap?[propertyName]);
    if (proxy == null) throw ('Not found proxy: $identifier.$propertyName');
    return proxy;
  }

  ///缺省包装类型
  static const _defaultClass = VmClass(identifier: '___defaultProxyClass___');

  ///包装类型集合
  static final _libraryMap = <String, VmClass>{};

  ///包装类型列表
  static final _libraryList = <VmClass>[];

  ///添加包装类型
  static void addClass(VmClass vmclass) {
    if (_libraryMap.containsKey(vmclass.identifier)) throw ('Already exists class: ${vmclass.identifier}');
    _libraryMap[vmclass.identifier] = vmclass;
    _libraryList.add(vmclass);
  }

  ///获取指定名称对应的包装类型
  static VmClass getClassByTypeName(String typeName) {
    final vmclass = _libraryMap[typeName];
    if (vmclass == null) throw ('Not found class: $typeName');
    return vmclass;
  }

  ///获取指定实例对应的包装类型
  static VmClass getClassByInstance(dynamic instance) {
    //先通过运行时字符串类型名查找
    final typeName = instance.runtimeType.toString();
    final vmclass = _libraryMap[typeName];
    if (vmclass != null) return vmclass;
    //再通过_matchClass方法匹配
    for (var item in _libraryList) {
      if (item._matchClass(instance)) return item;
    }
    throw ('Not found class: $typeName');
  }

  ///执行被包装类型的实例的函数
  static dynamic runInstanceFunction(dynamic instance, String functionName, List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments) {
    return getClassByInstance(instance)._getProxy(functionName).runInstanceFunction(instance, positionalArguments, namedArguments);
  }

  ///读取被包装类型的实例的属性
  static dynamic getInstanceProperty(dynamic instance, String propertyName) {
    return getClassByInstance(instance)._getProxy(propertyName).getInstanceProperty(instance);
  }

  ///设置被包装类型的实例的属性
  static dynamic setInstanceProperty(dynamic instance, String propertyName, dynamic propertyValue) {
    return getClassByInstance(instance)._getProxy(propertyName).setInstanceProperty(instance, propertyValue);
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
    if (externalInstancePropertyReader == null) throw ('Not found externalInstancePropertyReader: $identifier => instance.runtimeType is ${instance.runtimeType}');
    return Function.apply(externalInstancePropertyReader!(instance), positionalArguments, namedArguments);
  }

  ///读取实例属性
  dynamic getInstanceProperty(dynamic instance) {
    if (externalInstancePropertyReader == null) throw ('Not found externalInstancePropertyReader: $identifier => instance.runtimeType is ${instance.runtimeType}');
    return externalInstancePropertyReader!(instance);
  }

  ///写入实例属性
  dynamic setInstanceProperty(dynamic instance, dynamic value) {
    if (externalInstancePropertyWriter == null) throw ('Not found externalInstancePropertyWriter: $identifier => instance.runtimeType is ${instance.runtimeType}');
    return externalInstancePropertyWriter!(instance, value);
  }
}

///
///虚拟机目标操作类
///
class VmCaller extends VmObject {
  ///要操作的目标对象
  final dynamic target;

  ///要操作的目标对象的函数名
  String get functionName => identifier;

  ///要操作的目标对象的属性名
  String get propertyname => identifier;

  VmCaller({
    required dynamic target,
    required super.identifier,
  }) : target = target is VmCaller ? target.getProperty() : target;

  ///执行[target]的[identifier]函数
  dynamic runFunction(List? positionalArguments, Map<Symbol, dynamic>? namedArguments) {
    if (target is VmClass) return (target as VmClass).runStaticFunction(identifier, positionalArguments, namedArguments);
    if (target is VmVariable) return (target as VmVariable).runInstanceFunction(identifier, positionalArguments, namedArguments);
    if (target is VmObject) throw ('Unsupport runFunction target: ${target.runtimeType}.$identifier');
    return VmClass.runInstanceFunction(target, identifier, positionalArguments, namedArguments);
  }

  ///读取[target]的[identifier]属性
  dynamic getProperty() {
    if (target is VmClass) return (target as VmClass).getStaticProperty(identifier);
    if (target is VmVariable) return (target as VmVariable).getInstanceProperty(identifier);
    if (target is VmObject) throw ('Unsupport getProperty target: ${target.runtimeType}.$identifier');
    return VmClass.getInstanceProperty(target, identifier);
  }

  ///设置[target]的[identifier]属性
  dynamic setProperty(dynamic value) {
    if (target is VmClass) return (target as VmClass).setStaticProperty(identifier, value);
    if (target is VmVariable) return (target as VmVariable).setInstanceProperty(identifier, value);
    if (target is VmObject) throw ('Unsupport setProperty target: ${target.runtimeType}.$identifier');
    return VmClass.setInstanceProperty(target, identifier, value);
  }

  ///获取[target]的值
  static dynamic getValue(dynamic target) {
    if (target is VmCaller) return target.getProperty();
    if (target is VmVariable) return target.value;
    if (target is VmObject) throw ('Unsupport getValue target: ${target.runtimeType}');
    return target;
  }

  ///设置[target]的值
  static dynamic setValue(dynamic target, dynamic value) {
    if (target is VmCaller) return target.setProperty(value);
    if (target is VmVariable) return target.value = value;
    throw ('Unsupport setValue target: ${target.runtimeType} $value');
  }
}

///
///虚拟机声明辅助类
///
class VmHelper extends VmObject {
  ///声明时明确指定的类型如：int、double、bool等
  String get typeName => identifier;

  ///声明时明确指定的类型如果有问号则该值为：'?'，否则为：null
  final String? typeQuestion;

  ///声明字段的名称
  final String? fieldName;

  ///声明字段的默认值
  final dynamic fieldValue;

  ///声明字段是否为命名参数
  final bool isNamedField;

  VmHelper({
    String? identifier,
    this.typeQuestion,
    this.fieldName,
    this.fieldValue,
    this.isNamedField = false,
  }) : super(identifier: identifier ?? VmClass._defaultClass.identifier);
}

///
///虚拟机虚拟变量
///
class VmVariable extends VmObject {
  ///匿名变量名称
  static const _anonymousVariable = '_anonymousVariable';

  ///声明时是否有late
  final bool isLate;

  ////声明时是否有final
  final bool isFinal;

  ////声明时是否有const
  final bool isConst;

  ////声明时用的关键字如：var、const、final等
  final String? keyword;

  ///声明时明确指定的类型如：int、double、bool等
  final String? typeName;

  ///声明时明确指定的类型如果有问号则该值为：'?'，否则为：null
  final String? typeQuestion;

  ///初始值
  final dynamic initValue;

  ///是否已经初始化过
  bool _inited;

  ///根据[typeName]与[_instance]推算出来的的代理包装类
  VmClass _vmclass;

  ///对应类型的当前实例
  dynamic _instance;

  VmVariable({
    super.identifier = _anonymousVariable,
    this.isLate = false,
    this.isFinal = false,
    this.isConst = false,
    this.keyword,
    this.typeName,
    this.typeQuestion,
    this.initValue,
  })  : _inited = false,
        _vmclass = VmClass._defaultClass,
        _instance = null;

  void _ensureInited() {
    if (!_inited) throw ('Not inited VmVariable: $identifier');
  }

  void init() {
    if (_inited) throw ('Already inited VmVariable: $identifier');
    _inited = true;
    value = initValue; //注意这里调用的 set 方法
    _vmclass = typeName == null ? VmClass.getClassByInstance(_instance) : VmClass.getClassByTypeName(typeName!); //初始化绑定的类型
  }

  ///设置实例
  set value(dynamic val) {
    _ensureInited();
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

  ///读取实例
  dynamic get value {
    _ensureInited();
    return _instance;
  }

  ///执行实例的函数
  dynamic runInstanceFunction(String functionName, List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments) {
    _ensureInited();
    return _vmclass._getProxy(functionName).runInstanceFunction(_instance, positionalArguments, namedArguments);
  }

  ///读取实例的属性
  dynamic getInstanceProperty(String propertyName) {
    _ensureInited();
    return _vmclass._getProxy(propertyName).getInstanceProperty(_instance);
  }

  ///设置实例的属性
  dynamic setInstanceProperty(String propertyName, dynamic propertyValue) {
    _ensureInited();
    return _vmclass._getProxy(propertyName).setInstanceProperty(_instance, propertyValue);
  }

  ///转换为字符串描述
  @override
  String toString() {
    final keyList = <String>[];
    final defList = <String>[];
    keyList.add('VmVariable');
    keyList.add('===>');
    if (isLate) defList.add('late');
    if (isFinal) defList.add('final');
    if (isConst) defList.add('const');
    keyList.add('Describe(${defList.join(', ')})');
    keyList.add('Keyword(${typeName ?? keyword.toString()}${typeQuestion ?? ''})');
    keyList.add('--->');
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
  ///匿名函数名称
  static const _anonymousFunction = '_anonymousFunction';

  ///默认模板函数
  static void _defaultTemplate() => throw ('Not inited VmFunction');

  ///声明时是否有get
  final bool isGetter;

  ////声明时是否有set
  final bool isSetter;

  ///声明时明确指定的返回值类型如：int、double、bool等
  final String? returnTypeName;

  ///声明时明确指定的返回值类如果有问号则该值为：'?'，否则为：null
  final String? returnTypeQuestion;

  ///列表参数数量
  final List<VmHelper> listArguments;

  ///命名参数数量
  final List<VmHelper> nameArguments;

  ///函数体语法树
  final Map<VmKeys, dynamic> blockBodyAstTree;

  ///模板回调监听
  final dynamic Function(List argumentList)? callbackListener;

  ///是否已经初始化过
  bool _inited;

  ///对应位置参数数量的模版函数
  Function _templater;

  VmFunction({
    super.identifier = _anonymousFunction,
    this.isGetter = false,
    this.isSetter = false,
    this.returnTypeName,
    this.returnTypeQuestion,
    this.listArguments = const [],
    this.nameArguments = const [],
    this.blockBodyAstTree = const {},
    this.callbackListener,
  })  : _inited = false,
        _templater = _defaultTemplate;

  void _ensureInited() {
    if (!_inited) throw ('Not inited VmFunction: $identifier');
  }

  void init() {
    if (_inited) throw ('Already inited VmFunction: $identifier');
    _inited = true;
    switch (listArguments.length) {
      case 0:
        _templater = _template0;
        break;
      case 1:
        _templater = _template1;
        break;
      case 2:
        _templater = _template2;
        break;
      case 3:
        _templater = _template3;
        break;
      case 4:
        _templater = _template4;
        break;
      case 5:
        _templater = _template5;
        break;
      case 6:
        _templater = _template6;
        break;
      case 7:
        _templater = _template7;
        break;
      case 8:
        _templater = _template8;
        break;
      case 9:
        _templater = _template9;
        break;
      default:
        throw ('Not found template: $identifier._template${listArguments.length}');
    }
  }

  ///获取可以作为参数传递给其他函数的模版值
  Function get value {
    _ensureInited();
    return _templater;
  }

  @override
  String toString() {
    final keyList = <String>[];
    keyList.add('VmFunction');
    keyList.add('===>');
    keyList.add('${returnTypeName ?? 'void'}${returnTypeQuestion ?? ''}');
    if (isGetter) keyList.add('get');
    if (isSetter) keyList.add('set');
    keyList.add(identifier);
    keyList.add('[${listArguments.map((e) => '${e.identifier}${e.typeQuestion ?? ''} ${e.fieldName}').toList().join(', ')}]');
    keyList.add('{${nameArguments.map((e) => '${e.identifier}${e.typeQuestion ?? ''} ${e.fieldName}${e.fieldValue == null ? '' : ' = ${e.fieldValue}'}').toList().join(', ')}}');
    return keyList.join(' ');
  }

  dynamic _template0() => callbackListener == null ? null : callbackListener!([]);

  dynamic _template1(a) => callbackListener == null ? null : callbackListener!([a]);

  dynamic _template2(a, b) => callbackListener == null ? null : callbackListener!([a, b]);

  dynamic _template3(a, b, c) => callbackListener == null ? null : callbackListener!([a, b, c]);

  dynamic _template4(a, b, c, d) => callbackListener == null ? null : callbackListener!([a, b, c, d]);

  dynamic _template5(a, b, c, d, e) => callbackListener == null ? null : callbackListener!([a, b, c, d, e]);

  dynamic _template6(a, b, c, d, e, f) => callbackListener == null ? null : callbackListener!([a, b, c, d, e, f]);

  dynamic _template7(a, b, c, d, e, f, g) => callbackListener == null ? null : callbackListener!([a, b, c, d, e, f, g]);

  dynamic _template8(a, b, c, d, e, f, g, h) => callbackListener == null ? null : callbackListener!([a, b, c, d, e, f, g, h]);

  dynamic _template9(a, b, c, d, e, f, g, h, i) => callbackListener == null ? null : callbackListener!([a, b, c, d, e, f, g, h, i]);
}

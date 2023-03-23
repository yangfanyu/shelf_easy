import 'package:dart_style/dart_style.dart';

import 'vm_keys.dart';

///
///包装类的类型
///
class VmType extends Type {
  ///包装类的类型名称
  final String name;

  VmType({required this.name});

  @override
  bool operator ==(Object other) {
    if (other is VmType) return other.name == name;
    if (other is Type) return other.toString() == name;
    return false;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => name;
}

///
///内部类的超类
///
mixin VmSuper {
  ///实例的字段作用域列表
  final _propertyMapList = [<String, VmValue>{}, <String, VmValue>{}];

  ///实例的超类字段作用域
  Map<String, VmValue> get _superPropertyMap => _propertyMapList.first;

  ///实例的子类字段作用域
  Map<String, VmValue> get _childPropertyMap => _propertyMapList.last;

  ///强制读取实例的某字段
  VmValue getProperty(String propertyName) => _childPropertyMap[propertyName] ?? _superPropertyMap[propertyName]!; //必须先尝试从child中读取

  ///实例的超类字段作用域中存在某字段
  bool hasSuperProperty(String propertyName) => _superPropertyMap.containsKey(propertyName);

  ///实例的子类字段作用域中存在某字段
  bool hasChildProperty(String propertyName) => _childPropertyMap.containsKey(propertyName);

  ///是被虚拟机初始化过的标记key
  static const _initedByVmwareKey = '___initedByVmwareKey___';

  ///超类实例是否被虚拟机初始化过
  bool get isInitedByVmware => _superPropertyMap.containsKey(_initedByVmwareKey);

  ///复制超类的全部实例字段，并在子作用域中添加[isInitedByVmware]标记
  void _initProperties(VmClass superclass) {
    final propertyMap = _superPropertyMap;
    propertyMap[_initedByVmwareKey] = propertyMap[_initedByVmwareKey] ?? VmValue.forVariable(identifier: _initedByVmwareKey, initValue: true); //添加标记
    superclass.externalProxyMap?.forEach((key, value) {
      if (value.isExternalInstanceProxy) {
        propertyMap[key] = VmValue.forSubproxy(identifier: key, initValue: () => VmLazyer(instance: this, property: key)); //覆盖保存
      }
    });
  }

  ///转换为易读的字符串描述，添加了[minLevel]参数使得可以给flutter小部件使用
  @override
  String toString({minLevel}) {
    if (isInitedByVmware) {
      return '_${runtimeType.toString().toLowerCase()}(${_propertyMapList.map((e) => '{${e.keys.join(', ')}}').join(', ')})_';
    } else {
      return '_${runtimeType.toString().toLowerCase()}(___)_';
    }
  }

  ///转换为易读的JSON对象
  Map<String, dynamic> toJson() {
    return {
      '_superPropertyMap': _superPropertyMap,
      '_childPropertyMap': _childPropertyMap,
    };
  }
}

///
///默认内部类实例
///
class VmInstance with VmSuper {}

///
///数据值的元类型
///
enum VmMetaType {
  ///外部类型的普通类型数据
  externalValue,

  ///外部类型的万能类型数据
  externalSmart,

  ///外部类型的继承字段代理
  externalSuper,

  ///内部类型的普通类型数据
  internalValue,

  ///内部定义的方法类型数据
  internalApply,

  ///内部类型的数据实例别名，即[internalValue]与[internalApply]元类型的别名
  internalAlias,
}

///
///数据值的元数据
///
class VmMetaData {
  ///作为内部定义方法时声明为: constructor，排除 factory 方法
  final bool isIniter;

  ///作为内部定义方法时声明为: static，包括 constructor、factory 方法
  final bool isStatic;

  ///作为内部定义方法时声明为: get
  final bool isGetter;

  ///作为内部定义方法时声明为: set
  final bool isSetter;

  ///作为内部定义方法时的列表参数
  final List<VmHelper> listArguments;

  ///作为内部定义方法时的命名参数
  final List<VmHelper> nameArguments;

  ///作为内部定义方法时的初始化语法树，仅 非factory的constructor 有此内容
  final List<Map<VmKeys, dynamic>?> initTree;

  ///作为内部定义方法时的函数体语法树
  final Map<VmKeys, dynamic> bodyTree;

  ///作为内部定义类的静态方法时的回调监听
  final dynamic Function(List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments, VmClass classScope, List<Map<VmKeys, dynamic>>? instanceFields, VmValue method)? staticListener;

  ///作为内部定义类的实例方法时的回调监听
  final dynamic Function(List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments, VmClass? classScope, VmValue? instanceScope, VmValue method)? instanceListener;

  const VmMetaData({
    this.isIniter = false,
    this.isStatic = false,
    this.isGetter = false,
    this.isSetter = false,
    this.listArguments = const [],
    this.nameArguments = const [],
    this.initTree = const [],
    this.bodyTree = const {},
    this.staticListener,
    this.instanceListener,
  });
}

///
///运行时抽象类
///
abstract class VmObject {
  ///对象的标识符
  final String identifier;

  VmObject({required this.identifier});

  ///读取对象的对应包装类
  VmClass getClass();

  ///读取对象的逻辑处理值
  dynamic getLogic();

  ///读取对象的原生数据值
  dynamic getValue();

  ///设置对象的原生数据值 或 逻辑处理值
  dynamic setValue(dynamic value);

  ///转换为易读的字符串描述
  @override
  String toString() => '$runtimeType ===> $identifier';

  ///转换为易读的JSON对象
  Map<String, dynamic> toJson();

  ///读取原生数据值转换器，如：在flutter中经常需要<Widget>[]类型的参数，但虚拟机中实际上是个<dynamic>[]类型
  static dynamic Function(dynamic value)? nativeValueConverter;

  ///读取[target]的对应包装类
  static VmClass readClass(dynamic target, {String? type}) {
    if (type == null) {
      return target is VmObject ? target.getClass() : VmClass._getClassByInstance(target);
    } else {
      return VmClass._getClassByTypeName(type);
    }
  }

  ///读取[target]的逻辑处理值
  static dynamic readLogic(dynamic target, {String? type}) {
    final value = target is VmObject ? target.getLogic() : target;
    switch (type) {
      case 'double':
        return value is int ? value.toDouble() : value as double?; //使用int值初始化double时，initValue的运行时类型为int，所以进行了转换
      case 'Set':
        return value is Map ? value.values.toSet() : value as Set?; //扫描器获取初始值时，无法识别无类型声明的空'{}'类型，这时默认为Map类型，需要再次进行类型转换
      default:
        return value;
    }
  }

  ///读取[target]的原生数据值
  static dynamic readValue(dynamic target, {String? type}) {
    final value = target is VmObject ? target.getValue() : target;
    switch (type) {
      case 'double':
        return value is int ? value.toDouble() : value as double?; //使用int值初始化double时，initValue的运行时类型为int，所以进行了转换
      case 'Set':
        return value is Map ? value.values.toSet() : value as Set?; //扫描器获取初始值时，无法识别无类型声明的空'{}'类型，这时默认为Map类型，需要再次进行类型转换
      default:
        return nativeValueConverter == null ? value : nativeValueConverter!(value);
    }
  }

  ///保存[target]的原生数据值 或 逻辑处理值
  static dynamic saveValue(dynamic target, dynamic value) {
    if (target is VmObject) {
      return target.setValue(value);
    } else {
      throw ('Unsupport saveValue operator for type: ${target.runtimeType}');
    }
  }

  ///转换[target]语法树为可jsonEncode的数据值
  static dynamic treeValue(dynamic target) {
    if (target is Map) {
      return target.map((key, value) => MapEntry(key is String ? key : (key is VmKeys ? key.name : key.toString()), treeValue(value)));
    } else if (target is List) {
      return target.map((value) => treeValue(value)).toList();
    } else if (target is VmKeys) {
      return target.name;
    } else {
      return target;
    }
  }

  ///对函数声明时的参数进行分组
  static void groupDeclarationParameters(List<dynamic>? fromParameters, List<VmHelper> toListArguments, List<VmHelper> toNameArguments) {
    if (fromParameters != null) {
      for (VmHelper item in fromParameters) {
        if (item.isNamedField) {
          toNameArguments.add(item);
        } else {
          toListArguments.add(item);
        }
      }
    }
  }

  ///对函数调用时的参数进行分组
  static void groupInvocationParameters(List<dynamic>? fromParameters, List<dynamic> toListArguments, Map<Symbol, dynamic> toNameArguments) {
    if (fromParameters != null) {
      for (var item in fromParameters) {
        if (item is VmHelper && item.isNamedField) {
          toNameArguments[Symbol(item.fieldName)] = item;
        } else {
          toListArguments.add(item);
        }
      }
    }
  }
}

///
///运行时类型包装类
///
class VmClass<T> extends VmObject {
  ///是否为外部导入类型
  final bool isExternal;

  ///该包装类的类型实例
  final VmType vmwareType;

  ///该包装类的深度递归的超类名
  final List<String> superclassNames;

  ///外部导入类型的字段代理集合
  final Map<String, VmProxy<T>>? externalProxyMap;

  ///内部定义类型的字段代理集合
  final Map<String, VmProxy<T>>? internalProxyMap;

  ///内部定义类型的静态字段的已初始化集合，在相关调用时会将该集合放到作用域栈中
  final Map<String, VmValue>? internalStaticPropertyMap;

  ///内部定义类型的实例字段的初始化树列表，初始化树采用列表可保证初始化顺序不变
  final List<Map<VmKeys, dynamic>>? internalInstanceFieldTree;

  ///内部定义类型继承的父包装类型，当前仅支持继承：添加了VmSuper扩展的外部类型
  VmClass? _internalSuperclass;

  VmClass({
    required super.identifier,
    this.isExternal = true,
    this.superclassNames = const [],
    this.externalProxyMap,
    this.internalProxyMap,
    this.internalStaticPropertyMap,
    this.internalInstanceFieldTree,
    VmClass? internalSuperclass,
  })  : vmwareType = VmType(name: identifier),
        _internalSuperclass = isExternal ? null : internalSuperclass {
    externalProxyMap?.forEach((key, value) => value.bindVmClass(this)); //给代理集合绑定包装类型
    internalProxyMap?.forEach((key, value) => value.bindVmClass(this)); //给代理集合绑定包装类型
    internalStaticPropertyMap?.forEach((key, value) => value.bindStaticScope(this)); //给类静态成员绑定作用域
  }

  ///重新装载该包装类型的属性
  void reassemble(VmClass vmclass) {
    if (identifier != vmclass.identifier || isExternal || vmclass.isExternal) {
      throw ('Unsupport reassemble operator: $identifier<isExternal $isExternal> => ${vmclass.identifier}<isExternal ${vmclass.isExternal}>');
    }
    //重置
    superclassNames.clear();
    internalProxyMap?.clear();
    internalStaticPropertyMap?.clear();
    internalInstanceFieldTree?.clear();
    _internalSuperclass = null;
    //复制
    superclassNames.addAll(vmclass.superclassNames);
    internalProxyMap?.addAll(vmclass.internalProxyMap as Map<String, VmProxy<T>>? ?? const {});
    internalStaticPropertyMap?.addAll(vmclass.internalStaticPropertyMap ?? const {});
    internalInstanceFieldTree?.addAll(vmclass.internalInstanceFieldTree ?? const []);
    _internalSuperclass = vmclass._internalSuperclass;
    //绑定
    internalProxyMap?.forEach((key, value) => value.bindVmClass(this)); //给代理集合绑定包装类型
    internalStaticPropertyMap?.forEach((key, value) => value.bindStaticScope(this)); //给类静态成员绑定作用域
  }

  ///转换为精确的List<T>类型
  List<T>? toTypeList(List? source) => source?.map((e) => e as T).toList();

  ///转换为精确的Set<T>类型
  Set<T>? toTypeSet(Set? source) => source?.map((e) => e as T).toSet();

  ///转换为精确的Mao<T, V>类型，目前Map的推导只有key才准确，实际返回的是Map<T, dynamic>类型
  Map<T, V>? toTypeMap<V>(Map? source, VmClass<V> vmclass) => source?.map((key, value) => MapEntry(key as T, value as V));

  ///判断实例是否为该包装类型的实例
  bool isThisType(dynamic instance) {
    final logic = VmObject.readLogic(instance); //先读取逻辑值进行判断
    if (logic is VmValue) {
      return logic._valueType == this; //最底层为 internalMethod 或 internalObject 的对象的逻辑值必然为 VmValue
    } else {
      if (isExternal) {
        return VmObject.readValue(logic) is T; //外部类型需要读取原生值进行判断
      } else {
        return false; //内部类型读取出来的逻辑值必定为 VmValue
      }
    }
  }

  ///将实例转换为该包装类型的实例，实质上是做类型判断
  T asThisType(dynamic instance) {
    if (isThisType(instance)) return instance;
    throw ('Instance type: ${instance.runtimeType} => Not matched class type: $identifier');
  }

  ///获取指定字段的代理，[setter]为true表示这是为设置属性而获取的代理，由于set函数在字段的末尾添加了等于符号，所以将优先查找'propertyName='这样的函数
  VmProxy getProxy(String propertyName, {required bool setter}) {
    if (setter) {
      final setterPropName = '$propertyName=';
      final proxy = isExternal ? (externalProxyMap?[setterPropName] ?? externalProxyMap?[propertyName]) : (internalProxyMap?[setterPropName] ?? internalProxyMap?[propertyName]);
      if (proxy != null) return proxy;
      if (_internalSuperclass != null) return _internalSuperclass!.getProxy(propertyName, setter: setter);
      throw ('Not found proxy: $identifier.$propertyName');
    } else {
      final proxy = isExternal ? (externalProxyMap?[propertyName]) : (internalProxyMap?[propertyName]);
      if (proxy != null) return proxy;
      if (_internalSuperclass != null) return _internalSuperclass!.getProxy(propertyName, setter: setter);
      throw ('Not found proxy: $identifier.$propertyName');
    }
  }

  ///检查指定字段的代理是否存在，逻辑与[getProxy]一样，只是用false代替异常的抛出，用于 xxx?.xxx 的调用
  bool hasProxy(String propertyName, {required bool setter}) {
    if (setter) {
      final setterPropName = '$propertyName=';
      final proxy = isExternal ? (externalProxyMap?[setterPropName] ?? externalProxyMap?[propertyName]) : (internalProxyMap?[setterPropName] ?? internalProxyMap?[propertyName]);
      if (proxy != null) return true;
      if (_internalSuperclass != null) return _internalSuperclass!.hasProxy(propertyName, setter: setter);
      return false;
    } else {
      final proxy = isExternal ? (externalProxyMap?[propertyName]) : (internalProxyMap?[propertyName]);
      if (proxy != null) return true;
      if (_internalSuperclass != null) return _internalSuperclass!.hasProxy(propertyName, setter: setter);
      return false;
    }
  }

  @override
  VmClass getClass() => VmObject.readClass(vmwareType);

  @override
  dynamic getLogic() => this; //注意：此处返回自身，用于逻辑调用

  @override
  dynamic getValue() => vmwareType;

  @override
  dynamic setValue(value) => throw UnimplementedError();

  @override
  String toString() => 'VmClass<${isExternal ? T : identifier}> ===> $identifier ---> super_${superclassNames}_${superclassNames.length}';

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'toString': toString(),
      'identifier': identifier,
      'isExternal': isExternal,
      'vmwareType': vmwareType.toString(),
      'superclassNames': superclassNames,
    };
    if (externalProxyMap != null) map['externalProxyMap'] = externalProxyMap?.length;
    if (internalProxyMap != null) map['internalProxyMap'] = internalProxyMap;
    if (internalStaticPropertyMap != null) map['internalStaticPropertyMap'] = internalStaticPropertyMap;
    if (internalInstanceFieldTree != null) map['internalInstanceFieldTree'] = internalInstanceFieldTree?.map((e) => e.keys.map((e) => e.toString()).toList()).toList();
    if (_internalSuperclass != null) map['internalExtendsSuperclass'] = _internalSuperclass?.toString();
    return map;
  }

  ///new方法的名称
  static const newMethodName = 'new';

  ///函数的类型名称
  static const functionTypeName = 'Function';

  ///函数的类型名称
  static const objectTypeName = 'Object';

  ///动态的类型名称
  static const smartTypeNames = ['FutureOr', 'Object', 'Null', 'dynamic', 'void'];

  ///非Object子类型Null
  // ignore: prefer_void_to_null
  static final baseClassNull = VmClass<Null>(
    identifier: 'Null',
    externalProxyMap: {
      'hashCode': VmProxy(identifier: 'hashCode', externalInstancePropertyReader: (instance) => instance.hashCode),
      'noSuchMethod': VmProxy(identifier: 'noSuchMethod', externalInstancePropertyReader: (instance) => instance.noSuchMethod),
      'runtimeType': VmProxy(identifier: 'runtimeType', externalInstancePropertyReader: (instance) => instance.runtimeType),
      'toString': VmProxy(identifier: 'toString', externalInstancePropertyReader: (instance) => instance.toString),
    },
  );

  ///非Object子类型dynamic
  static final baseClassDynamic = VmClass<dynamic>(
    identifier: 'dynamic',
    externalProxyMap: {
      'hashCode': VmProxy(identifier: 'hashCode', externalInstancePropertyReader: (instance) => instance.hashCode),
      'noSuchMethod': VmProxy(identifier: 'noSuchMethod', externalInstancePropertyReader: (instance) => instance.noSuchMethod),
      'runtimeType': VmProxy(identifier: 'runtimeType', externalInstancePropertyReader: (instance) => instance.runtimeType),
      'toString': VmProxy(identifier: 'toString', externalInstancePropertyReader: (instance) => instance.toString),
    },
  );

  ///非Object子类型void
  static final baseClassVoid = VmClass<void>(
    identifier: 'void',
    externalProxyMap: {},
  );

  ///非Object子类型列表
  static final libraryBaseList = <VmClass>[baseClassNull, baseClassDynamic, baseClassVoid];

  ///全局包装类型集合
  static final _globalLibraryMap = <String, VmClass>{};

  ///全局包装类型列表
  static final _globalLibraryList = <VmClass>[];

  ///添加包装类型[vmclass]到全局缓存，如果已存在则重新装载，不存在则添加带全局库中
  static VmClass addClass(VmClass vmclass) {
    if (_globalLibraryMap.containsKey(vmclass.identifier)) throw ('Already exists VmClass in global library, identifier is: ${vmclass.identifier}');
    if (!vmclass.isExternal) throw ('Not an external VmClass add to global library, identifier is: ${vmclass.identifier}');
    _globalLibraryList.add(_globalLibraryMap[vmclass.identifier] = vmclass);
    return vmclass;
  }

  ///按照继承数量逆序排列包装类型列表，这样能最大程度保证自动类型推测函数能返回继承链最长的包装类型
  static void sortClassDesc() {
    _globalLibraryList.sort((a, b) {
      final ai = libraryBaseList.indexOf(a);
      final bi = libraryBaseList.indexOf(b);
      if (ai >= 0 && bi >= 0) return ai < bi ? -1 : 1;
      if (ai < 0 && bi >= 0) return -1;
      if (ai >= 0 && bi < 0) return 1;
      if (a.superclassNames.length != b.superclassNames.length) {
        return a.superclassNames.length > b.superclassNames.length ? -1 : 1;
      }
      return a.externalProxyMap!.length > b.externalProxyMap!.length ? -1 : 1;
    });
  }

  ///加速类型推测的函数
  static String? Function(dynamic instance)? quickTypeSpeculationMethod;

  ///很慢的类型推测报告
  static void Function(dynamic instance, VmClass vmclass, int cycles, int total)? slowTypeSpeculationReport;

  ///从当前的运行器中搜索内部定义类型的回调函数
  static VmClass? Function(String typeName)? _internalClassSearchRunner;

  ///注册当前运行器中搜索内部定义类型的回调函数
  static void registerInternalClassSearchRunner(VmClass? Function(String typeName) searchRunner) {
    if (_internalClassSearchRunner != null) throw ('There can only be one _internalClassSearchRunner at a time, please shutdown the previous VmRunner first.');
    _internalClassSearchRunner = searchRunner;
  }

  ///释放当前运行器中搜索内部定义类型的回调函数
  static void shutdownInternalClassSearchRunner() {
    _internalClassSearchRunner = null;
  }

  ///获取指定名称[typeName]对应的包装类型
  static VmClass _getClassByTypeName(String typeName) {
    VmClass? vmclass;
    //先通过类型名从运行时应用库中搜索
    vmclass = _internalClassSearchRunner == null ? null : _internalClassSearchRunner!(typeName);
    if (vmclass != null) return vmclass;
    //然后通过类型名在全局缓存库中搜索
    vmclass = _globalLibraryMap[typeName];
    if (vmclass != null) return vmclass;
    throw ('Not found VmClass: $typeName');
  }

  ///获取任意实例[instance]对应的包装类型，分析本文件可知[instance]必然不是[VmObject]的子类
  static VmClass _getClassByInstance(dynamic instance) {
    String? typeName = instance.runtimeType.toString().split('<').first.replaceAll('_', ''); //去掉模板参数，去掉私有符号
    VmClass? vmclass;
    //先通过类型名从运行时应用库中搜索
    vmclass = _internalClassSearchRunner == null ? null : _internalClassSearchRunner!(typeName);
    if (vmclass != null) return vmclass;
    //然后通过类型名在全局缓存库中搜索
    vmclass = _globalLibraryMap[typeName];
    if (vmclass != null) return vmclass;
    //再使用加速推测方案进行匹配
    if (instance is List) {
      typeName = 'List';
    } else if (instance is Set) {
      typeName = 'Set';
    } else if (instance is Map) {
      typeName = 'Map';
    } else if (instance is Iterable) {
      typeName = 'Iterable';
    } else if (instance is Iterator) {
      typeName = 'Iterator';
    } else if (instance is Function) {
      typeName = 'Function'; //for any Function
    } else if (instance is Exception) {
      typeName = 'Exception'; //for VmException
    } else if (instance is Type) {
      typeName = 'Type'; //for VmType
    } else if (quickTypeSpeculationMethod != null) {
      typeName = quickTypeSpeculationMethod!(instance);
    } else {
      typeName = null;
    }
    if (typeName != null) {
      vmclass = _globalLibraryMap[typeName];
      if (vmclass != null) return vmclass;
    }
    //最后使用实例进行遍历匹配，这个可能会慢的一批
    for (var i = 0; i < _globalLibraryList.length; i++) {
      vmclass = _globalLibraryList[i];
      if (vmclass.isThisType(instance)) {
        if (i > 10 && slowTypeSpeculationReport != null) {
          slowTypeSpeculationReport!(instance, vmclass, i + 1, _globalLibraryList.length); //超过10次循环则认为这个instance的类型推断很慢
        }
        return vmclass;
      }
    }
    throw ('Not found VmClass: ${instance.runtimeType}');
  }
}

///
///运行时字段代理类
///
class VmProxy<T> extends VmObject {
  ///是否为外部导入类型
  final bool isExternal;

  ///外部导入类型的静态属性读取方法
  final dynamic Function()? externalStaticPropertyReader;

  ///外部导入类型的静态属性写入方法
  final dynamic Function(dynamic value)? externalStaticPropertyWriter;

  ///外部导入类型的静态函数调用方法
  final Function? externalStaticFunctionCaller;

  ///外部导入类型的实例属性读取方法
  final dynamic Function(T instance)? externalInstancePropertyReader;

  ///外部导入类型的实例属性写入方法
  final dynamic Function(T instance, dynamic value)? externalInstancePropertyWriter;

  ///外部导入类型的实例函数调用方法
  final Function? externalInstanceFunctionCaller;

  ///内部定义类型的静态属性操作对象
  final VmValue? internalStaticPropertyOperator;

  ///被代理的类型
  VmClass _vmclass;

  VmProxy({
    required super.identifier,
    this.isExternal = true,
    this.externalStaticPropertyReader,
    this.externalStaticPropertyWriter,
    this.externalStaticFunctionCaller,
    this.externalInstancePropertyReader,
    this.externalInstancePropertyWriter,
    this.externalInstanceFunctionCaller,
    this.internalStaticPropertyOperator,
  }) : _vmclass = VmClass.baseClassVoid;

  ///绑定类型
  dynamic bindVmClass(VmClass vmclass) => _vmclass = vmclass;

  ///执行函数
  dynamic runFunction(dynamic instance, List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments) {
    if (instance == this || instance == _vmclass) {
      //执行静态函数
      if (isExternal) {
        final listArgumentsNative = positionalArguments?.map((e) => VmObject.readValue(e)).toList();
        final nameArgumentsNative = namedArguments?.map((key, value) => MapEntry(key, VmObject.readValue(value)));
        if (externalStaticFunctionCaller != null) return Function.apply(externalStaticFunctionCaller!, listArgumentsNative, nameArgumentsNative);
        if (externalStaticPropertyReader != null) return Function.apply(externalStaticPropertyReader!(), listArgumentsNative, nameArgumentsNative);
        throw ('Not found externalStaticFunctionCaller and externalStaticPropertyReader: ${_vmclass.identifier}.$identifier');
      } else {
        return (internalStaticPropertyOperator as VmValue).runFunction(positionalArguments, namedArguments);
      }
    } else {
      //执行实例函数
      if (isExternal) {
        final instanceNative = VmObject.readValue(instance);
        final listArgumentsNative = positionalArguments?.map((e) => VmObject.readValue(e)).toList();
        final nameArgumentsNative = namedArguments?.map((key, value) => MapEntry(key, VmObject.readValue(value)));
        if (externalInstanceFunctionCaller != null) return Function.apply(externalInstanceFunctionCaller!, [instanceNative, ...(listArgumentsNative ?? const [])], nameArgumentsNative);
        if (externalInstancePropertyReader != null) return Function.apply(externalInstancePropertyReader!(instanceNative), listArgumentsNative, nameArgumentsNative);
        throw ('Not found externalInstanceFunctionCaller and externalInstancePropertyReader: ${_vmclass.identifier}.$identifier');
      } else {
        return (VmObject.readLogic(instance) as VmValue).getProperty(identifier).runFunction(positionalArguments, namedArguments);
      }
    }
  }

  ///读取属性
  dynamic getProperty(dynamic instance) {
    if (instance == this || instance == _vmclass) {
      //读取静态属性
      if (isExternal) {
        if (externalStaticPropertyReader != null) return externalStaticPropertyReader!();
        throw ('Not found externalStaticPropertyReader: ${_vmclass.identifier}.$identifier');
      } else {
        return (internalStaticPropertyOperator as VmValue).getLogic(); //注意：为了保证能够逻辑处理，此处使用的是逻辑值
      }
    } else {
      //读取实例属性
      if (isExternal) {
        final instanceNative = VmObject.readValue(instance);
        if (externalInstancePropertyReader != null) return externalInstancePropertyReader!(instanceNative);
        throw ('Not found externalInstancePropertyReader: ${_vmclass.identifier}.$identifier');
      } else {
        return (VmObject.readLogic(instance) as VmValue).getProperty(identifier).getLogic(); //注意：为了保证能够逻辑处理，此处使用的是逻辑值
      }
    }
  }

  ///写入属性
  dynamic setProperty(dynamic instance, dynamic value) {
    if (instance == this || instance == _vmclass) {
      //写入静态属性
      if (isExternal) {
        final valueNative = VmObject.readValue(value);
        if (externalStaticPropertyWriter != null) return externalStaticPropertyWriter!(valueNative);
        throw ('Not found externalStaticPropertyWriter: ${_vmclass.identifier}.$identifier');
      } else {
        return (internalStaticPropertyOperator as VmValue).setValue(value);
      }
    } else {
      //写入实例属性
      if (isExternal) {
        final instanceNative = VmObject.readValue(instance);
        final valueNative = VmObject.readValue(value);
        if (externalInstancePropertyWriter != null) return externalInstancePropertyWriter!(instanceNative, valueNative);
        throw ('Not found externalInstancePropertyWriter: ${_vmclass.identifier}.$identifier');
      } else {
        return (VmObject.readLogic(instance) as VmValue).getProperty(identifier).setValue(value);
      }
    }
  }

  ///是否为外部导入类型的实例代理
  bool get isExternalInstanceProxy => externalInstancePropertyReader != null || externalInstancePropertyWriter != null || externalInstanceFunctionCaller != null;

  @override
  VmClass getClass() => VmObject.readClass(getProperty(this));

  @override
  dynamic getLogic() => this; //注意：此处返回自身，用于逻辑调用

  @override
  dynamic getValue() => getProperty(this);

  @override
  dynamic setValue(value) => throw UnimplementedError();

  @override
  String toString() => 'VmProxy<$T> ===> $identifier';

  @override
  Map<String, dynamic> toJson() {
    final map = {
      'toString': toString(),
      'identifier': identifier,
      'isExternal': isExternal,
    };
    if (externalStaticPropertyReader != null) map['externalStaticPropertyReader'] = true;
    if (externalStaticPropertyWriter != null) map['externalStaticPropertyWriter'] = true;
    if (externalStaticFunctionCaller != null) map['externalStaticFunctionCaller'] = true;
    if (externalInstancePropertyReader != null) map['externalInstancePropertyReader'] = true;
    if (externalInstancePropertyWriter != null) map['externalInstancePropertyWriter'] = true;
    if (externalInstanceFunctionCaller != null) map['externalInstanceFunctionCaller'] = true;
    if (internalStaticPropertyOperator != null) map['internalStaticPropertyOperator'] = internalStaticPropertyOperator.toString();
    return map;
  }
}

///
///运行时实例包装类
///
class VmValue extends VmObject {
  ///元类型
  final VmMetaType metaType;

  ///元数据
  final VmMetaData metaData;

  ///值类型
  VmClass _valueType;

  ///值数据
  dynamic _valueData;

  ///类静态作用域
  VmClass? _staticScope;

  ///超实例作用域
  VmValue? _instanceScope;

  ///匿名作用域列表
  List<Map<String, VmObject>>? _anonymousScopeList;

  VmValue._({
    required super.identifier,
    required this.metaType,
    required this.metaData,
    required VmClass valueType,
    required dynamic valueData,
  })  : _valueType = valueType,
        _valueData = valueData {
    if (metaType == VmMetaType.internalApply) {
      switch (metaData.listArguments.length) {
        case 0:
          _valueData = () => runFunction([], null);
          break;
        case 1:
          _valueData = (a) => runFunction([a], null);
          break;
        case 2:
          _valueData = (a, b) => runFunction([a, b], null);
          break;
        case 3:
          _valueData = (a, b, c) => runFunction([a, b, c], null);
          break;
        case 4:
          _valueData = (a, b, c, d) => runFunction([a, b, c, d], null);
          break;
        case 5:
          _valueData = (a, b, c, d, e) => runFunction([a, b, c, d, e], null);
          break;
        case 6:
          _valueData = (a, b, c, d, e, f) => runFunction([a, b, c, d, e, f], null);
          break;
        case 7:
          _valueData = (a, b, c, d, e, f, g) => runFunction([a, b, c, d, e, f, g], null);
          break;
        case 8:
          _valueData = (a, b, c, d, e, f, g, h) => runFunction([a, b, c, d, e, f, g, h], null);
          break;
        case 9:
          _valueData = (a, b, c, d, e, f, g, h, i) => runFunction([a, b, c, d, e, f, g, h, i], null);
          break;
        default:
          throw ('Unsupport template: $identifier ${metaData.listArguments.length}');
      }
    }
  }

  ///创建变量值
  factory VmValue.forVariable({
    String identifier = '___anonymousVmVariable___',
    String? initType,
    dynamic initValue,
  }) {
    final realLogic = VmObject.readLogic(initValue, type: initType);
    if (realLogic is VmValue) {
      late VmMetaType metaType;
      if (VmClass.smartTypeNames.contains(initType)) {
        metaType = VmMetaType.externalSmart;
      } else {
        metaType = VmMetaType.internalAlias;
      }
      return VmValue._(
        identifier: identifier,
        metaType: metaType,
        metaData: const VmMetaData(),
        valueType: realLogic._valueType,
        valueData: realLogic,
      );
    } else {
      final realClass = VmObject.readClass(initValue, type: initType);
      final realValue = VmObject.readValue(initValue, type: initType);
      late VmMetaType metaType;
      if (VmClass.smartTypeNames.contains(realClass.identifier)) {
        metaType = VmMetaType.externalSmart;
      } else if (realClass.isExternal) {
        metaType = VmMetaType.externalValue;
      } else if (realValue == null) {
        metaType = VmMetaType.internalAlias;
      } else {
        metaType = VmMetaType.internalValue;
      }
      return VmValue._(
        identifier: identifier,
        metaType: metaType,
        metaData: const VmMetaData(),
        valueType: realClass,
        valueData: realValue,
      );
    }
  }

  ///创建函数值
  factory VmValue.forFunction({
    String identifier = '___anonymousVmFunction___',
    bool? isIniter,
    bool? isStatic,
    bool? isGetter,
    bool? isSetter,
    List<VmHelper>? listArguments,
    List<VmHelper>? nameArguments,
    List<Map<VmKeys, dynamic>?>? initTree,
    Map<VmKeys, dynamic>? bodyTree,
    required dynamic Function(List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments, VmClass staticScope, List<Map<VmKeys, dynamic>>? instanceFields, VmValue method) staticListener,
    required dynamic Function(List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments, VmClass? staticScope, VmValue? instanceScope, VmValue method) instanceListener,
  }) {
    return VmValue._(
      identifier: identifier,
      metaType: VmMetaType.internalApply,
      metaData: VmMetaData(
        isIniter: isIniter ?? false,
        isStatic: isStatic ?? false,
        isGetter: isGetter ?? false,
        isSetter: isSetter ?? false,
        listArguments: listArguments ?? const [],
        nameArguments: nameArguments ?? const [],
        initTree: initTree ?? const [],
        bodyTree: bodyTree ?? const {},
        staticListener: staticListener,
        instanceListener: instanceListener,
      ),
      valueType: VmClass._getClassByTypeName(VmClass.functionTypeName),
      valueData: null,
    );
  }

  ///创建子代理
  factory VmValue.forSubproxy({
    String identifier = '___anonymousVmSubproxy___',
    required VmLazyer Function() initValue,
  }) {
    return VmValue._(
      identifier: identifier,
      metaType: VmMetaType.externalSuper,
      metaData: const VmMetaData(),
      valueType: VmClass._getClassByTypeName(VmClass.functionTypeName),
      valueData: initValue,
    );
  }

  ///作为内部定义类型的实例来获取实例字段集合列表，包括超类与子类定义的全部字段
  List<Map<String, VmValue>> get internalInstancePropertyMapList {
    final target = _valueData;
    if (target is VmValue) {
      return target.internalInstancePropertyMapList;
    } else {
      return (target as VmSuper)._propertyMapList;
    }
  }

  ///作为内部定义的匿名函数来读取匿名作用域列表
  List<Map<String, VmObject>>? get functionAnonymousScopeList {
    final target = _valueData;
    if (target is VmValue) {
      return target.functionAnonymousScopeList;
    } else {
      return _anonymousScopeList;
    }
  }

  ///作为内部定义类型的静态成员或实例来绑定静态作用域
  void bindStaticScope(VmClass staticScope) {
    final target = _valueData;
    if (target is VmValue) {
      target.bindStaticScope(staticScope);
    } else {
      _staticScope ??= staticScope;
    }
  }

  ///作为内部定义类型的实例来绑定实例成员的相关作用域，注意：在调用前需要先调用[bindStaticScope]绑定静态作用域
  void bindMemberScope() {
    final target = _valueData;
    if (target is VmValue) {
      target.bindMemberScope();
    } else {
      if (_staticScope == null) throw ('Please call bindStaticScope before calling bindMemberScope: $identifier');
      //遍历子类字段来绑定作用域
      (target as VmSuper)._childPropertyMap.forEach((key, value) {
        value._staticScope ??= _staticScope;
        value._instanceScope ??= this;
      });
    }
  }

  ///作为内部定义的匿名函数来绑定匿名作用域列表，注意：匿名函数与其作用域列表一般是用于外部类库的回调
  void bindAnonymousScopeList(List<Map<String, VmObject>>? scopeList) {
    final target = _valueData;
    if (target is VmValue) {
      target.bindAnonymousScopeList(scopeList);
    } else {
      _anonymousScopeList ??= scopeList;
    }
  }

  ///作为内部定义类型的实例来读取字段
  VmValue getProperty(String propertyName) {
    final target = _valueData;
    if (target is VmValue) {
      return target.getProperty(propertyName);
    } else {
      return (target as VmSuper).getProperty(propertyName);
    }
  }

  ///作为任意的函数来直接执行
  dynamic runFunction(List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments) {
    final target = _valueData;
    if (target is VmValue) {
      return target.runFunction(positionalArguments, namedArguments);
    } else {
      if (metaType == VmMetaType.externalSuper) {
        final listArgumentsNative = positionalArguments?.map((e) => VmObject.readValue(e)).toList();
        final nameArgumentsNative = namedArguments?.map((key, value) => MapEntry(key, VmObject.readValue(value)));
        final targeLayzer = target() as VmLazyer;
        return Function.apply(targeLayzer.getValue(), listArgumentsNative, nameArgumentsNative);
      } else if (metaType == VmMetaType.internalApply) {
        if (metaData.isIniter) {
          return metaData.staticListener!(positionalArguments, namedArguments, _staticScope!, _staticScope!.internalInstanceFieldTree, this); //非factory构造函数
        } else if (metaData.isStatic) {
          return metaData.staticListener!(positionalArguments, namedArguments, _staticScope!, null, this); //普通静态函数
        } else {
          return metaData.instanceListener!(positionalArguments, namedArguments, _staticScope, _instanceScope, this); //普通定义函数、匿名定义函数、实例成员函数
        }
      } else {
        final listArgumentsNative = positionalArguments?.map((e) => VmObject.readValue(e)).toList();
        final nameArgumentsNative = namedArguments?.map((key, value) => MapEntry(key, VmObject.readValue(value)));
        return Function.apply(target, listArgumentsNative, nameArgumentsNative);
      }
    }
  }

  ///构建内部定义类型[vmclass]的实例的初始化值
  VmSuper prepareForConstructor(List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments, VmClass vmclass) {
    final target = _valueData;
    if (target is VmValue) {
      return target.prepareForConstructor(positionalArguments, namedArguments, vmclass);
    } else {
      final superclass = vmclass._internalSuperclass!; //必然存在，无需判断
      if (superclass.identifier == VmClass.objectTypeName) {
        final instance = VmInstance(); //默认继承Object类型的使用VmInstance创建实例
        return instance.._initProperties(superclass); //创建超类的字段代理
      } else {
        final listResult = <dynamic>[];
        final nameResult = <Symbol, dynamic>{};
        positionalArguments ??= const [];
        namedArguments ??= const {};
        //匹配列表参数
        for (var i = 0; i < metaData.listArguments.length; i++) {
          final field = metaData.listArguments[i];
          final value = i < positionalArguments.length ? positionalArguments[i] : field.fieldValue; //列表参数按照索引一一对应即可
          if (field.isSuperField) {
            listResult.add(value);
          }
        }
        //匹配命名参数
        for (var i = 0; i < metaData.nameArguments.length; i++) {
          final field = metaData.nameArguments[i];
          final fieldKey = Symbol(field.fieldName);
          final value = namedArguments.containsKey(fieldKey) ? namedArguments[fieldKey] : field.fieldValue; //命名参数按照字段名称进行匹配
          if (field.isSuperField) {
            nameResult[fieldKey] = value;
          }
        }
        final instance = superclass.getProxy(VmClass.newMethodName, setter: false).runFunction(superclass, listResult, nameResult) as VmSuper; //创建对应的超类的实例
        return instance.._initProperties(superclass); //创建超类的字段代理
      }
    }
  }

  ///准备执行该函数所需的参数列表，[buildTarget]是被该函数初始化的构建目标实例
  List<VmObject> prepareForInvocation(List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments, VmValue? buildTarget) {
    final target = _valueData;
    if (target is VmValue) {
      return target.prepareForInvocation(positionalArguments, namedArguments, buildTarget);
    } else {
      final result = <VmObject>[];
      positionalArguments ??= const [];
      namedArguments ??= const {};
      //匹配列表参数
      for (var i = 0; i < metaData.listArguments.length; i++) {
        final field = metaData.listArguments[i];
        final value = i < positionalArguments.length ? positionalArguments[i] : field.fieldValue; //列表参数按照索引一一对应即可
        if (field.isSuperField) {
          //已在超类作用域中添加，直接忽略
        } else if (field.isClassField) {
          buildTarget!.getProperty(field.fieldName).setValue(value);
        } else {
          result.add(VmValue.forVariable(identifier: field.fieldName, initType: field.fieldType, initValue: value));
        }
      }
      //匹配命名参数
      for (var i = 0; i < metaData.nameArguments.length; i++) {
        final field = metaData.nameArguments[i];
        final fieldKey = Symbol(field.fieldName);
        final value = namedArguments.containsKey(fieldKey) ? namedArguments[fieldKey] : field.fieldValue; //命名参数按照字段名称进行匹配
        if (field.isSuperField) {
          //已在超类作用域中添加，直接忽略
        } else if (field.isClassField) {
          buildTarget!.getProperty(field.fieldName).setValue(value);
        } else {
          result.add(VmValue.forVariable(identifier: field.fieldName, initType: field.fieldType, initValue: value));
        }
      }
      return result;
    }
  }

  @override
  VmClass getClass() {
    final target = _valueData;
    if (target is VmValue) {
      return target.getClass();
    } else {
      if (metaType == VmMetaType.externalSuper) {
        final targeLayzer = target() as VmLazyer;
        return targeLayzer.getClass();
      } else {
        return _valueType;
      }
    }
  }

  @override
  dynamic getLogic() {
    final target = _valueData;
    if (target is VmValue) {
      return target.getLogic();
    } else {
      if (metaType == VmMetaType.externalSuper) {
        final targeLayzer = target() as VmLazyer;
        return targeLayzer.getLogic();
      } else if (metaType == VmMetaType.internalValue) {
        return this; //注意：此处返回自身，用于逻辑调用
      } else if (metaType == VmMetaType.internalApply) {
        if (metaData.isGetter) return VmObject.readLogic(runFunction(null, null));
        return this; //注意：此处返回自身，用于逻辑调用
      } else {
        return target; //数据原生值
      }
    }
  }

  @override
  dynamic getValue() {
    final target = _valueData;
    if (target is VmValue) {
      return target.getValue();
    } else {
      if (metaType == VmMetaType.externalSuper) {
        final targeLayzer = target() as VmLazyer;
        return targeLayzer.getValue(); //读取超类值
      } else if (metaType == VmMetaType.internalValue) {
        return target; //VmSuper值
      } else if (metaType == VmMetaType.internalApply) {
        if (metaData.isGetter) return VmObject.readValue(runFunction(null, null));
        return target; //函数模板值
      } else {
        return target; //数据原生值
      }
    }
  }

  @override
  dynamic setValue(value) {
    switch (metaType) {
      case VmMetaType.externalValue:
        return _valueData = VmObject.readValue(value, type: _valueType.identifier); //保存原生值
      case VmMetaType.externalSmart:
        //与VmValue.forVariable的处理流程是一致的
        final realLogic = VmObject.readLogic(value);
        if (realLogic is VmValue) {
          _valueType = realLogic._valueType;
          return _valueData = realLogic;
        } else {
          final realClass = VmObject.readClass(value);
          final realValue = VmObject.readValue(value);
          _valueType = realClass;
          return _valueData = realValue;
        }
      case VmMetaType.externalSuper:
        final targeLayzer = _valueData() as VmLazyer;
        return targeLayzer.setValue(VmObject.readValue(value)); //保存超类值
      case VmMetaType.internalValue:
        throw ('Unsuppport setValue operator for internalValue: $identifier');
      case VmMetaType.internalApply:
        if (metaData.isSetter) return runFunction([value], null);
        throw ('Unsuppport setValue operator for internalApply: $identifier');
      case VmMetaType.internalAlias:
        return _valueData = VmObject.readLogic(value, type: _valueType.identifier); //保存逻辑值
    }
  }

  @override
  String toString() {
    switch (metaType) {
      case VmMetaType.externalValue:
        return 'VmValue<externalValue> ===> ${_valueType.identifier} $identifier --> ${_valueData.runtimeType} $_valueData';
      case VmMetaType.externalSmart:
        if (_valueData is VmValue) {
          return 'VmValue<externalSmart> ===> ${_valueType.identifier} $identifier #smart{ $_valueData }';
        } else {
          return 'VmValue<externalSmart> ===> ${_valueType.identifier} $identifier --> ${_valueData.runtimeType} $_valueData';
        }
      case VmMetaType.externalSuper:
        return 'VmValue<externalSuper> ===> ${_valueType.identifier} $identifier #super{ $_valueData }';
      case VmMetaType.internalApply:
        final typeArg1 = metaData.isIniter ? 'initer' : (metaData.isStatic ? 'static' : 'normal');
        final typeArg2 = metaData.isGetter ? 'getter' : (metaData.isSetter ? 'setter' : 'normal');
        final listArgs = '[${metaData.listArguments.map((e) => '${e.isClassField ? 'this.' : (e.isSuperField ? 'super.' : '')}${e.fieldName}${e.fieldValue == null ? '' : ' = ${e.getValue()}'}').join(', ')}]';
        final nameArgs = '{${metaData.nameArguments.map((e) => '${e.isClassField ? 'this.' : (e.isSuperField ? 'super.' : '')}${e.fieldName}${e.fieldValue == null ? '' : ' = ${e.getValue()}'}').join(', ')}}';
        return 'VmValue<internalApply> ===> ${_valueType.identifier} $identifier --> $typeArg1 $typeArg2 $listArgs $nameArgs';
      case VmMetaType.internalValue:
        return 'VmValue<internalValue> ===> ${_valueType.identifier} $identifier --> ${_valueData.runtimeType} $_valueData';
      case VmMetaType.internalAlias:
        return 'VmValue<internalAlias> ===> ${_valueType.identifier} $identifier #alias{ $_valueData }';
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'toString': toString(),
      'identifier': identifier,
      'metaType': metaType.toString(),
      'metaData': metaType == VmMetaType.internalApply
          ? {
              'isIniter': metaData.isIniter,
              'isStatic': metaData.isStatic,
              'isGetter': metaData.isGetter,
              'isSetter': metaData.isSetter,
              'listArguments': '[${metaData.listArguments.map((e) => '${e.isClassField ? 'this.' : (e.isSuperField ? 'super.' : '')}${e.fieldName}${e.fieldValue == null ? '' : ' = ${e.getValue()}'}').join(', ')}]',
              'nameArguments': '{${metaData.nameArguments.map((e) => '${e.isClassField ? 'this.' : (e.isSuperField ? 'super.' : '')}${e.fieldName}${e.fieldValue == null ? '' : ' = ${e.getValue()}'}').join(', ')}}',
              'initTree': metaData.initTree.map((e) => e?.keys.map((e) => e.toString()).toList()).toList(),
              'bodyTree': metaData.bodyTree.keys.map((e) => e.toString()).toList(),
              'staticListener': metaData.staticListener != null,
              'instanceListener': metaData.instanceListener != null,
            }
          : metaData.toString(),
    };
    map['_valueType'] = _valueType.toString();
    map['_valueData'] = _valueData is VmValue ? _valueData : _valueData?.toString();
    if (_staticScope != null) map['_staticScope'] = _staticScope?.toString();
    if (_staticScope != null) map['_instanceScope'] = _instanceScope?.toString();
    return map;
  }
}

///
///运行时延迟操作类
///
class VmLazyer extends VmObject {
  ///是否为方法调用
  final bool isMethod;

  ///是否为索引表达式
  final bool isIndexed;

  ///延迟操作的目标
  final dynamic instance;

  ///延迟操作的属性，类型大概是 int 或 String
  final dynamic property;

  ///构造时是否是通过[property]找到的[instance]
  final bool instanceByProperty;

  ///方法调用的列表参数
  final List<dynamic>? listArguments;

  ///方法调用的命名参数
  final Map<Symbol, dynamic>? nameArguments;

  ///是否已完成延迟操作
  bool _completed;

  ///完成延迟操作的结果
  dynamic _result;

  VmLazyer({
    this.isMethod = false,
    this.isIndexed = false,
    required dynamic instance,
    required dynamic property,
    this.instanceByProperty = false,
    this.listArguments,
    this.nameArguments,
  })  : instance = VmObject.readLogic(instance),
        property = VmObject.readValue(property),
        _completed = false,
        super(identifier: '___anonymousVmLazyer___');

  @override
  VmClass getClass() => VmObject.readClass(getLogic());

  @override
  dynamic getLogic() {
    if (_completed) return _result;
    final target = instance;
    if (isMethod) {
      if (target is VmClass && instanceByProperty) {
        _result = target.getProxy(VmClass.newMethodName, setter: false).runFunction(target, listArguments, nameArguments); //执行构造函数new
      } else if (target is VmProxy && instanceByProperty) {
        _result = target.runFunction(target, listArguments, nameArguments); //执行顶级函数
      } else if (target is VmValue && instanceByProperty) {
        _result = target.runFunction(listArguments, nameArguments); //执行内部函数
      } else if (target is Function && instanceByProperty) {
        final listArgumentsNative = listArguments?.map((e) => VmObject.readValue(e)).toList();
        final nameArgumentsNative = nameArguments?.map((key, value) => MapEntry(key, VmObject.readValue(value)));
        return Function.apply(target, listArgumentsNative, nameArgumentsNative); //执行外部函数
      } else if (target is VmClass) {
        _result = target.getProxy(property, setter: false).runFunction(target, listArguments, nameArguments); //执行静态函数
      } else {
        _result = validateNull ? VmObject.readClass(target).getProxy(property, setter: false).runFunction(target, listArguments, nameArguments) : null; //执行实例函数
      }
    } else if (isIndexed) {
      _result = target[property]; //索引List取值
    } else if (target is VmClass) {
      _result = target.getProxy(property, setter: false).getProperty(target); //读取静态属性
    } else {
      _result = validateNull ? VmObject.readClass(target).getProxy(property, setter: false).getProperty(target) : null; //读取实例属性
    }
    _completed = true;
    return _result;
  }

  @override
  dynamic getValue() => VmObject.readValue(getLogic());

  @override
  dynamic setValue(value) {
    final target = instance;
    if (isMethod) {
      throw ('Unsupport setValue operator for VmLazyer: isMethod = true');
    } else if (isIndexed) {
      return target[property] = value; //索引List赋值
    } else if (target is VmClass) {
      return target.getProxy(property, setter: true).setProperty(target, value); //写入静态属性
    } else {
      return validateNull ? VmObject.readClass(target).getProxy(property, setter: true).setProperty(target, value) : null; //写入实例属性
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'toString': toString(),
      'identifier': identifier,
      'isMethod': isMethod,
      'instance': instance?.toString(),
      'property': property,
      'instanceByProperty': instanceByProperty,
      'listArguments': listArguments?.length,
      'nameArguments': nameArguments?.length,
      '_completed': _completed,
      '_result': _result?.toString(),
    };
    return map;
  }

  ///对null值进行检测，用于 xxx?.xxx 的调用
  bool get validateNull => instance != null || VmObject.readClass(instance).hasProxy(property, setter: true); //setter的值不重要
}

///
///运行时声明辅助类
///
class VmHelper extends VmObject {
  ///声明时明确指定的类型如：int、double、bool等
  final String? fieldType;

  ///声明的字段名称
  final String fieldName;

  ///声明的字段默认值
  final dynamic fieldValue;

  ///声明的字段是否为命名参数
  final bool isNamedField;

  ///声明的字段是否为类字段参数
  final bool isClassField;

  ///声明的字段是否为超类的字段
  final bool isSuperField;

  VmHelper({
    this.fieldType,
    String? fieldName,
    dynamic fieldValue,
    this.isNamedField = false,
    this.isClassField = false,
    this.isSuperField = false,
  })  : fieldName = fieldName ?? '___anonymousVmField___',
        fieldValue = VmObject.readLogic(fieldValue),
        super(identifier: '___anonymousVmHelper___');

  @override
  VmClass getClass() => VmObject.readClass(fieldValue, type: fieldType);

  @override
  dynamic getLogic() => VmObject.readLogic(fieldValue, type: fieldType);

  @override
  dynamic getValue() => VmObject.readValue(fieldValue, type: fieldType);

  @override
  dynamic setValue(value) => throw UnimplementedError();

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'toString': toString(),
      'identifier': identifier,
      'fieldType': fieldType,
      'fieldName': fieldName,
      'fieldValue': fieldValue?.toString(),
      'isNamedField': isNamedField,
      'isClassField': isClassField,
      'isSuperField': isSuperField,
    };
    return map;
  }
}

///
///运行时信号标识类
///
class VmSignal extends VmObject {
  ///是否为break信号
  final bool isBreak;

  ///是否为return信号
  final bool isReturn;

  ///是否为continue信号
  final bool isContinue;

  ///附带值如：函数返回值等
  final dynamic signalValue;

  ///是否为中断语句信号
  bool get isInterrupt => isBreak || isReturn;

  VmSignal({
    this.isBreak = false,
    this.isReturn = false,
    this.isContinue = false,
    dynamic signalValue,
  })  : signalValue = VmObject.readLogic(signalValue),
        super(identifier: '___anonymousVmSignal___');

  @override
  VmClass getClass() => VmObject.readClass(signalValue);

  @override
  dynamic getLogic() => VmObject.readLogic(signalValue);

  @override
  dynamic getValue() => VmObject.readValue(signalValue);

  @override
  dynamic setValue(value) => throw UnimplementedError();

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'toString': toString(),
      'identifier': identifier,
      'isBreak': isBreak,
      'isReturn': isReturn,
      'isContinue': isContinue,
      'signalValue': signalValue?.toString(),
    };
    return map;
  }
}

///
///运行时异常信息类
///
class VmException implements Exception {
  ///代码片段格式化器
  static final _formatter = DartFormatter(indent: 8, pageWidth: 500);

  ///异常的初始错误对象
  final Object originError;

  ///异常的初始错误对象
  final StackTrace originStack;

  ///异常的全部源代码栈
  final List<String> sourceStack;

  ///是否有完整的源代码
  bool isCompilationUnit;

  VmException(this.originError, this.originStack, String sourceCode, this.isCompilationUnit) : sourceStack = [sourceCode];

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln(originError);
    buffer.writeln('');
    buffer.writeln('####### Exception source code:');
    try {
      buffer.writeln(isCompilationUnit ? _formatter.format(sourceStack.first) : _formatter.formatStatement(sourceStack.first));
    } catch (_) {
      buffer.writeln(sourceStack.first);
    }
    buffer.writeln('####### Completed source code:');
    try {
      buffer.writeln(isCompilationUnit ? _formatter.format(sourceStack.last) : _formatter.formatStatement(sourceStack.last));
    } catch (_) {
      buffer.writeln(sourceStack.last);
    }
    buffer.writeln(originStack);
    return buffer.toString();
  }
}

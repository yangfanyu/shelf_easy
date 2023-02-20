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
///数据值的元类型
///
enum VmMetaType {
  ///外部普通类型的对象
  externalObject,

  ///外部动态类型的对象
  externalSmarts,

  ///内部定义方法的对象
  internalMethod,

  ///内部定义类型的对象
  internalObject,

  ///内部定义对象的别名，即[internalMethod]与[internalObject]元类型的数据值的别名
  internalByname,
}

///
///数据值的元数据
///
class VmMetaData {
  ///作为内部定义方法时声明为: constructor，排除 factory 方法
  final bool isIniter;

  ///作为内部定义方法时声明为: static，包括 factory 方法
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

  ///读取[target]的对应包装类
  static VmClass readClass(dynamic target, {String? type}) {
    if (type == null) {
      return target is VmObject ? target.getClass() : VmClass.getClassByInstance(target);
    } else {
      return VmClass.getClassByTypeName(type);
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
        return value;
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

  ///读取[target]的原生数据值，使用递归深度转换。
  static dynamic deepValue(dynamic target) {
    if (target is List) {
      return target.map((e) => deepValue(e)).toList();
    } else if (target is Set) {
      return target.map((e) => deepValue(e)).toSet();
    } else if (target is Map) {
      return target.map((key, value) => MapEntry(deepValue(key), deepValue(value)));
    } else if (target is VmObject) {
      return target.getValue();
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
        if (item is VmHelper) {
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

  ///外部导入类型的字段代理集合
  final Map<String, VmProxy<T>>? externalProxyMap;

  ///内部定义类型的字段代理集合
  final Map<String, VmProxy<T>>? internalProxyMap;

  ///内部定义类型的静态字段的已初始化集合，在相关调用时会将该集合放到作用域栈中
  final Map<String, VmValue>? internalStaticPropertyMap;

  ///内部定义类型的实例字段的初始化树列表，初始化树采用列表可保证初始化顺序不变
  final List<Map<VmKeys, dynamic>>? internalInstanceFieldTree;

  VmClass({
    required super.identifier,
    this.isExternal = true,
    this.externalProxyMap,
    this.internalProxyMap,
    this.internalStaticPropertyMap,
    this.internalInstanceFieldTree,
  }) : vmwareType = VmType(name: identifier) {
    //给代理集合绑定包装类型
    externalProxyMap?.forEach((key, value) => value.bindVmClass(this));
    internalProxyMap?.forEach((key, value) => value.bindVmClass(this));
    //给类静态成员绑定作用域
    internalStaticPropertyMap?.forEach((key, value) => value.bindStaticScope(this));
  }

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

  ///将实例转换为该包装类型的实例，实质上是做类型检查
  T asThisType(dynamic instance) {
    if (isThisType(instance)) return instance;
    throw ('Instance type: ${instance.runtimeType} => Not matched class type: $identifier');
  }

  ///获取指定字段的代理，[setter]为true表示这是为设置属性而获取的代理，由于set函数在字段的末尾添加了等于符号，所以将优先查找'propertyName='这样的函数
  VmProxy<T> getProxy(String propertyName, {required bool setter}) {
    if (setter) {
      final setterPropName = '$propertyName=';
      final proxy = isExternal ? (externalProxyMap?[setterPropName] ?? externalProxyMap?[propertyName]) : (internalProxyMap?[setterPropName] ?? internalProxyMap?[propertyName]);
      if (proxy == null) throw ('Not found proxy: $identifier.$propertyName');
      return proxy;
    } else {
      final proxy = isExternal ? (externalProxyMap?[propertyName]) : (internalProxyMap?[propertyName]);
      if (proxy == null) throw ('Not found proxy: $identifier.$propertyName');
      return proxy;
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
  String toString() => 'VmClass<${isExternal ? T : identifier}> ===> $identifier';

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'toString': toString(),
      'identifier': identifier,
      'isExternal': isExternal,
      'vmwareType': vmwareType.toString(),
    };
    if (externalProxyMap != null) map['externalProxyMap'] = externalProxyMap?.length;
    if (internalProxyMap != null) map['internalProxyMap'] = internalProxyMap;
    if (internalStaticPropertyMap != null) map['internalStaticPropertyMap'] = internalStaticPropertyMap;
    if (internalInstanceFieldTree != null) map['internalInstanceFieldTree'] = internalInstanceFieldTree?.map((e) => e.keys.map((e) => e.toString()).toList()).toList();
    return map;
  }

  ///函数的类型名称
  static const functionTypeName = 'Function';

  ///动态的类型名称
  static const dynamicTypeNames = ['Object', 'dynamic'];

  ///包装类型集合
  static final _libraryMap = <String, VmClass>{};

  ///包装类型列表
  static final _libraryList = <VmClass>[];

  ///添加包装类型[vmclass]
  static void addClass(VmClass vmclass) {
    if (_libraryMap.containsKey(vmclass.identifier)) throw ('Already exists VmClass: ${vmclass.identifier}');
    _libraryMap[vmclass.identifier] = vmclass;
    _libraryList.add(vmclass);
  }

  ///获取指定名称[typeName]对应的包装类型
  static VmClass getClassByTypeName(String typeName) {
    final vmclass = _libraryMap[typeName];
    if (vmclass != null) return vmclass;
    throw ('Not found VmClass: $typeName');
  }

  ///获取任意实例[instance]对应的[VmClass]包装类型
  static VmClass getClassByInstance(dynamic instance) {
    //先读取逻辑值进行判断
    final logic = VmObject.readLogic(instance);
    if (logic is VmValue) return logic._valueType;
    //再使用类型名进行查找
    final typeName = logic.runtimeType.toString();
    final vmclass = _libraryMap[typeName];
    if (vmclass != null) return vmclass;
    //最后使用实例进行匹配
    for (var item in _libraryList) {
      if (item.isThisType(logic)) return item;
    }
    throw ('Not found VmClass: $typeName');
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
  late final VmClass _vmclass;

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
  });

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
        return (internalStaticPropertyOperator as VmValue).getValue();
      }
    } else {
      //读取实例属性
      if (isExternal) {
        final instanceNative = VmObject.readValue(instance);
        if (externalInstancePropertyReader != null) return externalInstancePropertyReader!(instanceNative);
        throw ('Not found externalInstancePropertyReader: ${_vmclass.identifier}.$identifier');
      } else {
        return (VmObject.readLogic(instance) as VmValue).getProperty(identifier).getValue();
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

  ///父实例作用域
  VmValue? _instanceScope;

  VmValue._({
    required super.identifier,
    required this.metaType,
    required this.metaData,
    required VmClass valueType,
    required dynamic valueData,
  })  : _valueType = valueType,
        _valueData = valueData {
    if (metaType == VmMetaType.internalMethod) {
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

  ///创建变量值，如果[initValue]是[VmValue]实例，则复制除[identifier]之外的属性
  factory VmValue.forVariable({
    String identifier = '___anonymousVmVariable___',
    String? initType,
    dynamic initValue,
  }) {
    final realLogic = VmObject.readLogic(initValue, type: initType);
    if (realLogic is VmValue) {
      return VmValue._(
        identifier: identifier,
        metaType: VmClass.dynamicTypeNames.contains(initType) ? VmMetaType.externalSmarts : VmMetaType.internalByname,
        metaData: const VmMetaData(),
        valueType: realLogic._valueType,
        valueData: realLogic,
      );
    } else {
      final realClass = VmObject.readClass(initValue, type: initType);
      final realValue = VmObject.readValue(initValue, type: initType);
      return VmValue._(
        identifier: identifier,
        metaType: VmClass.dynamicTypeNames.contains(realClass.identifier) ? VmMetaType.externalSmarts : (realClass.isExternal ? VmMetaType.externalObject : VmMetaType.internalObject),
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
      metaType: VmMetaType.internalMethod,
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
      valueType: VmClass.getClassByTypeName(VmClass.functionTypeName),
      valueData: null,
    );
  }

  ///作为内部定义类型的实例的字段集合
  Map<String, VmValue> get internalInstancePropertyMap {
    final target = _valueData;
    if (target is VmValue) {
      return target.internalInstancePropertyMap;
    } else {
      return target;
    }
  }

  ///作为内部定义类型的静态成员来绑定静态作用域
  void bindStaticScope(VmClass staticScope) {
    final target = _valueData;
    if (target is VmValue) {
      target.bindStaticScope(staticScope);
    } else {
      _staticScope ??= staticScope;
    }
  }

  ///作为内部定义类型的实例绑定成员的相关作用域，注意：在调用前需要先调用[bindStaticScope]绑定静态作用域
  void bindMemberScope() {
    final target = _valueData;
    if (target is VmValue) {
      target.bindMemberScope();
    } else {
      if (_staticScope == null) throw ('Please call bindStaticScope before calling bindMemberScope');
      internalInstancePropertyMap.forEach((key, value) {
        value._staticScope ??= _staticScope;
        value._instanceScope ??= this;
      });
    }
  }

  ///作为任意的函数来直接执行
  dynamic runFunction(List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments) {
    final target = _valueData;
    if (target is VmValue) {
      return target.runFunction(positionalArguments, namedArguments);
    } else {
      if (metaType == VmMetaType.internalMethod) {
        if (metaData.isIniter) {
          return metaData.staticListener!(positionalArguments, namedArguments, _staticScope!, _staticScope!.internalInstanceFieldTree, this); //原始构造函数
        } else if (metaData.isStatic) {
          return metaData.staticListener!(positionalArguments, namedArguments, _staticScope!, null, this); //普通静态函数
        } else {
          return metaData.instanceListener!(positionalArguments, namedArguments, _staticScope, _instanceScope, this); //普通定义函数、实例成员函数
        }
      } else {
        final listArgumentsNative = positionalArguments?.map((e) => VmObject.readValue(e)).toList();
        final nameArgumentsNative = namedArguments?.map((key, value) => MapEntry(key, VmObject.readValue(value)));
        return Function.apply(target, listArgumentsNative, nameArgumentsNative);
      }
    }
  }

  ///作为内部定义类型的实例来读取字段
  VmValue getProperty(String propertyName) {
    final target = _valueData;
    if (target is VmValue) {
      return target.getProperty(propertyName);
    } else {
      return target[propertyName];
    }
  }

  ///准备调用该函数所需的参数列表。为构造函数做准备时[buildTarget]为要被构建的目标实例
  List<VmObject> prepareInvocation(List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments, VmValue? buildTarget) {
    final target = _valueData;
    if (target is VmValue) {
      return target.prepareInvocation(positionalArguments, namedArguments, buildTarget);
    } else {
      final result = <VmObject>[];
      positionalArguments ??= const [];
      namedArguments ??= const {};
      //匹配列表参数
      for (var i = 0; i < metaData.listArguments.length; i++) {
        final field = metaData.listArguments[i];
        final value = i < positionalArguments.length ? positionalArguments[i] : field.fieldValue; //列表参数按照索引一一对应即可
        if (field.isClassField) {
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
        if (field.isClassField) {
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
      return _valueType;
    }
  }

  @override
  dynamic getLogic() {
    final target = _valueData;
    if (target is VmValue) {
      return target.getLogic();
    } else {
      if (metaType == VmMetaType.internalMethod) {
        if (metaData.isGetter) return VmObject.readLogic(runFunction(null, null));
        return this; //注意：此处返回自身，用于逻辑调用
      } else if (metaType == VmMetaType.internalObject) {
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
      if (metaType == VmMetaType.internalMethod) {
        if (metaData.isGetter) return VmObject.readValue(runFunction(null, null));
        return target; //函数模板值
      } else if (metaType == VmMetaType.internalObject) {
        return target; //字段Map值
      } else {
        return target; //数据原生值
      }
    }
  }

  @override
  dynamic setValue(value) {
    switch (metaType) {
      case VmMetaType.externalObject:
        return _valueData = VmObject.readValue(value, type: _valueType.identifier); //保存原生值
      case VmMetaType.externalSmarts:
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
      case VmMetaType.internalMethod:
        if (metaData.isSetter) return runFunction([value], null);
        throw ('Unsuppport setValue operator for internalMethod: $identifier');
      case VmMetaType.internalObject:
        throw ('Unsuppport setValue operator for internalObject: $identifier');
      case VmMetaType.internalByname:
        return _valueData = VmObject.readLogic(value, type: _valueType.identifier); //保存逻辑值
    }
  }

  @override
  String toString() {
    switch (metaType) {
      case VmMetaType.externalObject:
        return 'VmValue<externalObject> ===> ${_valueType.identifier} $identifier --> ${_valueData.runtimeType} $_valueData';
      case VmMetaType.externalSmarts:
        if (_valueData is VmValue) {
          return 'VmValue<externalSmarts> ===> ${_valueType.identifier} $identifier @@@{ $_valueData }@@@';
        } else {
          return 'VmValue<externalObject> ===> ${_valueType.identifier} $identifier --> ${_valueData.runtimeType} $_valueData';
        }
      case VmMetaType.internalMethod:
        final typeArg1 = metaData.isIniter ? 'initer' : (metaData.isStatic ? 'static' : 'normal');
        final typeArg2 = metaData.isGetter ? 'getter' : (metaData.isSetter ? 'setter' : 'normal');
        final listArgs = '[${metaData.listArguments.map((e) => '${e.isClassField ? 'this.' : ''}${e.fieldName}').toList().join(', ')}]';
        final nameArgs = '{${metaData.nameArguments.map((e) => '${e.isClassField ? 'this.' : ''}${e.fieldName}${e.fieldValue == null ? '' : ' = ${e.getValue()}'}').toList().join(', ')}}';
        return 'VmValue<internalMethod> ===> ${_valueType.identifier} $identifier --> $typeArg1 $typeArg2 $listArgs $nameArgs';
      case VmMetaType.internalObject:
        return 'VmValue<internalObject> ===> ${_valueType.identifier} $identifier --> (${internalInstancePropertyMap.keys.map((e) => e.toString()).toList().join(', ')})';
      case VmMetaType.internalByname:
        return 'VmValue<internalByname> ===> ${_valueType.identifier} $identifier ###{ $_valueData }###';
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'toString': toString(),
      'identifier': identifier,
      'metaType': metaType.toString(),
      'metaData': metaData.toString(),
    };
    switch (metaType) {
      case VmMetaType.externalObject:
        map['_valueType'] = _valueType.toString();
        map['_valueData'] = _valueData?.toString();
        break;
      case VmMetaType.externalSmarts:
        map['_valueType'] = _valueType.toString();
        if (_valueData is VmValue) {
          map['_valueData'] = _valueData;
        } else {
          map['_valueData'] = _valueData?.toString();
        }
        break;
      case VmMetaType.internalMethod:
        map['metaData'] = {
          'isIniter': metaData.isIniter,
          'isStatic': metaData.isStatic,
          'isGetter': metaData.isGetter,
          'isSetter': metaData.isSetter,
          'listArguments': '[${metaData.listArguments.map((e) => '${e.isClassField ? 'this.' : ''}${e.fieldName}').toList().join(', ')}]',
          'nameArguments': '{${metaData.nameArguments.map((e) => '${e.isClassField ? 'this.' : ''}${e.fieldName}${e.fieldValue == null ? '' : ' = ${e.getValue()}'}').toList().join(', ')}}',
          'initTree': metaData.initTree.map((e) => e?.keys.map((e) => e.toString()).toList()).toList(),
          'bodyTree': metaData.bodyTree.keys.map((e) => e.toString()).toList(),
          'staticListener': metaData.staticListener != null,
          'instanceListener': metaData.instanceListener != null,
        };
        map['_valueType'] = _valueType.toString();
        map['_valueData'] = _valueData?.toString();
        break;
      case VmMetaType.internalObject:
        map['_valueType'] = _valueType.toString();
        map['_valueData'] = _valueData;
        break;
      case VmMetaType.internalByname:
        map['_valueType'] = _valueType.toString();
        map['_valueData'] = _valueData;
        break;
    }
    map['_staticScope'] = _staticScope?.toString();
    map['_instanceScope'] = _instanceScope?.toString();
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
      if (target is VmClass) {
        _result = target.getProxy(property, setter: false).runFunction(target, listArguments, nameArguments); //执行静态函数
      } else if (target is VmProxy && instanceByProperty) {
        _result = target.runFunction(target, listArguments, nameArguments); //执行顶级函数
      } else if (target is VmValue && instanceByProperty) {
        _result = target.runFunction(listArguments, nameArguments); //执行内部函数
      } else {
        _result = VmObject.readClass(target).getProxy(property, setter: false).runFunction(target, listArguments, nameArguments); //执行实例方法
      }
    } else if (isIndexed) {
      _result = target[property]; //索引List取值
    } else if (target is VmClass) {
      _result = target.getProxy(property, setter: false).getProperty(target); //读取静态属性
    } else {
      _result = VmObject.readClass(target).getProxy(property, setter: false).getProperty(target); //读取实例属性
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
      return VmObject.readClass(target).getProxy(property, setter: true).setProperty(target, value); //写入实例属性
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
      'listArguments': listArguments?.length,
      'nameArguments': nameArguments?.length,
      '_completed': _completed,
      '_result': _result?.toString(),
    };
    return map;
  }
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

  VmHelper({
    this.fieldType,
    String? fieldName,
    dynamic fieldValue,
    this.isNamedField = false,
    this.isClassField = false,
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

  ///附带值如：函数返回值等
  final dynamic signalValue;

  ///是否为中断语句信号
  bool get isInterrupt => isBreak || isReturn;

  VmSignal({
    this.isBreak = false,
    this.isReturn = false,
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
      'signalValue': signalValue?.toString(),
    };
    return map;
  }
}

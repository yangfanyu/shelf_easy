import 'vm_keys.dart';

///
///虚拟机数据类型
///
class VmType extends Type {
  ///虚拟机数据类型名称
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
///虚拟机抽象类
///
abstract class VmObject {
  ///对象的标识符
  final String identifier;

  VmObject({required this.identifier});

  ///读取对象的包装类
  VmClass getClass();

  ///读取对象的原生值
  dynamic getValue();

  ///设置对象的原生值
  dynamic setValue(dynamic value);

  ///转换为易读的字符串描述
  @override
  String toString() => '$runtimeType ===> $identifier';

  ///转换为易读的JSON对象
  Map<String, dynamic> toJson();
}

///
///虚拟机类型包装类
///
class VmClass<T> extends VmObject {
  ///是否为外部导入类型
  final bool isExternal;

  ///外部导入类型的字段代理集合
  final Map<String, VmProxy<T>>? externalProxyMap;

  ///内部定义类型的字段代理集合
  final Map<String, VmProxy<T>>? internalProxyMap;

  ///内部定义类型的静态字段的已初始化集合，在相关调用时会将该集合放到作用域栈中
  final Map<String, VmObject>? internalStaticPropertyMap;

  ///内部定义类型的实例字段的初始化树列表，初始化树采用列表可保证初始化顺序不变
  final List<Map<VmKeys, dynamic>>? internalInstanceFieldTree;

  VmClass({
    required super.identifier,
    this.isExternal = true,
    this.externalProxyMap,
    this.internalProxyMap,
    this.internalStaticPropertyMap,
    this.internalInstanceFieldTree,
  }) {
    //给代理绑定包装类型
    externalProxyMap?.forEach((key, value) => value.bindVmClass(this));
    internalProxyMap?.forEach((key, value) => value.bindVmClass(this));
  }

  ///判断实例是否为该包装类型的实例
  bool isThisType(dynamic instance) {
    if (isExternal) {
      return VmValue.readValue(instance) is T; //如果为外部导入的类型，读取实例的值进行判断
    } else {
      return instance is VmValue && instance._vmclass.identifier == identifier; //如果为内部定义的类型，使用实例的类型来判断
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
  VmClass getClass() => VmClass.getClassByInstance(getValue());

  @override
  dynamic getValue() => VmType(name: identifier);

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
    };
    if (externalProxyMap != null) map['externalProxyMap'] = externalProxyMap?.length;
    if (internalProxyMap != null) map['internalProxyMap'] = internalProxyMap;
    if (internalStaticPropertyMap != null) map['internalStaticPropertyMap'] = internalStaticPropertyMap;
    if (internalInstanceFieldTree != null) map['internalInstanceFieldTree'] = internalInstanceFieldTree?.map((e) => e.keys.map((e) => e.toString()).toList()).toList();
    return map;
  }

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
    final typeName = instance.runtimeType.toString();
    final vmclass = _libraryMap[typeName];
    if (vmclass != null) return vmclass;
    for (var item in _libraryList) {
      if (item.isThisType(instance)) return item;
    }
    throw ('Not found VmClass: $typeName');
  }

  ///执行任意实例[instance]的[functionName]函数
  static dynamic runFunction(dynamic instance, String functionName, List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments) {
    if (instance is VmProxy && instance.identifier == functionName) {
      return instance.runFunction(instance, positionalArguments, namedArguments); //执行外部导入的顶级函数
    }
    if (instance is VmValue && instance.identifier == functionName && instance.isMethod) {
      if (instance.methodIsStatic) {
        final vmclass = VmClass.getClassByTypeName(functionName);
        return instance.runAsStaticFunction(positionalArguments, namedArguments, vmclass, vmclass.internalInstanceFieldTree); //执行内部定义的构造函数
      }
      return instance.runAsFunction(positionalArguments, namedArguments); //执行内部定义的顶级函数
    }
    final vmclass = instance is VmClass ? instance : VmValue.readClass(instance);
    return vmclass.getProxy(functionName, setter: false).runFunction(instance, positionalArguments, namedArguments);
  }

  ///读取任意实例[instance]的[propertyName]属性
  static dynamic getProperty(dynamic instance, String propertyName) {
    final vmclass = instance is VmClass ? instance : VmValue.readClass(instance);
    return vmclass.getProxy(propertyName, setter: false).getProperty(instance);
  }

  ///设置任意实例[instance]的[propertyName]属性
  static dynamic setProperty(dynamic instance, String propertyName, dynamic propertyValue) {
    final vmclass = instance is VmClass ? instance : VmValue.readClass(instance);
    return vmclass.getProxy(propertyName, setter: true).setProperty(instance, propertyValue);
  }
}

///
///虚拟机字段代理类
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
        final listArgumentsNative = positionalArguments?.map((e) => VmValue.readValue(e)).toList();
        final nameArgumentsNative = namedArguments?.map((key, value) => MapEntry(key, VmValue.readValue(value)));
        if (externalStaticFunctionCaller != null) return Function.apply(externalStaticFunctionCaller!, listArgumentsNative, nameArgumentsNative);
        if (externalStaticPropertyReader != null) return Function.apply(externalStaticPropertyReader!(), listArgumentsNative, nameArgumentsNative);
        throw ('Not found externalStaticFunctionCaller and externalStaticPropertyReader: ${_vmclass.identifier}.$identifier');
      } else {
        final target = internalStaticPropertyOperator!;
        if (target.isMethod) return target.runAsStaticFunction(positionalArguments, namedArguments, _vmclass, target.identifier == _vmclass.identifier ? _vmclass.internalInstanceFieldTree : null); //静态普通函数
        return target.runAsFunction(positionalArguments, namedArguments); //静态变量函数
      }
    } else {
      //执行实例函数
      if (isExternal) {
        final instanceNative = VmValue.readValue(instance);
        final listArgumentsNative = positionalArguments?.map((e) => VmValue.readValue(e)).toList();
        final nameArgumentsNative = namedArguments?.map((key, value) => MapEntry(key, VmValue.readValue(value)));
        if (externalInstanceFunctionCaller != null) return Function.apply(externalInstanceFunctionCaller!, [instanceNative, ...(listArgumentsNative ?? const [])], nameArgumentsNative);
        if (externalInstancePropertyReader != null) return Function.apply(externalInstancePropertyReader!(instanceNative), listArgumentsNative, nameArgumentsNative);
        throw ('Not found externalInstanceFunctionCaller and externalInstancePropertyReader: ${_vmclass.identifier}.$identifier');
      } else {
        final target = (instance as VmValue).getField(identifier);
        if (target.isMethod) return target.runAsInstanceFunction(positionalArguments, namedArguments); //实例普通函数
        return target.runAsFunction(positionalArguments, namedArguments); //实例变量函数
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
        final target = internalStaticPropertyOperator!;
        if (target.isMethod && target.methodIsGetter) return target.runAsStaticFunction(null, null, _vmclass, null); //静态get函数
        return target.getValue();
      }
    } else {
      //读取实例属性
      if (isExternal) {
        final instanceNative = VmValue.readValue(instance);
        if (externalInstancePropertyReader != null) return externalInstancePropertyReader!(instanceNative);
        throw ('Not found externalInstancePropertyReader: ${_vmclass.identifier}.$identifier');
      } else {
        final target = (instance as VmValue).getField(identifier);
        if (target.isMethod && target.methodIsGetter) return target.runAsInstanceFunction(null, null); //实例get函数
        return target.getValue();
      }
    }
  }

  ///写入属性
  dynamic setProperty(dynamic instance, dynamic value) {
    if (instance == this || instance == _vmclass) {
      //写入静态属性
      if (isExternal) {
        final valueNative = VmValue.readValue(value);
        if (externalStaticPropertyWriter != null) return externalStaticPropertyWriter!(valueNative);
        throw ('Not found externalStaticPropertyWriter: ${_vmclass.identifier}.$identifier');
      } else {
        final target = internalStaticPropertyOperator!;
        if (target.isMethod && target.methodIsSetter) return target.runAsStaticFunction([value], null, _vmclass, null); //静态set函数
        return target.setValue(value);
      }
    } else {
      //写入实例属性
      if (isExternal) {
        final instanceNative = VmValue.readValue(instance);
        final valueNative = VmValue.readValue(value);
        if (externalInstancePropertyWriter != null) return externalInstancePropertyWriter!(instanceNative, valueNative);
        throw ('Not found externalInstancePropertyWriter: ${_vmclass.identifier}.$identifier');
      } else {
        final target = (instance as VmValue).getField(identifier);
        if (target.isMethod && target.methodIsSetter) return target.runAsInstanceFunction([value], null); //实例set函数
        return target.setValue(value);
      }
    }
  }

  @override
  VmClass getClass() => VmClass.getClassByInstance(getValue());

  @override
  dynamic getValue() => getProperty(this);

  @override
  dynamic setValue(value) => setProperty(this, value);

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
///虚拟机实例值包装
///
class VmValue extends VmObject {
  ///是否为内部定义方法
  final bool isMethod;

  ///不是内部定义方法时的初始类型
  final String? initType;

  ///不是内部定义方法时的初始化值
  final dynamic initValue;

  ///作为内部定义方法时声明为static
  final bool methodIsStatic;

  ///作为内部定义方法时声明为get
  final bool methodIsGetter;

  ///作为内部定义方法时声明为set
  final bool methodIsSetter;

  ///作为内部定义方法时的列表参数
  final List<VmHelper> methodListArguments;

  ///作为内部定义方法时的命名参数
  final List<VmHelper> methodNameArguments;

  ///作为内部定义方法时的初始化语法树（仅原始构造函数有此内容）
  final List<Map<VmKeys, dynamic>?> methodInitTree;

  ///作为内部定义方法时的函数体语法树
  final Map<VmKeys, dynamic> methodBodyTree;

  ///作为内部定义类的静态方法时的回调监听
  final dynamic Function(List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments, VmClass classScope, List<Map<VmKeys, dynamic>>? instanceFields, VmValue method)? methodStaticListener;

  ///作为内部定义类的实例方法时的回调监听
  final dynamic Function(List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments, VmClass? classScope, VmValue? instanceScope, VmValue method)? methodInstanceListener;

  ///值类型
  final VmClass _vmclass;

  ///父实例
  VmValue? _father;

  ///通用值
  dynamic _value;

  ///作为内部定义类型的实例的字段集合
  Map<String, VmValue> get internalInstancePropertyMap => _value;

  VmValue._({
    required super.identifier,
    this.isMethod = false,
    this.initType,
    this.initValue,
    this.methodIsStatic = false,
    this.methodIsGetter = false,
    this.methodIsSetter = false,
    this.methodListArguments = const [],
    this.methodNameArguments = const [],
    this.methodInitTree = const [],
    this.methodBodyTree = const {},
    this.methodStaticListener,
    this.methodInstanceListener,
  }) : _vmclass = isMethod ? VmClass.getClassByTypeName('Function') : _formatClass(initType, initValue) {
    if (isMethod && (methodStaticListener == null || methodInstanceListener == null)) throw ('Method callback listener cannot be null: $identifier');
    _value = isMethod ? _formatTemplate(this) : _formatValue(initType, initValue);
  }

  ///创建变量值，如果[initValue]是[VmValue]实例，则复制除[identifier]之外的属性
  factory VmValue.forVariable({
    String identifier = '___anonymousVmValue___',
    String? initType,
    dynamic initValue,
  }) {
    if (initValue is VmValue) {
      return VmValue._(
        identifier: identifier,
        isMethod: initValue.isMethod,
        initType: initValue._vmclass.identifier,
        initValue: initValue,
        methodIsStatic: initValue.methodIsStatic,
        methodIsGetter: initValue.methodIsGetter,
        methodIsSetter: initValue.methodIsSetter,
        methodListArguments: initValue.methodListArguments,
        methodNameArguments: initValue.methodNameArguments,
        methodInitTree: initValue.methodInitTree,
        methodBodyTree: initValue.methodBodyTree,
        methodStaticListener: initValue.methodStaticListener,
        methodInstanceListener: initValue.methodInstanceListener,
      )..bindFatherOfChildren();
    } else {
      return VmValue._(
        identifier: identifier,
        initType: initType,
        initValue: initValue,
      )..bindFatherOfChildren();
    }
  }

  factory VmValue.forFunction({
    String identifier = '___anonymousVmValue___',
    bool methodIsStatic = false,
    bool methodIsGetter = false,
    bool methodIsSetter = false,
    List<VmHelper> methodListArguments = const [],
    List<VmHelper> methodNameArguments = const [],
    List<Map<VmKeys, dynamic>?> methodInitTree = const [],
    Map<VmKeys, dynamic> methodBodyTree = const {},
    dynamic Function(List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments, VmClass classScope, List<Map<VmKeys, dynamic>>? instanceFields, VmValue method)? methodStaticListener,
    dynamic Function(List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments, VmClass? classScope, VmValue? instanceScope, VmValue method)? methodInstanceListener,
  }) {
    return VmValue._(
      identifier: identifier,
      isMethod: true,
      methodIsStatic: methodIsStatic,
      methodIsGetter: methodIsGetter,
      methodIsSetter: methodIsSetter,
      methodListArguments: methodListArguments,
      methodNameArguments: methodNameArguments,
      methodInitTree: methodInitTree,
      methodBodyTree: methodBodyTree,
      methodStaticListener: methodStaticListener,
      methodInstanceListener: methodInstanceListener,
    )..bindFatherOfChildren();
  }

  ///作为函数来直接执行
  dynamic runAsFunction(List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments) {
    if (isMethod) {
      return methodInstanceListener!(positionalArguments, namedArguments, _father?._vmclass, _father, this);
    } else {
      final listArgumentsNative = positionalArguments?.map((e) => VmValue.readValue(e)).toList();
      final nameArgumentsNative = namedArguments?.map((key, value) => MapEntry(key, VmValue.readValue(value)));
      return Function.apply(_value, listArgumentsNative, nameArgumentsNative);
    }
  }

  ///作为内部定义类型的静态函数来执行
  dynamic runAsStaticFunction(List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments, VmClass classScope, List<Map<VmKeys, dynamic>>? instanceFields) {
    return methodStaticListener!(positionalArguments, namedArguments, classScope, instanceFields, this);
  }

  ///作为内部定义类型的实例的成员函数来执行
  dynamic runAsInstanceFunction(List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments) {
    return methodInstanceListener!(positionalArguments, namedArguments, _father?._vmclass, _father, this);
  }

  ///作为内部定义类型的实例绑定成员的父实例
  void bindFatherOfChildren() {
    if (!_vmclass.isExternal) {
      internalInstancePropertyMap.forEach((key, value) => value._father ??= this);
    }
  }

  ///作为内部定义类型的实例来读取字段
  VmValue getField(String fieldName) => _value[fieldName] as VmValue;

  @override
  VmClass getClass() => _value is VmObject ? (_value as VmObject).getClass() : _vmclass;

  @override
  dynamic getValue() {
    if (isMethod && methodIsGetter) return runAsInstanceFunction(null, null);
    return _value is VmObject ? (_value as VmObject).getValue() : _value;
  }

  @override
  dynamic setValue(value) {
    if (isMethod && methodIsSetter) return runAsInstanceFunction([value], null);
    if (isMethod || (value is VmValue && value.isMethod)) throw ('Method not support setValue operator'); //方法不支持设置值，防止数据混乱
    return _value is VmObject ? (_value as VmObject).setValue(value) : (_value = _formatValue(_vmclass.identifier, value));
  }

  @override
  String toString() {
    if (isMethod) {
      final listArgs = '[${methodListArguments.map((e) => '${e.isClassField ? 'this.' : ''}${e.fieldName}').toList().join(', ')}]';
      final nameArgs = '{${methodNameArguments.map((e) => '${e.isClassField ? 'this.' : ''}${e.fieldName}${e.fieldValue == null ? '' : ' = ${e.getValue()}'}').toList().join(', ')}}';
      return 'VmValue ===> ${_vmclass.identifier} $identifier --------> $listArgs $nameArgs';
    } else {
      if (_vmclass.isExternal) {
        return 'VmValue ===> ${_vmclass.identifier} $identifier --------> ${_value.runtimeType} $_value';
      } else {
        return 'VmValue ===> ${_vmclass.identifier} $identifier --------> ${_value.runtimeType} ${internalInstancePropertyMap.length} Fields';
      }
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'toString': toString(),
      'identifier': identifier,
      'isMethod': isMethod,
    };
    if (isMethod) {
      map['methodIsGetter'] = methodIsGetter;
      map['methodIsSetter'] = methodIsSetter;
      map['methodListArguments'] = '[${methodListArguments.map((e) => '${e.isClassField ? 'this.' : ''}${e.fieldName}').toList().join(', ')}]';
      map['methodNameArguments'] = '{${methodNameArguments.map((e) => '${e.isClassField ? 'this.' : ''}${e.fieldName}${e.fieldValue == null ? '' : ' = ${e.getValue()}'}').toList().join(', ')}}';
      map['methodInitTree'] = methodInitTree.map((e) => e?.keys.map((e) => e.toString()).toList()).toList();
      map['methodBodyTree'] = methodBodyTree.keys.map((e) => e.toString()).toList();
      map['methodStaticListener'] = methodStaticListener != null;
      map['methodInstanceListener'] = methodInstanceListener != null;
    } else {
      map['initType'] = initType;
      map['initValue'] = initValue?.toString();
    }
    map['_father'] = _father?.toString();
    if (_vmclass.isExternal) {
      map['_value'] = _value?.toString();
    } else {
      map['_value'] = _value;
    }
    return map;
  }

  ///读取[target]的包装类
  static VmClass readClass(dynamic target) => target is VmObject ? target.getClass() : VmClass.getClassByInstance(target);

  ///读取[target]的原生值
  static dynamic readValue(dynamic target) => target is VmObject ? target.getValue() : target;

  ///保存[target]的原生值
  static dynamic saveValue(dynamic target, dynamic value) => target is VmObject ? target.setValue(value) : throw ('${target.runtimeType} not support saveValue operator');

  ///准备调用该函数所需的参数列表。为构造函数做准备时[instanceScope]为要被初始化的实例
  List<VmObject> prepareForRealInvocation(List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments, VmValue? instanceScope) {
    final result = <VmObject>[];
    positionalArguments ??= const [];
    namedArguments ??= const {};
    //匹配列表参数
    for (var i = 0; i < methodListArguments.length; i++) {
      final field = methodListArguments[i];
      final value = i < positionalArguments.length ? positionalArguments[i] : field.fieldValue; //列表参数按照索引一一对应即可
      if (field.isClassField && instanceScope != null) {
        instanceScope.getField(field.fieldName).setValue(value);
      } else {
        result.add(VmValue.forVariable(identifier: field.fieldName, initType: field.typeName, initValue: value));
      }
    }
    //匹配命名参数
    for (var i = 0; i < methodNameArguments.length; i++) {
      final field = methodNameArguments[i];
      final fieldKey = Symbol(field.fieldName);
      final value = namedArguments.containsKey(fieldKey) ? namedArguments[fieldKey] : field.fieldValue; //命名参数按照字段名称进行匹配
      if (field.isClassField && instanceScope != null) {
        instanceScope.getField(field.fieldName).setValue(value);
      } else {
        result.add(VmValue.forVariable(identifier: field.fieldName, initType: field.typeName, initValue: value));
      }
    }
    return result;
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

  ///根据[type]与[value]返回正确的类型
  static VmClass _formatClass(String? type, dynamic value) {
    if (type != null) return VmClass.getClassByTypeName(type);
    if (value is VmObject) return value.getClass();
    return VmClass.getClassByInstance(value);
  }

  ///根据[type]与[value]返回正确的类型数据
  static dynamic _formatValue(String? type, dynamic value) {
    final val = value is VmObject ? value.getValue() : value;
    switch (type) {
      case 'int':
        return val as int?;
      case 'double':
        return val is int ? val.toDouble() : val as double?; //使用int值初始化double时，initValue的运行时类型为int，所以进行了转换
      case 'num':
        return val as num?;
      case 'bool':
        return val as bool?;
      case 'String':
        return val as String?;
      case 'List':
        return val as List?;
      case 'Map':
        return val as Map?;
      case 'Set':
        return val is Map ? val.values.toSet() : val as Set?; //扫描器获取初始值时，无法识别无类型声明的空'{}'类型，这时默认为Map类型，需要再次进行类型转换
      default:
        return val;
    }
  }

  ///根据列表参数的长度返回[method]的正确函数模版
  static Function _formatTemplate(VmValue method) {
    final father = method._father;
    final identifier = method.identifier;
    final methodListArguments = method.methodListArguments;
    final methodInstanceListener = method.methodInstanceListener;
    if (!method.isMethod) throw ('Only method value support template: $identifier');
    if (methodInstanceListener == null) throw ('Template callback methodInstanceListener cannot be null: $identifier');
    switch (methodListArguments.length) {
      case 0:
        return () => methodInstanceListener([], null, father?._vmclass, father, method);
      case 1:
        return (a) => methodInstanceListener([a], null, father?._vmclass, father, method);
      case 2:
        return (a, b) => methodInstanceListener([a, b], null, father?._vmclass, father, method);
      case 3:
        return (a, b, c) => methodInstanceListener([a, b, c], null, father?._vmclass, father, method);
      case 4:
        return (a, b, c, d) => methodInstanceListener([a, b, c, d], null, father?._vmclass, father, method);
      case 5:
        return (a, b, c, d, e) => methodInstanceListener([a, b, c, d, e], null, father?._vmclass, father, method);
      case 6:
        return (a, b, c, d, e, f) => methodInstanceListener([a, b, c, d, e, f], null, father?._vmclass, father, method);
      case 7:
        return (a, b, c, d, e, f, g) => methodInstanceListener([a, b, c, d, e, f, g], null, father?._vmclass, father, method);
      case 8:
        return (a, b, c, d, e, f, g, h) => methodInstanceListener([a, b, c, d, e, f, g, h], null, father?._vmclass, father, method);
      case 9:
        return (a, b, c, d, e, f, g, h, i) => methodInstanceListener([a, b, c, d, e, f, g, h, i], null, father?._vmclass, father, method);
      default:
        throw ('Unsupport template ${methodListArguments.length}: $identifier');
    }
  }
}

///
///虚拟机延迟操作类
///
class VmLazyer extends VmObject {
  ///是否为方法调用
  final bool isMethod;

  ///是否为索引表达式
  final bool isIndexed;

  ///延迟操作的目标
  final dynamic instance;

  ///延迟操作的属性
  final dynamic property;

  ///方法调用的列表参数
  final List<dynamic>? listArguments;

  ///方法调用的命名参数
  final Map<Symbol, dynamic>? nameArguments;

  ///是否为挂起状态
  bool _pending;

  ///解除挂起的结果
  dynamic _result;

  VmLazyer({
    this.isMethod = false,
    this.isIndexed = false,
    required dynamic instance,
    required this.property,
    this.listArguments,
    this.nameArguments,
  })  : instance = instance is VmLazyer ? instance.orgValue() : instance,
        _pending = true,
        super(identifier: '___anonymousVmLazyer___');

  ///解析并读取原始值
  dynamic orgValue() {
    if (_pending) {
      _pending = false;
      _result = isMethod ? VmClass.runFunction(instance, property, listArguments, nameArguments) : (isIndexed ? instance[property] : VmClass.getProperty(instance, property));
    }
    return _result;
  }

  @override
  VmClass getClass() => VmValue.readClass(orgValue());

  @override
  dynamic getValue() => VmValue.readValue(orgValue());

  @override
  dynamic setValue(value) => isMethod ? throw ('Method not support setValue operator') : (isIndexed ? instance[property] = value : VmClass.setProperty(instance, property, value));

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
      '_pending': _pending,
      '_result': _result?.toString(),
    };
    return map;
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

  ///声明的字段是否为类字段参数
  final bool isClassField;

  VmHelper({
    this.typeName,
    this.typeQuestion,
    String? fieldName,
    this.fieldValue,
    this.isNamedField = false,
    this.isClassField = false,
  })  : fieldName = fieldName ?? '___anonymousVmField___',
        super(identifier: '___anonymousVmHelper___');

  @override
  VmClass getClass() => VmValue._formatClass(typeName, fieldValue);

  @override
  dynamic getValue() => VmValue._formatValue(typeName, fieldValue);

  @override
  dynamic setValue(value) => throw UnimplementedError();

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'toString': toString(),
      'identifier': identifier,
      'typeName': typeName,
      'typeQuestion': typeQuestion,
      'fieldName': fieldName,
      'fieldValue': fieldValue?.toString(),
      'isNamedField': isNamedField,
      'isClassField': isClassField,
    };
    return map;
  }
}

///
///虚拟机运行信号类
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
    this.signalValue,
  }) : super(identifier: '___anonymousVmSignal___');

  @override
  VmClass getClass() => VmValue.readClass(signalValue);

  @override
  dynamic getValue() => VmValue.readValue(signalValue);

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

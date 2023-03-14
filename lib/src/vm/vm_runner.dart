import 'vm_keys.dart';
import 'vm_object.dart';
import 'vm_library.dart';

///
///Dart语言子集的运行器
///
class VmRunner {
  ///应用库语法树集合，一般来讲一个文件对应一个Map<VmKeys, dynamic>子项
  final Map<String, Map<VmKeys, dynamic>> _sourceTrees;

  ///运行时作用域堆栈：[ 基本库，核心库，用户库，应用库，......其他运行时临时作用域...... ]
  final List<Map<String, VmObject>> _objectStack;

  VmRunner({Map<String, Map<VmKeys, dynamic>> sourceTrees = const {}})
      : _sourceTrees = {},
        _objectStack = [..._globalScopeList, {}] {
    VmClass.registerInternalClassSearchRunner(searchClassInAppScope); //给底层绑定应用库类型搜索器
    reassemble(sourceTrees: sourceTrees);
  }

  ///重新装载应用库语法树集合，扫描过程中预定义的内容会放入[应用库]作用域中
  void reassemble({required Map<String, Map<VmKeys, dynamic>> sourceTrees}) {
    if (_objectStack.length != 4) throw ('Cannot reassemble because _objectStack.length is not 4: ${_objectStack.length}');
    _sourceTrees.clear(); //清空旧语法树
    _objectStack.last.clear(); //清空旧应用库
    _sourceTrees.addAll(sourceTrees); //复制新语法树
    _sourceTrees.forEach((key, value) => VmRunnerCore._scanMap(this, value)); //生成新应用库
  }

  ///释放底层的绑定与本实例的[应用库]作用域
  void shutdown() {
    _sourceTrees.clear(); //清空旧语法树
    _objectStack.last.clear(); //清空旧应用库
    VmClass.shutdownInternalClassSearchRunner(); //从底层解绑应用库类型搜索器
  }

  ///添加虚拟类型[vmclass]到[应用库]作用域
  VmClass addClassToAppScope(VmClass vmclass) {
    if (_objectStack.length != 4) throw ('Cannot addClassToAppScope because _objectStack.length is not 4: ${_objectStack.length}');
    addVmObject(vmclass);
    return vmclass;
  }

  ///从[应用库]作用域中搜索标识符[identifier]对应的虚拟类型
  VmClass? searchClassInAppScope(String identifier) {
    final vmobject = _objectStack[3][identifier];
    if (vmobject is VmClass) return vmobject;
    return null;
  }

  ///添加虚拟对象[vmobject]到当前作用域
  VmObject addVmObject(VmObject vmobject) {
    final scopeMap = _objectStack.last; //取栈顶作用域
    if (scopeMap.containsKey(vmobject.identifier)) throw ('Already exists VmObject in current scope, identifier is: ${vmobject.identifier}');
    scopeMap[vmobject.identifier] = vmobject;
    return vmobject;
  }

  ///获取标识符[identifier]对应的虚拟对象
  VmObject getVmObject(String identifier) {
    for (var i = _objectStack.length - 1; i >= 0; i--) {
      final vmobject = _objectStack[i][identifier];
      if (vmobject != null) return vmobject;
    }
    throw ('Not found VmObject in every scope, identifier is: $identifier');
  }

  ///从到当前作用域移除标识符[identifier]对应的虚拟对象
  VmObject delVmObject(String identifier) {
    final scopeMap = _objectStack.last; //取栈顶作用域
    final vmobject = scopeMap.remove(identifier);
    if (vmobject == null) throw ('Not found VmObject in current scope, identifier is: $identifier');
    return vmobject;
  }

  ///栈顶作用域是否已经存在标识符[identifier]指向的对象
  bool inCurrentScope(String identifier) => _objectStack.last.containsKey(identifier);

  ///在虚拟机中的[methodName]指定的任意类型函数
  dynamic callFunction(String methodName, {List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments}) {
    final nameList = methodName.split('.');
    var instance = getVmObject(nameList.first);
    //先尝试属性链的解析与调用
    for (var i = 1; i < nameList.length; i++) {
      final property = nameList[i];
      if (i == nameList.length - 1) {
        instance = VmLazyer(isMethod: true, instance: instance, property: property, listArguments: positionalArguments, nameArguments: namedArguments);
        return instance.getValue();
      } else {
        instance = VmLazyer(instance: instance, property: property); //继续属性链的解析
      }
    }
    //这里必然是只有一项的情况
    instance = VmLazyer(isMethod: true, instance: instance, property: instance.identifier, instanceByProperty: true, listArguments: positionalArguments, nameArguments: namedArguments);
    return instance.getValue();
  }

  T _runAloneScope<T>(T Function(Map<String, VmObject> scope) callback, {List<Map<String, VmObject>> scopeList = const []}) {
    if (objectStackInAndOutReport != null) objectStackInAndOutReport!(true, true, _objectStack.length);
    scopeList.isEmpty ? _objectStack.add({}) : _objectStack.addAll(scopeList); //添加作用域
    try {
      final result = callback(_objectStack.last); //回调逻辑
      scopeList.isEmpty ? _objectStack.removeLast() : _objectStack.removeRange(_objectStack.length - scopeList.length, _objectStack.length); //移除作用域
      if (objectStackInAndOutReport != null) objectStackInAndOutReport!(false, true, _objectStack.length);
      return result; //返回结果
    } catch (_) {
      scopeList.isEmpty ? _objectStack.removeLast() : _objectStack.removeRange(_objectStack.length - scopeList.length, _objectStack.length); //移除作用域
      if (objectStackInAndOutReport != null) objectStackInAndOutReport!(false, false, _objectStack.length);
      rethrow; //继续抛出
    }
  }

  ///内部定义类的静态方法的回调监听
  dynamic _staticListener(List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments, VmClass staticScope, List<Map<VmKeys, dynamic>>? instanceFields, VmValue method) {
    if (instanceFields != null) {
      //原始构造函数
      final initValue = method.prepareForConstructor(positionalArguments, namedArguments, staticScope); //创建初始值
      final instanceScope = VmValue.forVariable(identifier: VmRunnerCore._classConstructorSelf_, initType: staticScope.identifier, initValue: initValue); //创建新实例
      _runAloneScope((scope) {
        addVmObject(instanceScope); //添加被构造的关键变量
        VmRunnerCore._scanList(this, instanceFields); // => _scanFieldDeclaration or _scanMethodDeclaration 构建实例成员字段
        instanceScope.bindStaticScope(staticScope); //构建实例成员字段完成后，立即绑定实例的静态作用域
        instanceScope.bindMemberScope(); //构建实例成员字段完成后，绑定成员的全部作用域
        VmRunnerCore._scanVmFunction(this, positionalArguments, namedArguments, method, instanceScope); //构建实例成员字段完成后，再运行函数的内容
        delVmObject(VmRunnerCore._classConstructorSelf_); //删除被构造的关键变量
      }, scopeList: [
        staticScope.internalStaticPropertyMap!,
        ...instanceScope.internalInstancePropertyMapList,
      ]);
      return instanceScope;
    } else {
      return _runAloneScope((scope) {
        return VmRunnerCore._scanVmFunction(this, positionalArguments, namedArguments, method, null);
      }, scopeList: [
        staticScope.internalStaticPropertyMap!,
      ]);
    }
  }

  ///内部定义类的实例方法的回调监听
  dynamic _instanceListener(List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments, VmClass? staticScope, VmValue? instanceScope, VmValue method) {
    final scopeList = <Map<String, VmObject>>[];
    if (staticScope != null) scopeList.add(staticScope.internalStaticPropertyMap!); //类静态作用域
    if (instanceScope != null) scopeList.addAll(instanceScope.internalInstancePropertyMapList); //实例作用域
    return _runAloneScope((scope) {
      return VmRunnerCore._scanVmFunction(this, positionalArguments, namedArguments, method, null);
    }, scopeList: scopeList);
  }

  ///将应用库语法树集合转换为易读的JSON对象
  Map<String, dynamic> toJsonSourceTrees({String? key}) {
    if (key == null) {
      return {'_sourceTrees': VmObject.treeValue(_sourceTrees)};
    } else {
      return {'_sourceTrees[$key]': VmObject.treeValue(_sourceTrees[key])};
    }
  }

  ///将运行时作用域堆栈转换为易读的JSON对象
  Map<String, dynamic> toJsonObjectStack({int? index, bool simple = true}) {
    if (index == null) {
      return {'_objectStack': simple ? _objectStack.map((e) => e.map((key, value) => MapEntry(key, value.toString()))).toList() : _objectStack};
    } else {
      return {'_objectStack[$index]': simple ? _objectStack[index].map((key, value) => MapEntry(key, value.toString())) : _objectStack[index]};
    }
  }

  ///作用域堆栈的变化通知
  static void Function(bool isIn, bool isOk, int stackLength)? objectStackInAndOutReport;

  ///全局作用域列表：[ 基本库，核心库，用户库 ]
  static final List<Map<String, VmObject>> _globalScopeList = [{}, {}, {}];

  ///加载全局类库与自定义类库
  static void loadGlobalLibrary({List<VmClass> customClassList = const [], List<VmProxy> customProxyList = const []}) {
    //基本库
    final baseScope = _globalScopeList[0];
    for (var vmclass in VmClass.libraryBaseList) {
      if (baseScope.containsKey(vmclass.identifier)) throw ('Already exists VmClass in global base scope, identifier is: ${vmclass.identifier}');
      baseScope[vmclass.identifier] = VmClass.addClass(vmclass); //同时添加到底层的全局类库中
    }
    //核心库
    final coreScope = _globalScopeList[1];
    for (var vmclass in VmLibrary.libraryClassList) {
      if (coreScope.containsKey(vmclass.identifier)) throw ('Already exists VmClass in global core scope, identifier is: ${vmclass.identifier}');
      coreScope[vmclass.identifier] = VmClass.addClass(vmclass); //同时添加到底层的全局类库中
    }
    for (var vmproxy in VmLibrary.libraryProxyList) {
      if (coreScope.containsKey(vmproxy.identifier)) throw ('Already exists VmProxy in global core scope, identifier is: ${vmproxy.identifier}');
      coreScope[vmproxy.identifier] = vmproxy;
    }
    //用户库
    final userScope = _globalScopeList[2];
    for (var vmclass in customClassList) {
      if (userScope.containsKey(vmclass.identifier)) throw ('Already exists VmClass in global user scope, identifier is: ${vmclass.identifier}');
      userScope[vmclass.identifier] = VmClass.addClass(vmclass); //同时添加到底层的全局类库中
    }
    for (var vmproxy in customProxyList) {
      if (userScope.containsKey(vmproxy.identifier)) throw ('Already exists VmProxy in global user scope, identifier is: ${vmproxy.identifier}');
      userScope[vmproxy.identifier] = vmproxy;
    }
    //底层全局类库排序
    VmClass.sortClassDesc();
  }
}

///
///Dart语言子集的运行器核心逻辑
///
class VmRunnerCore {
  ///当前cascade操作的操作者
  static const _cascadeOperatorValue_ = '___cascadeOperatorValue___';

  ///当前switch(x)语句的x值
  static const _switchConditionValue_ = '___switchConditionValue___';

  ///当前for语句关键变量标识
  static const _forLoopPartsPrepared_ = '___forLoopPartsPrepared___';

  ///当前定义的class名称标识
  static const _classDeclarationName_ = '___classDeclarationName___';

  ///当前构造的class实例自身
  static const _classConstructorSelf_ = '___classConstructorSelf___';

  static final Map<VmKeys, dynamic Function(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node)> _scanner = {
    VmKeys.$CompilationUnit: _scanCompilationUnit,
    VmKeys.$TopLevelVariableDeclaration: _scanTopLevelVariableDeclaration,
    VmKeys.$VariableDeclarationList: _scanVariableDeclarationList,
    VmKeys.$VariableDeclaration: _scanVariableDeclaration,
    VmKeys.$FunctionDeclaration: _scanFunctionDeclaration,
    VmKeys.$NamedType: _scanNamedType,
    VmKeys.$GenericFunctionType: _scanGenericFunctionType,
    VmKeys.$SimpleIdentifier: _scanSimpleIdentifier,
    VmKeys.$PrefixedIdentifier: _scanPrefixedIdentifier,
    VmKeys.$DeclaredIdentifier: _scanDeclaredIdentifier,
    VmKeys.$NullLiteral: _scanNullLiteral,
    VmKeys.$IntegerLiteral: _scanIntegerLiteral,
    VmKeys.$DoubleLiteral: _scanDoubleLiteral,
    VmKeys.$BooleanLiteral: _scanBooleanLiteral,
    VmKeys.$SimpleStringLiteral: _scanSimpleStringLiteral,
    VmKeys.$InterpolationString: _scanInterpolationString,
    VmKeys.$StringInterpolation: _scanStringInterpolation,
    VmKeys.$ListLiteral: _scanListLiteral,
    VmKeys.$SetOrMapLiteral: _scanSetOrMapLiteral,
    VmKeys.$MapLiteralEntry: _scanMapLiteralEntry,
    VmKeys.$BinaryExpression: _scanBinaryExpression,
    VmKeys.$PrefixExpression: _scanPrefixExpression,
    VmKeys.$PostfixExpression: _scanPostfixExpression,
    VmKeys.$AssignmentExpression: _scanAssignmentExpression,
    VmKeys.$ConditionalExpression: _scanConditionalExpression,
    VmKeys.$ParenthesizedExpression: _scanParenthesizedExpression,
    VmKeys.$IndexExpression: _scanIndexExpression,
    VmKeys.$InterpolationExpression: _scanInterpolationExpression,
    VmKeys.$AsExpression: _scanAsExpression,
    VmKeys.$IsExpression: _scanIsExpression,
    VmKeys.$CascadeExpression: _scanCascadeExpression,
    VmKeys.$ThrowExpression: _scanThrowExpression,
    VmKeys.$FunctionExpression: _scanFunctionExpression,
    VmKeys.$NamedExpression: _scanNamedExpression,
    VmKeys.$InstanceCreationExpression: _scanInstanceCreationExpression,
    VmKeys.$FormalParameterList: _scanFormalParameterList,
    VmKeys.$SuperFormalParameter: _scanSuperFormalParameter,
    VmKeys.$FieldFormalParameter: _scanFieldFormalParameter,
    VmKeys.$SimpleFormalParameter: _scanSimpleFormalParameter,
    VmKeys.$FunctionTypedFormalParameter: _scanFunctionTypedFormalParameter,
    VmKeys.$DefaultFormalParameter: _scanDefaultFormalParameter,
    VmKeys.$ExpressionFunctionBody: _scanExpressionFunctionBody,
    VmKeys.$BlockFunctionBody: _scanBlockFunctionBody,
    VmKeys.$EmptyFunctionBody: _scanEmptyFunctionBody,
    VmKeys.$MethodInvocation: _scanMethodInvocation,
    VmKeys.$ArgumentList: _scanArgumentList,
    VmKeys.$PropertyAccess: _scanPropertyAccess,
    VmKeys.$Block: _scanBlock,
    VmKeys.$VariableDeclarationStatement: _scanVariableDeclarationStatement,
    VmKeys.$ExpressionStatement: _scanExpressionStatement,
    VmKeys.$IfStatement: _scanIfStatement,
    VmKeys.$SwitchStatement: _scanSwitchStatement,
    VmKeys.$SwitchCase: _scanSwitchCase,
    VmKeys.$SwitchDefault: _scanSwitchDefault,
    VmKeys.$ForStatement: _scanForStatement,
    VmKeys.$ForPartsWithDeclarations: _scanForPartsWithDeclarations,
    VmKeys.$ForEachPartsWithDeclaration: _scanForEachPartsWithDeclaration,
    VmKeys.$WhileStatement: _scanWhileStatement,
    VmKeys.$DoStatement: _scanDoStatement,
    VmKeys.$BreakStatement: _scanBreakStatement,
    VmKeys.$ReturnStatement: _scanReturnStatement,
    VmKeys.$ContinueStatement: _scanContinueStatement,
    VmKeys.$ClassDeclaration: _scanClassDeclaration,
    VmKeys.$FieldDeclaration: _scanFieldDeclaration,
    VmKeys.$ConstructorDeclaration: _scanConstructorDeclaration,
    VmKeys.$ConstructorFieldInitializer: _scanConstructorFieldInitializer,
    VmKeys.$MethodDeclaration: _scanMethodDeclaration,
  };

  static dynamic _scanMap(VmRunner runner, Map<VmKeys, dynamic>? node) {
    if (node == null) return null;
    if (node.length != 2) throw ('Not two key: ${node.keys.toList()}');
    final key = node.keys.where((e) => e != VmKeys.$NodeSourceKey).first;
    try {
      final scanner = _scanner[key];
      if (scanner == null) throw ('Not found scanner: $key');
      return scanner(runner, node, node[key]);
    } catch (error, stack) {
      final source = node[VmKeys.$NodeSourceKey][VmKeys.$NodeSourceValue];
      if (error is VmException) {
        error.sourceStack.add(source);
        error.isCompilationUnit = key == VmKeys.$CompilationUnit;
        rethrow; //继续抛出
      } else {
        throw VmException(error, stack, source, key == VmKeys.$CompilationUnit); //抛出新的
      }
    }
  }

  static List<dynamic>? _scanList(VmRunner runner, List<Map<VmKeys, dynamic>?>? nodeList) => nodeList?.map((e) => _scanMap(runner, e)).toList();

  static dynamic _scanVmFunction(VmRunner runner, List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments, VmValue method, VmValue? buildTarget) {
    final parameters = method.prepareForInvocation(positionalArguments, namedArguments, buildTarget); //准备函数参数
    final result = runner._runAloneScope((scope) {
      for (var element in parameters) {
        runner.addVmObject(element);
      }
      _scanList(runner, method.metaData.initTree); // => _scanConstructorFieldInitializer 运行构造函数的参数初始化树
      return _scanMap(runner, method.metaData.bodyTree); //运行通用的函数体语法树
    });
    return VmObject.readLogic(result); //注意：为了保证能够逻辑处理，此处使用的是逻辑值
  }

  static void _scanCompilationUnit(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) => _scanList(runner, node[VmKeys.$CompilationUnitDeclarations]);

  static void _scanTopLevelVariableDeclaration(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) => _scanMap(runner, node[VmKeys.$TopLevelVariableDeclarationVariables]);

  static List<VmValue>? _scanVariableDeclarationList(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    //属性读取
    final type = node[VmKeys.$VariableDeclarationListType] as Map<VmKeys, dynamic>?;
    final variables = node[VmKeys.$VariableDeclarationListVariables] as List<Map<VmKeys, dynamic>?>?;
    //逻辑处理
    final typeResult = _scanMap(runner, type) as VmHelper?; // => _scanNamedType or _scanGenericFunctionType or null
    return variables?.map((item) {
      final itemResult = _scanMap(runner, item) as VmHelper; // => _scanVariableDeclaration
      return runner.addVmObject(
        VmValue.forVariable(
          identifier: itemResult.fieldName,
          initType: typeResult?.fieldType,
          initValue: itemResult.fieldValue,
        ),
      ) as VmValue;
    }).toList();
  }

  static VmHelper _scanVariableDeclaration(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final name = node[VmKeys.$VariableDeclarationName] as String;
    final initializer = node[VmKeys.$VariableDeclarationInitializer] as Map<VmKeys, dynamic>?;
    final initializerResult = _scanMap(runner, initializer);
    return VmHelper(fieldName: name, fieldValue: initializerResult);
  }

  static VmValue _scanFunctionDeclaration(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    //属性读取
    final isGetter = node[VmKeys.$FunctionDeclarationIsGetter] as bool;
    final isSetter = node[VmKeys.$FunctionDeclarationIsSetter] as bool;
    final name = node[VmKeys.$FunctionDeclarationName] as String;
    final functionExpression = node[VmKeys.$FunctionDeclarationFunctionExpression] as Map<VmKeys, dynamic>?;
    //逻辑处理
    final functionExpressionResult = _scanMap(runner, functionExpression) as VmValue?; // => _scanFunctionExpression or null
    return runner.addVmObject(
      VmValue.forFunction(
        identifier: name,
        isIniter: functionExpressionResult?.metaData.isIniter,
        isStatic: functionExpressionResult?.metaData.isStatic,
        isGetter: isGetter,
        isSetter: isSetter,
        listArguments: functionExpressionResult?.metaData.listArguments,
        nameArguments: functionExpressionResult?.metaData.nameArguments,
        initTree: functionExpressionResult?.metaData.initTree,
        bodyTree: functionExpressionResult?.metaData.bodyTree,
        staticListener: runner._staticListener,
        instanceListener: runner._instanceListener,
      ),
    ) as VmValue;
  }

  static VmHelper _scanNamedType(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) => VmHelper(fieldType: node[VmKeys.$NamedTypeName]);

  static VmHelper _scanGenericFunctionType(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) => VmHelper(fieldType: VmClass.functionTypeName);

  static VmObject _scanSimpleIdentifier(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) => runner.getVmObject(node[VmKeys.$SimpleIdentifierName]);

  static VmLazyer _scanPrefixedIdentifier(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final prefix = node[VmKeys.$PrefixedIdentifierPrefix] as String;
    final identifier = node[VmKeys.$PrefixedIdentifierIdentifier] as String;
    final prefixResult = runner.getVmObject(prefix);
    return VmLazyer(instance: prefixResult, property: identifier);
  }

  static VmHelper _scanDeclaredIdentifier(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final type = node[VmKeys.$DeclaredIdentifierType] as Map<VmKeys, dynamic>?;
    final name = node[VmKeys.$DeclaredIdentifierName] as String?;
    final typeResult = _scanMap(runner, type) as VmHelper?; // => _scanNamedType or _scanGenericFunctionType or null
    return VmHelper(fieldType: typeResult?.fieldType, fieldName: name);
  }

  static dynamic _scanNullLiteral(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) => node[VmKeys.$NullLiteralValue];

  static int? _scanIntegerLiteral(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) => node[VmKeys.$IntegerLiteralValue];

  static double? _scanDoubleLiteral(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) => node[VmKeys.$DoubleLiteralValue];

  static bool? _scanBooleanLiteral(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) => node[VmKeys.$BooleanLiteralValue];

  static String? _scanSimpleStringLiteral(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) => node[VmKeys.$SimpleStringLiteralValue];

  static String? _scanInterpolationString(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) => node[VmKeys.$InterpolationStringValue];

  static String? _scanStringInterpolation(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) => _scanList(runner, node[VmKeys.$StringInterpolationElements])?.map((e) => VmObject.readValue(e)).join('');

  static List<dynamic>? _scanListLiteral(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) => _scanList(runner, node[VmKeys.$ListLiteralElements])?.map((e) => VmObject.readLogic(e)).toList(); //虽无影响但防嵌套过深，所以取逻辑值，下同

  static dynamic _scanSetOrMapLiteral(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    //属性读取
    final typeArguments = node[VmKeys.$SetOrMapLiteralTypeArguments] as List?;
    final elements = node[VmKeys.$SetOrMapLiteralElements] as List<Map<VmKeys, dynamic>?>?;
    final elementsResults = _scanList(runner, elements);
    if (elementsResults == null) return null; //runtimeType => Null
    //根据<a,b,c>...推断
    if (typeArguments != null) {
      if (typeArguments.length == 2) {
        return {for (MapEntry e in elementsResults) VmObject.readLogic(e.key): VmObject.readLogic(e.value)}; //runtimeType => Map
      } else if (typeArguments.length == 1) {
        return elementsResults.map((e) => VmObject.readLogic(e)).toSet(); //runtimeType => Set
      }
    }
    //根据子项数据类型推断
    if (elementsResults.isNotEmpty) {
      if (elementsResults.first is MapEntry) {
        return {for (MapEntry e in elementsResults) VmObject.readLogic(e.key): VmObject.readLogic(e.value)}; //runtimeType => Map
      } else {
        return elementsResults.toSet().map((e) => VmObject.readLogic(e)).toSet(); //runtimeType => Set
      }
    }
    //因为无任何标识参数时，直接定义{}是个Map，另外final test={} 中 test 也为 Map，所以默认返回Map，
    return {}; //runtimeType => Map
  }

  static MapEntry _scanMapLiteralEntry(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final key = node[VmKeys.$MapLiteralEntryKey] as Map<VmKeys, dynamic>?;
    final value = node[VmKeys.$MapLiteralEntryValue] as Map<VmKeys, dynamic>?;
    return MapEntry(_scanMap(runner, key), _scanMap(runner, value));
  }

  static dynamic _scanBinaryExpression(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final operator = node[VmKeys.$BinaryExpressionOperator] as String?;
    final leftOperand = node[VmKeys.$BinaryExpressionLeftOperand] as Map<VmKeys, dynamic>?;
    final rightOperand = node[VmKeys.$BinaryExpressionRightOperand] as Map<VmKeys, dynamic>?;
    final leftResult = _scanMap(runner, leftOperand);
    final rightResult = _scanMap(runner, rightOperand);
    final leftValue = VmObject.readValue(leftResult);
    final rightValue = VmObject.readValue(rightResult);
    switch (operator) {
      case '+':
        return leftValue + rightValue; //num
      case '-':
        return leftValue - rightValue; //num
      case '*':
        return leftValue * rightValue; //num
      case '/':
        return leftValue / rightValue; //num
      case '%':
        return leftValue % rightValue; //num
      case '~/':
        return leftValue ~/ rightValue; //num
      case '>':
        return leftValue > rightValue; //bool
      case '<':
        return leftValue < rightValue; //bool
      case '>=':
        return leftValue >= rightValue; //bool
      case '<=':
        return leftValue <= rightValue; //bool
      case '==':
        return leftValue == rightValue; //bool
      case '!=':
        return leftValue != rightValue; //bool
      case '&&':
        return leftValue && rightValue; //bool
      case '||':
        return leftValue || rightValue; //bool
      case '??':
        return VmObject.readLogic(leftResult) ?? VmObject.readLogic(rightResult); //注意：为了保证能够逻辑处理，此处使用的是逻辑值
      case '>>':
        return leftValue >> rightValue; //num
      case '<<':
        return leftValue << rightValue; //num
      case '&':
        return leftValue & rightValue; //num
      case '|':
        return leftValue | rightValue; //num
      case '^':
        return leftValue ^ rightValue; //num
      case '>>>':
        return leftValue >>> rightValue; //num
      default:
        throw ('Unsupport BinaryExpression: $operator');
    }
  }

  static dynamic _scanPrefixExpression(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final operator = node[VmKeys.$PrefixExpressionOperator] as String?;
    final operand = node[VmKeys.$PrefixExpressionOperand] as Map<VmKeys, dynamic>?;
    final operandResult = _scanMap(runner, operand);
    final operandValue = VmObject.readValue(operandResult);
    dynamic value;
    switch (operator) {
      case '-':
        value = -operandValue; //num
        break;
      case '!':
        value = !operandValue; //bool
        break;
      case '~':
        value = ~operandValue; //num
        break;
      case '++':
        value = operandValue + 1; //num
        VmObject.saveValue(operandResult, value);
        break;
      case '--':
        value = operandValue - 1; //num
        VmObject.saveValue(operandResult, value);
        break;
      default:
        throw ('Unsupport PrefixExpression: $operator');
    }
    return value; //返回计算之后的值
  }

  static dynamic _scanPostfixExpression(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final operator = node[VmKeys.$PostfixExpressionOperator] as String?;
    final operand = node[VmKeys.$PostfixExpressionOperand] as Map<VmKeys, dynamic>?;
    final operandResult = _scanMap(runner, operand);
    final operandValue = VmObject.readValue(operandResult);
    dynamic value;
    switch (operator) {
      case '++':
        value = operandValue + 1; //num
        VmObject.saveValue(operandResult, value);
        break;
      case '--':
        value = operandValue - 1; //num
        VmObject.saveValue(operandResult, value);
        break;
      default:
        throw ('Unsupport PostfixExpression: $operator');
    }
    return operandValue; //返回计算之前的值
  }

  static dynamic _scanAssignmentExpression(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final operator = node[VmKeys.$AssignmentExpressionOperator] as String?;
    final leftHandSide = node[VmKeys.$AssignmentExpressionLeftHandSide] as Map<VmKeys, dynamic>?;
    final rightHandSide = node[VmKeys.$AssignmentExpressionRightHandSide] as Map<VmKeys, dynamic>?;
    final leftResult = _scanMap(runner, leftHandSide);
    final rightResult = _scanMap(runner, rightHandSide);
    final leftValue = VmObject.readValue(leftResult);
    final rightValue = VmObject.readValue(rightResult);
    dynamic value;
    switch (operator) {
      case '=':
        value = VmObject.readLogic(rightResult); //注意：为了保证能够逻辑处理，此处使用的是逻辑值
        break;
      case '+=':
        value = leftValue + rightValue; //num
        break;
      case '-=':
        value = leftValue - rightValue; //num
        break;
      case '*=':
        value = leftValue * rightValue; //num
        break;
      case '/=':
        value = leftValue / rightValue; //num
        break;
      case '%=':
        value = leftValue % rightValue; //num
        break;
      case '~/=':
        value = leftValue ~/ rightValue; //num
        break;
      case '??=':
        value = VmObject.readLogic(leftResult) ?? VmObject.readLogic(rightResult); //注意：为了保证能够逻辑处理，此处使用的是逻辑值
        break;
      case '>>=':
        value = leftValue >> rightValue; //num
        break;
      case '<<=':
        value = leftValue << rightValue; //num
        break;
      case '&=':
        value = leftValue & rightValue; //num
        break;
      case '|=':
        value = leftValue | rightValue; //num
        break;
      case '^=':
        value = leftValue ^ rightValue; //num
        break;
      case '>>>=':
        value = leftValue >>> rightValue; //num
        break;
      default:
        throw ('Unsupport AssignmentExpression: $operator');
    }
    VmObject.saveValue(leftResult, value);
    return value; //返回计算之后的值
  }

  static dynamic _scanConditionalExpression(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final condition = node[VmKeys.$ConditionalExpressionCondition] as Map<VmKeys, dynamic>?;
    final thenExpression = node[VmKeys.$ConditionalExpressionThenExpression] as Map<VmKeys, dynamic>?;
    final elseExpression = node[VmKeys.$ConditionalExpressionElseExpression] as Map<VmKeys, dynamic>?;
    final conditionResult = _scanMap(runner, condition);
    final conditionValue = VmObject.readValue(conditionResult) as bool;
    return conditionValue ? _scanMap(runner, thenExpression) : _scanMap(runner, elseExpression);
  }

  static dynamic _scanParenthesizedExpression(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final expression = node[VmKeys.$ParenthesizedExpressionExpression] as Map<VmKeys, dynamic>?;
    return _scanMap(runner, expression);
  }

  static VmLazyer _scanIndexExpression(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final target = node[VmKeys.$IndexExpressionTarget] as Map<VmKeys, dynamic>?;
    final isCascaded = node[VmKeys.$IndexExpressionIsCascaded] as bool;
    final index = node[VmKeys.$IndexExpressionIndex] as Map<VmKeys, dynamic>?;
    final targetResult = _scanMap(runner, target) ?? (isCascaded ? runner.getVmObject(_cascadeOperatorValue_) : null);
    final indexResult = _scanMap(runner, index);
    return VmLazyer(isIndexed: true, instance: targetResult, property: indexResult);
  }

  static dynamic _scanInterpolationExpression(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final expression = node[VmKeys.$InterpolationExpressionExpression] as Map<VmKeys, dynamic>?;
    final expressionResult = _scanMap(runner, expression);
    return VmObject.readValue(expressionResult); //这里必须解析结果
  }

  static dynamic _scanAsExpression(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final expression = node[VmKeys.$AsExpressionExpression] as Map<VmKeys, dynamic>?;
    final type = node[VmKeys.$AsExpressionType] as Map<VmKeys, dynamic>?;
    final expressionResult = _scanMap(runner, expression);
    final typeResult = _scanMap(runner, type) as VmHelper; // => _scanNamedType or _scanGenericFunctionType
    final typeValue = runner.getVmObject(typeResult.fieldType.toString()) as VmClass;
    return typeValue.asThisType(expressionResult);
  }

  static bool _scanIsExpression(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final notOperator = node[VmKeys.$IsExpressionNotOperator] as String?;
    final expression = node[VmKeys.$IsExpressionExpression] as Map<VmKeys, dynamic>?;
    final type = node[VmKeys.$IsExpressionType] as Map<VmKeys, dynamic>?;
    final expressionResult = _scanMap(runner, expression);
    final typeResult = _scanMap(runner, type) as VmHelper; // => _scanNamedType or _scanGenericFunctionType
    final typeValue = runner.getVmObject(typeResult.fieldType.toString()) as VmClass;
    return notOperator == '!' ? !typeValue.isThisType(expressionResult) : typeValue.isThisType(expressionResult);
  }

  static VmValue _scanCascadeExpression(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final target = node[VmKeys.$CascadeExpressionTarget] as Map<VmKeys, dynamic>?;
    final cascadeSections = node[VmKeys.$CascadeExpressionCascadeSections] as List<Map<VmKeys, dynamic>?>?;
    final targetResult = _scanMap(runner, target);
    return runner._runAloneScope<VmValue>((scope) {
      final scopeResult = runner.addVmObject(VmValue.forVariable(identifier: _cascadeOperatorValue_, initValue: targetResult)) as VmValue;
      _scanList(runner, cascadeSections);
      return scopeResult;
    });
  }

  static void _scanThrowExpression(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final expression = node[VmKeys.$ThrowExpressionExpression] as Map<VmKeys, dynamic>?;
    final expressionResult = _scanMap(runner, expression);
    throw (VmObject.readValue(expressionResult)); //这里必须解析结果
  }

  static VmValue _scanFunctionExpression(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    //属性读取
    final parameters = node[VmKeys.$FunctionExpressionParameters] as Map<VmKeys, dynamic>?;
    final body = node[VmKeys.$FunctionExpressionBody] as Map<VmKeys, dynamic>?;
    //逻辑处理
    final parametersResult = _scanMap(runner, parameters) as List?; // => _scanFormalParameterList or null
    final listArguments = <VmHelper>[];
    final nameArguments = <VmHelper>[];
    VmObject.groupDeclarationParameters(parametersResult, listArguments, nameArguments);
    return VmValue.forFunction(
      listArguments: listArguments,
      nameArguments: nameArguments,
      bodyTree: body,
      staticListener: runner._staticListener,
      instanceListener: runner._instanceListener,
    );
  }

  static VmHelper _scanNamedExpression(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final name = node[VmKeys.$NamedExpressionName] as String;
    final expression = node[VmKeys.$NamedExpressionExpression] as Map<VmKeys, dynamic>?;
    final expressionResult = _scanMap(runner, expression);
    return VmHelper(
      fieldName: name,
      fieldValue: expressionResult,
      isNamedField: true,
    );
  }

  static dynamic _scanInstanceCreationExpression(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    //属性读取
    final constructorType = node[VmKeys.$InstanceCreationExpressionConstructorType] as Map<VmKeys, dynamic>?;
    final constructorName = node[VmKeys.$InstanceCreationExpressionConstructorName] as String?;
    final argumentList = node[VmKeys.$InstanceCreationExpressionArgumentList] as Map<VmKeys, dynamic>?;
    //逻辑处理
    final constructorTypeResult = _scanMap(runner, constructorType) as VmHelper; // => _scanNamedType
    final constructorNameResult = constructorName ?? constructorTypeResult.fieldType!;
    final argumentsResult = _scanMap(runner, argumentList) as List?; // => _scanArgumentList or null
    final listArguments = <dynamic>[];
    final nameArguments = <Symbol, dynamic>{};
    VmObject.groupInvocationParameters(argumentsResult, listArguments, nameArguments);
    return VmLazyer(
      isMethod: true,
      instance: runner.getVmObject(constructorTypeResult.fieldType!),
      property: constructorNameResult,
      instanceByProperty: constructorName == null,
      listArguments: listArguments,
      nameArguments: nameArguments,
    ).getLogic(); //注意：为了保证能够逻辑处理，此处使用的是逻辑值
  }

  static List<dynamic>? _scanFormalParameterList(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) => _scanList(runner, node[VmKeys.$FormalParameterListParameters]);

  static VmHelper _scanSuperFormalParameter(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final type = node[VmKeys.$SuperFormalParameterType] as Map<VmKeys, dynamic>?;
    final name = node[VmKeys.$SuperFormalParameterName] as String;
    final isNamed = node[VmKeys.$SuperFormalParameterIsNamed] as bool?;
    final typeResult = _scanMap(runner, type) as VmHelper?; // => _scanNamedType or _scanGenericFunctionType or null
    return VmHelper(
      fieldType: typeResult?.fieldType,
      fieldName: name,
      isNamedField: isNamed ?? false,
      isSuperField: true,
    );
  }

  static VmHelper _scanFieldFormalParameter(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final type = node[VmKeys.$FieldFormalParameterType] as Map<VmKeys, dynamic>?;
    final name = node[VmKeys.$FieldFormalParameterName] as String;
    final isNamed = node[VmKeys.$FieldFormalParameterIsNamed] as bool?;
    final typeResult = _scanMap(runner, type) as VmHelper?; // => _scanNamedType or _scanGenericFunctionType or null
    return VmHelper(
      fieldType: typeResult?.fieldType,
      fieldName: name,
      isNamedField: isNamed ?? false,
      isClassField: true,
    );
  }

  static VmHelper _scanSimpleFormalParameter(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final type = node[VmKeys.$SimpleFormalParameterType] as Map<VmKeys, dynamic>?;
    final name = node[VmKeys.$SimpleFormalParameterName] as String?;
    final isNamed = node[VmKeys.$SimpleFormalParameterIsNamed] as bool?;
    final typeResult = _scanMap(runner, type) as VmHelper?; // => _scanNamedType or _scanGenericFunctionType or null
    return VmHelper(
      fieldType: typeResult?.fieldType,
      fieldName: name,
      isNamedField: isNamed ?? false,
    );
  }

  static VmHelper _scanFunctionTypedFormalParameter(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final name = node[VmKeys.$FunctionTypedFormalParameterName] as String?;
    final isNamed = node[VmKeys.$FunctionTypedFormalParameterIsNamed] as bool?;
    return VmHelper(
      fieldType: VmClass.functionTypeName,
      fieldName: name,
      isNamedField: isNamed ?? false,
    );
  }

  static VmHelper _scanDefaultFormalParameter(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final name = node[VmKeys.$DefaultFormalParameterName] as String?;
    final isNamed = node[VmKeys.$DefaultFormalParameterIsNamed] as bool?;
    final parameter = node[VmKeys.$DefaultFormalParameterParameter] as Map<VmKeys, dynamic>?;
    final defaultValue = node[VmKeys.$DefaultFormalParameterDefaultValue] as Map<VmKeys, dynamic>?;
    final parameterResult = _scanMap(runner, parameter) as VmHelper?; // => _scanFieldFormalParameter or _scanSimpleFormalParameter or null
    final defaultValueResult = _scanMap(runner, defaultValue);
    return VmHelper(
      fieldType: parameterResult?.fieldType,
      fieldName: name ?? parameterResult?.fieldName,
      fieldValue: defaultValueResult,
      isNamedField: isNamed ?? parameterResult?.isNamedField ?? false,
      isClassField: parameterResult?.isClassField ?? false,
      isSuperField: parameterResult?.isSuperField ?? false,
    );
  }

  static dynamic _scanExpressionFunctionBody(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) => _scanMap(runner, node[VmKeys.$ExpressionFunctionBodyExpression]);

  static dynamic _scanBlockFunctionBody(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) => _scanMap(runner, node[VmKeys.$BlockFunctionBodyBlock]);

  static dynamic _scanEmptyFunctionBody(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) => null;

  static dynamic _scanMethodInvocation(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    //属性读取
    final target = node[VmKeys.$MethodInvocationTarget] as Map<VmKeys, dynamic>?;
    final isCascaded = node[VmKeys.$MethodInvocationIsCascaded] as bool;
    final methodName = node[VmKeys.$MethodInvocationMethodName] as String;
    final argumentList = node[VmKeys.$MethodInvocationArgumentList] as Map<VmKeys, dynamic>?;
    //逻辑处理
    final targetResult = _scanMap(runner, target) ?? (isCascaded ? runner.getVmObject(_cascadeOperatorValue_) : null);
    final argumentsResult = _scanMap(runner, argumentList) as List?; // => _scanArgumentList or null
    final listArguments = <dynamic>[];
    final nameArguments = <Symbol, dynamic>{};
    VmObject.groupInvocationParameters(argumentsResult, listArguments, nameArguments);
    return VmLazyer(
      isMethod: true,
      instance: targetResult ?? runner.getVmObject(methodName),
      property: methodName,
      instanceByProperty: targetResult == null,
      listArguments: listArguments,
      nameArguments: nameArguments,
    ).getLogic(); //注意：为了保证能够逻辑处理，此处使用的是逻辑值
  }

  static List<dynamic>? _scanArgumentList(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) => _scanList(runner, node[VmKeys.$ArgumentListArguments]); // => _scanNamedExpression or others

  static VmLazyer _scanPropertyAccess(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final target = node[VmKeys.$PropertyAccessTarget] as Map<VmKeys, dynamic>?;
    final isCascaded = node[VmKeys.$PropertyAccessIsCascaded] as bool;
    final propertyName = node[VmKeys.$PropertyAccessPropertyName] as String;
    final targetResult = _scanMap(runner, target) ?? (isCascaded ? runner.getVmObject(_cascadeOperatorValue_) : null);
    return VmLazyer(instance: targetResult, property: propertyName);
  }

  static dynamic _scanBlock(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final statements = node[VmKeys.$BlockStatements] as List<Map<VmKeys, dynamic>?>?;
    if (statements == null) return null;
    return runner._runAloneScope((scope) {
      for (var item in statements) {
        final itemResult = _scanMap(runner, item);
        if (itemResult is VmSignal && itemResult.isInterrupt) {
          return itemResult;
        }
        if (itemResult is VmSignal && itemResult.isContinue) {
          return itemResult; //continue应跳过剩下的语句
        }
      }
      return null;
    });
  }

  static dynamic _scanVariableDeclarationStatement(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) => _scanMap(runner, node[VmKeys.$VariableDeclarationStatementVariables]);

  static dynamic _scanExpressionStatement(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) => _scanMap(runner, node[VmKeys.$ExpressionStatementExpression]);

  static dynamic _scanIfStatement(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final condition = node[VmKeys.$IfStatementCondition] as Map<VmKeys, dynamic>?;
    final thenExpression = node[VmKeys.$IfStatementThenStatement] as Map<VmKeys, dynamic>?;
    final elseExpression = node[VmKeys.$IfStatementElseStatement] as Map<VmKeys, dynamic>?;
    final conditionResult = _scanMap(runner, condition);
    final conditionValue = VmObject.readValue(conditionResult) as bool;
    return conditionValue ? _scanMap(runner, thenExpression) : _scanMap(runner, elseExpression);
  }

  static dynamic _scanSwitchStatement(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final expression = node[VmKeys.$SwitchStatementExpression] as Map<VmKeys, dynamic>?;
    final members = node[VmKeys.$SwitchStatementMembers] as List<Map<VmKeys, dynamic>?>?;
    if (members == null) return null;
    final expressionResult = _scanMap(runner, expression);
    final expressionValue = VmObject.readValue(expressionResult);
    return runner._runAloneScope((scope) {
      runner.addVmObject(VmValue.forVariable(identifier: _switchConditionValue_, initValue: expressionValue)); //创建关键变量
      for (var item in members) {
        final itemResult = _scanMap(runner, item); // => _scanSwitchCase 或 _scanSwitchDefault
        if (itemResult is VmSignal && itemResult.isInterrupt) {
          return itemResult.isBreak ? itemResult.signalValue : itemResult; //break只跳出本switch范围
        }
        if (itemResult is VmSignal && itemResult.isContinue) {
          return itemResult; //continue应跳过剩下的语句
        }
      }
      return null;
    });
  }

  static dynamic _scanSwitchCase(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final expression = node[VmKeys.$SwitchCaseExpression] as Map<VmKeys, dynamic>?;
    final statements = node[VmKeys.$SwitchCaseStatements] as List<Map<VmKeys, dynamic>?>?;
    if (statements == null) return null;
    final expressionResult = _scanMap(runner, expression);
    final expressionValue = VmObject.readValue(expressionResult);
    final conditionValue = VmObject.readValue(runner.getVmObject(_switchConditionValue_)); //读取关键变量
    if (expressionValue != conditionValue) return null;
    for (var item in statements) {
      final itemResult = _scanMap(runner, item);
      if (itemResult is VmSignal && itemResult.isInterrupt) {
        return itemResult;
      }
      if (itemResult is VmSignal && itemResult.isContinue) {
        return itemResult; //continue应跳过剩下的语句
      }
    }
    return null;
  }

  static dynamic _scanSwitchDefault(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final statements = node[VmKeys.$SwitchDefaultStatements] as List<Map<VmKeys, dynamic>?>?;
    if (statements == null) return null;
    for (var item in statements) {
      final itemResult = _scanMap(runner, item);
      if (itemResult is VmSignal && itemResult.isInterrupt) {
        return itemResult;
      }
      if (itemResult is VmSignal && itemResult.isContinue) {
        return itemResult; //continue应跳过剩下的语句
      }
    }
    return null;
  }

  static dynamic _scanForStatement(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final forLoopParts = node[VmKeys.$ForStatementForLoopParts] as Map<VmKeys, dynamic>?;
    final body = node[VmKeys.$ForStatementBody] as Map<VmKeys, dynamic>?;
    return runner._runAloneScope((scope) {
      bool forLoopPartsResult = _scanMap(runner, forLoopParts); // => _scanForPartsWithDeclarations 或 _scanForEachPartsWithDeclaration 必定为bool
      while (forLoopPartsResult) {
        final bodyResult = _scanMap(runner, body);
        if (bodyResult is VmSignal && bodyResult.isInterrupt) {
          return bodyResult.isBreak ? bodyResult.signalValue : bodyResult; //break只跳出本for范围
        }
        if (bodyResult is VmSignal && bodyResult.isContinue) {
          //继续循环无需任何处理
        }
        forLoopPartsResult = _scanMap(runner, forLoopParts); // => _scanForPartsWithDeclarations 或 _scanForEachPartsWithDeclaration 必定为bool
      }
      return null;
    });
  }

  static bool _scanForPartsWithDeclarations(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final variables = node[VmKeys.$ForPartsWithDeclarationsVariables] as Map<VmKeys, dynamic>?;
    final condition = node[VmKeys.$ForPartsWithDeclarationsCondition] as Map<VmKeys, dynamic>?;
    final updaters = node[VmKeys.$ForPartsWithDeclarationsUpdaters] as List<Map<VmKeys, dynamic>?>?;
    if (runner.inCurrentScope(_forLoopPartsPrepared_)) {
      if (updaters != null) _scanList(runner, updaters); //更新循环变量
    } else {
      runner.addVmObject(VmValue.forVariable(identifier: _forLoopPartsPrepared_)); //创建关键变量
      _scanMap(runner, variables); //创建循环变量
    }
    final conditionResult = _scanMap(runner, condition);
    return VmObject.readValue(conditionResult);
  }

  static bool _scanForEachPartsWithDeclaration(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final loopVariable = node[VmKeys.$ForEachPartsWithDeclarationLoopVariable] as Map<VmKeys, dynamic>?;
    final iterable = node[VmKeys.$ForEachPartsWithDeclarationIterable] as Map<VmKeys, dynamic>?;
    final loopVariableResult = _scanMap(runner, loopVariable) as VmHelper; // => _scanDeclaredIdentifier
    if (runner.inCurrentScope(_forLoopPartsPrepared_)) {
      final iterableValue = VmObject.readValue(runner.getVmObject(_forLoopPartsPrepared_)) as Iterator;
      if (!iterableValue.moveNext()) return false;
      final loopVariable = runner.getVmObject(loopVariableResult.fieldName);
      VmObject.saveValue(loopVariable, iterableValue.current); //更新循环变量
      return true;
    } else {
      final iterableResult = _scanMap(runner, iterable);
      final iterableValue = (VmObject.readValue(iterableResult) as Iterable).iterator;
      if (!iterableValue.moveNext()) return false;
      runner.addVmObject(VmValue.forVariable(identifier: _forLoopPartsPrepared_, initValue: iterableValue)); //创建关键变量
      runner.addVmObject(VmValue.forVariable(identifier: loopVariableResult.fieldName, initType: loopVariableResult.fieldType, initValue: iterableValue.current)); //创建循环变量
      return true;
    }
  }

  static dynamic _scanWhileStatement(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final condition = node[VmKeys.$WhileStatementCondition] as Map<VmKeys, dynamic>?;
    final body = node[VmKeys.$WhileStatementBody] as Map<VmKeys, dynamic>?;
    dynamic conditionResult = _scanMap(runner, condition);
    bool conditionValue = VmObject.readValue(conditionResult);
    while (conditionValue) {
      final bodyResult = _scanMap(runner, body);
      if (bodyResult is VmSignal && bodyResult.isInterrupt) {
        return bodyResult.isBreak ? bodyResult.signalValue : bodyResult; //break只跳出本while范围
      }
      if (bodyResult is VmSignal && bodyResult.isContinue) {
        //继续循环无需任何处理
      }
      conditionResult = _scanMap(runner, condition);
      conditionValue = VmObject.readValue(conditionResult);
    }
    return null;
  }

  static dynamic _scanDoStatement(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final body = node[VmKeys.$DoStatementBody] as Map<VmKeys, dynamic>?;
    final condition = node[VmKeys.$DoStatementCondition] as Map<VmKeys, dynamic>?;
    dynamic conditionResult;
    bool conditionValue;
    do {
      final bodyResult = _scanMap(runner, body);
      if (bodyResult is VmSignal && bodyResult.isInterrupt) {
        return bodyResult.isBreak ? bodyResult.signalValue : bodyResult; //break只跳出本while范围
      }
      if (bodyResult is VmSignal && bodyResult.isContinue) {
        //继续循环无需任何处理
      }
      conditionResult = _scanMap(runner, condition);
      conditionValue = VmObject.readValue(conditionResult);
    } while (conditionValue);
    return null;
  }

  static VmSignal _scanBreakStatement(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) => VmSignal(isBreak: true);

  static VmSignal _scanReturnStatement(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final expression = node[VmKeys.$ReturnStatementExpression] as Map<VmKeys, dynamic>?;
    final expressionResult = _scanMap(runner, expression);
    return VmSignal(isReturn: true, signalValue: expressionResult);
  }

  static VmSignal _scanContinueStatement(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) => VmSignal(isContinue: true);

  ///
  ///类相关
  ///

  static VmClass _scanClassDeclaration(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    //属性读取
    final name = node[VmKeys.$ClassDeclarationName] as String;
    final members = node[VmKeys.$ClassDeclarationMembers] as List<Map<VmKeys, dynamic>?>?;
    final extendsClause = node[VmKeys.$ClassDeclarationExtendsClause] as Map<VmKeys, dynamic>?;
    //逻辑处理
    final result = runner._runAloneScope<VmClass>((scope) {
      final staticScope = scope; //绑定类静态作用域
      runner.addVmObject(VmValue.forVariable(identifier: _classDeclarationName_, initValue: name)); //添加关键变量
      final proxyMap = <String, VmProxy<VmValue>>{}; //字段操作代理集合
      final fieldTree = <Map<VmKeys, dynamic>>[]; //实例字段初始化语法树列表
      final membersResult = _scanList(runner, members) as List; //放在staticScope添加后执行，可自动填入静态成员
      final extendsClauseResult = _scanMap(runner, extendsClause) as VmHelper?; // => _scanNamedType or null
      final superclass = (extendsClauseResult == null ? runner.getVmObject(VmClass.objectTypeName) : runner.getVmObject(extendsClauseResult.fieldType!)) as VmClass;
      if (!superclass.isExternal) {
        throw ('ClassDeclaration unsupport internal superclass: ${superclass.identifier}'); //内部定义的类型 仅支持继承 添加了VmSuper扩展的外部类
      }
      for (var item in membersResult) {
        if (item is List<VmValue>) {
          // => _scanFieldDeclaration 静态变量
          for (var vmvalue in item) {
            if (proxyMap.containsKey(vmvalue.identifier)) throw ('ClassDeclaration already exists proxy: $name.${vmvalue.identifier}');
            proxyMap[vmvalue.identifier] = VmProxy(identifier: vmvalue.identifier, isExternal: false, internalStaticPropertyOperator: vmvalue);
          }
        } else if (item is List<VmHelper>) {
          // => _scanFieldDeclaration 实例变量
          for (var vmhelper in item) {
            if (proxyMap.containsKey(vmhelper.fieldName)) throw ('ClassDeclaration already exists proxy: $name.${vmhelper.fieldName}');
            proxyMap[vmhelper.fieldName] = VmProxy(identifier: vmhelper.fieldName, isExternal: false);
            fieldTree.add(vmhelper.fieldValue); //添加到初始化语法树列表
          }
        } else if (item is VmValue) {
          // => _scanConstructorDeclaration or _scanMethodDeclaration 构造函数、静态函数
          if (proxyMap.containsKey(item.identifier)) throw ('ClassDeclaration already exists proxy: $name.${item.identifier}');
          proxyMap[item.identifier] = VmProxy(identifier: item.identifier, isExternal: false, internalStaticPropertyOperator: item);
        } else if (item is VmHelper) {
          // => _scanMethodDeclaration 实例函数
          if (proxyMap.containsKey(item.fieldName)) throw ('ClassDeclaration already exists proxy: $name.${item.fieldName}');
          proxyMap[item.fieldName] = VmProxy(identifier: item.fieldName, isExternal: false);
          fieldTree.add(item.fieldValue); //添加到初始化语法树列表
        } else {
          throw ('ClassDeclaration unsupport member result: ${item.runtimeType}');
        }
      }
      runner.delVmObject(_classDeclarationName_); //移除关键变量
      //创建类型并返回
      return VmClass<VmValue>(
        identifier: name,
        isExternal: false,
        superclassNames: [...superclass.superclassNames, superclass.identifier],
        internalProxyMap: proxyMap,
        internalStaticPropertyMap: staticScope.map((key, value) => MapEntry(key, value as VmValue)),
        internalInstanceFieldTree: fieldTree,
        internalSuperclass: superclass,
      );
    });
    runner.addClassToAppScope(result); //添加到应用库中
    return result;
  }

  static List<VmObject> _scanFieldDeclaration(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    final isStatic = node[VmKeys.$FieldDeclarationIsStatic] as bool;
    final fields = node[VmKeys.$FieldDeclarationFields] as Map<VmKeys, dynamic>?;
    if (isStatic || runner.inCurrentScope(_classConstructorSelf_)) {
      final fieldsResult = _scanMap(runner, fields) as List<VmValue>; // => _scanVariableDeclarationList 自动在当前作用域创建静态属性，无需再次创建新作用域
      return fieldsResult;
    } else {
      return runner._runAloneScope<List<VmObject>>((scope) {
        final fieldsResult = _scanMap(runner, fields) as List<VmValue>; // => _scanVariableDeclarationList 自动在当前作用域创建属性，所以需要创建临时作用域
        return fieldsResult.map((e) => VmHelper(fieldName: e.identifier, fieldValue: father)).toList(); //返回上级语法树
      });
    }
  }

  static VmValue _scanConstructorDeclaration(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    //属性读取
    final name = node[VmKeys.$ConstructorDeclarationName] as String?;
    final factoryKeyword = node[VmKeys.$ConstructorDeclarationFactoryKeyword] as String?;
    final parameters = node[VmKeys.$ConstructorDeclarationParameters] as Map<VmKeys, dynamic>?;
    final initializers = node[VmKeys.$ConstructorDeclarationInitializers] as List<Map<VmKeys, dynamic>?>?;
    final body = node[VmKeys.$ConstructorDeclarationBody] as Map<VmKeys, dynamic>?;
    //逻辑处理
    final parametersResult = _scanMap(runner, parameters) as List?; // => _scanFormalParameterList or null
    final listArguments = <VmHelper>[];
    final nameArguments = <VmHelper>[];
    VmObject.groupDeclarationParameters(parametersResult, listArguments, nameArguments);
    final vmfunctionResult = VmValue.forFunction(
      identifier: name ?? VmObject.readValue(runner.getVmObject(_classDeclarationName_)),
      isIniter: factoryKeyword == null, //原始构造函数，factory方法也会进入到这个分支
      isStatic: true,
      listArguments: listArguments,
      nameArguments: nameArguments,
      initTree: initializers,
      bodyTree: body,
      staticListener: runner._staticListener,
      instanceListener: runner._instanceListener,
    );
    runner.addVmObject(vmfunctionResult);
    return vmfunctionResult;
  }

  static VmValue _scanConstructorFieldInitializer(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    //属性读取
    final fieldName = node[VmKeys.$ConstructorFieldInitializerFieldName] as String;
    final expression = node[VmKeys.$ConstructorFieldInitializerExpression] as Map<VmKeys, dynamic>?;
    //逻辑处理
    final expressionResult = _scanMap(runner, expression);
    final targetInstance = runner.getVmObject(_classConstructorSelf_) as VmValue;
    targetInstance.getProperty(fieldName).setValue(expressionResult);
    return targetInstance;
  }

  static VmObject _scanMethodDeclaration(VmRunner runner, Map<VmKeys, dynamic> father, Map<VmKeys, dynamic> node) {
    //属性读取
    final isStatic = node[VmKeys.$MethodDeclarationIsStatic] as bool;
    final isGetter = node[VmKeys.$MethodDeclarationIsGetter] as bool;
    final isSetter = node[VmKeys.$MethodDeclarationIsSetter] as bool;
    final name = node[VmKeys.$MethodDeclarationName] as String;
    final parameters = node[VmKeys.$MethodDeclarationParameters] as Map<VmKeys, dynamic>?;
    final body = node[VmKeys.$MethodDeclarationBody] as Map<VmKeys, dynamic>?;
    //逻辑处理
    final nameResult = isSetter ? '$name=' : name; //dart:mirror查看到的标准类set函数也是在字段的末尾添加等于符号
    final parametersResult = _scanMap(runner, parameters) as List?; // => _scanFormalParameterList or null
    final listArguments = <VmHelper>[];
    final nameArguments = <VmHelper>[];
    VmObject.groupDeclarationParameters(parametersResult, listArguments, nameArguments);
    if (isStatic || runner.inCurrentScope(_classConstructorSelf_)) {
      final vmfunctionResult = VmValue.forFunction(
        identifier: nameResult,
        isStatic: isStatic,
        isGetter: isGetter,
        isSetter: isSetter,
        listArguments: listArguments,
        nameArguments: nameArguments,
        bodyTree: body,
        staticListener: runner._staticListener,
        instanceListener: runner._instanceListener,
      );
      runner.addVmObject(vmfunctionResult);
      return vmfunctionResult;
    } else {
      return VmHelper(fieldName: nameResult, fieldValue: father); //返回上级语法树
    }
  }
}

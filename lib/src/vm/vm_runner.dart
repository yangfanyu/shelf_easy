import 'vm_keys.dart';
import 'vm_object.dart';
import 'vm_library.dart';

///
///Dart代码子集的运行器
///
class VmRunner {
  ///对象栈
  final List<Map<String, VmObject>> _objectStack;

  VmRunner() : _objectStack = [{}];

  ///初始化类型库
  void initLibrary() {
    final scopeMap = _objectStack.first; //取全局作用域
    for (var vmclass in VmLibrary.libraryClassList) {
      VmClass.addClass(vmclass); //添加到底层的类型库中
      if (scopeMap.containsKey(vmclass.identifier)) throw ('Already exists VmObject in global scope, identifier is: ${vmclass.identifier}');
      scopeMap[vmclass.identifier] = vmclass; //添加到全局作用域中
    }
    for (var vmproxy in VmLibrary.libraryProxyList) {
      if (scopeMap.containsKey(vmproxy.identifier)) throw ('Already exists VmObject in global scope, identifier is: ${vmproxy.identifier}');
      scopeMap[vmproxy.identifier] = vmproxy; //添加到全局作用域中
    }
  }

  ///扫描语法树并创建预定义内容
  void initRuntime(Map<VmKeys, dynamic> astTree) => VmRunnerCore._scanMap(this, astTree);

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

  ///插入虚拟机对象[vmobject]到当前作用域
  VmObject addVmObject(VmObject vmobject) {
    final scopeMap = _objectStack.last; //取栈顶作用域
    if (scopeMap.containsKey(vmobject.identifier)) throw ('Already exists VmObject in current scope, identifier is: ${vmobject.identifier}');
    scopeMap[vmobject.identifier] = vmobject;
    return vmobject;
  }

  ///当前作用域是否已经存在标识符[identifier]指向的对象
  bool inCurrentScope(String identifier) => _objectStack.last.containsKey(identifier);

  ///执行虚拟机中的[functionName]指定的函数
  T callFunction<T>(String functionName, {List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments}) {
    return VmRunnerCore._scanVmFunction(this, positionalArguments, namedArguments, getVmObject(functionName) as VmValue, null, null);
  }

  ///创建作用域
  Map<String, VmObject> _newScope() {
    final scopeMap = <String, VmObject>{};
    _objectStack.add(scopeMap);
    return scopeMap;
  }

  ///删除作用域
  Map<String, VmObject> _delScope() => _objectStack.removeLast();

  ///内部定义类的静态方法的回调监听
  dynamic _staticListener(List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments, VmClass classScope, List<Map<VmKeys, dynamic>>? instanceFields, VmValue method) {
    if (instanceFields != null) {
      //原始构造函数
      final instanceScope = VmValue.forVariable(identifier: VmRunnerCore._classConstructorSelf_, initType: classScope.identifier, initValue: <String, VmValue>{}); //创建新实例
      _objectStack.add(classScope.internalStaticPropertyMap!); //添加类静态作用域
      _objectStack.add(instanceScope.internalInstancePropertyMap); //添加实例作用域
      addVmObject(instanceScope); //添加被构造的关键变量
      VmRunnerCore._scanVmFunction(this, positionalArguments, namedArguments, method, instanceScope, instanceFields);
      delVmObject(VmRunnerCore._classConstructorSelf_); //删除被构造的关键变量
      _objectStack.removeLast(); //移除实例作用域
      _objectStack.removeLast(); //移除类静态作用域
      return instanceScope..bindFatherOfChildren(); //绑定成员的父实例
    } else {
      //普通静态函数
      _objectStack.add(classScope.internalStaticPropertyMap!); //添加类静态作用域
      final result = VmRunnerCore._scanVmFunction(this, positionalArguments, namedArguments, method, null, instanceFields);
      _objectStack.removeLast(); //移除类静态作用域
      return result;
    }
  }

  ///内部定义类的实例方法的回调监听
  dynamic _instanceListener(List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments, VmClass? classScope, VmValue? instanceScope, VmValue method) {
    if (classScope != null) _objectStack.add(classScope.internalStaticPropertyMap!); //添加类静态作用域
    if (instanceScope != null) _objectStack.add(instanceScope.internalInstancePropertyMap); //添加实例作用域
    final result = VmRunnerCore._scanVmFunction(this, positionalArguments, namedArguments, method, instanceScope, null);
    if (instanceScope != null) _objectStack.removeLast(); //移除实例作用域
    if (classScope != null) _objectStack.removeLast(); //移除类静态作用域
    return result;
  }

  ///转换为可json序列化的数据
  // Map<String, dynamic> toJson() => {'_memberStack': _objectStack};
  Map<String, dynamic> toJson() => {'_memberStack': _objectStack.map((e) => e.map((key, value) => MapEntry(key, value.toString()))).toList()};
}

///
///Dart代码子集的运行器核心逻辑
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

  static final Map<VmKeys, dynamic Function(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node)> _scanner = {
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
    VmKeys.$FormalParameterList: _scanFormalParameterList,
    VmKeys.$FieldFormalParameter: _scanFieldFormalParameter,
    VmKeys.$SimpleFormalParameter: _scanSimpleFormalParameter,
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
    VmKeys.$ClassDeclaration: _scanClassDeclaration,
    VmKeys.$FieldDeclaration: _scanFieldDeclaration,
    VmKeys.$ConstructorDeclaration: _scanConstructorDeclaration,
    VmKeys.$ConstructorFieldInitializer: _scanConstructorFieldInitializer,
    VmKeys.$MethodDeclaration: _scanMethodDeclaration,
  };

  static dynamic _scanMap(VmRunner runner, Map<VmKeys, dynamic>? node) {
    if (node != null && node.length != 1) throw ('Not one key: ${node.keys.toList()}');
    dynamic result;
    node?.forEach((key, value) {
      final scanner = _scanner[key];
      if (scanner == null) throw ('Not found scanner: $key');
      result = scanner(runner, key, value);
    });
    return result;
  }

  static List<dynamic>? _scanList(VmRunner runner, List<Map<VmKeys, dynamic>?>? nodeList) => nodeList?.map((e) => _scanMap(runner, e)).toList();

  static dynamic _scanVmFunction(VmRunner runner, List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments, VmValue method, VmValue? instanceScope, List<Map<VmKeys, dynamic>>? instanceFields) {
    if (instanceFields != null) _scanList(runner, instanceFields); // => _scanFieldDeclaration or _scanMethodDeclaration 构建实例成员属性
    final parameters = method.prepareForRealInvocation(positionalArguments, namedArguments, instanceScope); //准备函数参数
    runner._newScope(); //创建函数作用域
    for (var element in parameters) {
      runner.addVmObject(element);
    }
    _scanList(runner, method.methodInitTree); // => _scanConstructorFieldInitializer 运行构造函数的参数初始化树
    final result = _scanMap(runner, method.methodBodyTree); //运行通用的函数体语法树
    runner._delScope(); //释放函数作用域
    return result is VmSignal ? result.signalValue : result;
  }

  static void _scanCompilationUnit(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => _scanList(runner, node[VmKeys.$CompilationUnitDeclarations]);

  static dynamic _scanTopLevelVariableDeclaration(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => _scanMap(runner, node[VmKeys.$TopLevelVariableDeclarationVariables]);

  static List<VmValue>? _scanVariableDeclarationList(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
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
          initType: typeResult?.typeName,
          initValue: itemResult.fieldValue,
        ),
      ) as VmValue;
    }).toList();
  }

  static VmHelper _scanVariableDeclaration(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    //属性读取
    final name = node[VmKeys.$VariableDeclarationName] as String;
    final initializer = node[VmKeys.$VariableDeclarationInitializer] as Map<VmKeys, dynamic>?;
    //逻辑处理
    final initializerResult = _scanMap(runner, initializer);
    return VmHelper(
      fieldName: name,
      fieldValue: initializerResult,
    );
  }

  static VmValue _scanFunctionDeclaration(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    //属性读取
    final isGetter = node[VmKeys.$FunctionDeclarationIsGetter] as bool;
    final isSetter = node[VmKeys.$FunctionDeclarationIsSetter] as bool;
    final name = node[VmKeys.$FunctionDeclarationName] as String;
    final functionExpression = node[VmKeys.$FunctionDeclarationFunctionExpression] as Map<VmKeys, dynamic>?;
    //逻辑处理
    final functionExpressionResult = _scanMap(runner, functionExpression) as VmValue; // => _scanFunctionExpression
    //创建函数
    return runner.addVmObject(
      VmValue.forFunction(
        identifier: name,
        methodIsGetter: isGetter,
        methodIsSetter: isSetter,
        methodListArguments: functionExpressionResult.methodListArguments,
        methodNameArguments: functionExpressionResult.methodNameArguments,
        methodInitTree: functionExpressionResult.methodInitTree,
        methodBodyTree: functionExpressionResult.methodBodyTree,
        methodStaticListener: functionExpressionResult.methodStaticListener,
        methodInstanceListener: functionExpressionResult.methodInstanceListener,
      ),
    ) as VmValue;
  }

  static VmHelper _scanNamedType(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    //属性读取
    final name = node[VmKeys.$NamedTypeName] as Map<VmKeys, dynamic>?;
    final question = node[VmKeys.$NamedTypeQuestion] as String?;
    //逻辑处理
    final nameResult = _scanMap(runner, name) as VmClass; // => _scanSimpleIdentifier 类型名称必然为int之类的某个类型标识符，此处返回结果必然是VmClass
    return VmHelper(
      typeName: nameResult.identifier,
      typeQuestion: question,
    );
  }

  static VmHelper _scanGenericFunctionType(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    //属性读取
    final name = node[VmKeys.$GenericFunctionTypeName] as String; //Function
    final question = node[VmKeys.$GenericFunctionTypeQuestion] as String?;
    //逻辑处理
    final nameResult = runner.getVmObject(name) as VmClass;
    return VmHelper(
      typeName: nameResult.identifier,
      typeQuestion: question,
    );
  }

  static VmObject _scanSimpleIdentifier(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => runner.getVmObject(node[VmKeys.$SimpleIdentifierName]);

  static VmLazyer _scanPrefixedIdentifier(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final prefix = node[VmKeys.$PrefixedIdentifierPrefix] as String;
    final identifier = node[VmKeys.$PrefixedIdentifierIdentifier] as String;
    final prefixResult = runner.getVmObject(prefix);
    return VmLazyer(
      instance: prefixResult,
      property: identifier,
    );
  }

  static VmHelper _scanDeclaredIdentifier(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    //属性读取
    final type = node[VmKeys.$DeclaredIdentifierType] as Map<VmKeys, dynamic>?;
    final name = node[VmKeys.$DeclaredIdentifierName] as String?;
    //逻辑处理
    final typeResult = _scanMap(runner, type) as VmHelper; // => _scanNamedType or _scanGenericFunctionType
    return VmHelper(
      typeName: typeResult.typeName,
      typeQuestion: typeResult.typeQuestion,
      fieldName: name,
    );
  }

  static dynamic _scanNullLiteral(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => node[VmKeys.$NullLiteralValue];

  static int? _scanIntegerLiteral(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => node[VmKeys.$IntegerLiteralValue];

  static double? _scanDoubleLiteral(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => node[VmKeys.$DoubleLiteralValue];

  static bool? _scanBooleanLiteral(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => node[VmKeys.$BooleanLiteralValue];

  static String? _scanSimpleStringLiteral(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => node[VmKeys.$SimpleStringLiteralValue];

  static String? _scanInterpolationString(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => node[VmKeys.$InterpolationStringValue];

  static String? _scanStringInterpolation(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => _scanList(runner, node[VmKeys.$StringInterpolationElements])?.map((e) => VmValue.readValue(e)).join('');

  static List? _scanListLiteral(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => _scanList(runner, node[VmKeys.$ListLiteralElements]);

  static dynamic _scanSetOrMapLiteral(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    //属性读取
    final typeArguments = node[VmKeys.$SetOrMapLiteralTypeArguments] as List?;
    final elements = node[VmKeys.$SetOrMapLiteralElements] as List<Map<VmKeys, dynamic>?>?;
    final elementsResults = _scanList(runner, elements);
    if (elementsResults == null) return null; //runtimeType => Null
    //根据<a,b,c>...推断
    if (typeArguments != null) {
      if (typeArguments.length == 2) {
        return {for (MapEntry e in elementsResults) e.key: e.value}; //runtimeType => Map
      } else if (typeArguments.length == 1) {
        return elementsResults.toSet(); //runtimeType => Set
      }
    }
    //根据子项数据类型推断
    if (elementsResults.isNotEmpty) {
      if (elementsResults.first is MapEntry) {
        return {for (MapEntry e in elementsResults) e.key: e.value}; //runtimeType => Map
      } else {
        return elementsResults.toSet(); //runtimeType => Set
      }
    }
    //因为无任何标识参数时，直接定义{}是个Map，另外final test={} 中 test 也为 Map，所以默认返回Map，
    return {}; //runtimeType => Map
  }

  static MapEntry _scanMapLiteralEntry(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final key = node[VmKeys.$MapLiteralEntryKey] as Map<VmKeys, dynamic>?;
    final value = node[VmKeys.$MapLiteralEntryValue] as Map<VmKeys, dynamic>?;
    return MapEntry(_scanMap(runner, key), _scanMap(runner, value));
  }

  static dynamic _scanBinaryExpression(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final operator = node[VmKeys.$BinaryExpressionOperator] as String?;
    final leftOperand = node[VmKeys.$BinaryExpressionLeftOperand] as Map<VmKeys, dynamic>?;
    final rightOperand = node[VmKeys.$BinaryExpressionRightOperand] as Map<VmKeys, dynamic>?;
    final leftResult = _scanMap(runner, leftOperand);
    final rightResult = _scanMap(runner, rightOperand);
    final leftValue = VmValue.readValue(leftResult);
    final rightValue = VmValue.readValue(rightResult);
    switch (operator) {
      case '+':
        return leftValue + rightValue;
      case '-':
        return leftValue - rightValue;
      case '*':
        return leftValue * rightValue;
      case '/':
        return leftValue / rightValue;
      case '%':
        return leftValue % rightValue;
      case '~/':
        return leftValue ~/ rightValue;
      case '>':
        return leftValue > rightValue;
      case '<':
        return leftValue < rightValue;
      case '>=':
        return leftValue >= rightValue;
      case '<=':
        return leftValue <= rightValue;
      case '==':
        return leftValue == rightValue;
      case '!=':
        return leftValue != rightValue;
      case '&&':
        return leftValue && rightValue;
      case '||':
        return leftValue || rightValue;
      case '??':
        return leftValue ?? rightValue;
      case '>>':
        return leftValue >> rightValue;
      case '<<':
        return leftValue << rightValue;
      case '&':
        return leftValue & rightValue;
      case '|':
        return leftValue | rightValue;
      case '^':
        return leftValue ^ rightValue;
      case '>>>':
        return leftValue >>> rightValue;
      default:
        throw ('Unsupport BinaryExpression: $operator');
    }
  }

  static dynamic _scanPrefixExpression(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final operator = node[VmKeys.$PrefixExpressionOperator] as String?;
    final operand = node[VmKeys.$PrefixExpressionOperand] as Map<VmKeys, dynamic>?;
    final operandResult = _scanMap(runner, operand);
    final operandValue = VmValue.readValue(operandResult);
    dynamic value;
    switch (operator) {
      case '-':
        value = -operandValue;
        break;
      case '!':
        value = !operandValue;
        break;
      case '~':
        value = ~operandValue;
        break;
      case '++':
        value = operandValue + 1;
        VmValue.saveValue(operandResult, value);
        break;
      case '--':
        value = operandValue - 1;
        VmValue.saveValue(operandResult, value);
        break;
      default:
        throw ('Unsupport PrefixExpression: $operator');
    }
    return value; //返回计算之后的值
  }

  static dynamic _scanPostfixExpression(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final operator = node[VmKeys.$PostfixExpressionOperator] as String?;
    final operand = node[VmKeys.$PostfixExpressionOperand] as Map<VmKeys, dynamic>?;
    final operandResult = _scanMap(runner, operand);
    final operandValue = VmValue.readValue(operandResult);
    dynamic value;
    switch (operator) {
      case '++':
        value = operandValue + 1;
        VmValue.saveValue(operandResult, value);
        break;
      case '--':
        value = operandValue - 1;
        VmValue.saveValue(operandResult, value);
        break;
      default:
        throw ('Unsupport PostfixExpression: $operator');
    }
    return operandValue; //返回计算之前的值
  }

  static dynamic _scanAssignmentExpression(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final operator = node[VmKeys.$AssignmentExpressionOperator] as String?;
    final leftHandSide = node[VmKeys.$AssignmentExpressionLeftHandSide] as Map<VmKeys, dynamic>?;
    final rightHandSide = node[VmKeys.$AssignmentExpressionRightHandSide] as Map<VmKeys, dynamic>?;
    final leftResult = _scanMap(runner, leftHandSide);
    final rightResult = _scanMap(runner, rightHandSide);
    final leftValue = VmValue.readValue(leftResult);
    final rightValue = VmValue.readValue(rightResult);
    dynamic value;
    switch (operator) {
      case '=':
        value = rightValue;
        break;
      case '+=':
        value = leftValue + rightValue;
        break;
      case '-=':
        value = leftValue - rightValue;
        break;
      case '*=':
        value = leftValue * rightValue;
        break;
      case '/=':
        value = leftValue / rightValue;
        break;
      case '%=':
        value = leftValue % rightValue;
        break;
      case '~/=':
        value = leftValue ~/ rightValue;
        break;
      case '??=':
        value = leftValue ?? rightValue;
        break;
      case '>>=':
        value = leftValue >> rightValue;
        break;
      case '<<=':
        value = leftValue << rightValue;
        break;
      case '&=':
        value = leftValue & rightValue;
        break;
      case '|=':
        value = leftValue | rightValue;
        break;
      case '^=':
        value = leftValue ^ rightValue;
        break;
      case '>>>=':
        value = leftValue >>> rightValue;
        break;
      default:
        throw ('Unsupport AssignmentExpression: $operator');
    }
    VmValue.saveValue(leftResult, value);
    return value; //返回计算之后的值
  }

  static dynamic _scanConditionalExpression(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final condition = node[VmKeys.$ConditionalExpressionCondition] as Map<VmKeys, dynamic>?;
    final thenExpression = node[VmKeys.$ConditionalExpressionThenExpression] as Map<VmKeys, dynamic>?;
    final elseExpression = node[VmKeys.$ConditionalExpressionElseExpression] as Map<VmKeys, dynamic>?;
    final conditionResult = _scanMap(runner, condition);
    final conditionValue = VmValue.readValue(conditionResult) as bool;
    return conditionValue ? _scanMap(runner, thenExpression) : _scanMap(runner, elseExpression);
  }

  static dynamic _scanParenthesizedExpression(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final expression = node[VmKeys.$ParenthesizedExpressionExpression] as Map<VmKeys, dynamic>?;
    return _scanMap(runner, expression);
  }

  static VmLazyer _scanIndexExpression(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final target = node[VmKeys.$IndexExpressionTarget] as Map<VmKeys, dynamic>?;
    final isCascaded = node[VmKeys.$IndexExpressionIsCascaded] as bool;
    final index = node[VmKeys.$IndexExpressionIndex] as Map<VmKeys, dynamic>?;
    final targetResult = _scanMap(runner, target) ?? (isCascaded ? runner.getVmObject(_cascadeOperatorValue_) : null);
    final indexResult = _scanMap(runner, index);
    final targetValue = VmValue.readValue(targetResult);
    final indexValue = VmValue.readValue(indexResult);
    return VmLazyer(
      isIndexed: true,
      instance: targetValue,
      property: indexValue,
    );
  }

  static dynamic _scanInterpolationExpression(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final expression = node[VmKeys.$InterpolationExpressionExpression] as Map<VmKeys, dynamic>?;
    final expressionResult = _scanMap(runner, expression);
    final expressionValue = VmValue.readValue(expressionResult);
    return expressionValue; //这里必须解析结果
  }

  static dynamic _scanAsExpression(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final expression = node[VmKeys.$AsExpressionExpression] as Map<VmKeys, dynamic>?;
    final type = node[VmKeys.$AsExpressionType] as Map<VmKeys, dynamic>?;
    final expressionResult = _scanMap(runner, expression);
    final expressionValue = VmValue.readValue(expressionResult);
    final typeResult = _scanMap(runner, type) as VmHelper; // => _scanNamedType or _scanGenericFunctionType
    final typeValue = runner.getVmObject(typeResult.typeName.toString()) as VmClass;
    return typeValue.asThisType(expressionValue); //类型转换
  }

  static bool _scanIsExpression(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final notOperator = node[VmKeys.$IsExpressionNotOperator] as String?;
    final expression = node[VmKeys.$IsExpressionExpression] as Map<VmKeys, dynamic>?;
    final type = node[VmKeys.$IsExpressionType] as Map<VmKeys, dynamic>?;
    final expressionResult = _scanMap(runner, expression);
    final expressionValue = VmValue.readValue(expressionResult);
    final typeResult = _scanMap(runner, type) as VmHelper; // => _scanNamedType or _scanGenericFunctionType
    final typeValue = runner.getVmObject(typeResult.typeName.toString()) as VmClass;
    return notOperator == '!' ? !typeValue.isThisType(expressionValue) : typeValue.isThisType(expressionValue);
  }

  static dynamic _scanCascadeExpression(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final target = node[VmKeys.$CascadeExpressionTarget] as Map<VmKeys, dynamic>?;
    final cascadeSections = node[VmKeys.$CascadeExpressionCascadeSections] as List<Map<VmKeys, dynamic>?>?;
    final targetResult = _scanMap(runner, target);
    runner._newScope(); //创建作用域，因为可能有嵌套的cascade
    final targetValue = runner.addVmObject(VmValue.forVariable(identifier: _cascadeOperatorValue_, initValue: targetResult));
    _scanList(runner, cascadeSections);
    runner._delScope(); //删除作用域
    return targetValue;
  }

  static void _scanThrowExpression(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final expression = node[VmKeys.$ThrowExpressionExpression] as Map<VmKeys, dynamic>?;
    final expressionResult = _scanMap(runner, expression);
    final expressionValue = VmValue.readValue(expressionResult);
    throw (expressionValue); //这里必须解析结果
  }

  static VmValue _scanFunctionExpression(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    //属性读取
    final parameters = node[VmKeys.$FunctionExpressionParameters] as Map<VmKeys, dynamic>?;
    final body = node[VmKeys.$FunctionExpressionBody] as Map<VmKeys, dynamic>?;
    //逻辑处理
    final parametersResult = _scanMap(runner, parameters) as List?; // => _scanFormalParameterList or null
    final listArguments = <VmHelper>[];
    final nameArguments = <VmHelper>[];
    VmValue.groupDeclarationParameters(parametersResult, listArguments, nameArguments);
    return VmValue.forFunction(
      methodListArguments: listArguments,
      methodNameArguments: nameArguments,
      methodBodyTree: body ?? const {},
      methodStaticListener: runner._staticListener,
      methodInstanceListener: runner._instanceListener,
    );
  }

  static VmHelper _scanNamedExpression(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final name = node[VmKeys.$NamedExpressionName] as String;
    final expression = node[VmKeys.$NamedExpressionExpression] as Map<VmKeys, dynamic>?;
    final expressionResult = _scanMap(runner, expression);
    return VmHelper(
      fieldName: name,
      fieldValue: expressionResult,
      isNamedField: true,
    );
  }

  static List? _scanFormalParameterList(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => _scanList(runner, node[VmKeys.$FormalParameterListParameters]);

  static VmHelper _scanFieldFormalParameter(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final type = node[VmKeys.$FieldFormalParameterType] as Map<VmKeys, dynamic>?;
    final name = node[VmKeys.$FieldFormalParameterName] as String;
    final typeResult = _scanMap(runner, type) as VmHelper?; // => _scanNamedType or _scanGenericFunctionType or null
    return VmHelper(
      typeName: typeResult?.typeName,
      typeQuestion: typeResult?.typeQuestion,
      fieldName: name,
      isClassField: true,
    );
  }

  static VmHelper _scanSimpleFormalParameter(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final type = node[VmKeys.$SimpleFormalParameterType] as Map<VmKeys, dynamic>?;
    final name = node[VmKeys.$SimpleFormalParameterName] as String?;
    final typeResult = _scanMap(runner, type) as VmHelper?; // => _scanNamedType or _scanGenericFunctionType or null
    return VmHelper(
      typeName: typeResult?.typeName,
      typeQuestion: typeResult?.typeQuestion,
      fieldName: name,
    );
  }

  static VmHelper _scanDefaultFormalParameter(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final name = node[VmKeys.$DefaultFormalParameterName] as String?;
    final parameter = node[VmKeys.$DefaultFormalParameterParameter] as Map<VmKeys, dynamic>?;
    final defaultValue = node[VmKeys.$DefaultFormalParameterDefaultValue] as Map<VmKeys, dynamic>?;
    final parameterResult = _scanMap(runner, parameter) as VmHelper?; // => _scanFieldFormalParameter or _scanSimpleFormalParameter
    final defaultValueResult = _scanMap(runner, defaultValue);
    return VmHelper(
      typeName: parameterResult?.typeName,
      typeQuestion: parameterResult?.typeQuestion,
      fieldName: name ?? parameterResult?.fieldName,
      fieldValue: defaultValueResult,
      isNamedField: true,
      isClassField: parameterResult?.isClassField ?? false,
    );
  }

  static dynamic _scanExpressionFunctionBody(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => _scanMap(runner, node[VmKeys.$ExpressionFunctionBodyExpression]);

  static dynamic _scanBlockFunctionBody(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => _scanMap(runner, node[VmKeys.$BlockFunctionBodyBlock]);

  static dynamic _scanEmptyFunctionBody(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => null;

  static dynamic _scanMethodInvocation(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    //属性读取
    final target = node[VmKeys.$MethodInvocationTarget] as Map<VmKeys, dynamic>?;
    final isCascaded = node[VmKeys.$MethodInvocationIsCascaded] as bool;
    final methodName = node[VmKeys.$MethodInvocationMethodName] as String;
    final argumentList = node[VmKeys.$MethodInvocationArgumentList] as Map<VmKeys, dynamic>?;
    final targetResult = _scanMap(runner, target) ?? (isCascaded ? runner.getVmObject(_cascadeOperatorValue_) : runner.getVmObject(methodName));
    final argumentsResult = _scanMap(runner, argumentList) as List?; // => _scanArgumentList or null
    //逻辑处理
    final listArguments = <dynamic>[];
    final nameArguments = <Symbol, dynamic>{};
    VmValue.groupInvocationParameters(argumentsResult, listArguments, nameArguments);
    return VmLazyer(
      isMethod: true,
      instance: targetResult,
      property: methodName,
      listArguments: listArguments,
      nameArguments: nameArguments,
    ).orgValue(); //直接调用返回原始结果
  }

  static List? _scanArgumentList(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => _scanList(runner, node[VmKeys.$ArgumentListArguments]); // => _scanNamedExpression or others

  static VmLazyer _scanPropertyAccess(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    //属性读取
    final target = node[VmKeys.$PropertyAccessTarget] as Map<VmKeys, dynamic>?;
    final isCascaded = node[VmKeys.$PropertyAccessIsCascaded] as bool;
    final propertyName = node[VmKeys.$PropertyAccessPropertyName] as String;
    final targetResult = _scanMap(runner, target) ?? (isCascaded ? runner.getVmObject(_cascadeOperatorValue_) : null);
    //逻辑处理
    return VmLazyer(
      instance: targetResult,
      property: propertyName,
    );
  }

  static dynamic _scanBlock(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final statements = node[VmKeys.$BlockStatements] as List<Map<VmKeys, dynamic>?>?;
    if (statements == null) return null;
    runner._newScope();
    for (var item in statements) {
      final itemResult = _scanMap(runner, item);
      if (itemResult is VmSignal && itemResult.isInterrupt) {
        runner._delScope();
        return itemResult;
      }
    }
    runner._delScope();
    return null;
  }

  static dynamic _scanVariableDeclarationStatement(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => _scanMap(runner, node[VmKeys.$VariableDeclarationStatementVariables]);

  static dynamic _scanExpressionStatement(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => _scanMap(runner, node[VmKeys.$ExpressionStatementExpression]);

  static dynamic _scanIfStatement(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final condition = node[VmKeys.$IfStatementCondition] as Map<VmKeys, dynamic>?;
    final thenExpression = node[VmKeys.$IfStatementThenStatement] as Map<VmKeys, dynamic>?;
    final elseExpression = node[VmKeys.$IfStatementElseStatement] as Map<VmKeys, dynamic>?;
    final conditionResult = _scanMap(runner, condition);
    final conditionValue = VmValue.readValue(conditionResult);
    return conditionValue ? _scanMap(runner, thenExpression) : _scanMap(runner, elseExpression);
  }

  static dynamic _scanSwitchStatement(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final expression = node[VmKeys.$SwitchStatementExpression] as Map<VmKeys, dynamic>?;
    final members = node[VmKeys.$SwitchStatementMembers] as List<Map<VmKeys, dynamic>?>?;
    if (members == null) return null;
    final expressionResult = _scanMap(runner, expression);
    final expressionValue = VmValue.readValue(expressionResult);
    runner._newScope();
    runner.addVmObject(VmValue.forVariable(identifier: _switchConditionValue_, initValue: expressionValue)); //创建关键变量
    for (var item in members) {
      final itemResult = _scanMap(runner, item); // => _scanSwitchCase 或 _scanSwitchDefault
      if (itemResult is VmSignal && itemResult.isInterrupt) {
        runner._delScope();
        return itemResult.isBreak ? VmValue.readValue(itemResult) : itemResult; //break只跳出本switch范围
      }
    }
    runner._delScope();
    return null;
  }

  static dynamic _scanSwitchCase(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final expression = node[VmKeys.$SwitchCaseExpression] as Map<VmKeys, dynamic>?;
    final statements = node[VmKeys.$SwitchCaseStatements] as List<Map<VmKeys, dynamic>?>?;
    if (statements == null) return null;
    final expressionResult = _scanMap(runner, expression);
    final expressionValue = VmValue.readValue(expressionResult);
    final conditionValue = VmValue.readValue(runner.getVmObject(_switchConditionValue_)); //读取关键变量
    if (expressionValue != conditionValue) return null;
    for (var item in statements) {
      final itemResult = _scanMap(runner, item);
      if (itemResult is VmSignal && itemResult.isInterrupt) {
        return itemResult;
      }
    }
    return null;
  }

  static dynamic _scanSwitchDefault(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final statements = node[VmKeys.$SwitchDefaultStatements] as List<Map<VmKeys, dynamic>?>?;
    if (statements == null) return null;
    for (var item in statements) {
      final itemResult = _scanMap(runner, item);
      if (itemResult is VmSignal && itemResult.isInterrupt) {
        return itemResult;
      }
    }
    return null;
  }

  static dynamic _scanForStatement(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final forLoopParts = node[VmKeys.$ForStatementForLoopParts] as Map<VmKeys, dynamic>?;
    final body = node[VmKeys.$ForStatementBody] as Map<VmKeys, dynamic>?;
    runner._newScope();
    bool forLoopPartsResult = _scanMap(runner, forLoopParts); // => _scanForPartsWithDeclarations 或 _scanForEachPartsWithDeclaration 必定为bool
    while (forLoopPartsResult) {
      final bodyResult = _scanMap(runner, body);
      if (bodyResult is VmSignal && bodyResult.isInterrupt) {
        runner._delScope();
        return bodyResult.isBreak ? VmValue.readValue(bodyResult) : bodyResult; //break只跳出本for范围
      }
      forLoopPartsResult = _scanMap(runner, forLoopParts); // => _scanForPartsWithDeclarations 或 _scanForEachPartsWithDeclaration 必定为bool
    }
    runner._delScope();
    return null;
  }

  static bool _scanForPartsWithDeclarations(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
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
    return VmValue.readValue(conditionResult);
  }

  static bool _scanForEachPartsWithDeclaration(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final loopVariable = node[VmKeys.$ForEachPartsWithDeclarationLoopVariable] as Map<VmKeys, dynamic>?;
    final iterable = node[VmKeys.$ForEachPartsWithDeclarationIterable] as Map<VmKeys, dynamic>?;
    final loopVariableResult = _scanMap(runner, loopVariable) as VmHelper;
    if (runner.inCurrentScope(_forLoopPartsPrepared_)) {
      //更新循环变量
      final iterableValue = VmValue.readValue(runner.getVmObject(_forLoopPartsPrepared_)) as Iterator;
      if (!iterableValue.moveNext()) return false;
      final loopVariable = runner.getVmObject(loopVariableResult.fieldName);
      VmValue.saveValue(loopVariable, iterableValue.current);
      return true;
    } else {
      final iterableResult = _scanMap(runner, iterable);
      final iterableValue = (VmValue.readValue(iterableResult) as Iterable).iterator;
      if (!iterableValue.moveNext()) return false;
      runner.addVmObject(VmValue.forVariable(identifier: _forLoopPartsPrepared_, initValue: iterableValue)); //创建关键变量
      //创建循环变量
      runner.addVmObject(VmValue.forVariable(identifier: loopVariableResult.fieldName, initType: loopVariableResult.typeName, initValue: iterableValue.current));
      return true;
    }
  }

  static dynamic _scanWhileStatement(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final condition = node[VmKeys.$WhileStatementCondition] as Map<VmKeys, dynamic>?;
    final body = node[VmKeys.$WhileStatementBody] as Map<VmKeys, dynamic>?;
    dynamic conditionResult = _scanMap(runner, condition);
    bool conditionValue = VmValue.readValue(conditionResult);
    while (conditionValue) {
      final bodyResult = _scanMap(runner, body);
      if (bodyResult is VmSignal && bodyResult.isInterrupt) {
        return bodyResult.isBreak ? VmValue.readValue(bodyResult) : bodyResult; //break只跳出本while范围
      }
      conditionResult = _scanMap(runner, condition);
      conditionValue = VmValue.readValue(conditionResult);
    }
    return null;
  }

  static dynamic _scanDoStatement(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final body = node[VmKeys.$DoStatementBody] as Map<VmKeys, dynamic>?;
    final condition = node[VmKeys.$DoStatementCondition] as Map<VmKeys, dynamic>?;
    dynamic conditionResult;
    bool conditionValue;
    do {
      final bodyResult = _scanMap(runner, body);
      if (bodyResult is VmSignal && bodyResult.isInterrupt) {
        return bodyResult.isBreak ? VmValue.readValue(bodyResult) : bodyResult; //break只跳出本while范围
      }
      conditionResult = _scanMap(runner, condition);
      conditionValue = VmValue.readValue(conditionResult);
    } while (conditionValue);
    return null;
  }

  static VmSignal _scanBreakStatement(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => VmSignal(isBreak: true);

  static VmSignal _scanReturnStatement(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final expression = node[VmKeys.$ReturnStatementExpression] as Map<VmKeys, dynamic>?;
    final expressionResult = _scanMap(runner, expression);
    return VmSignal(isReturn: true, signalValue: expressionResult);
  }

  ///
  ///类相关，下面的内容去掉后对上面的内容无任何影响
  ///

  static VmClass _scanClassDeclaration(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    //属性读取
    final name = node[VmKeys.$ClassDeclarationName] as String;
    final members = node[VmKeys.$ClassDeclarationMembers] as List<Map<VmKeys, dynamic>?>?;
    //逻辑处理
    final staticScope = runner._newScope(); //创建类静态作用域
    runner.addVmObject(VmValue.forVariable(identifier: _classDeclarationName_, initValue: name)); //添加关键变量
    final proxyMap = <String, VmProxy<VmValue>>{}; //代理集合
    final fieldTree = <Map<VmKeys, dynamic>>[]; //实例字段初始化树
    final membersResult = _scanList(runner, members) as List;
    for (var item in membersResult) {
      if (item is List<VmValue>) {
        // => _scanFieldDeclaration 静态变量
        for (var vmvalue in item) {
          proxyMap[vmvalue.identifier] = VmProxy(identifier: vmvalue.identifier, isExternal: false, internalStaticPropertyOperator: vmvalue);
        }
      } else if (item is List<VmHelper>) {
        // => _scanFieldDeclaration 实例变量
        for (var vmhelper in item) {
          proxyMap[vmhelper.fieldName] = VmProxy(identifier: vmhelper.fieldName, isExternal: false);
          fieldTree.add(vmhelper.fieldValue); //添加到语法树列表
        }
      } else if (item is VmValue) {
        // => _scanConstructorFieldInitializer or _scanMethodDeclaration 构造函数、静态函数
        proxyMap[item.identifier] = VmProxy(identifier: item.identifier, isExternal: false, internalStaticPropertyOperator: item);
      } else if (item is VmHelper) {
        // => _scanMethodDeclaration 实例函数
        proxyMap[item.fieldName] = VmProxy(identifier: item.fieldName, isExternal: false);
        fieldTree.add(item.fieldValue); //添加到语法树列表
      } else {
        throw ('ClassDeclaration unsupport member: ${item.runtimeType}');
      }
    }
    runner.delVmObject(_classDeclarationName_); //移除关键变量
    runner._delScope(); //移除类静态作用域
    //创建类型
    final vmclassResult = VmClass<VmValue>(
      identifier: name,
      isExternal: false,
      internalProxyMap: proxyMap,
      internalStaticPropertyMap: staticScope,
      internalInstanceFieldTree: fieldTree,
    );
    VmClass.addClass(vmclassResult); //添加到底层库
    runner.addVmObject(vmclassResult); //添加到运行库
    return vmclassResult;
  }

  static dynamic _scanFieldDeclaration(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final isStatic = node[VmKeys.$FieldDeclarationIsStatic] as bool;
    final fields = node[VmKeys.$FieldDeclarationFields] as Map<VmKeys, dynamic>?;
    if (isStatic || runner.inCurrentScope(_classConstructorSelf_)) {
      final fieldsResult = _scanMap(runner, fields) as List<VmValue>; // => _scanVariableDeclarationList 自动在当前作用域创建静态属性，无需再次添加
      return fieldsResult;
    } else {
      runner._newScope();
      final fieldsResult = _scanMap(runner, fields) as List<VmValue>; // => _scanVariableDeclarationList 自动在当前作用域创建属性，所以需要创建临时作用域
      runner._delScope();
      return fieldsResult.map((e) => VmHelper(fieldName: e.identifier, fieldValue: {key: node})).toList(); //返回上级语法树
    }
  }

  static VmValue _scanConstructorDeclaration(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    //属性读取
    final name = node[VmKeys.$ConstructorDeclarationName] as String?;
    final parameters = node[VmKeys.$ConstructorDeclarationParameters] as Map<VmKeys, dynamic>?;
    final initializers = node[VmKeys.$ConstructorDeclarationInitializers] as List<Map<VmKeys, dynamic>?>?;
    final body = node[VmKeys.$ConstructorDeclarationBody] as Map<VmKeys, dynamic>?;
    //逻辑处理
    final parametersResult = _scanMap(runner, parameters) as List?; // => _scanFormalParameterList or null
    final listArguments = <VmHelper>[];
    final nameArguments = <VmHelper>[];
    VmValue.groupDeclarationParameters(parametersResult, listArguments, nameArguments);
    //创建函数
    final vmfunctionResult = VmValue.forFunction(
      identifier: name ?? VmValue.readValue(runner.getVmObject(_classDeclarationName_)),
      methodIsStatic: true,
      methodListArguments: listArguments,
      methodNameArguments: nameArguments,
      methodInitTree: initializers ?? const [],
      methodBodyTree: body ?? const {},
      methodStaticListener: runner._staticListener,
      methodInstanceListener: runner._instanceListener,
    );
    runner.addVmObject(vmfunctionResult);
    return vmfunctionResult;
  }

  static VmValue _scanConstructorFieldInitializer(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    //属性读取
    final fieldName = node[VmKeys.$ConstructorFieldInitializerFieldName] as String;
    final expression = node[VmKeys.$ConstructorFieldInitializerExpression] as Map<VmKeys, dynamic>?;
    final expressionResult = _scanMap(runner, expression);
    //逻辑处理
    final targetInstance = runner.getVmObject(_classConstructorSelf_) as VmValue;
    targetInstance.getField(fieldName).setValue(expressionResult);
    return targetInstance;
  }

  static dynamic _scanMethodDeclaration(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
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
    VmValue.groupDeclarationParameters(parametersResult, listArguments, nameArguments);
    //创建函数
    if (isStatic || runner.inCurrentScope(_classConstructorSelf_)) {
      final vmfunctionResult = VmValue.forFunction(
        identifier: nameResult,
        methodIsStatic: isStatic,
        methodIsGetter: isGetter,
        methodIsSetter: isSetter,
        methodListArguments: listArguments,
        methodNameArguments: nameArguments,
        methodBodyTree: body ?? const {},
        methodStaticListener: runner._staticListener,
        methodInstanceListener: runner._instanceListener,
      );
      runner.addVmObject(vmfunctionResult);
      return vmfunctionResult;
    } else {
      return VmHelper(fieldName: nameResult, fieldValue: {key: node}); //返回上级语法树
    }
  }
}

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

  ///插入虚拟对象[vmobject]到当前作用域
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
    final result = VmRunnerCore._scanVmFunction(this, positionalArguments, namedArguments, VmObject.readLogic(getVmObject(functionName)), null);
    return VmObject.deepValue(result); //返回深度递归转换后的值
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
  dynamic _staticListener(List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments, VmClass staticScope, List<Map<VmKeys, dynamic>>? instanceFields, VmValue method) {
    if (instanceFields != null) {
      //原始构造函数
      final instanceScope = VmValue.forVariable(identifier: VmRunnerCore._classConstructorSelf_, initType: staticScope.identifier, initValue: <String, VmValue>{}); //创建新实例
      _objectStack.add(staticScope.internalStaticPropertyMap!); //添加类静态作用域
      _objectStack.add(instanceScope.internalInstancePropertyMap); //添加实例作用域
      addVmObject(instanceScope); //添加被构造的关键变量

      VmRunnerCore._scanList(this, instanceFields); // => _scanFieldDeclaration or _scanMethodDeclaration 构建实例成员字段
      instanceScope.bindStaticScope(staticScope); //构建实例成员字段完成后，立即绑定实例的静态作用域
      instanceScope.bindMemberScope(); //构建实例成员字段完成后，绑定成员的全部作用域
      VmRunnerCore._scanVmFunction(this, positionalArguments, namedArguments, method, instanceScope); //构建实例成员字段完成后，再运行函数的内容

      delVmObject(VmRunnerCore._classConstructorSelf_); //删除被构造的关键变量
      _objectStack.removeLast(); //移除实例作用域
      _objectStack.removeLast(); //移除类静态作用域
      return instanceScope;
    } else {
      //普通静态函数
      _objectStack.add(staticScope.internalStaticPropertyMap!); //添加类静态作用域
      final result = VmRunnerCore._scanVmFunction(this, positionalArguments, namedArguments, method, null);
      _objectStack.removeLast(); //移除类静态作用域
      return result;
    }
  }

  ///内部定义类的实例方法的回调监听
  dynamic _instanceListener(List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments, VmClass? staticScope, VmValue? instanceScope, VmValue method) {
    if (staticScope != null) _objectStack.add(staticScope.internalStaticPropertyMap!); //添加类静态作用域
    if (instanceScope != null) _objectStack.add(instanceScope.internalInstancePropertyMap); //添加实例作用域
    final result = VmRunnerCore._scanVmFunction(this, positionalArguments, namedArguments, method, null);
    if (instanceScope != null) _objectStack.removeLast(); //移除实例作用域
    if (staticScope != null) _objectStack.removeLast(); //移除类静态作用域
    return result;
  }

  ///转换为可json序列化的详细数据
  Map<String, dynamic> toJson() => {'_memberStack': _objectStack};

  ///转换为可json序列化的简单数据
  Map<String, dynamic> toSimpleJson() => {'_memberStack': _objectStack.map((e) => e.map((key, value) => MapEntry(key, value.toString()))).toList()};
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

  static dynamic _scanVmFunction(VmRunner runner, List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments, VmValue method, VmValue? buildTarget) {
    final parameters = method.prepareInvocation(positionalArguments, namedArguments, buildTarget); //准备函数参数
    runner._newScope(); //创建函数作用域
    for (var element in parameters) {
      runner.addVmObject(element);
    }
    _scanList(runner, method.metaData.initTree); // => _scanConstructorFieldInitializer 运行构造函数的参数初始化树
    final result = _scanMap(runner, method.metaData.bodyTree); //运行通用的函数体语法树
    runner._delScope(); //释放函数作用域
    return VmObject.readLogic(result); //注意：为了保证能够逻辑处理，此处使用的是逻辑值
  }

  static void _scanCompilationUnit(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => _scanList(runner, node[VmKeys.$CompilationUnitDeclarations]);

  static void _scanTopLevelVariableDeclaration(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => _scanMap(runner, node[VmKeys.$TopLevelVariableDeclarationVariables]);

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
          initType: typeResult?.fieldType,
          initValue: itemResult.fieldValue,
        ),
      ) as VmValue;
    }).toList();
  }

  static VmHelper _scanVariableDeclaration(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final name = node[VmKeys.$VariableDeclarationName] as String;
    final initializer = node[VmKeys.$VariableDeclarationInitializer] as Map<VmKeys, dynamic>?;
    final initializerResult = _scanMap(runner, initializer);
    return VmHelper(fieldName: name, fieldValue: initializerResult);
  }

  static VmValue _scanFunctionDeclaration(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
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

  static VmHelper _scanNamedType(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => VmHelper(fieldType: node[VmKeys.$NamedTypeName]);

  static VmHelper _scanGenericFunctionType(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => VmHelper(fieldType: VmClass.functionTypeName);

  static VmObject _scanSimpleIdentifier(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => runner.getVmObject(node[VmKeys.$SimpleIdentifierName]);

  static VmLazyer _scanPrefixedIdentifier(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final prefix = node[VmKeys.$PrefixedIdentifierPrefix] as String;
    final identifier = node[VmKeys.$PrefixedIdentifierIdentifier] as String;
    final prefixResult = runner.getVmObject(prefix);
    return VmLazyer(instance: prefixResult, property: identifier);
  }

  static VmHelper _scanDeclaredIdentifier(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final type = node[VmKeys.$DeclaredIdentifierType] as Map<VmKeys, dynamic>?;
    final name = node[VmKeys.$DeclaredIdentifierName] as String?;
    final typeResult = _scanMap(runner, type) as VmHelper?; // => _scanNamedType or _scanGenericFunctionType or null
    return VmHelper(fieldType: typeResult?.fieldType, fieldName: name);
  }

  static dynamic _scanNullLiteral(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => node[VmKeys.$NullLiteralValue];

  static int? _scanIntegerLiteral(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => node[VmKeys.$IntegerLiteralValue];

  static double? _scanDoubleLiteral(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => node[VmKeys.$DoubleLiteralValue];

  static bool? _scanBooleanLiteral(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => node[VmKeys.$BooleanLiteralValue];

  static String? _scanSimpleStringLiteral(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => node[VmKeys.$SimpleStringLiteralValue];

  static String? _scanInterpolationString(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => node[VmKeys.$InterpolationStringValue];

  static String? _scanStringInterpolation(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => _scanList(runner, node[VmKeys.$StringInterpolationElements])?.map((e) => VmObject.readValue(e)).join('');

  static List<dynamic>? _scanListLiteral(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => _scanList(runner, node[VmKeys.$ListLiteralElements])?.map((e) => VmObject.readLogic(e)).toList(); //虽无影响但防嵌套过深，所以取逻辑值，下同

  static dynamic _scanSetOrMapLiteral(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
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

  static dynamic _scanPrefixExpression(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
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

  static dynamic _scanPostfixExpression(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
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

  static dynamic _scanAssignmentExpression(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
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

  static dynamic _scanConditionalExpression(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final condition = node[VmKeys.$ConditionalExpressionCondition] as Map<VmKeys, dynamic>?;
    final thenExpression = node[VmKeys.$ConditionalExpressionThenExpression] as Map<VmKeys, dynamic>?;
    final elseExpression = node[VmKeys.$ConditionalExpressionElseExpression] as Map<VmKeys, dynamic>?;
    final conditionResult = _scanMap(runner, condition);
    final conditionValue = VmObject.readValue(conditionResult) as bool;
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
    return VmLazyer(isIndexed: true, instance: targetResult, property: indexResult);
  }

  static dynamic _scanInterpolationExpression(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final expression = node[VmKeys.$InterpolationExpressionExpression] as Map<VmKeys, dynamic>?;
    final expressionResult = _scanMap(runner, expression);
    return VmObject.readValue(expressionResult); //这里必须解析结果
  }

  static dynamic _scanAsExpression(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final expression = node[VmKeys.$AsExpressionExpression] as Map<VmKeys, dynamic>?;
    final type = node[VmKeys.$AsExpressionType] as Map<VmKeys, dynamic>?;
    final expressionResult = _scanMap(runner, expression);
    final typeResult = _scanMap(runner, type) as VmHelper; // => _scanNamedType or _scanGenericFunctionType
    final typeValue = runner.getVmObject(typeResult.fieldType.toString()) as VmClass;
    return typeValue.asThisType(expressionResult);
  }

  static bool _scanIsExpression(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final notOperator = node[VmKeys.$IsExpressionNotOperator] as String?;
    final expression = node[VmKeys.$IsExpressionExpression] as Map<VmKeys, dynamic>?;
    final type = node[VmKeys.$IsExpressionType] as Map<VmKeys, dynamic>?;
    final expressionResult = _scanMap(runner, expression);
    final typeResult = _scanMap(runner, type) as VmHelper; // => _scanNamedType or _scanGenericFunctionType
    final typeValue = runner.getVmObject(typeResult.fieldType.toString()) as VmClass;
    return notOperator == '!' ? !typeValue.isThisType(expressionResult) : typeValue.isThisType(expressionResult);
  }

  static VmValue _scanCascadeExpression(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final target = node[VmKeys.$CascadeExpressionTarget] as Map<VmKeys, dynamic>?;
    final cascadeSections = node[VmKeys.$CascadeExpressionCascadeSections] as List<Map<VmKeys, dynamic>?>?;
    final targetResult = _scanMap(runner, target);
    runner._newScope(); //创建作用域，因为可能有嵌套的cascade
    final targetValue = runner.addVmObject(VmValue.forVariable(identifier: _cascadeOperatorValue_, initValue: targetResult)) as VmValue;
    _scanList(runner, cascadeSections);
    runner._delScope(); //删除作用域
    return targetValue;
  }

  static void _scanThrowExpression(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final expression = node[VmKeys.$ThrowExpressionExpression] as Map<VmKeys, dynamic>?;
    final expressionResult = _scanMap(runner, expression);
    throw (VmObject.readValue(expressionResult)); //这里必须解析结果
  }

  static VmValue _scanFunctionExpression(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
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

  static List<dynamic>? _scanFormalParameterList(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => _scanList(runner, node[VmKeys.$FormalParameterListParameters]);

  static VmHelper _scanFieldFormalParameter(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final type = node[VmKeys.$FieldFormalParameterType] as Map<VmKeys, dynamic>?;
    final name = node[VmKeys.$FieldFormalParameterName] as String;
    final typeResult = _scanMap(runner, type) as VmHelper?; // => _scanNamedType or _scanGenericFunctionType or null
    return VmHelper(
      fieldType: typeResult?.fieldType,
      fieldName: name,
      isClassField: true,
    );
  }

  static VmHelper _scanSimpleFormalParameter(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final type = node[VmKeys.$SimpleFormalParameterType] as Map<VmKeys, dynamic>?;
    final name = node[VmKeys.$SimpleFormalParameterName] as String?;
    final typeResult = _scanMap(runner, type) as VmHelper?; // => _scanNamedType or _scanGenericFunctionType or null
    return VmHelper(
      fieldType: typeResult?.fieldType,
      fieldName: name,
    );
  }

  static VmHelper _scanDefaultFormalParameter(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final name = node[VmKeys.$DefaultFormalParameterName] as String?;
    final parameter = node[VmKeys.$DefaultFormalParameterParameter] as Map<VmKeys, dynamic>?;
    final defaultValue = node[VmKeys.$DefaultFormalParameterDefaultValue] as Map<VmKeys, dynamic>?;
    final parameterResult = _scanMap(runner, parameter) as VmHelper?; // => _scanFieldFormalParameter or _scanSimpleFormalParameter or null
    final defaultValueResult = _scanMap(runner, defaultValue);
    return VmHelper(
      fieldType: parameterResult?.fieldType,
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

  static List<dynamic>? _scanArgumentList(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) => _scanList(runner, node[VmKeys.$ArgumentListArguments]); // => _scanNamedExpression or others

  static VmLazyer _scanPropertyAccess(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final target = node[VmKeys.$PropertyAccessTarget] as Map<VmKeys, dynamic>?;
    final isCascaded = node[VmKeys.$PropertyAccessIsCascaded] as bool;
    final propertyName = node[VmKeys.$PropertyAccessPropertyName] as String;
    final targetResult = _scanMap(runner, target) ?? (isCascaded ? runner.getVmObject(_cascadeOperatorValue_) : null);
    return VmLazyer(instance: targetResult, property: propertyName);
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
    final conditionValue = VmObject.readValue(conditionResult) as bool;
    return conditionValue ? _scanMap(runner, thenExpression) : _scanMap(runner, elseExpression);
  }

  static dynamic _scanSwitchStatement(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final expression = node[VmKeys.$SwitchStatementExpression] as Map<VmKeys, dynamic>?;
    final members = node[VmKeys.$SwitchStatementMembers] as List<Map<VmKeys, dynamic>?>?;
    if (members == null) return null;
    final expressionResult = _scanMap(runner, expression);
    final expressionValue = VmObject.readValue(expressionResult);
    runner._newScope();
    runner.addVmObject(VmValue.forVariable(identifier: _switchConditionValue_, initValue: expressionValue)); //创建关键变量
    for (var item in members) {
      final itemResult = _scanMap(runner, item); // => _scanSwitchCase 或 _scanSwitchDefault
      if (itemResult is VmSignal && itemResult.isInterrupt) {
        runner._delScope();
        return itemResult.isBreak ? itemResult.signalValue : itemResult; //break只跳出本switch范围
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
    final expressionValue = VmObject.readValue(expressionResult);
    final conditionValue = VmObject.readValue(runner.getVmObject(_switchConditionValue_)); //读取关键变量
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
        return bodyResult.isBreak ? bodyResult.signalValue : bodyResult; //break只跳出本for范围
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
    return VmObject.readValue(conditionResult);
  }

  static bool _scanForEachPartsWithDeclaration(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
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

  static dynamic _scanWhileStatement(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    final condition = node[VmKeys.$WhileStatementCondition] as Map<VmKeys, dynamic>?;
    final body = node[VmKeys.$WhileStatementBody] as Map<VmKeys, dynamic>?;
    dynamic conditionResult = _scanMap(runner, condition);
    bool conditionValue = VmObject.readValue(conditionResult);
    while (conditionValue) {
      final bodyResult = _scanMap(runner, body);
      if (bodyResult is VmSignal && bodyResult.isInterrupt) {
        return bodyResult.isBreak ? bodyResult.signalValue : bodyResult; //break只跳出本while范围
      }
      conditionResult = _scanMap(runner, condition);
      conditionValue = VmObject.readValue(conditionResult);
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
        return bodyResult.isBreak ? bodyResult.signalValue : bodyResult; //break只跳出本while范围
      }
      conditionResult = _scanMap(runner, condition);
      conditionValue = VmObject.readValue(conditionResult);
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
    final proxyMap = <String, VmProxy<VmValue>>{}; //字段操作代理集合
    final fieldTree = <Map<VmKeys, dynamic>>[]; //实例字段初始化语法树列表
    final membersResult = _scanList(runner, members) as List; //放在staticScope添加后执行，可自动填入静态成员
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
          fieldTree.add(vmhelper.fieldValue); //添加到初始化语法树列表
        }
      } else if (item is VmValue) {
        // => _scanConstructorDeclaration or _scanMethodDeclaration 构造函数、静态函数
        proxyMap[item.identifier] = VmProxy(identifier: item.identifier, isExternal: false, internalStaticPropertyOperator: item);
      } else if (item is VmHelper) {
        // => _scanMethodDeclaration 实例函数
        proxyMap[item.fieldName] = VmProxy(identifier: item.fieldName, isExternal: false);
        fieldTree.add(item.fieldValue); //添加到初始化语法树列表
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
      internalStaticPropertyMap: staticScope.map((key, value) => MapEntry(key, value as VmValue)),
      internalInstanceFieldTree: fieldTree,
    );
    VmClass.addClass(vmclassResult); //添加到底层库
    runner.addVmObject(vmclassResult); //添加到运行库
    return vmclassResult;
  }

  static List<VmObject> _scanFieldDeclaration(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
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
    VmObject.groupDeclarationParameters(parametersResult, listArguments, nameArguments);
    final vmfunctionResult = VmValue.forFunction(
      identifier: name ?? VmObject.readValue(runner.getVmObject(_classDeclarationName_)),
      isIniter: name == null || name == '_', //原始构造函数，factory方法也会进入到这个分支，所以用name来判断保证只有一个原始构造函数
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

  static VmValue _scanConstructorFieldInitializer(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
    //属性读取
    final fieldName = node[VmKeys.$ConstructorFieldInitializerFieldName] as String;
    final expression = node[VmKeys.$ConstructorFieldInitializerExpression] as Map<VmKeys, dynamic>?;
    //逻辑处理
    final expressionResult = _scanMap(runner, expression);
    final targetInstance = runner.getVmObject(_classConstructorSelf_) as VmValue;
    targetInstance.getProperty(fieldName).setValue(expressionResult);
    return targetInstance;
  }

  static VmObject _scanMethodDeclaration(VmRunner runner, VmKeys key, Map<VmKeys, dynamic> node) {
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
      return VmHelper(fieldName: nameResult, fieldValue: {key: node}); //返回上级语法树
    }
  }
}

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

  ///插入虚拟机对象[vmobject]到当前作用域
  void addVmObject(VmObject vmobject) {
    final scopeMap = _objectStack.last; //取栈顶作用域
    if (scopeMap.containsKey(vmobject.identifier)) throw ('Already exists VmObject in current scope, identifier is: ${vmobject.identifier}');
    _objectStack.last[vmobject.identifier] = vmobject;
  }

  ///批量插入虚拟机对象[vmobjectList]到当前作用域
  void addVmObjectList(List<VmObject> vmobjectList) {
    for (var e in vmobjectList) {
      addVmObject(e);
    }
  }

  ///当前作用域是否已经存在标识符[identifier]指向的对象
  bool inCurrentScope(String identifier) => _objectStack.last.containsKey(identifier);

  ///执行虚拟机中的[functionName]指定的函数
  T callFunction<T>(String functionName, {List<dynamic> positionalArguments = const [], Map<String, dynamic>? namedArguments}) {
    final vmfunction = getVmObject(functionName) as VmFunction;
    final arguments = [...positionalArguments];
    namedArguments?.forEach((key, value) => arguments.add(VmHelper(fieldName: key, fieldValue: value, isNamedField: true)));
    return VmRunnerCore._scanVmFunction(this, vmfunction, arguments);
  }

  ///创建作用域
  void _newScope() => _objectStack.add({});

  ///删除作用域
  void _delScope() => _objectStack.removeLast();

  ///转换为可json序列化的数据
  Map<String, dynamic> toJson() => {'_memberStack': _objectStack.map((e) => e.map((key, value) => MapEntry(key, value.toString()))).toList()};
}

///
///Dart代码子集的运行器核心逻辑
///
class VmRunnerCore {
  ///当前switch(x)语句的x值
  static const _switchConditionValue_ = '___switchConditionValue___';

  ///当前for语句关键变量标识
  static const _forLoopPartsPrepared_ = '___forLoopPartsPrepared___';

  static final Map<VmKeys, dynamic Function(VmRunner runner, Map<VmKeys, dynamic> node)> _scanner = {
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
    VmKeys.$ThrowExpression: _scanThrowExpression,
    VmKeys.$FunctionExpression: _scanFunctionExpression,
    VmKeys.$NamedExpression: _scanNamedExpression,
    VmKeys.$FormalParameterList: _scanFormalParameterList,
    VmKeys.$SimpleFormalParameter: _scanSimpleFormalParameter,
    VmKeys.$DefaultFormalParameter: _scanDefaultFormalParameter,
    VmKeys.$ExpressionFunctionBody: _scanExpressionFunctionBody,
    VmKeys.$BlockFunctionBody: _scanBlockFunctionBody,
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
  };

  static dynamic _scanMap(VmRunner runner, Map<VmKeys, dynamic>? node) {
    if (node != null && node.length != 1) throw ('Not one key: ${node.keys.toList()}');
    dynamic result;
    node?.forEach((key, value) {
      final scanner = _scanner[key];
      if (scanner == null) throw ('Not found scanner: $key');
      result = scanner(runner, value);
    });
    return result;
  }

  static List<dynamic>? _scanList(VmRunner runner, List<Map<VmKeys, dynamic>?>? nodeList) => nodeList?.map((e) => _scanMap(runner, e)).toList();

  static dynamic _scanVmFunction(VmRunner runner, VmFunction vmfunction, List? arguments) {
    runner._newScope(); //创建作用域
    runner.addVmObjectList(vmfunction.prepareForApply(arguments)); //准备局部变量
    final result = _scanMap(runner, vmfunction.functionBodyTree); //运行语法树
    runner._delScope(); //释放作用域
    return VmCaller.getValue(result);
  }

  static void _scanCompilationUnit(VmRunner runner, Map<VmKeys, dynamic> node) => _scanList(runner, node[VmKeys.$CompilationUnitDeclarations]);

  static void _scanTopLevelVariableDeclaration(VmRunner runner, Map<VmKeys, dynamic> node) => _scanMap(runner, node[VmKeys.$TopLevelVariableDeclarationVariables]);

  static void _scanVariableDeclarationList(VmRunner runner, Map<VmKeys, dynamic> node) {
    //属性读取
    final isLate = node[VmKeys.$VariableDeclarationListIsLate] as bool;
    final isFinal = node[VmKeys.$VariableDeclarationListIsFinal] as bool;
    final isConst = node[VmKeys.$VariableDeclarationListIsConst] as bool;
    final keyword = node[VmKeys.$VariableDeclarationListKeyword] as String?;
    final type = node[VmKeys.$VariableDeclarationListType] as Map<VmKeys, dynamic>?;
    final variables = node[VmKeys.$VariableDeclarationListVariables] as List<Map<VmKeys, dynamic>?>?;
    //逻辑处理
    final typeResult = _scanMap(runner, type) as VmHelper?; // => _scanNamedType or null
    variables?.forEach((item) {
      //递归扫描
      final itemResult = _scanMap(runner, item) as VmVariable; // => _scanVariableDeclaration
      //创建变量
      runner.addVmObject(
        VmVariable(
          isLate: isLate,
          isFinal: isFinal,
          isConst: isConst,
          keyword: keyword,
          typeName: typeResult?.typeName,
          typeQuestion: typeResult?.typeQuestion,
          identifier: itemResult.identifier,
          initValue: itemResult.initValue,
        ),
      );
    });
  }

  static VmVariable _scanVariableDeclaration(VmRunner runner, Map<VmKeys, dynamic> node) {
    //属性读取
    final name = node[VmKeys.$VariableDeclarationName] as String;
    final initializer = node[VmKeys.$VariableDeclarationInitializer] as Map<VmKeys, dynamic>?;
    //逻辑处理
    final initializerResult = _scanMap(runner, initializer);
    return VmVariable(identifier: name, initValue: initializerResult);
  }

  static void _scanFunctionDeclaration(VmRunner runner, Map<VmKeys, dynamic> node) {
    //属性读取
    final isGetter = node[VmKeys.$FunctionDeclarationIsGetter] as bool;
    final isSetter = node[VmKeys.$FunctionDeclarationIsSetter] as bool;
    final name = node[VmKeys.$FunctionDeclarationName] as String;
    final returnType = node[VmKeys.$FunctionDeclarationReturnType] as Map<VmKeys, dynamic>?;
    final functionExpression = node[VmKeys.$FunctionDeclarationFunctionExpression] as Map<VmKeys, dynamic>?;
    //逻辑处理
    final returnTypeResult = _scanMap(runner, returnType) as VmHelper?; // => _scanNamedType or null
    final functionExpressionResult = _scanMap(runner, functionExpression) as VmFunction; // => _scanFunctionExpression
    //创建函数
    runner.addVmObject(
      VmFunction(
        identifier: name,
        isGetter: isGetter,
        isSetter: isSetter,
        isAsynchronous: functionExpressionResult.isAsynchronous,
        returnTypeName: returnTypeResult?.typeName,
        returnTypeQuestion: returnTypeResult?.typeQuestion,
        listArguments: functionExpressionResult.listArguments,
        nameArguments: functionExpressionResult.nameArguments,
        functionBodyTree: functionExpressionResult.functionBodyTree,
        callbackListener: functionExpressionResult.callbackListener,
      ),
    );
  }

  static VmHelper _scanNamedType(VmRunner runner, Map<VmKeys, dynamic> node) {
    //属性读取
    final name = node[VmKeys.$NamedTypeName] as Map<VmKeys, dynamic>?;
    final question = node[VmKeys.$NamedTypeQuestion] as String?;
    //逻辑处理
    final nameResult = _scanMap(runner, name) as VmClass; // => _scanSimpleIdentifier 类型名称必然为int之类的某个类型标识符，此处返回结果必然是VmClass
    return VmHelper(typeName: nameResult.identifier, typeQuestion: question);
  }

  static VmHelper _scanGenericFunctionType(VmRunner runner, Map<VmKeys, dynamic> node) {
    //属性读取
    final name = node[VmKeys.$GenericFunctionTypeName] as String; //Function
    final question = node[VmKeys.$GenericFunctionTypeQuestion] as String?;
    //逻辑处理
    final nameResult = runner.getVmObject(name) as VmClass;
    return VmHelper(typeName: nameResult.identifier, typeQuestion: question);
  }

  static VmObject _scanSimpleIdentifier(VmRunner runner, Map<VmKeys, dynamic> node) => runner.getVmObject(node[VmKeys.$SimpleIdentifierName]);

  static VmCaller _scanPrefixedIdentifier(VmRunner runner, Map<VmKeys, dynamic> node) {
    final prefix = node[VmKeys.$PrefixedIdentifierPrefix] as String;
    final identifier = node[VmKeys.$PrefixedIdentifierIdentifier] as String;
    final prefixResult = runner.getVmObject(prefix);
    return VmCaller(target: prefixResult, identifier: identifier); //延迟调用，因为无法确定上层是什么操作
  }

  static VmHelper _scanDeclaredIdentifier(VmRunner runner, Map<VmKeys, dynamic> node) {
    //属性读取
    final type = node[VmKeys.$DeclaredIdentifierType] as Map<VmKeys, dynamic>?;
    final name = node[VmKeys.$DeclaredIdentifierName] as String?;
    //逻辑处理
    final typeResult = _scanMap(runner, type) as VmHelper; // => _scanNamedType
    return VmHelper(typeName: typeResult.typeName, typeQuestion: typeResult.typeQuestion, fieldName: name);
  }

  static dynamic _scanNullLiteral(VmRunner runner, Map<VmKeys, dynamic> node) => node[VmKeys.$NullLiteralValue];

  static int? _scanIntegerLiteral(VmRunner runner, Map<VmKeys, dynamic> node) => node[VmKeys.$IntegerLiteralValue];

  static double? _scanDoubleLiteral(VmRunner runner, Map<VmKeys, dynamic> node) => node[VmKeys.$DoubleLiteralValue];

  static bool? _scanBooleanLiteral(VmRunner runner, Map<VmKeys, dynamic> node) => node[VmKeys.$BooleanLiteralValue];

  static String? _scanSimpleStringLiteral(VmRunner runner, Map<VmKeys, dynamic> node) => node[VmKeys.$SimpleStringLiteralValue];

  static String? _scanInterpolationString(VmRunner runner, Map<VmKeys, dynamic> node) => node[VmKeys.$InterpolationStringValue];

  static String? _scanStringInterpolation(VmRunner runner, Map<VmKeys, dynamic> node) => _scanList(runner, node[VmKeys.$StringInterpolationElements])?.join('');

  static List? _scanListLiteral(VmRunner runner, Map<VmKeys, dynamic> node) => _scanList(runner, node[VmKeys.$ListLiteralElements]);

  static dynamic _scanSetOrMapLiteral(VmRunner runner, Map<VmKeys, dynamic> node) {
    //属性读取
    final typeArguments = node[VmKeys.$SetOrMapLiteralTypeArguments] as List?;
    final elements = node[VmKeys.$SetOrMapLiteralElements] as List<Map<VmKeys, dynamic>?>?;
    final scanResults = _scanList(runner, elements);
    if (scanResults == null) return null; //runtimeType => Null
    //根据<a,b,c>...推断
    if (typeArguments != null) {
      if (typeArguments.length == 2) {
        return {for (MapEntry e in scanResults) e.key: e.value}; //runtimeType => Map
      } else if (typeArguments.length == 1) {
        return scanResults.toSet(); //runtimeType => Set
      }
    }
    //根据子项数据类型推断
    if (scanResults.isNotEmpty) {
      if (scanResults.first is MapEntry) {
        return {for (MapEntry e in scanResults) e.key: e.value}; //runtimeType => Map
      } else {
        return scanResults.toSet(); //runtimeType => Set
      }
    }
    //因为无任何标识参数时，直接定义{}是个Map，另外final test={} 中 test 也为 Map，所以默认返回Map，
    return {}; //runtimeType => Map
  }

  static MapEntry _scanMapLiteralEntry(VmRunner runner, Map<VmKeys, dynamic> node) {
    final key = node[VmKeys.$MapLiteralEntryKey] as Map<VmKeys, dynamic>?;
    final value = node[VmKeys.$MapLiteralEntryValue] as Map<VmKeys, dynamic>?;
    return MapEntry(_scanMap(runner, key), _scanMap(runner, value));
  }

  static dynamic _scanBinaryExpression(VmRunner runner, Map<VmKeys, dynamic> node) {
    final operator = node[VmKeys.$BinaryExpressionOperator] as String?;
    final leftOperand = node[VmKeys.$BinaryExpressionLeftOperand] as Map<VmKeys, dynamic>?;
    final rightOperand = node[VmKeys.$BinaryExpressionRightOperand] as Map<VmKeys, dynamic>?;
    final leftResult = _scanMap(runner, leftOperand);
    final rightResult = _scanMap(runner, rightOperand);
    final leftValue = VmCaller.getValue(leftResult);
    final rightValue = VmCaller.getValue(rightResult);
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

  static dynamic _scanPrefixExpression(VmRunner runner, Map<VmKeys, dynamic> node) {
    final operator = node[VmKeys.$PrefixExpressionOperator] as String?;
    final operand = node[VmKeys.$PrefixExpressionOperand] as Map<VmKeys, dynamic>?;
    final operandResult = _scanMap(runner, operand);
    final operandValue = VmCaller.getValue(operandResult);
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
        VmCaller.setValue(operandResult, value);
        break;
      case '--':
        value = operandValue - 1;
        VmCaller.setValue(operandResult, value);
        break;
      default:
        throw ('Unsupport PrefixExpression: $operator');
    }
    return value; //返回计算之后的值
  }

  static dynamic _scanPostfixExpression(VmRunner runner, Map<VmKeys, dynamic> node) {
    final operator = node[VmKeys.$PostfixExpressionOperator] as String?;
    final operand = node[VmKeys.$PostfixExpressionOperand] as Map<VmKeys, dynamic>?;
    final operandResult = _scanMap(runner, operand);
    final operandValue = VmCaller.getValue(operandResult);
    dynamic value;
    switch (operator) {
      case '++':
        value = operandValue + 1;
        VmCaller.setValue(operandResult, value);
        break;
      case '--':
        value = operandValue - 1;
        VmCaller.setValue(operandResult, value);
        break;
      default:
        throw ('Unsupport PostfixExpression: $operator');
    }
    return operandValue; //返回计算之前的值
  }

  static dynamic _scanAssignmentExpression(VmRunner runner, Map<VmKeys, dynamic> node) {
    final operator = node[VmKeys.$AssignmentExpressionOperator] as String?;
    final leftHandSide = node[VmKeys.$AssignmentExpressionLeftHandSide] as Map<VmKeys, dynamic>?;
    final rightHandSide = node[VmKeys.$AssignmentExpressionRightHandSide] as Map<VmKeys, dynamic>?;
    final leftResult = _scanMap(runner, leftHandSide);
    final rightResult = _scanMap(runner, rightHandSide);
    final leftValue = VmCaller.getValue(leftResult);
    final rightValue = VmCaller.getValue(rightResult);
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
    VmCaller.setValue(leftResult, value);
    return value;
  }

  static dynamic _scanConditionalExpression(VmRunner runner, Map<VmKeys, dynamic> node) {
    final condition = node[VmKeys.$ConditionalExpressionCondition] as Map<VmKeys, dynamic>?;
    final thenExpression = node[VmKeys.$ConditionalExpressionThenExpression] as Map<VmKeys, dynamic>?;
    final elseExpression = node[VmKeys.$ConditionalExpressionElseExpression] as Map<VmKeys, dynamic>?;
    final conditionResult = _scanMap(runner, condition);
    final conditionValue = VmCaller.getValue(conditionResult);
    if (conditionValue) {
      final thenResult = _scanMap(runner, thenExpression);
      return VmCaller.getValue(thenResult);
    } else {
      final elseResult = _scanMap(runner, elseExpression);
      return VmCaller.getValue(elseResult);
    }
  }

  static dynamic _scanParenthesizedExpression(VmRunner runner, Map<VmKeys, dynamic> node) {
    final expression = node[VmKeys.$ParenthesizedExpressionExpression] as Map<VmKeys, dynamic>?;
    final expressionResult = _scanMap(runner, expression);
    return VmCaller.getValue(expressionResult);
  }

  static dynamic _scanIndexExpression(VmRunner runner, Map<VmKeys, dynamic> node) {
    final target = node[VmKeys.$IndexExpressionTarget] as Map<VmKeys, dynamic>?;
    final index = node[VmKeys.$IndexExpressionIndex] as Map<VmKeys, dynamic>?;
    final targetResult = _scanMap(runner, target);
    final indexResult = _scanMap(runner, index);
    final targetValue = VmCaller.getValue(targetResult);
    final indexValue = VmCaller.getValue(indexResult);
    return targetValue[indexValue];
  }

  static dynamic _scanInterpolationExpression(VmRunner runner, Map<VmKeys, dynamic> node) {
    final expression = node[VmKeys.$InterpolationExpressionExpression] as Map<VmKeys, dynamic>?;
    final expressionResult = _scanMap(runner, expression);
    return VmCaller.getValue(expressionResult);
  }

  static dynamic _scanAsExpression(VmRunner runner, Map<VmKeys, dynamic> node) {
    final expression = node[VmKeys.$AsExpressionExpression] as Map<VmKeys, dynamic>?;
    final type = node[VmKeys.$AsExpressionType] as Map<VmKeys, dynamic>?;
    final expressionResult = _scanMap(runner, expression);
    final expressionValue = VmCaller.getValue(expressionResult);
    final typeResult = _scanMap(runner, type) as VmHelper; // => _scanNamedType
    final typeValue = runner.getVmObject(typeResult.typeName.toString()) as VmClass;
    return typeValue.asThisType(expressionValue); //类型转换
  }

  static bool _scanIsExpression(VmRunner runner, Map<VmKeys, dynamic> node) {
    final notOperator = node[VmKeys.$IsExpressionNotOperator] as String?;
    final expression = node[VmKeys.$IsExpressionExpression] as Map<VmKeys, dynamic>?;
    final type = node[VmKeys.$IsExpressionType] as Map<VmKeys, dynamic>?;
    final expressionResult = _scanMap(runner, expression);
    final expressionValue = VmCaller.getValue(expressionResult);
    final typeResult = _scanMap(runner, type) as VmHelper; // => _scanNamedType
    final typeValue = runner.getVmObject(typeResult.typeName.toString()) as VmClass;
    return notOperator == '!' ? !typeValue.isMatched(expressionValue) : typeValue.isMatched(expressionValue);
  }

  static void _scanThrowExpression(VmRunner runner, Map<VmKeys, dynamic> node) {
    final expression = node[VmKeys.$ThrowExpressionExpression] as Map<VmKeys, dynamic>?;
    final expressionResult = _scanMap(runner, expression);
    final expressionValue = VmCaller.getValue(expressionResult);
    throw (expressionValue);
  }

  static VmFunction _scanFunctionExpression(VmRunner runner, Map<VmKeys, dynamic> node) {
    final parameters = node[VmKeys.$FunctionExpressionParameters] as Map<VmKeys, dynamic>?;
    final body = node[VmKeys.$FunctionExpressionBody] as Map<VmKeys, dynamic>?;
    final isAsynchronous = node[VmKeys.$FunctionExpressionBodyIsAsynchronous] as bool;
    final parametersResult = _scanMap(runner, parameters) as List?; // => _scanFormalParameterList or null
    final listArguments = <VmHelper>[];
    final nameArguments = <VmHelper>[];
    if (parametersResult != null) {
      for (VmHelper item in parametersResult) {
        if (item.isNamedField) {
          nameArguments.add(item);
        } else {
          listArguments.add(item);
        }
      }
    }
    return VmFunction(
      isAsynchronous: isAsynchronous,
      listArguments: listArguments,
      nameArguments: nameArguments,
      functionBodyTree: body ?? {},
      callbackListener: (argumentList, vmfunction) => _scanVmFunction(runner, vmfunction, argumentList),
    );
  }

  static VmHelper _scanNamedExpression(VmRunner runner, Map<VmKeys, dynamic> node) {
    final name = node[VmKeys.$NamedExpressionName] as String;
    final expression = node[VmKeys.$NamedExpressionExpression] as Map<VmKeys, dynamic>?;
    final expressionResult = _scanMap(runner, expression);
    return VmHelper(fieldName: name, fieldValue: expressionResult, isNamedField: true);
  }

  static List? _scanFormalParameterList(VmRunner runner, Map<VmKeys, dynamic> node) => _scanList(runner, node[VmKeys.$FormalParameterListParameters]);

  static VmHelper _scanSimpleFormalParameter(VmRunner runner, Map<VmKeys, dynamic> node) {
    final type = node[VmKeys.$SimpleFormalParameterType] as Map<VmKeys, dynamic>?;
    final name = node[VmKeys.$SimpleFormalParameterName] as String?;
    final typeResult = _scanMap(runner, type) as VmHelper?; // => _scanNamedType or null
    return VmHelper(
      typeName: typeResult?.typeName,
      typeQuestion: typeResult?.typeQuestion,
      fieldName: name,
    );
  }

  static VmHelper _scanDefaultFormalParameter(VmRunner runner, Map<VmKeys, dynamic> node) {
    final name = node[VmKeys.$DefaultFormalParameterName] as String?;
    final parameter = node[VmKeys.$DefaultFormalParameterParameter] as Map<VmKeys, dynamic>?;
    final defaultValue = node[VmKeys.$DefaultFormalParameterDefaultValue] as Map<VmKeys, dynamic>?;
    final parameterResult = _scanMap(runner, parameter) as VmHelper?; // => _scanSimpleFormalParameter
    final defaultValueResult = _scanMap(runner, defaultValue);
    return VmHelper(
      typeName: parameterResult?.typeName,
      typeQuestion: parameterResult?.typeQuestion,
      fieldName: name ?? parameterResult?.fieldName,
      fieldValue: defaultValueResult,
      isNamedField: true,
    );
  }

  static dynamic _scanExpressionFunctionBody(VmRunner runner, Map<VmKeys, dynamic> node) => _scanMap(runner, node[VmKeys.$ExpressionFunctionBodyExpression]);

  static dynamic _scanBlockFunctionBody(VmRunner runner, Map<VmKeys, dynamic> node) => _scanMap(runner, node[VmKeys.$BlockFunctionBodyBlock]);

  static dynamic _scanMethodInvocation(VmRunner runner, Map<VmKeys, dynamic> node) {
    final target = node[VmKeys.$MethodInvocationTarget] as Map<VmKeys, dynamic>?;
    final methodName = node[VmKeys.$MethodInvocationMethodName] as String;
    final argumentList = node[VmKeys.$MethodInvocationArgumentList] as Map<VmKeys, dynamic>?;
    final targetResult = _scanMap(runner, target);
    final argumentsResult = _scanMap(runner, argumentList) as List?; // => _scanArgumentList or null
    //构建标准apply调用的参数
    final listArguments = <dynamic>[];
    final nameArguments = <Symbol, dynamic>{};
    if (argumentsResult != null) {
      for (var item in argumentsResult) {
        if (item is VmHelper) {
          nameArguments[Symbol(item.fieldName)] = VmCaller.getValue(item.fieldValue);
        } else {
          listArguments.add(VmCaller.getValue(item));
        }
      }
    }
    //根据的情况执行函数逻辑
    if (targetResult == null) {
      final methodResult = runner.getVmObject(methodName);
      if (methodResult is VmClass) return methodResult.runStaticFunction(methodName, listArguments, nameArguments); //构造函数
      if (methodResult is VmProxy) return methodResult.runStaticFunction(listArguments, nameArguments); //全局函数
      if (methodResult is VmCaller) throw ('MethodInvocation method is a VmCaller: ${methodResult.identifier}');
      if (methodResult is VmHelper) throw ('MethodInvocation method is a VmHelper: ${methodResult.identifier}');
      if (methodResult is VmSignal) throw ('MethodInvocation method is a VmSignal: ${methodResult.identifier}');
      if (methodResult is VmFunction) return _scanVmFunction(runner, methodResult, argumentsResult); //虚拟函数
      if (methodResult is VmVariable) return methodResult.apply(listArguments, nameArguments); //变量函数
      return VmClass.runInstanceFunction(methodResult, methodName, listArguments, nameArguments);
    } else {
      if (targetResult is VmClass) return targetResult.runStaticFunction(methodName, listArguments, nameArguments); //静态函数
      if (targetResult is VmProxy) return VmClass.runInstanceFunction(VmCaller.getValue(targetResult), methodName, listArguments, nameArguments);
      if (targetResult is VmCaller) return VmClass.runInstanceFunction(VmCaller.getValue(targetResult), methodName, listArguments, nameArguments);
      if (targetResult is VmHelper) return VmClass.runInstanceFunction(VmCaller.getValue(targetResult), methodName, listArguments, nameArguments);
      if (targetResult is VmSignal) return VmClass.runInstanceFunction(VmCaller.getValue(targetResult), methodName, listArguments, nameArguments);
      if (targetResult is VmVariable) return targetResult.runInstanceFunction(methodName, listArguments, nameArguments); //实例函数
      if (targetResult is VmFunction) return VmClass.runInstanceFunction(VmCaller.getValue(targetResult), methodName, listArguments, nameArguments);
      return VmClass.runInstanceFunction(targetResult, methodName, listArguments, nameArguments);
    }
  }

  static List? _scanArgumentList(VmRunner runner, Map<VmKeys, dynamic> node) => _scanList(runner, node[VmKeys.$ArgumentListArguments]);

  static VmCaller _scanPropertyAccess(VmRunner runner, Map<VmKeys, dynamic> node) {
    final target = node[VmKeys.$PropertyAccessTarget] as Map<VmKeys, dynamic>?;
    final propertyName = node[VmKeys.$PropertyAccessPropertyName] as String;
    final targetResult = _scanMap(runner, target);
    return VmCaller(target: targetResult, identifier: propertyName); //延迟调用，因为无法确定上层是什么操作
  }

  static dynamic _scanBlock(VmRunner runner, Map<VmKeys, dynamic> node) {
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

  static dynamic _scanVariableDeclarationStatement(VmRunner runner, Map<VmKeys, dynamic> node) => _scanMap(runner, node[VmKeys.$VariableDeclarationStatementVariables]);

  static dynamic _scanExpressionStatement(VmRunner runner, Map<VmKeys, dynamic> node) => _scanMap(runner, node[VmKeys.$ExpressionStatementExpression]);

  static dynamic _scanIfStatement(VmRunner runner, Map<VmKeys, dynamic> node) {
    final condition = node[VmKeys.$IfStatementCondition] as Map<VmKeys, dynamic>?;
    final thenExpression = node[VmKeys.$IfStatementThenStatement] as Map<VmKeys, dynamic>?;
    final elseExpression = node[VmKeys.$IfStatementElseStatement] as Map<VmKeys, dynamic>?;
    final conditionResult = _scanMap(runner, condition);
    final conditionValue = VmCaller.getValue(conditionResult);
    if (conditionValue) {
      return _scanMap(runner, thenExpression);
    } else {
      return _scanMap(runner, elseExpression);
    }
  }

  static dynamic _scanSwitchStatement(VmRunner runner, Map<VmKeys, dynamic> node) {
    final expression = node[VmKeys.$SwitchStatementExpression] as Map<VmKeys, dynamic>?;
    final members = node[VmKeys.$SwitchStatementMembers] as List<Map<VmKeys, dynamic>?>?;
    if (members == null) return null;
    final expressionResult = _scanMap(runner, expression);
    final expressionValue = VmCaller.getValue(expressionResult);
    runner._newScope();
    runner.addVmObject(VmVariable(identifier: _switchConditionValue_, initValue: expressionValue)); //创建关键变量
    for (var item in members) {
      final itemResult = _scanMap(runner, item); // => _scanSwitchCase 或 _scanSwitchDefault
      if (itemResult is VmSignal && itemResult.isInterrupt) {
        runner._delScope();
        return itemResult.isBreak ? VmCaller.getValue(itemResult) : itemResult; //break只跳出本switch范围
      }
    }
    runner._delScope();
    return null;
  }

  static dynamic _scanSwitchCase(VmRunner runner, Map<VmKeys, dynamic> node) {
    final expression = node[VmKeys.$SwitchCaseExpression] as Map<VmKeys, dynamic>?;
    final statements = node[VmKeys.$SwitchCaseStatements] as List<Map<VmKeys, dynamic>?>?;
    if (statements == null) return null;
    final expressionResult = _scanMap(runner, expression);
    final expressionValue = VmCaller.getValue(expressionResult);
    final conditionValue = VmCaller.getValue(runner.getVmObject(_switchConditionValue_)); //读取关键变量
    if (expressionValue != conditionValue) return null;
    for (var item in statements) {
      final itemResult = _scanMap(runner, item);
      if (itemResult is VmSignal && itemResult.isInterrupt) {
        return itemResult;
      }
    }
    return null;
  }

  static dynamic _scanSwitchDefault(VmRunner runner, Map<VmKeys, dynamic> node) {
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

  static dynamic _scanForStatement(VmRunner runner, Map<VmKeys, dynamic> node) {
    final forLoopParts = node[VmKeys.$ForStatementForLoopParts] as Map<VmKeys, dynamic>?;
    final body = node[VmKeys.$ForStatementBody] as Map<VmKeys, dynamic>?;
    runner._newScope();
    bool forLoopPartsResult = _scanMap(runner, forLoopParts); // => _scanForPartsWithDeclarations 或 _scanForEachPartsWithDeclaration 必定为bool
    while (forLoopPartsResult) {
      final bodyResult = _scanMap(runner, body);
      if (bodyResult is VmSignal && bodyResult.isInterrupt) {
        runner._delScope();
        return bodyResult.isBreak ? VmCaller.getValue(bodyResult) : bodyResult; //break只跳出本for范围
      }
      forLoopPartsResult = _scanMap(runner, forLoopParts); // => _scanForPartsWithDeclarations 或 _scanForEachPartsWithDeclaration 必定为bool
    }
    runner._delScope();
    return null;
  }

  static bool _scanForPartsWithDeclarations(VmRunner runner, Map<VmKeys, dynamic> node) {
    final variables = node[VmKeys.$ForPartsWithDeclarationsVariables] as Map<VmKeys, dynamic>?;
    final condition = node[VmKeys.$ForPartsWithDeclarationsCondition] as Map<VmKeys, dynamic>?;
    final updaters = node[VmKeys.$ForPartsWithDeclarationsUpdaters] as List<Map<VmKeys, dynamic>?>?;
    if (runner.inCurrentScope(_forLoopPartsPrepared_)) {
      if (updaters != null) _scanList(runner, updaters); //更新循环变量
    } else {
      runner.addVmObject(VmVariable(identifier: _forLoopPartsPrepared_)); //创建关键变量
      _scanMap(runner, variables); //创建循环变量
    }
    final conditionResult = _scanMap(runner, condition);
    return VmCaller.getValue(conditionResult);
  }

  static bool _scanForEachPartsWithDeclaration(VmRunner runner, Map<VmKeys, dynamic> node) {
    final loopVariable = node[VmKeys.$ForEachPartsWithDeclarationLoopVariable] as Map<VmKeys, dynamic>?;
    final iterable = node[VmKeys.$ForEachPartsWithDeclarationIterable] as Map<VmKeys, dynamic>?;
    final loopVariableResult = _scanMap(runner, loopVariable) as VmHelper;
    if (runner.inCurrentScope(_forLoopPartsPrepared_)) {
      //更新循环变量
      final iterableValue = VmCaller.getValue(runner.getVmObject(_forLoopPartsPrepared_)) as Iterator;
      if (!iterableValue.moveNext()) return false;
      final loopVariable = runner.getVmObject(loopVariableResult.fieldName);
      VmCaller.setValue(loopVariable, iterableValue.current);
      return true;
    } else {
      final iterableResult = _scanMap(runner, iterable);
      final iterableValue = (VmCaller.getValue(iterableResult) as Iterable).iterator;
      if (!iterableValue.moveNext()) return false;
      runner.addVmObject(VmVariable(identifier: _forLoopPartsPrepared_, initValue: iterableValue)); //创建关键变量
      //创建循环变量
      runner.addVmObject(VmVariable(
        typeName: loopVariableResult.typeName,
        typeQuestion: loopVariableResult.typeQuestion,
        identifier: loopVariableResult.fieldName,
        initValue: iterableValue.current,
      ));
      return true;
    }
  }

  static dynamic _scanWhileStatement(VmRunner runner, Map<VmKeys, dynamic> node) {
    final condition = node[VmKeys.$WhileStatementCondition] as Map<VmKeys, dynamic>?;
    final body = node[VmKeys.$WhileStatementBody] as Map<VmKeys, dynamic>?;
    dynamic conditionResult = _scanMap(runner, condition);
    bool conditionValue = VmCaller.getValue(conditionResult);
    while (conditionValue) {
      final bodyResult = _scanMap(runner, body);
      if (bodyResult is VmSignal && bodyResult.isInterrupt) {
        return bodyResult.isBreak ? VmCaller.getValue(bodyResult) : bodyResult; //break只跳出本while范围
      }
      conditionResult = _scanMap(runner, condition);
      conditionValue = VmCaller.getValue(conditionResult);
    }
    return null;
  }

  static dynamic _scanDoStatement(VmRunner runner, Map<VmKeys, dynamic> node) {
    final body = node[VmKeys.$DoStatementBody] as Map<VmKeys, dynamic>?;
    final condition = node[VmKeys.$DoStatementCondition] as Map<VmKeys, dynamic>?;
    dynamic conditionResult;
    bool conditionValue;
    do {
      final bodyResult = _scanMap(runner, body);
      if (bodyResult is VmSignal && bodyResult.isInterrupt) {
        return bodyResult.isBreak ? VmCaller.getValue(bodyResult) : bodyResult; //break只跳出本while范围
      }
      conditionResult = _scanMap(runner, condition);
      conditionValue = VmCaller.getValue(conditionResult);
    } while (conditionValue);
    return null;
  }

  static VmSignal _scanBreakStatement(VmRunner runner, Map<VmKeys, dynamic> node) {
    final breakKeyword = node[VmKeys.$BreakStatementBreakKeyword] as String?;
    return VmSignal(isBreak: true, keyword: breakKeyword, signalValue: null);
  }

  static VmSignal _scanReturnStatement(VmRunner runner, Map<VmKeys, dynamic> node) {
    final returnKeyword = node[VmKeys.$ReturnStatementReturnKeyword] as String?;
    final expression = node[VmKeys.$ReturnStatementExpression] as Map<VmKeys, dynamic>?;
    final expressionResult = _scanMap(runner, expression);
    final expressionValue = VmCaller.getValue(expressionResult);
    return VmSignal(isReturn: true, keyword: returnKeyword, signalValue: expressionValue);
  }
}

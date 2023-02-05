import 'vm_keys.dart';
import 'vm_library.dart';

///
///Dart代码子集的运行器
///
class VmRunner {
  ///变量栈
  final List<Map<String, VmRunnerVariable>> _variablesStack;

  ///函数栈
  final List<Map<String, VmRunnerFunction>> _functionsStack;

  VmRunner()
      : _variablesStack = [{}],
        _functionsStack = [{}];

  ///
  ///扫描语法树并创建预定义内容
  ///
  void scanAstTree(Map<VmKeys, dynamic> astTree) {
    VmRunnerScanner._scanMap(this, astTree);
  }

  ///
  ///转换为可json序列化的数据
  ///
  Map<String, dynamic> toJson() => {
        'variablesStack': _variablesStack.map((e) => e.map((key, value) => MapEntry(key, value.toString()))).toList(),
        'functionsStack': _functionsStack.map((e) => e.map((key, value) => MapEntry(key, value.toString()))).toList(),
      };

  void _defineVariable(VmRunnerVariableMeta meta) {
    final variable = meta.createVariable();
    _variablesStack.last[variable.meta.name] = variable;
  }

  VmRunnerVariable? _queryVariable(String? identifier) {
    if (identifier == null) return null;
    for (var i = _variablesStack.length - 1; i >= 0; i--) {
      final target = _variablesStack[i][identifier];
      if (target != null) return target;
    }
    return null;
  }
}

///
///语法树扫描器
///
class VmRunnerScanner {
  static final Map<VmKeys, dynamic Function(VmRunner runner, Map<VmKeys, dynamic> node)> _scanner = {
    VmKeys.$CompilationUnit: _scanCompilationUnit,
    VmKeys.$TopLevelVariableDeclaration: _scanTopLevelVariableDeclaration,
    VmKeys.$VariableDeclarationList: _scanVariableDeclarationList,
    VmKeys.$VariableDeclaration: _scanVariableDeclaration,
    VmKeys.$NamedType: _scanNamedType,
    VmKeys.$SimpleIdentifier: _scanSimpleIdentifier,
    VmKeys.$PrefixedIdentifier: _scanPrefixedIdentifier,
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
    VmKeys.$MethodInvocation: _scanMethodInvocation,
    VmKeys.$ArgumentList: _scanArgumentList,
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

  static void _scanCompilationUnit(VmRunner runner, Map<VmKeys, dynamic> node) => _scanList(runner, node[VmKeys.$CompilationUnitDeclarations]);

  static void _scanTopLevelVariableDeclaration(VmRunner runner, Map<VmKeys, dynamic> node) => _scanMap(runner, node[VmKeys.$TopLevelVariableDeclarationVariables]);

  static void _scanVariableDeclarationList(VmRunner runner, Map<VmKeys, dynamic> node) {
    final isLate = node[VmKeys.$VariableDeclarationListIsLate] as bool?;
    final isFinal = node[VmKeys.$VariableDeclarationListIsFinal] as bool?;
    final isConst = node[VmKeys.$VariableDeclarationListIsConst] as bool?;
    final keyword = node[VmKeys.$VariableDeclarationListKeyword] as String?;
    final type = node[VmKeys.$VariableDeclarationListType] as Map<VmKeys, dynamic>?;
    final typeQuestion = node[VmKeys.$VariableDeclarationListTypeQuestion] as String?;
    final typeToSource = node[VmKeys.$VariableDeclarationListTypeToSource] as String?;
    final variables = node[VmKeys.$VariableDeclarationListVariables] as List<Map<VmKeys, dynamic>?>?;
    variables?.forEach((e) {
      //递归扫描
      final variableMeta = _scanMap(runner, e) as VmRunnerVariableMeta?;
      //创建变量
      runner._defineVariable(VmRunnerVariableMeta(
        isLate: isLate,
        isFinal: isFinal,
        isConst: isConst,
        keyword: keyword,
        type: _scanMap(runner, type),
        typeQuestion: typeQuestion,
        typeToSource: typeToSource,
        name: variableMeta?.name,
        initializer: variableMeta?.initializer,
      ));
    });
  }

  static VmRunnerVariableMeta _scanVariableDeclaration(VmRunner runner, Map<VmKeys, dynamic> node) {
    final name = node[VmKeys.$VariableDeclarationName] as String?;
    final initializer = node[VmKeys.$VariableDeclarationInitializer] as Map<VmKeys, dynamic>?;
    final initializerResult = _scanMap(runner, initializer);
    return VmRunnerVariableMeta(
      name: name,
      initializer: initializerResult is VmRunnerVariable ? initializerResult.value : initializerResult,
    );
  }

  static String? _scanNamedType(VmRunner runner, Map<VmKeys, dynamic> node) => node[VmKeys.$NamedTypeName];

  static VmRunnerVariable? _scanSimpleIdentifier(VmRunner runner, Map<VmKeys, dynamic> node) => runner._queryVariable(node[VmKeys.$SimpleIdentifierName]);

  static dynamic _scanPrefixedIdentifier(VmRunner runner, Map<VmKeys, dynamic> node) {
    final prefix = node[VmKeys.$PrefixedIdentifierPrefix] as String;
    final identifier = node[VmKeys.$PrefixedIdentifierIdentifier] as String;
    final queryResult = runner._queryVariable(prefix);
    if (queryResult == null) {
      return VmLibrary.queryClassProperty(prefix, identifier);
    } else {
      return VmLibrary.queryInstanceProperty(queryResult.value, queryResult.classType, identifier);
    }
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
    final leftValue = leftResult is VmRunnerVariable ? leftResult.value : leftResult;
    final rightValue = rightResult is VmRunnerVariable ? rightResult.value : rightResult;
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
      default:
        throw ('Unsupport BinaryExpression: $operator');
    }
  }

  static dynamic _scanPrefixExpression(VmRunner runner, Map<VmKeys, dynamic> node) {
    final operator = node[VmKeys.$PrefixExpressionOperator] as String?;
    final operand = node[VmKeys.$PrefixExpressionOperand] as Map<VmKeys, dynamic>?;
    final targetResult = _scanMap(runner, operand);
    switch (operator) {
      case '-':
        return -(targetResult is VmRunnerVariable ? targetResult.value : targetResult);
      case '!':
        return !(targetResult is VmRunnerVariable ? targetResult.value : targetResult);
      case '~':
        return ~(targetResult is VmRunnerVariable ? targetResult.value : targetResult);
      case '++':
        return ++(targetResult as VmRunnerVariable).value;
      case '--':
        return --(targetResult as VmRunnerVariable).value;
      default:
        throw ('Unsupport PrefixExpression: $operator');
    }
  }

  static dynamic _scanPostfixExpression(VmRunner runner, Map<VmKeys, dynamic> node) {
    final operator = node[VmKeys.$PostfixExpressionOperator] as String?;
    final operand = node[VmKeys.$PostfixExpressionOperand] as Map<VmKeys, dynamic>?;
    final targetResult = _scanMap(runner, operand);
    switch (operator) {
      case '++':
        return (targetResult as VmRunnerVariable).value++;
      case '--':
        return (targetResult as VmRunnerVariable).value--;
      default:
        throw ('Unsupport PostfixExpression: $operator');
    }
  }

  static dynamic _scanAssignmentExpression(VmRunner runner, Map<VmKeys, dynamic> node) {
    final operator = node[VmKeys.$AssignmentExpressionOperator] as String?;
    final leftHandSide = node[VmKeys.$AssignmentExpressionLeftHandSide] as Map<VmKeys, dynamic>?;
    final rightHandSide = node[VmKeys.$AssignmentExpressionRightHandSide] as Map<VmKeys, dynamic>?;
    final leftResult = _scanMap(runner, leftHandSide) as VmRunnerVariable; //必然为VmRunnerVariable类型
    final rightResult = _scanMap(runner, rightHandSide);
    final rightValue = rightResult is VmRunnerVariable ? rightResult.value : rightResult;
    switch (operator) {
      case '+=':
        return leftResult.value += rightValue;
      case '-=':
        return leftResult.value -= rightValue;
      case '*=':
        return leftResult.value *= rightValue;
      case '/=':
        return leftResult.value /= rightValue;
      case '%=':
        return leftResult.value %= rightValue;
      case '~/=':
        return leftResult.value ~/= rightValue;
      case '??=':
        return leftResult.value ??= rightValue;
      case '>>=':
        return leftResult.value >>= rightValue;
      case '<<=':
        return leftResult.value <<= rightValue;
      case '&=':
        return leftResult.value &= rightValue;
      case '|=':
        return leftResult.value |= rightValue;
      case '^=':
        return leftResult.value ^= rightValue;
      default:
        throw ('Unsupport AssignmentExpression: $operator');
    }
  }

  static dynamic _scanConditionalExpression(VmRunner runner, Map<VmKeys, dynamic> node) {
    final condition = node[VmKeys.$ConditionalExpressionCondition] as Map<VmKeys, dynamic>?;
    final conditionResult = _scanMap(runner, condition);
    final conditionValue = conditionResult is VmRunnerVariable ? conditionResult.value : conditionResult;
    if (conditionValue) {
      final thenExpression = node[VmKeys.$ConditionalExpressionThenExpression] as Map<VmKeys, dynamic>?;
      final thenResult = _scanMap(runner, thenExpression);
      return thenResult is VmRunnerVariable ? thenResult.value : thenResult;
    } else {
      final elseExpression = node[VmKeys.$ConditionalExpressionElseExpression] as Map<VmKeys, dynamic>?;
      final elseResult = _scanMap(runner, elseExpression);
      return elseResult is VmRunnerVariable ? elseResult.value : elseResult;
    }
  }

  static dynamic _scanParenthesizedExpression(VmRunner runner, Map<VmKeys, dynamic> node) {
    final expression = node[VmKeys.$ParenthesizedExpressionExpression] as Map<VmKeys, dynamic>?;
    final result = _scanMap(runner, expression);
    return result is VmRunnerVariable ? result.value : result;
  }

  static dynamic _scanIndexExpression(VmRunner runner, Map<VmKeys, dynamic> node) {
    final target = node[VmKeys.$IndexExpressionTarget] as Map<VmKeys, dynamic>?;
    final realTarget = node[VmKeys.$IndexExpressionRealTarget] as Map<VmKeys, dynamic>?;
    final index = node[VmKeys.$IndexExpressionIndex] as Map<VmKeys, dynamic>?;
    final targetResult = _scanMap(runner, target) ?? _scanMap(runner, realTarget); //dart分析器中对target的描述：如果此索引表达式是级联表达式的一部分，则返回null。
    final indexResult = _scanMap(runner, index);
    final targetValue = targetResult is VmRunnerVariable ? targetResult.value : targetResult;
    final indexValue = indexResult is VmRunnerVariable ? indexResult.value : indexResult;
    return targetValue[indexValue];
  }

  static dynamic _scanInterpolationExpression(VmRunner runner, Map<VmKeys, dynamic> node) {
    final expression = node[VmKeys.$InterpolationExpressionExpression] as Map<VmKeys, dynamic>?;
    final result = _scanMap(runner, expression);
    return result is VmRunnerVariable ? result.value : result;
  }

  static dynamic _scanMethodInvocation(VmRunner runner, Map<VmKeys, dynamic> node) {
    final target = node[VmKeys.$MethodInvocationTarget] as String?;
    final realTarget = node[VmKeys.$MethodInvocationRealTarget] as String?;
    final methodName = node[VmKeys.$MethodInvocationMethodName] as String;
    final argumentList = node[VmKeys.$MethodInvocationArgumentList] as Map<VmKeys, dynamic>?;
    final targetResult = runner._queryVariable(target) ?? runner._queryVariable(realTarget);
    final argumentsResult = _scanMap(runner, argumentList) as List?;
    if (targetResult == null) {
      return VmLibrary.applyClassFunction(target ?? realTarget ?? methodName, methodName, argumentsResult); //target ?? realTarget ?? methodName 这里 methodName 不可少，纯构造函数的类名就是方法名
    } else {
      return VmLibrary.applyInstanceFunction(targetResult.value, targetResult.classType, methodName, argumentsResult);
    }
  }

  static List? _scanArgumentList(VmRunner runner, Map<VmKeys, dynamic> node) => _scanList(runner, node[VmKeys.$ArgumentListArguments]);
}

///
///通用变量
///
class VmRunnerVariable {
  final VmRunnerVariableMeta meta;
  dynamic value;

  VmRunnerVariable({required this.meta, required this.value});

  ///对于外部库的类型名称，[Set]与[Map]的[runtimeType]并不准确，这里进行了复写来保持与[VmLibrary]的核心库一致
  String get classType {
    if (value is int || value is int?) return 'int';
    if (value is double || value is double?) return 'double';
    if (value is num || value is num?) return 'num';
    if (value is bool || value is bool?) return 'bool';
    if (value is String || value is String?) return 'String';
    if (value is List || value is List?) return 'List';
    if (value is Set || value is Set?) return 'Set';
    if (value is Map || value is Map?) return 'Map';
    if (value is Runes || value is Runes?) return 'Runes';
    if (value is Symbol || value is Symbol?) return 'Symbol';
    return value.runtimeType.toString();
  }

  @override
  String toString() => '$meta <--------> ${value.runtimeType} => $value';
}

///
///通用变量元数据
///
class VmRunnerVariableMeta {
  final bool isLate;
  final bool isFinal;
  final bool isConst;
  final String? keyword;
  final String? type;
  final String? typeQuestion;
  final String? typeToSource;
  final String name;
  final dynamic initializer;

  VmRunnerVariableMeta({
    bool? isLate,
    bool? isFinal,
    bool? isConst,
    this.keyword,
    this.type,
    this.typeQuestion,
    this.typeToSource,
    String? name,
    this.initializer,
  })  : isLate = isLate ?? false,
        isFinal = isFinal ?? false,
        isConst = isConst ?? false,
        name = name ?? '';

  VmRunnerVariable createVariable() {
    final initValue = initializer;
    switch (type) {
      case 'int':
        return VmRunnerVariable(meta: this, value: initValue);
      case 'double':
        return VmRunnerVariable(meta: this, value: double.tryParse(initValue.toString())); //使用int值初始化double时，initValue的运行时类型为int，所以进行了转换
      case 'num':
        return VmRunnerVariable(meta: this, value: initValue);
      case 'bool':
        return VmRunnerVariable(meta: this, value: initValue);
      case 'String':
        return VmRunnerVariable(meta: this, value: initValue);
      case 'List':
        return VmRunnerVariable(meta: this, value: initValue);
      case 'Map':
        return VmRunnerVariable(meta: this, value: initValue);
      case 'Set':
        return VmRunnerVariable(meta: this, value: initValue is Map ? initValue.values.toSet() : initValue); //initValue为Map时，需要再次进行类型转换
      default:
        return VmRunnerVariable(meta: this, value: initValue);
    }
  }

  @override
  String toString() {
    final keyList = <String>[];
    if (isLate) keyList.add('late');
    if (isFinal) keyList.add('final');
    if (isConst) keyList.add('const');
    keyList.add(typeToSource ?? 'any');
    keyList.add('=>');
    keyList.add('${type ?? keyword.toString()}${typeQuestion ?? ''}');
    keyList.add(name);
    return keyList.join(' ');
  }
}

///
///变量集合
///
class VmRunnerFunction {}

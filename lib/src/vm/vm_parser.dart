import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'vm_keys.dart';

///
///Dart代码子集的解析器
///
class VmParser {
  ///
  ///解析源代码[source]的内容，生成可json序列化的语法树数据，[routeList]为排重的路由列表，[routeLogger]为路由路径输出器
  ///
  static Map<VmKeys, dynamic> parseSource(String source, {List<String>? routeList, void Function(String route)? routeLogger}) {
    final result = parseString(content: source);
    if (routeList != null || routeLogger != null) {
      result.unit.accept(VmParserRouter(routeList, routeLogger)); //输出分析的全部信息
    }
    return result.unit.accept(VmParserVisitor()) ?? {};
  }
}

///
///打印出每个节点的内容，通过观察输出信息来实现[VmParserVisitor]类的相应的函数
///
class VmParserRouter extends GeneralizingAstVisitor {
  ///排重的路由列表
  final List<String>? _routeList;

  ///路由路径输出器
  final void Function(String route)? _routeLogger;

  VmParserRouter(this._routeList, this._routeLogger);

  ///遍历全部节点
  @override
  dynamic visitNode(AstNode node) {
    var typeName = node.runtimeType.toString();
    if (typeName.endsWith('Impl')) {
      typeName = typeName.substring(0, typeName.length - 4);
    }
    if (_routeList != null) {
      if (!_routeList!.contains(typeName)) _routeList!.add(typeName);
    }
    if (_routeLogger != null) {
      _routeLogger!('route ===> $typeName ---> ${node.toSource()}');
    }
    return super.visitNode(node);
  }
}

///
///可json序列化的语法树数据生成器
///
class VmParserVisitor extends ThrowingAstVisitor<Map<VmKeys, Map<VmKeys, dynamic>>> {
  @override
  Map<VmKeys, Map<VmKeys, List?>> visitCompilationUnit(CompilationUnit node) => {
        VmKeys.$CompilationUnit: {
          VmKeys.$CompilationUnitDeclarations: node.declarations.map((e) => e.accept(this)).toList(),
        },
      };

  @override
  Map<VmKeys, Map<VmKeys, Map?>> visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) => {
        VmKeys.$TopLevelVariableDeclaration: {
          VmKeys.$TopLevelVariableDeclarationVariables: node.variables.accept(this),
        },
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitVariableDeclarationList(VariableDeclarationList node) => {
        VmKeys.$VariableDeclarationList: {
          VmKeys.$VariableDeclarationListIsLate: node.isLate,
          VmKeys.$VariableDeclarationListIsFinal: node.isFinal,
          VmKeys.$VariableDeclarationListIsConst: node.isConst,
          VmKeys.$VariableDeclarationListKeyword: node.keyword.toString(),
          VmKeys.$VariableDeclarationListType: node.type?.accept(this),
          VmKeys.$VariableDeclarationListTypeQuestion: node.type?.question?.toString(),
          VmKeys.$VariableDeclarationListTypeToSource: node.type?.toSource(),
          VmKeys.$VariableDeclarationListVariables: node.variables.map((e) => e.accept(this)).toList(),
        },
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitVariableDeclaration(VariableDeclaration node) => {
        VmKeys.$VariableDeclaration: {
          VmKeys.$VariableDeclarationName: node.name.toString(),
          VmKeys.$VariableDeclarationInitializer: node.initializer?.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, String>> visitNamedType(NamedType node) => {
        VmKeys.$NamedType: {
          VmKeys.$NamedTypeName: node.name.name,
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, String>> visitSimpleIdentifier(SimpleIdentifier node) => {
        VmKeys.$SimpleIdentifier: {
          VmKeys.$SimpleIdentifierName: node.name,
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, String>> visitPrefixedIdentifier(PrefixedIdentifier node) => {
        VmKeys.$PrefixedIdentifier: {
          VmKeys.$PrefixedIdentifierPrefix: node.prefix.name,
          VmKeys.$PrefixedIdentifierIdentifier: node.identifier.name,
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitNullLiteral(NullLiteral node) => {
        VmKeys.$NullLiteral: {
          VmKeys.$NullLiteralValue: null,
        },
      };

  @override
  Map<VmKeys, Map<VmKeys, int>> visitIntegerLiteral(IntegerLiteral node) => {
        VmKeys.$IntegerLiteral: {
          VmKeys.$IntegerLiteralValue: node.value ?? 0,
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, double>> visitDoubleLiteral(DoubleLiteral node) => {
        VmKeys.$DoubleLiteral: {
          VmKeys.$DoubleLiteralValue: node.value,
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, bool>> visitBooleanLiteral(BooleanLiteral node) => {
        VmKeys.$BooleanLiteral: {
          VmKeys.$BooleanLiteralValue: node.value,
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, String>> visitSimpleStringLiteral(SimpleStringLiteral node) => {
        VmKeys.$SimpleStringLiteral: {
          VmKeys.$SimpleStringLiteralValue: node.value,
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, String>> visitInterpolationString(InterpolationString node) => {
        VmKeys.$InterpolationString: {
          VmKeys.$InterpolationStringValue: node.value,
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, List>> visitStringInterpolation(StringInterpolation node) => {
        VmKeys.$StringInterpolation: {
          VmKeys.$StringInterpolationElements: node.elements.map((e) => e.accept(this)).toList(),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, List>> visitListLiteral(ListLiteral node) => {
        VmKeys.$ListLiteral: {
          VmKeys.$ListLiteralElements: node.elements.map((e) => e.accept(this)).toList(),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, List?>> visitSetOrMapLiteral(SetOrMapLiteral node) => {
        VmKeys.$SetOrMapLiteral: {
          VmKeys.$SetOrMapLiteralTypeArguments: node.typeArguments?.arguments.map((e) => e.toString()).toList(), //isSet与isMap永远为false，只能用这个推断类型了
          VmKeys.$SetOrMapLiteralElements: node.elements.map((e) => e.accept(this)).toList(), //jsonEncode不支持Set转换，这里统一返回List
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitMapLiteralEntry(MapLiteralEntry node) => {
        VmKeys.$MapLiteralEntry: {
          VmKeys.$MapLiteralEntryKey: node.key.accept(this),
          VmKeys.$MapLiteralEntryValue: node.value.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitBinaryExpression(BinaryExpression node) => {
        VmKeys.$BinaryExpression: {
          VmKeys.$BinaryExpressionOperator: node.operator.lexeme,
          VmKeys.$BinaryExpressionLeftOperand: node.leftOperand.accept(this),
          VmKeys.$BinaryExpressionRightOperand: node.rightOperand.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitPrefixExpression(PrefixExpression node) => {
        VmKeys.$PrefixExpression: {
          VmKeys.$PrefixExpressionOperator: node.operator.lexeme,
          VmKeys.$PrefixExpressionOperand: node.operand.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitPostfixExpression(PostfixExpression node) => {
        VmKeys.$PostfixExpression: {
          VmKeys.$PostfixExpressionOperator: node.operator.lexeme,
          VmKeys.$PostfixExpressionOperand: node.operand.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitAssignmentExpression(AssignmentExpression node) => {
        VmKeys.$AssignmentExpression: {
          VmKeys.$AssignmentExpressionOperator: node.operator.lexeme,
          VmKeys.$AssignmentExpressionLeftHandSide: node.leftHandSide.accept(this),
          VmKeys.$AssignmentExpressionRightHandSide: node.rightHandSide.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitConditionalExpression(ConditionalExpression node) => {
        VmKeys.$ConditionalExpression: {
          VmKeys.$ConditionalExpressionCondition: node.condition.accept(this),
          VmKeys.$ConditionalExpressionThenExpression: node.thenExpression.accept(this),
          VmKeys.$ConditionalExpressionElseExpression: node.elseExpression.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitParenthesizedExpression(ParenthesizedExpression node) => {
        VmKeys.$ParenthesizedExpression: {
          VmKeys.$ParenthesizedExpressionExpression: node.expression.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitIndexExpression(IndexExpression node) => {
        VmKeys.$IndexExpression: {
          VmKeys.$IndexExpressionTarget: node.target?.accept(this),
          VmKeys.$IndexExpressionRealTarget: node.realTarget.accept(this),
          VmKeys.$IndexExpressionIndex: node.index.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitInterpolationExpression(InterpolationExpression node) => {
        VmKeys.$InterpolationExpression: {
          VmKeys.$InterpolationExpressionExpression: node.expression.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitMethodInvocation(MethodInvocation node) => {
        VmKeys.$MethodInvocation: {
          VmKeys.$MethodInvocationTarget: node.target?.toString(),
          VmKeys.$MethodInvocationRealTarget: node.realTarget?.toString(),
          VmKeys.$MethodInvocationMethodName: node.methodName.name,
          VmKeys.$MethodInvocationArgumentList: node.argumentList.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, List>> visitArgumentList(ArgumentList node) => {
        VmKeys.$ArgumentList: {
          VmKeys.$ArgumentListArguments: node.arguments.map((e) => e.accept(this)).toList(),
        }
      };
}

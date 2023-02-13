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
          VmKeys.$VariableDeclarationListKeyword: node.keyword?.toString(),
          VmKeys.$VariableDeclarationListType: node.type?.accept(this),
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
  Map<VmKeys, Map<VmKeys, dynamic>> visitFunctionDeclaration(FunctionDeclaration node) => {
        VmKeys.$FunctionDeclaration: {
          VmKeys.$FunctionDeclarationIsGetter: node.isGetter,
          VmKeys.$FunctionDeclarationIsSetter: node.isSetter,
          VmKeys.$FunctionDeclarationName: node.name.toString(),
          VmKeys.$FunctionDeclarationReturnType: node.returnType?.accept(this),
          VmKeys.$FunctionDeclarationFunctionExpression: node.functionExpression.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitNamedType(NamedType node) => {
        VmKeys.$NamedType: {
          VmKeys.$NamedTypeName: node.name.accept(this),
          VmKeys.$NamedTypeQuestion: node.question?.toString(),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitGenericFunctionType(GenericFunctionType node) => {
        VmKeys.$GenericFunctionType: {
          VmKeys.$GenericFunctionTypeName: node.functionKeyword.toString(), //Function
          VmKeys.$GenericFunctionTypeQuestion: node.question?.toString(),
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
  Map<VmKeys, Map<VmKeys, dynamic>> visitDeclaredIdentifier(DeclaredIdentifier node) => {
        VmKeys.$DeclaredIdentifier: {
          VmKeys.$DeclaredIdentifierType: node.type?.accept(this),
          VmKeys.$DeclaredIdentifierName: node.name.toString(),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitNullLiteral(NullLiteral node) => {
        VmKeys.$NullLiteral: {
          VmKeys.$NullLiteralValue: null,
        },
      };

  @override
  Map<VmKeys, Map<VmKeys, int?>> visitIntegerLiteral(IntegerLiteral node) => {
        VmKeys.$IntegerLiteral: {
          VmKeys.$IntegerLiteralValue: node.value,
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
          VmKeys.$IndexExpressionTarget: node.realTarget.accept(this),
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
  Map<VmKeys, Map<VmKeys, dynamic>> visitAsExpression(AsExpression node) => {
        VmKeys.$AsExpression: {
          VmKeys.$AsExpressionExpression: node.expression.accept(this),
          VmKeys.$AsExpressionType: node.type.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitIsExpression(IsExpression node) => {
        VmKeys.$IsExpression: {
          VmKeys.$IsExpressionNotOperator: node.notOperator?.toString(),
          VmKeys.$IsExpressionExpression: node.expression.accept(this),
          VmKeys.$IsExpressionType: node.type.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitThrowExpression(ThrowExpression node) => {
        VmKeys.$ThrowExpression: {
          VmKeys.$ThrowExpressionExpression: node.expression.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitFunctionExpression(FunctionExpression node) => {
        VmKeys.$FunctionExpression: {
          VmKeys.$FunctionExpressionParameters: node.parameters?.accept(this),
          VmKeys.$FunctionExpressionBody: node.body.accept(this),
          VmKeys.$FunctionExpressionBodyIsAsynchronous: node.body.isAsynchronous,
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitNamedExpression(NamedExpression node) => {
        VmKeys.$NamedExpression: {
          VmKeys.$NamedExpressionName: node.name.label.name,
          VmKeys.$NamedExpressionExpression: node.expression.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, List>> visitFormalParameterList(FormalParameterList node) => {
        VmKeys.$FormalParameterList: {
          VmKeys.$FormalParameterListParameters: node.parameters.map((e) => e.accept(this)).toList(),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitSimpleFormalParameter(SimpleFormalParameter node) => {
        VmKeys.$SimpleFormalParameter: {
          VmKeys.$SimpleFormalParameterType: node.type?.accept(this),
          VmKeys.$SimpleFormalParameterName: node.name?.toString(),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitDefaultFormalParameter(DefaultFormalParameter node) => {
        VmKeys.$DefaultFormalParameter: {
          VmKeys.$DefaultFormalParameterName: node.name?.toString(),
          VmKeys.$DefaultFormalParameterParameter: node.parameter.accept(this),
          VmKeys.$DefaultFormalParameterDefaultValue: node.defaultValue?.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitExpressionFunctionBody(ExpressionFunctionBody node) => {
        VmKeys.$ExpressionFunctionBody: {
          VmKeys.$ExpressionFunctionBodyExpression: node.expression.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitBlockFunctionBody(BlockFunctionBody node) => {
        VmKeys.$BlockFunctionBody: {
          VmKeys.$BlockFunctionBodyBlock: node.block.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitMethodInvocation(MethodInvocation node) => {
        VmKeys.$MethodInvocation: {
          VmKeys.$MethodInvocationTarget: node.realTarget?.accept(this),
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

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitPropertyAccess(PropertyAccess node) => {
        VmKeys.$PropertyAccess: {
          VmKeys.$PropertyAccessTarget: node.realTarget.accept(this),
          VmKeys.$PropertyAccessPropertyName: node.propertyName.name,
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, List>> visitBlock(Block node) => {
        VmKeys.$Block: {
          VmKeys.$BlockStatements: node.statements.map((e) => e.accept(this)).toList(),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitVariableDeclarationStatement(VariableDeclarationStatement node) => {
        VmKeys.$VariableDeclarationStatement: {
          VmKeys.$VariableDeclarationStatementVariables: node.variables.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitExpressionStatement(ExpressionStatement node) => {
        VmKeys.$ExpressionStatement: {
          VmKeys.$ExpressionStatementExpression: node.expression.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitIfStatement(IfStatement node) => {
        VmKeys.$IfStatement: {
          VmKeys.$IfStatementCondition: node.condition.accept(this),
          VmKeys.$IfStatementThenStatement: node.thenStatement.accept(this),
          VmKeys.$IfStatementElseStatement: node.elseStatement?.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitSwitchStatement(SwitchStatement node) => {
        VmKeys.$SwitchStatement: {
          VmKeys.$SwitchStatementExpression: node.expression.accept(this),
          VmKeys.$SwitchStatementMembers: node.members.map((e) => e.accept(this)).toList(),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitSwitchCase(SwitchCase node) => {
        VmKeys.$SwitchCase: {
          VmKeys.$SwitchCaseExpression: node.expression.accept(this),
          VmKeys.$SwitchCaseStatements: node.statements.map((e) => e.accept(this)).toList(),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitSwitchDefault(SwitchDefault node) => {
        VmKeys.$SwitchDefault: {
          VmKeys.$SwitchDefaultStatements: node.statements.map((e) => e.accept(this)).toList(),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitForStatement(ForStatement node) => {
        VmKeys.$ForStatement: {
          VmKeys.$ForStatementForLoopParts: node.forLoopParts.accept(this),
          VmKeys.$ForStatementBody: node.body.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitForPartsWithDeclarations(ForPartsWithDeclarations node) => {
        VmKeys.$ForPartsWithDeclarations: {
          VmKeys.$ForPartsWithDeclarationsVariables: node.variables.accept(this),
          VmKeys.$ForPartsWithDeclarationsCondition: node.condition?.accept(this),
          VmKeys.$ForPartsWithDeclarationsUpdaters: node.updaters.map((e) => e.accept(this)).toList(),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitForEachPartsWithDeclaration(ForEachPartsWithDeclaration node) => {
        VmKeys.$ForEachPartsWithDeclaration: {
          VmKeys.$ForEachPartsWithDeclarationLoopVariable: node.loopVariable.accept(this),
          VmKeys.$ForEachPartsWithDeclarationIterable: node.iterable.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitWhileStatement(WhileStatement node) => {
        VmKeys.$WhileStatement: {
          VmKeys.$WhileStatementCondition: node.condition.accept(this),
          VmKeys.$WhileStatementBody: node.body.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitDoStatement(DoStatement node) => {
        VmKeys.$DoStatement: {
          VmKeys.$DoStatementBody: node.body.accept(this),
          VmKeys.$DoStatementCondition: node.condition.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitBreakStatement(BreakStatement node) => {
        VmKeys.$BreakStatement: {
          VmKeys.$BreakStatementBreakKeyword: node.breakKeyword.toString(),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitReturnStatement(ReturnStatement node) => {
        VmKeys.$ReturnStatement: {
          VmKeys.$ReturnStatementReturnKeyword: node.returnKeyword.toString(),
          VmKeys.$ReturnStatementExpression: node.expression?.accept(this),
        }
      };
}

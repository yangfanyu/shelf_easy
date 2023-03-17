import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'vm_keys.dart';

///
///Dart代码子集的解析器
///
class VmParser {
  ///解析源代码[source]的内容，生成可json序列化的语法树数据，[routeList]为排重的路由列表，[routeLogger]为路由路径输出器
  static Map<VmKeys, dynamic> parseSource(String source, {List<String>? routeList, void Function(String route)? routeLogger}) {
    final result = parseString(content: source);
    if (routeList != null || routeLogger != null) {
      result.unit.accept(VmParserRouter(routeList, routeLogger)); //输出分析的全部信息
    }
    return result.unit.accept(VmParserVisitor()) ?? const {};
  }

  ///解析源代码[source]的内容，生成桥接类型元数据的描述列表，[ignoreExtensionOn]为要忽略添加extension的目标类名
  static List<VmParserBirdgeItemData?> bridgeSource(String source, {required List<String> ignoreExtensionOn}) {
    final result = parseString(content: source);
    return result.unit.accept(VmParserBirdger(ignoreExtensionOn: ignoreExtensionOn));
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
  Map<VmKeys, Map<VmKeys, dynamic>> visitCompilationUnit(CompilationUnit node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$CompilationUnit: {
          VmKeys.$CompilationUnitDeclarations: node.declarations.map((e) => e.accept(this)).toList(),
        },
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$TopLevelVariableDeclaration: {
          VmKeys.$TopLevelVariableDeclarationVariables: node.variables.accept(this),
        },
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitVariableDeclarationList(VariableDeclarationList node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$VariableDeclarationList: {
          VmKeys.$VariableDeclarationListType: node.type?.accept(this),
          VmKeys.$VariableDeclarationListVariables: node.variables.map((e) => e.accept(this)).toList(),
        },
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitVariableDeclaration(VariableDeclaration node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$VariableDeclaration: {
          VmKeys.$VariableDeclarationName: node.name.lexeme,
          VmKeys.$VariableDeclarationInitializer: node.initializer?.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitFunctionDeclaration(FunctionDeclaration node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$FunctionDeclaration: {
          VmKeys.$FunctionDeclarationIsGetter: node.isGetter,
          VmKeys.$FunctionDeclarationIsSetter: node.isSetter,
          VmKeys.$FunctionDeclarationName: node.name.lexeme,
          VmKeys.$FunctionDeclarationFunctionExpression: node.functionExpression.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitNamedType(NamedType node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$NamedType: {
          VmKeys.$NamedTypeName: node.name.name, //可能包含'.'的写法，由VmRunner进行处理
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitGenericFunctionType(GenericFunctionType node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$GenericFunctionType: {},
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitSimpleIdentifier(SimpleIdentifier node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$SimpleIdentifier: {
          VmKeys.$SimpleIdentifierName: node.name,
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitPrefixedIdentifier(PrefixedIdentifier node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$PrefixedIdentifier: {
          VmKeys.$PrefixedIdentifierPrefix: node.prefix.name,
          VmKeys.$PrefixedIdentifierIdentifier: node.identifier.name,
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitDeclaredIdentifier(DeclaredIdentifier node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$DeclaredIdentifier: {
          VmKeys.$DeclaredIdentifierType: node.type?.accept(this),
          VmKeys.$DeclaredIdentifierName: node.name.lexeme,
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitNullLiteral(NullLiteral node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$NullLiteral: {
          VmKeys.$NullLiteralValue: null,
        },
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitIntegerLiteral(IntegerLiteral node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$IntegerLiteral: {
          VmKeys.$IntegerLiteralValue: node.value,
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitDoubleLiteral(DoubleLiteral node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$DoubleLiteral: {
          VmKeys.$DoubleLiteralValue: node.value,
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitBooleanLiteral(BooleanLiteral node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$BooleanLiteral: {
          VmKeys.$BooleanLiteralValue: node.value,
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitSimpleStringLiteral(SimpleStringLiteral node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$SimpleStringLiteral: {
          VmKeys.$SimpleStringLiteralValue: node.value,
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitInterpolationString(InterpolationString node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$InterpolationString: {
          VmKeys.$InterpolationStringValue: node.value,
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitStringInterpolation(StringInterpolation node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$StringInterpolation: {
          VmKeys.$StringInterpolationElements: node.elements.map((e) => e.accept(this)).toList(),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitListLiteral(ListLiteral node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$ListLiteral: {
          VmKeys.$ListLiteralElements: node.elements.map((e) => e.accept(this)).toList(),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitSetOrMapLiteral(SetOrMapLiteral node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$SetOrMapLiteral: {
          VmKeys.$SetOrMapLiteralTypeArguments: node.typeArguments?.arguments.map((e) => e.toString()).toList(), //isSet与isMap永远为false，只能用这个推断类型了
          VmKeys.$SetOrMapLiteralElements: node.elements.map((e) => e.accept(this)).toList(), //jsonEncode不支持Set转换，这里统一返回List
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitMapLiteralEntry(MapLiteralEntry node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$MapLiteralEntry: {
          VmKeys.$MapLiteralEntryKey: node.key.accept(this),
          VmKeys.$MapLiteralEntryValue: node.value.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitBinaryExpression(BinaryExpression node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$BinaryExpression: {
          VmKeys.$BinaryExpressionOperator: node.operator.lexeme,
          VmKeys.$BinaryExpressionLeftOperand: node.leftOperand.accept(this),
          VmKeys.$BinaryExpressionRightOperand: node.rightOperand.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitPrefixExpression(PrefixExpression node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$PrefixExpression: {
          VmKeys.$PrefixExpressionOperator: node.operator.lexeme,
          VmKeys.$PrefixExpressionOperand: node.operand.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitPostfixExpression(PostfixExpression node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$PostfixExpression: {
          VmKeys.$PostfixExpressionOperator: node.operator.lexeme,
          VmKeys.$PostfixExpressionOperand: node.operand.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitAssignmentExpression(AssignmentExpression node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$AssignmentExpression: {
          VmKeys.$AssignmentExpressionOperator: node.operator.lexeme,
          VmKeys.$AssignmentExpressionLeftHandSide: node.leftHandSide.accept(this),
          VmKeys.$AssignmentExpressionRightHandSide: node.rightHandSide.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitConditionalExpression(ConditionalExpression node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$ConditionalExpression: {
          VmKeys.$ConditionalExpressionCondition: node.condition.accept(this),
          VmKeys.$ConditionalExpressionThenExpression: node.thenExpression.accept(this),
          VmKeys.$ConditionalExpressionElseExpression: node.elseExpression.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitParenthesizedExpression(ParenthesizedExpression node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$ParenthesizedExpression: {
          VmKeys.$ParenthesizedExpressionExpression: node.expression.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitIndexExpression(IndexExpression node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$IndexExpression: {
          VmKeys.$IndexExpressionTarget: node.target?.accept(this),
          VmKeys.$IndexExpressionIsCascaded: node.isCascaded,
          VmKeys.$IndexExpressionIndex: node.index.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitInterpolationExpression(InterpolationExpression node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$InterpolationExpression: {
          VmKeys.$InterpolationExpressionExpression: node.expression.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitAsExpression(AsExpression node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$AsExpression: {
          VmKeys.$AsExpressionExpression: node.expression.accept(this),
          VmKeys.$AsExpressionType: node.type.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitIsExpression(IsExpression node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$IsExpression: {
          VmKeys.$IsExpressionNotOperator: node.notOperator?.lexeme,
          VmKeys.$IsExpressionExpression: node.expression.accept(this),
          VmKeys.$IsExpressionType: node.type.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitCascadeExpression(CascadeExpression node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$CascadeExpression: {
          VmKeys.$CascadeExpressionTarget: node.target.accept(this),
          VmKeys.$CascadeExpressionCascadeSections: node.cascadeSections.map((e) => e.accept(this)).toList(),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitThrowExpression(ThrowExpression node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$ThrowExpression: {
          VmKeys.$ThrowExpressionExpression: node.expression.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitFunctionExpression(FunctionExpression node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$FunctionExpression: {
          VmKeys.$FunctionExpressionParameters: node.parameters?.accept(this),
          VmKeys.$FunctionExpressionBody: node.body.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitNamedExpression(NamedExpression node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$NamedExpression: {
          VmKeys.$NamedExpressionName: node.name.label.name,
          VmKeys.$NamedExpressionExpression: node.expression.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitInstanceCreationExpression(InstanceCreationExpression node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$InstanceCreationExpression: {
          VmKeys.$InstanceCreationExpressionConstructorType: node.constructorName.type.accept(this),
          VmKeys.$InstanceCreationExpressionConstructorName: node.constructorName.name?.name,
          VmKeys.$InstanceCreationExpressionArgumentList: node.argumentList.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitFormalParameterList(FormalParameterList node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$FormalParameterList: {
          VmKeys.$FormalParameterListParameters: node.parameters.map((e) => e.accept(this)).toList(),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitSuperFormalParameter(SuperFormalParameter node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$SuperFormalParameter: {
          VmKeys.$SuperFormalParameterType: node.type?.accept(this),
          VmKeys.$SuperFormalParameterName: node.name.lexeme,
          VmKeys.$SuperFormalParameterIsNamed: node.isNamed,
        },
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitFieldFormalParameter(FieldFormalParameter node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$FieldFormalParameter: {
          VmKeys.$FieldFormalParameterType: node.type?.accept(this),
          VmKeys.$FieldFormalParameterName: node.name.lexeme,
          VmKeys.$FieldFormalParameterIsNamed: node.isNamed,
        },
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitSimpleFormalParameter(SimpleFormalParameter node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$SimpleFormalParameter: {
          VmKeys.$SimpleFormalParameterType: node.type?.accept(this),
          VmKeys.$SimpleFormalParameterName: node.name?.lexeme,
          VmKeys.$SimpleFormalParameterIsNamed: node.isNamed,
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitFunctionTypedFormalParameter(FunctionTypedFormalParameter node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$FunctionTypedFormalParameter: {
          VmKeys.$FunctionTypedFormalParameterName: node.name.lexeme,
          VmKeys.$FunctionTypedFormalParameterIsNamed: node.isNamed,
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitDefaultFormalParameter(DefaultFormalParameter node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$DefaultFormalParameter: {
          VmKeys.$DefaultFormalParameterName: node.name?.lexeme,
          VmKeys.$DefaultFormalParameterIsNamed: node.isNamed,
          VmKeys.$DefaultFormalParameterParameter: node.parameter.accept(this),
          VmKeys.$DefaultFormalParameterDefaultValue: node.defaultValue?.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitExpressionFunctionBody(ExpressionFunctionBody node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$ExpressionFunctionBody: {
          VmKeys.$ExpressionFunctionBodyExpression: node.expression.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitBlockFunctionBody(BlockFunctionBody node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$BlockFunctionBody: {
          VmKeys.$BlockFunctionBodyBlock: node.block.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitEmptyFunctionBody(EmptyFunctionBody node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$EmptyFunctionBody: {},
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitMethodInvocation(MethodInvocation node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$MethodInvocation: {
          VmKeys.$MethodInvocationTarget: node.target?.accept(this),
          VmKeys.$MethodInvocationIsCascaded: node.isCascaded,
          VmKeys.$MethodInvocationMethodName: node.methodName.name,
          VmKeys.$MethodInvocationArgumentList: node.argumentList.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitArgumentList(ArgumentList node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$ArgumentList: {
          VmKeys.$ArgumentListArguments: node.arguments.map((e) => e.accept(this)).toList(),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitPropertyAccess(PropertyAccess node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$PropertyAccess: {
          VmKeys.$PropertyAccessTarget: node.target?.accept(this),
          VmKeys.$PropertyAccessIsCascaded: node.isCascaded,
          VmKeys.$PropertyAccessPropertyName: node.propertyName.name,
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitBlock(Block node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$Block: {
          VmKeys.$BlockStatements: node.statements.map((e) => e.accept(this)).toList(),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitVariableDeclarationStatement(VariableDeclarationStatement node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$VariableDeclarationStatement: {
          VmKeys.$VariableDeclarationStatementVariables: node.variables.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitExpressionStatement(ExpressionStatement node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$ExpressionStatement: {
          VmKeys.$ExpressionStatementExpression: node.expression.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitIfStatement(IfStatement node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$IfStatement: {
          VmKeys.$IfStatementCondition: node.condition.accept(this),
          VmKeys.$IfStatementThenStatement: node.thenStatement.accept(this),
          VmKeys.$IfStatementElseStatement: node.elseStatement?.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitSwitchStatement(SwitchStatement node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$SwitchStatement: {
          VmKeys.$SwitchStatementExpression: node.expression.accept(this),
          VmKeys.$SwitchStatementMembers: node.members.map((e) => e.accept(this)).toList(),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitSwitchCase(SwitchCase node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$SwitchCase: {
          VmKeys.$SwitchCaseExpression: node.expression.accept(this),
          VmKeys.$SwitchCaseStatements: node.statements.map((e) => e.accept(this)).toList(),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitSwitchDefault(SwitchDefault node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$SwitchDefault: {
          VmKeys.$SwitchDefaultStatements: node.statements.map((e) => e.accept(this)).toList(),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitForStatement(ForStatement node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$ForStatement: {
          VmKeys.$ForStatementForLoopParts: node.forLoopParts.accept(this),
          VmKeys.$ForStatementBody: node.body.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitForPartsWithDeclarations(ForPartsWithDeclarations node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$ForPartsWithDeclarations: {
          VmKeys.$ForPartsWithDeclarationsVariables: node.variables.accept(this),
          VmKeys.$ForPartsWithDeclarationsCondition: node.condition?.accept(this),
          VmKeys.$ForPartsWithDeclarationsUpdaters: node.updaters.map((e) => e.accept(this)).toList(),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitForEachPartsWithDeclaration(ForEachPartsWithDeclaration node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$ForEachPartsWithDeclaration: {
          VmKeys.$ForEachPartsWithDeclarationLoopVariable: node.loopVariable.accept(this),
          VmKeys.$ForEachPartsWithDeclarationIterable: node.iterable.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitWhileStatement(WhileStatement node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$WhileStatement: {
          VmKeys.$WhileStatementCondition: node.condition.accept(this),
          VmKeys.$WhileStatementBody: node.body.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitDoStatement(DoStatement node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$DoStatement: {
          VmKeys.$DoStatementBody: node.body.accept(this),
          VmKeys.$DoStatementCondition: node.condition.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitBreakStatement(BreakStatement node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$BreakStatement: {},
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitReturnStatement(ReturnStatement node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$ReturnStatement: {
          VmKeys.$ReturnStatementExpression: node.expression?.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitContinueStatement(ContinueStatement node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$ContinueStatement: {},
      };

  ///
  ///类相关
  ///

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitClassDeclaration(ClassDeclaration node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$ClassDeclaration: {
          VmKeys.$ClassDeclarationName: node.name.lexeme,
          VmKeys.$ClassDeclarationMembers: node.members.map((e) => e.accept(this)).toList(),
          VmKeys.$ClassDeclarationExtendsClause: node.extendsClause?.superclass.accept(this),
        },
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitFieldDeclaration(FieldDeclaration node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$FieldDeclaration: {
          VmKeys.$FieldDeclarationIsStatic: node.isStatic,
          VmKeys.$FieldDeclarationFields: node.fields.accept(this),
          VmKeys.$FieldDeclarationFieldsNames: node.fields.variables.map((e) => e.name.lexeme).toList(), //生成名称列表，如 int a,b,c; ===> ['a', 'b', 'c']
        },
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitConstructorDeclaration(ConstructorDeclaration node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$ConstructorDeclaration: {
          VmKeys.$ConstructorDeclarationName: node.name?.lexeme,
          VmKeys.$ConstructorDeclarationFactoryKeyword: node.factoryKeyword?.lexeme,
          VmKeys.$ConstructorDeclarationParameters: node.parameters.accept(this),
          VmKeys.$ConstructorDeclarationInitializers: node.initializers.map((e) => e.accept(this)).toList(),
          VmKeys.$ConstructorDeclarationBody: node.body.accept(this),
        },
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitConstructorFieldInitializer(ConstructorFieldInitializer node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$ConstructorFieldInitializer: {
          VmKeys.$ConstructorFieldInitializerFieldName: node.fieldName.name,
          VmKeys.$ConstructorFieldInitializerExpression: node.expression.accept(this),
        },
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitMethodDeclaration(MethodDeclaration node) => {
        VmKeys.$NodeSourceKey: {VmKeys.$NodeSourceValue: node.toSource()},
        VmKeys.$MethodDeclaration: {
          VmKeys.$MethodDeclarationIsStatic: node.isStatic,
          VmKeys.$MethodDeclarationIsGetter: node.isGetter,
          VmKeys.$MethodDeclarationIsSetter: node.isSetter,
          VmKeys.$MethodDeclarationName: node.name.lexeme,
          VmKeys.$MethodDeclarationParameters: node.parameters?.accept(this),
          VmKeys.$MethodDeclarationBody: node.body.accept(this),
        },
      };
}

///
///虚拟机桥接类型的目录扫描生成器（生成字段只包含文件中的显示声明字段，flutter环境可用）
///
class VmParserBirdger extends SimpleAstVisitor {
  ///要忽略的extension的类名
  final List<String> ignoreExtensionOn;

  VmParserBirdger({required this.ignoreExtensionOn});

  @override
  List<VmParserBirdgeItemData?> visitCompilationUnit(CompilationUnit node) {
    final resultList = node.declarations.map((e) => e.accept(this)).toList();
    final members = <VmParserBirdgeItemData?>[];
    for (var e in resultList) {
      e is List<VmParserBirdgeItemData?> ? members.addAll(e) : members.add(e);
    }
    return members;
  }

  @override
  List<VmParserBirdgeItemData?> visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    final result = node.variables.accept(this) as List<VmParserBirdgeItemData?>; // => visitVariableDeclarationList
    final isAtJS = node.toSource().contains('@JS');
    for (var e in result) {
      if (e != null) {
        e.type = VmParserBirdgeItemType.topLevelVariable;
        e.isAtJS = isAtJS;
      }
    }
    return result;
  }

  @override
  List<VmParserBirdgeItemData?> visitVariableDeclarationList(VariableDeclarationList node) {
    return node.variables.map((e) => e.accept(this) as VmParserBirdgeItemData?).toList(); // => visitVariableDeclaration
  }

  @override
  VmParserBirdgeItemData? visitVariableDeclaration(VariableDeclaration node) {
    return VmParserBirdgeItemData(
      name: node.name.lexeme,
      isFinal: node.isFinal,
      isConst: node.isConst,
    );
  }

  @override
  VmParserBirdgeItemData? visitFunctionDeclaration(FunctionDeclaration node) {
    return VmParserBirdgeItemData(
      type: VmParserBirdgeItemType.topLevelFunction,
      name: node.name.lexeme,
      parameters: node.functionExpression.parameters == null ? const [] : node.functionExpression.parameters?.accept(this), // => visitFormalParameterList
      isAtJS: node.toSource().contains('@JS'),
      isGetter: node.isGetter,
      isSetter: node.isSetter,
    );
  }

  @override
  VmParserBirdgeItemData? visitClassDeclaration(ClassDeclaration node) {
    final resultList = node.members.map((e) => e.accept(this)).toList();
    final members = <VmParserBirdgeItemData?>[];
    for (var e in resultList) {
      e is List<VmParserBirdgeItemData?> ? members.addAll(e) : members.add(e);
    }
    final superclassNames = <String>[];
    if (node.extendsClause != null) superclassNames.add(node.extendsClause!.superclass.name.name); //extends最多只有一个
    if (node.implementsClause != null) superclassNames.addAll(node.implementsClause!.interfaces.map((e) => e.name.name).toList()); //implements可以很多个
    if (node.withClause != null) superclassNames.addAll(node.withClause!.mixinTypes.map((e) => e.name.name).toList()); //with可以很多个
    if (superclassNames.isEmpty) superclassNames.add('Object');
    return VmParserBirdgeItemData(
      type: VmParserBirdgeItemType.classDeclaration,
      name: node.name.lexeme,
      properties: members,
      isAtJS: node.toSource().contains('@JS'),
      isAbstract: node.abstractKeyword != null,
      superclassNames: superclassNames,
      extendsClassName: node.extendsClause?.superclass.name.name,
    );
  }

  @override
  VmParserBirdgeItemData? visitClassTypeAlias(ClassTypeAlias node) {
    // print('visitClassTypeAlias ---------> ${node.toSource()}');
    final superclassNames = <String>[];
    superclassNames.add(node.superclass.name.name); //extends最多只有一个
    if (node.implementsClause != null) superclassNames.addAll(node.implementsClause!.interfaces.map((e) => e.name.name).toList()); //implements可以很多个
    superclassNames.addAll(node.withClause.mixinTypes.map((e) => e.name.name).toList()); //with可以很多个
    if (superclassNames.isEmpty) superclassNames.add('Object');
    return VmParserBirdgeItemData(
      type: VmParserBirdgeItemType.classDeclaration,
      name: node.name.lexeme,
      properties: [], //const 默认值无法更改
      isAtJS: node.toSource().contains('@JS'),
      isAbstract: node.abstractKeyword != null,
      superclassNames: superclassNames,
    );
  }

  @override
  VmParserBirdgeItemData? visitMixinDeclaration(MixinDeclaration node) {
    final resultList = node.members.map((e) => e.accept(this)).toList();
    final members = <VmParserBirdgeItemData?>[];
    for (var e in resultList) {
      e is List<VmParserBirdgeItemData?> ? members.addAll(e) : members.add(e);
    }
    final superclassNames = <String>[];
    if (node.implementsClause != null) superclassNames.addAll(node.implementsClause!.interfaces.map((e) => e.name.name).toList()); //implements可以很多个
    if (superclassNames.isEmpty) superclassNames.add('Object');
    return VmParserBirdgeItemData(
      type: VmParserBirdgeItemType.classDeclaration,
      name: node.name.lexeme,
      properties: members,
      isAtJS: node.toSource().contains('@JS'),
      isAbstract: true, //当成抽象类
      superclassNames: superclassNames,
    );
  }

  @override
  VmParserBirdgeItemData? visitEnumDeclaration(EnumDeclaration node) {
    //node.members是空的
    final members = node.constants
        .map((e) => VmParserBirdgeItemData(
              type: VmParserBirdgeItemType.classStaticVariable, //作为静态值
              name: e.name.lexeme,
              isConst: true, //不可修改值
            ))
        .toList();
    final superclassNames = <String>[];
    if (node.implementsClause != null) superclassNames.addAll(node.implementsClause!.interfaces.map((e) => e.name.name).toList()); //implements可以很多个
    if (node.withClause != null) superclassNames.addAll(node.withClause!.mixinTypes.map((e) => e.name.name).toList()); //with可以很多个
    if (superclassNames.isEmpty) superclassNames.add('Enum'); //必然继承自 Enum
    return VmParserBirdgeItemData(
      type: VmParserBirdgeItemType.classDeclaration,
      name: node.name.lexeme,
      properties: members,
      isAtJS: node.toSource().contains('@JS'),
      isAbstract: true, //当成抽象类
      superclassNames: superclassNames,
    );
  }

  @override
  VmParserBirdgeItemData? visitExtensionDeclaration(ExtensionDeclaration node) {
    final resultList = node.members.map((e) => e.accept(this)).toList();
    final members = <VmParserBirdgeItemData?>[];
    for (var e in resultList) {
      e is List<VmParserBirdgeItemData?> ? members.addAll(e) : members.add(e);
    }
    final superclassNames = <String>[];
    if (superclassNames.isEmpty) superclassNames.add('Object');
    final extendedTypeResult = node.extendedType.accept(this); // => visitNamedType
    if (ignoreExtensionOn.contains(extendedTypeResult)) return null;
    return VmParserBirdgeItemData(
      type: VmParserBirdgeItemType.classDeclaration,
      name: VmParserBirdgeItemData.extensionName(extendedTypeResult), //生成扩展类名
      properties: members,
      isAtJS: node.toSource().contains('@JS'),
      isAbstract: true, //当成抽象类
      isExtension: true, //extension是私有类
      superclassNames: superclassNames,
    );
  }

  @override
  List<VmParserBirdgeItemData?> visitFieldDeclaration(FieldDeclaration node) {
    final typeResult = node.fields.type?.accept(this); // => visitNamedType, visitGenericFunctionType
    final result = node.fields.accept(this) as List<VmParserBirdgeItemData?>; // => visitVariableDeclarationList
    for (var e in result) {
      if (e != null) {
        e.type = node.isStatic ? VmParserBirdgeItemType.classStaticVariable : VmParserBirdgeItemType.classInstanceVariable;
        e.propertyCanNull = node.fields.type?.question != null;
        e.propertyTypeName = typeResult is String ? typeResult : null;
        e.propertyTypeMeta = typeResult is VmParserBirdgeItemData ? typeResult : null;
      }
    }
    return result;
  }

  @override
  List<VmParserBirdgeItemData?> visitConstructorDeclaration(ConstructorDeclaration node) {
    final name = node.name?.lexeme ?? '';
    return [
      VmParserBirdgeItemData(
        type: VmParserBirdgeItemType.classStaticFunction,
        name: name,
        parameters: node.parameters.accept(this), // => visitFormalParameterList
        isConstructor: true,
        isFactoryConstructor: node.factoryKeyword != null,
      ),
      name.isEmpty
          ? VmParserBirdgeItemData(
              type: VmParserBirdgeItemType.classStaticFunction,
              name: 'new',
              parameters: node.parameters.accept(this), // => visitFormalParameterList
              isConstructor: true,
              isFactoryConstructor: node.factoryKeyword != null,
            )
          : null,
    ];
  }

  @override
  VmParserBirdgeItemData? visitMethodDeclaration(MethodDeclaration node) {
    return VmParserBirdgeItemData(
      type: node.isStatic ? VmParserBirdgeItemType.classStaticFunction : VmParserBirdgeItemType.classInstanceFunction,
      name: node.name.lexeme,
      parameters: node.parameters == null ? const [] : node.parameters?.accept(this), // => visitFormalParameterList
      isGetter: node.isGetter,
      isSetter: node.isSetter,
      isOperator: node.isOperator,
      isAbstract: node.isAbstract,
    );
  }

  @override
  List<VmParserBirdgeItemData?> visitFormalParameterList(FormalParameterList node) {
    return node.parameters.map((e) => e.accept(this) as VmParserBirdgeItemData?).toList();
  }

  @override
  VmParserBirdgeItemData? visitSuperFormalParameter(SuperFormalParameter node) {
    final typeResult = node.type?.accept(this); // => visitNamedType, visitGenericFunctionType
    return VmParserBirdgeItemData(
      type: VmParserBirdgeItemType.functionParameter,
      name: node.name.lexeme,
      parameters: typeResult is VmParserBirdgeItemData ? typeResult.parameters : const [],
      isSuperParameter: true,
      isListReqParameter: node.isRequiredPositional,
      isListOptParameter: node.isOptionalPositional,
      isNameAnyParameter: node.isNamed,
      parameterType: typeResult is VmParserBirdgeItemData ? typeResult.parameterType : typeResult as String?,
      parameterValue: null,
      parameterReturn: typeResult is VmParserBirdgeItemData ? typeResult.parameterReturn : false,
      parameterCanNull: node.type?.question != null,
      callerTemplates: typeResult is VmParserBirdgeItemData ? typeResult.callerTemplates : null,
    );
  }

  @override
  VmParserBirdgeItemData? visitFieldFormalParameter(FieldFormalParameter node) {
    final typeResult = node.type?.accept(this); // => visitNamedType, visitGenericFunctionType
    return VmParserBirdgeItemData(
      type: VmParserBirdgeItemType.functionParameter,
      name: node.name.lexeme,
      parameters: typeResult is VmParserBirdgeItemData ? typeResult.parameters : const [],
      isFieldParameter: true,
      isListReqParameter: node.isRequiredPositional,
      isListOptParameter: node.isOptionalPositional,
      isNameAnyParameter: node.isNamed,
      parameterType: typeResult is VmParserBirdgeItemData ? typeResult.parameterType : typeResult as String?,
      parameterValue: null,
      parameterReturn: typeResult is VmParserBirdgeItemData ? typeResult.parameterReturn : false,
      parameterCanNull: node.type?.question != null,
      callerTemplates: typeResult is VmParserBirdgeItemData ? typeResult.callerTemplates : null,
    );
  }

  @override
  VmParserBirdgeItemData? visitSimpleFormalParameter(SimpleFormalParameter node) {
    final typeResult = node.type?.accept(this); // => visitNamedType, visitGenericFunctionType
    return VmParserBirdgeItemData(
      type: VmParserBirdgeItemType.functionParameter,
      name: node.name?.lexeme ?? '',
      parameters: typeResult is VmParserBirdgeItemData ? typeResult.parameters : const [],
      isListReqParameter: node.isRequiredPositional,
      isListOptParameter: node.isOptionalPositional,
      isNameAnyParameter: node.isNamed,
      parameterType: typeResult is VmParserBirdgeItemData ? typeResult.parameterType : typeResult as String?,
      parameterValue: null,
      parameterReturn: typeResult is VmParserBirdgeItemData ? typeResult.parameterReturn : false,
      parameterCanNull: node.type?.question != null,
      callerTemplates: typeResult is VmParserBirdgeItemData ? typeResult.callerTemplates : null,
    );
  }

  @override
  VmParserBirdgeItemData? visitFunctionTypedFormalParameter(FunctionTypedFormalParameter node) {
    return VmParserBirdgeItemData(
      type: VmParserBirdgeItemType.functionParameter,
      name: node.name.lexeme,
      parameters: node.parameters.accept(this),
      isListReqParameter: node.isRequiredPositional,
      isListOptParameter: node.isOptionalPositional,
      isNameAnyParameter: node.isNamed,
      parameterType: 'Function', //手动填充为 'Function' 来 保证 逻辑的正确
      parameterValue: null,
      parameterReturn: node.returnType != null && node.returnType?.toSource().trim() != 'void',
      parameterCanNull: node.question != null,
      callerTemplates: node.typeParameters?.toSource(), //如 Set.castFrom
    );
  }

  @override
  VmParserBirdgeItemData? visitDefaultFormalParameter(DefaultFormalParameter node) {
    final result = node.parameter.accept(this) as VmParserBirdgeItemData?; // => visitSuperFormalParameter, visitFieldFormalParameter, visitSimpleFormalParameter, visitFunctionTypedFormalParameter
    if (result != null) {
      result.type = VmParserBirdgeItemType.functionParameter;
      result.name = node.name?.lexeme ?? result.name;
      result.isListReqParameter = node.isRequiredPositional;
      result.isListOptParameter = node.isOptionalPositional;
      result.isNameAnyParameter = node.isNamed;
      result.parameterValue = node.defaultValue?.toSource();
    }
    return result;
  }

  @override
  VmParserBirdgeItemData? visitGenericFunctionType(GenericFunctionType node) {
    return VmParserBirdgeItemData(
      name: node.functionKeyword.lexeme, //无对应字段，填充为 functionKeyword 必然为 'Function'
      parameters: node.parameters.accept(this),
      parameterType: 'Function', //手动填充为 'Function' 来 保证 逻辑的正确
      parameterReturn: node.returnType != null && node.returnType?.toSource().trim() != 'void',
      callerTemplates: node.typeParameters?.toSource(), //如 Set.castFrom
    );
  }

  @override
  String? visitNamedType(NamedType node) => node.name.name; //这里其实也可能是函数的别名，所以生成代码时需要对 alias 进行查找。这里也可能包含'.'的写法，但主要判断的是Function类型所以不影响代码生成。

  @override
  VmParserBirdgeItemData? visitGenericTypeAlias(GenericTypeAlias node) {
    final functionTypeResult = node.functionType?.accept(this); // => visitGenericFunctionType
    if (functionTypeResult is VmParserBirdgeItemData) {
      functionTypeResult.type = VmParserBirdgeItemType.functionTypeAlias;
      functionTypeResult.name = node.name.lexeme;
    }
    return functionTypeResult;
  }

  @override
  VmParserBirdgeItemData? visitFunctionTypeAlias(FunctionTypeAlias node) {
    return VmParserBirdgeItemData(
      type: VmParserBirdgeItemType.functionTypeAlias,
      name: node.name.lexeme,
      parameters: node.parameters.accept(this),
      parameterType: 'Function', //手动填充为 'Function' 来 保证 逻辑的正确
      parameterReturn: node.returnType != null && node.returnType?.toSource().trim() != 'void',
      callerTemplates: node.typeParameters?.toSource(), //如 Set.castFrom
    );
  }
}

///
///桥接类型的字段描述类型
///
enum VmParserBirdgeItemType {
  ///暂不确定
  unknow,

  ///顶级变量
  topLevelVariable,

  ///顶级函数
  topLevelFunction,

  ///类的定义
  classDeclaration,

  ///类的静态变量
  classStaticVariable,

  ///类的静态函数
  classStaticFunction,

  ///类的实例变量
  classInstanceVariable,

  ///类的实例函数
  classInstanceFunction,

  ///函数的别名
  functionTypeAlias,

  ///任意函数的参数
  functionParameter,
}

///
///桥接类型的字段描述数据
///
class VmParserBirdgeItemData {
  ///数据种类
  VmParserBirdgeItemType type;

  ///数据名称
  String name;

  ///类型的字段列表
  List<VmParserBirdgeItemData?> properties;

  ///函数的参数列表
  List<VmParserBirdgeItemData?> parameters;

  ///是否被@JS注解
  bool isAtJS;

  ///是否为final
  bool isFinal;

  ///是否为const
  bool isConst;

  ///是否为getter
  bool isGetter;

  ///是否为setter
  bool isSetter;

  ///是否为operator
  bool isOperator;

  ///是否为abstract
  bool isAbstract;

  ///是否为constructor
  bool isConstructor;

  ///是否为factoryConstructor
  bool isFactoryConstructor;

  ///是否为extension
  bool isExtension;

  ///是否为超类的字段参数
  bool isSuperParameter;

  ///是否为本类的字段参数
  bool isFieldParameter;

  ///是否为必填list参数 => 即扫描器中明确的属性 isRequiredPositional 为 true
  bool isListReqParameter;

  ///是否为可选list参数 => 即扫描器中明确的属性 isOptionalPositional 为 true
  bool isListOptParameter;

  ///是否为任意name参数 => 即扫描器中明确的属性 isNamed 为 true
  bool isNameAnyParameter;

  ///作为参数的具体类型名称
  String? parameterType;

  ///作为参数的默认取值内容
  String? parameterValue;

  ///作为参数是函数类型时是否有返回值
  bool parameterReturn;

  ///作为参数是否可以为null
  bool parameterCanNull;

  ///作为参数是函数类型时生成caller添加的泛型字符串
  String? callerTemplates;

  ///作为字段是否可以为null
  bool propertyCanNull;

  ///作为字段的具体类型名称
  String? propertyTypeName;

  ///作为字段的具体类型数据
  VmParserBirdgeItemData? propertyTypeMeta;

  ///类型直接的extends、implements、with的超类
  List<String> superclassNames;

  ///类型直接的extends的超类
  String? extendsClassName;

  ///该数据来源的文件路径
  String absoluteFilePath;

  ///通过递归遍历所有的超类得到的全部超类列表
  final Set<String> _historyclassNames;

  VmParserBirdgeItemData({
    this.type = VmParserBirdgeItemType.unknow,
    required this.name,
    this.properties = const [],
    this.parameters = const [],
    this.isAtJS = false,
    this.isFinal = false,
    this.isConst = false,
    this.isGetter = false,
    this.isSetter = false,
    this.isOperator = false,
    this.isAbstract = false,
    this.isConstructor = false,
    this.isFactoryConstructor = false,
    this.isExtension = false,
    this.isSuperParameter = false,
    this.isFieldParameter = false,
    this.isListReqParameter = false,
    this.isListOptParameter = false,
    this.isNameAnyParameter = false,
    this.parameterType,
    this.parameterValue,
    this.parameterReturn = false,
    this.parameterCanNull = false,
    this.callerTemplates,
    this.propertyCanNull = false,
    this.propertyTypeName,
    this.propertyTypeMeta,
    this.superclassNames = const [],
    this.extendsClassName,
    this.absoluteFilePath = '',
  }) : _historyclassNames = {} {
    if (type == VmParserBirdgeItemType.classDeclaration) {
      //Object类无超类
      if (name == 'Object') {
        superclassNames = const [];
      }
      //去掉超类名称中的命名空间
      for (var i = 0; i < superclassNames.length; i++) {
        final superNameList = superclassNames[i].split('.');
        superclassNames[i] = superNameList.last;
      }
      //移除与自己类名相同的的超类名，一般出现在：类似于xxx_io.dart、xxx_web.dart使用命名空间来继承同名接口类的情况
      if (superclassNames.isNotEmpty) {
        superclassNames.removeWhere((element) => element == name);
      }
    }
  }

  ///是否为私有属性
  bool get isPrivate => name.startsWith('_') || isExtension;

  ///是否为new函数
  bool get isNewConstructor => isConstructor && name == 'new';

  ///是否为类静态属性
  bool get isClassStaticProperty => type == VmParserBirdgeItemType.classStaticVariable || type == VmParserBirdgeItemType.classStaticFunction;

  ///是否为类实例属性
  bool get isClassInstanceProperty => type == VmParserBirdgeItemType.classInstanceVariable || type == VmParserBirdgeItemType.classInstanceFunction;

  ///是否为要生成caller的函数类型的参数
  bool get isCallerFunctionType => parameterType == 'Function' && (parameters.isNotEmpty || parameterReturn);

  ///是否为为私有默认值
  bool get isPrivateDefaultValue {
    if (parameterValue == null) return false;
    final noBlankValue = parameterValue!.replaceAll(' ', '');
    return noBlankValue.startsWith('_') || noBlankValue.contains('._') || noBlankValue.contains(':_') || noBlankValue.contains(',_') || noBlankValue.contains('(_');
  }

  ///参数默认取值内容代码
  String get parameterValueCode {
    if (!parameterCanNull && parameterValue == null) {
      if (isListOptParameter || isNameAnyParameter) {
        //其实这里面只是为了生成的桥接不在编译器里面报错，正常来讲在开发时这种参数为必传项，这里生成的默认值直接被覆盖
        switch (parameterType) {
          case 'int':
            return ' = 0';
          case 'double':
            return ' = 0.0';
          case 'num':
            return ' = 0';
          case 'bool':
            return ' = false';
          case 'String':
            return ' = \'\'';
        }
      }
    }
    if (parameterValue != null && parameterType == 'double') {
      final exactValue = double.tryParse(parameterValue!); //int转double
      if (exactValue != null) {
        return ' = $exactValue';
      }
    }
    return parameterValue == null ? '' : ' = $parameterValue';
  }

  ///是否生成externalStaticPropertyReader
  bool get hasStaticReader {
    switch (type) {
      case VmParserBirdgeItemType.unknow:
        return false;
      case VmParserBirdgeItemType.topLevelVariable:
        return true; //必然可以
      case VmParserBirdgeItemType.topLevelFunction:
        return isGetter || !isSetter; //综合判断
      case VmParserBirdgeItemType.classDeclaration:
        return false;
      case VmParserBirdgeItemType.classStaticVariable:
        return true; //必然可以
      case VmParserBirdgeItemType.classStaticFunction:
        return isGetter || !isSetter; //综合判断
      case VmParserBirdgeItemType.classInstanceVariable:
        return false;
      case VmParserBirdgeItemType.classInstanceFunction:
        return false;
      case VmParserBirdgeItemType.functionTypeAlias:
        return false;
      case VmParserBirdgeItemType.functionParameter:
        return false;
    }
  }

  ///是否生成externalStaticPropertyWriter
  bool get hasStaticWriter {
    switch (type) {
      case VmParserBirdgeItemType.unknow:
        return false;
      case VmParserBirdgeItemType.topLevelVariable:
        return !isFinal && !isConst; //综合判断
      case VmParserBirdgeItemType.topLevelFunction:
        return isSetter; //单项判断
      case VmParserBirdgeItemType.classDeclaration:
        return false;
      case VmParserBirdgeItemType.classStaticVariable:
        return !isFinal && !isConst; //综合判断
      case VmParserBirdgeItemType.classStaticFunction:
        return isSetter; //单项判断
      case VmParserBirdgeItemType.classInstanceVariable:
        return false;
      case VmParserBirdgeItemType.classInstanceFunction:
        return false;
      case VmParserBirdgeItemType.functionTypeAlias:
        return false;
      case VmParserBirdgeItemType.functionParameter:
        return false;
    }
  }

  ///是否生成externalStaticFunctionCaller
  bool get hasStaticCaller {
    switch (type) {
      case VmParserBirdgeItemType.unknow:
        return false;
      case VmParserBirdgeItemType.topLevelVariable:
        return false;
      case VmParserBirdgeItemType.topLevelFunction:
        return parameters.any((e) => e != null && e.isCallerFunctionType) && !isSetter; //综合判断
      case VmParserBirdgeItemType.classDeclaration:
        return false;
      case VmParserBirdgeItemType.classStaticVariable:
        return false;
      case VmParserBirdgeItemType.classStaticFunction:
        return parameters.any((e) => e != null && e.isCallerFunctionType) && !isSetter; //综合判断
      case VmParserBirdgeItemType.classInstanceVariable:
        return false;
      case VmParserBirdgeItemType.classInstanceFunction:
        return false;
      case VmParserBirdgeItemType.functionTypeAlias:
        return false;
      case VmParserBirdgeItemType.functionParameter:
        return false;
    }
  }

  ///是否生成externalInstancePropertyReader
  bool get hasInstanceReader {
    switch (type) {
      case VmParserBirdgeItemType.unknow:
        return false;
      case VmParserBirdgeItemType.topLevelVariable:
        return false;
      case VmParserBirdgeItemType.topLevelFunction:
        return false;
      case VmParserBirdgeItemType.classDeclaration:
        return false;
      case VmParserBirdgeItemType.classStaticVariable:
        return false;
      case VmParserBirdgeItemType.classStaticFunction:
        return false;
      case VmParserBirdgeItemType.classInstanceVariable:
        return true; //必然可以
      case VmParserBirdgeItemType.classInstanceFunction:
        return isGetter || !isSetter; //综合判断
      case VmParserBirdgeItemType.functionTypeAlias:
        return false;
      case VmParserBirdgeItemType.functionParameter:
        return false;
    }
  }

  ///是否生成externalInstancePropertyWriter
  bool get hasInstanceWriter {
    switch (type) {
      case VmParserBirdgeItemType.unknow:
        return false;
      case VmParserBirdgeItemType.topLevelVariable:
        return false;
      case VmParserBirdgeItemType.topLevelFunction:
        return false;
      case VmParserBirdgeItemType.classDeclaration:
        return false;
      case VmParserBirdgeItemType.classStaticVariable:
        return false;
      case VmParserBirdgeItemType.classStaticFunction:
        return false;
      case VmParserBirdgeItemType.classInstanceVariable:
        return !isFinal && !isConst; //综合判断
      case VmParserBirdgeItemType.classInstanceFunction:
        return isSetter; //单项判断
      case VmParserBirdgeItemType.functionTypeAlias:
        return false;
      case VmParserBirdgeItemType.functionParameter:
        return false;
    }
  }

  ///是否生成externalInstanceFunctionCaller
  bool get hasInstanceCaller {
    switch (type) {
      case VmParserBirdgeItemType.unknow:
        return false;
      case VmParserBirdgeItemType.topLevelVariable:
        return false;
      case VmParserBirdgeItemType.topLevelFunction:
        return false;
      case VmParserBirdgeItemType.classDeclaration:
        return false;
      case VmParserBirdgeItemType.classStaticVariable:
        return false;
      case VmParserBirdgeItemType.classStaticFunction:
        return false;
      case VmParserBirdgeItemType.classInstanceVariable:
        return false;
      case VmParserBirdgeItemType.classInstanceFunction:
        return parameters.any((e) => e != null && e.isCallerFunctionType) && !isSetter; //综合判断
      case VmParserBirdgeItemType.functionTypeAlias:
        return false;
      case VmParserBirdgeItemType.functionParameter:
        return false;
    }
  }

  ///合并同名类型的实例字段
  void combineClass(VmParserBirdgeItemData sameclassData) {
    if (sameclassData.name != name && sameclassData.name != extensionName(name)) {
      throw ('Unsupport combineClass operator: ${sameclassData.name} not $name');
    }
    for (var e in sameclassData.properties) {
      if (e != null && !e.isPrivate && e.isClassInstanceProperty) {
        properties.add(e); //因为toProxyCode中使用的是Set，所以无需排重
      }
    }
  }

  ///继承全部超类的实例字段
  void extendsSuper({
    required VmParserBirdgeItemData currentClass,
    required Map<String, VmParserBirdgeItemData> publicMap,
    required Map<String, VmParserBirdgeItemData> pirvateMap,
    required void Function(String className, String superName, String filePath) onNotFoundSuperClass,
  }) {
    for (var superName in currentClass.superclassNames) {
      var superClass = publicMap[superName] ?? pirvateMap[superName];
      if (superClass != null) {
        for (var e in superClass.properties) {
          if (e != null && !e.isPrivate && e.isClassInstanceProperty) {
            properties.add(e); //因为toProxyCode中使用的是Set，所以无需排重
          }
        }
        extendsSuper(
          currentClass: superClass,
          publicMap: publicMap,
          pirvateMap: pirvateMap,
          onNotFoundSuperClass: onNotFoundSuperClass,
        ); //继续向上遍历
      } else {
        onNotFoundSuperClass(currentClass.name, superName, currentClass.absoluteFilePath);
      }
      _historyclassNames.add(superName);
    }
  }

  ///继承非factory构造函数的super参数的类型与默认值，调用该函数前请先调用[extendsSuper]进行继承处理
  void extendsValue({
    required Map<String, VmParserBirdgeItemData> publicMap,
    required Map<String, VmParserBirdgeItemData> pirvateMap,
    required void Function(String className, String fieldName, String filePath) onNotFoundClassField,
  }) {
    ///遍历本类的字段找到非factory构造函数
    for (var e in properties) {
      if (e != null && e.isConstructor && !e.isFactoryConstructor) {
        for (var p in e.parameters) {
          //复制super参数的对应超类构造函数的参数的默认值与类型
          if (p != null && p.isSuperParameter) {
            VmParserBirdgeItemData? currentParam = p;
            var currentValue = currentParam.parameterValue;
            var extendsClass = extendsClassName == null ? null : publicMap[extendsClassName] ?? pirvateMap[extendsClassName];
            while (currentParam != null && currentParam.isSuperParameter && extendsClass != null) {
              final superConstructor = extendsClass.properties.firstWhere((element) => element != null && element.isConstructor && !element.isFactoryConstructor, orElse: () => null); //构造函数的名字暂时没办法匹配，全部取第一个
              currentParam = superConstructor?.parameters.firstWhere((element) => element != null && element.name == p.name, orElse: () => null);
              currentValue = currentValue ?? currentParam?.parameterValue; //取第一个不为null的即可
              extendsClass = extendsClass.extendsClassName == null ? null : publicMap[extendsClass.extendsClassName] ?? pirvateMap[extendsClass.extendsClassName];
            }
            p.parameterValue = currentValue; //更新默认值
            if (currentParam != null && !currentParam.isSuperParameter && !currentParam.isFieldParameter) {
              //修改这两个属性，使得下面不用再重复搜索
              p.isSuperParameter = false;
              p.isFieldParameter = false;
              //已经是非类字段了，进行除value之外的完整复制
              p.parameters = currentParam.parameters;
              p.parameterType = currentParam.parameterType;
              // p.parameterValue = currentParam.parameterValue; //这个属性不需要复制，因为默认值已经在之前设置
              p.parameterReturn = currentParam.parameterReturn;
              p.parameterCanNull = currentParam.parameterCanNull; //需要继承是否可以为null值
              p.callerTemplates = currentParam.callerTemplates;
            }
          }
          //复制super参数或field参数对应成员字段的类型，实例字段已继承，无需再递归super类
          if (p != null && (p.isSuperParameter || p.isFieldParameter)) {
            final field = properties.firstWhere((element) => element != null && element.name == p.name, orElse: () => null);
            if (field != null) {
              if (field.propertyTypeName != null) {
                p.parameterType = field.propertyTypeName;
              } else if (field.propertyTypeMeta != null) {
                p.parameters = field.propertyTypeMeta!.parameters;
                p.parameterType = field.propertyTypeMeta!.parameterType;
                // p.parameterValue = field.propertyTypeMeta!.parameterValue; //这个属性不需要复制，因为与默认值没有任何关系
                p.parameterReturn = field.propertyTypeMeta!.parameterReturn;
                // p.parameterCanNull = field.propertyTypeMeta!.parameterCanNull; //这个属性不需要复制，因为与能否为null没有任何关系
                p.callerTemplates = field.propertyTypeMeta!.callerTemplates;
              }
              p.parameterCanNull = field.propertyCanNull; //是否可以为null取决于字段的定义
            } else {
              onNotFoundClassField(name, p.name, absoluteFilePath);
            }
          }
        }
      }
    }
  }

  ///替换函数的参数的类型别名，替换函数的参数的内部静态引用默认值，移除函数的拥有私有引用默认值的named参数
  void replaceAlias({
    VmParserBirdgeItemData? classScope,
    required Map<String, VmParserBirdgeItemData> functionRefs,
    required void Function(String className, String proxyName, String paramName, String aliasName, String filePath) onReplaceProxyAlias,
    required void Function(String className, String proxyName, String paramName, String paramValue, String filePath) onIgnorePrivateArgV,
  }) {
    if (type == VmParserBirdgeItemType.classDeclaration) {
      for (var e in properties) {
        e?.replaceAlias(classScope: this, functionRefs: functionRefs, onReplaceProxyAlias: onReplaceProxyAlias, onIgnorePrivateArgV: onIgnorePrivateArgV);
      }
    } else {
      //替换函数字段的参数的别名类型，因为parameters不为空的话才是函数，所以无需判断type了
      for (var e in parameters) {
        if (e != null && e.parameterType != null) {
          final refType = functionRefs[e.parameterType];
          if (refType != null) {
            e.parameters = refType.parameters;
            e.parameterType = refType.parameterType; //必然为 'Function'
            // e.parameterValue = refType.parameterValue;//这个属性不需要复制，因为refType是类型定义，与默认值没有任何关系
            e.parameterReturn = refType.parameterReturn;
            // e.parameterCanNull = refType.parameterCanNull;//这个属性不需要复制，因为refType是类型定义，与能否为null没有任何关系
            e.callerTemplates = refType.callerTemplates;
            onReplaceProxyAlias(classScope?.name ?? '', name, e.name, refType.name, refType.absoluteFilePath);
          }
        }
      }
      //替换类内部静态引用值，全局引用值无需处理
      if (classScope != null) {
        for (var e in parameters) {
          if (e != null && e.parameterValue != null) {
            final isStaticReferValue = classScope.properties.firstWhere((element) => element != null && element.name == e.parameterValue && element.isClassStaticProperty, orElse: () => null) != null;
            if (isStaticReferValue) {
              e.parameterValue = '${classScope.name}.${e.parameterValue}';
            }
          }
        }
      }
      //移除函数的拥有私有引用默认值的named参数（判断一下，有可能是const [])
      if (parameters.isNotEmpty) {
        parameters.removeWhere((e) {
          if (e != null && e.isNameAnyParameter && e.isPrivateDefaultValue) {
            onIgnorePrivateArgV(classScope?.name ?? '', name, e.name, e.parameterValue ?? '', classScope?.absoluteFilePath ?? absoluteFilePath);
            return true;
          } else {
            return false;
          }
        });
      }
    }
  }

  ///生成VmClass源代码
  String toClassCode({
    String indent = '',
    required List<String> ignoreProxyObject,
    required List<String> ignoreProxyCaller,
    required void Function(String className, String proxyName, String filePath) onIgnoreProxyObject,
    required void Function(String className, String proxyName, String filePath) onIgnoreProxyCaller,
  }) {
    final codeParts = <String>[];
    final unionPartsMap = <String, Set<String>>{};
    //字段排序
    properties.sort((a, b) {
      //空属性
      if (a == null && b != null) return -1;
      if (a != null && b == null) return 1;
      if (a == null || b == null) return 0;
      //无名属性
      if (a.name.isEmpty && b.name.isNotEmpty) return -1;
      if (a.name.isNotEmpty && b.name.isEmpty) return 1;
      //构造函数
      if (a.isConstructor && !b.isConstructor) return -1;
      if (!a.isConstructor && b.isConstructor) return 1;
      //new构造
      if (a.isNewConstructor && !b.isNewConstructor) return -1;
      if (!a.isNewConstructor && b.isNewConstructor) return 1;
      //工厂构造
      if (a.isFactoryConstructor && !b.isFactoryConstructor) return -1;
      if (!a.isFactoryConstructor && b.isFactoryConstructor) return 1;
      //静态属性
      if (a.isClassStaticProperty && !b.isClassStaticProperty) return -1;
      if (!a.isClassStaticProperty && b.isClassStaticProperty) return 1;
      //实例属性
      if (a.isClassInstanceProperty && !b.isClassInstanceProperty) return -1;
      if (!a.isClassInstanceProperty && b.isClassInstanceProperty) return 1;
      //字母排序
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    //生成代码
    codeParts.add('VmClass<$name>(');
    codeParts.add('$indent${indent}identifier: \'${getIdentifier(name)}\',');
    codeParts.add('$indent${indent}superclassNames: [${_historyclassNames.map((e) => '\'$e\'').join(', ')}],');
    for (var e in properties) {
      if (e != null && !e.isPrivate && !e.isOperator) {
        if (!isIgnoreProxyMatched(this, e.name, ignoreProxyObject)) {
          final unionParts = unionPartsMap[e.name] = unionPartsMap[e.name] ?? {};
          if (!e.isConstructor || (!isAbstract || e.isFactoryConstructor)) {
            e.toProxyCode(
              classScope: this,
              unionParts: unionParts,
              ignoreProxyCaller: ignoreProxyCaller,
              onIgnoreProxyCaller: onIgnoreProxyCaller,
            );
          }
        } else {
          onIgnoreProxyObject(name, e.name, absoluteFilePath);
        }
      }
    }
    if (unionPartsMap.isEmpty) {
      codeParts.add('$indent${indent}externalProxyMap: {},'); //除void不可能出现这种情况，但void为VmClass内置的
    } else {
      codeParts.add('$indent${indent}externalProxyMap: {');
      unionPartsMap.forEach((key, value) {
        if (value.isNotEmpty) {
          final identifier = key.isEmpty ? getIdentifier(name) : getIdentifier(key);
          codeParts.add('$indent$indent$indent\'$identifier\': VmProxy(identifier: \'$identifier\', ${value.join(', ')}),');
        }
      });
      codeParts.add('$indent$indent},');
    }
    codeParts.add('$indent);');
    return codeParts.join('\n');
  }

  ///生成VmProxy源代码，[unionParts]为[Set]便于合并重复的子项
  String toProxyCode({
    VmParserBirdgeItemData? classScope,
    Set<String>? unionParts,
    required List<String> ignoreProxyCaller,
    required void Function(String className, String proxyName, String filePath) onIgnoreProxyCaller,
  }) {
    final className = classScope != null ? classScope.name : '';
    final staticDot = classScope != null ? '.' : '';
    final identifier = classScope != null && name.isEmpty ? getIdentifier(className) : getIdentifier(name);
    final proxyName = classScope != null && name.isEmpty ? 'new' : name;
    final codeParts = unionParts ?? <String>{};
    if (hasStaticReader) codeParts.add('externalStaticPropertyReader: () => $className$staticDot$proxyName');
    if (hasStaticWriter) codeParts.add('externalStaticPropertyWriter: (value) => $className$staticDot$proxyName = value');
    if (hasStaticCaller && !isIgnoreProxyMatched(classScope, proxyName, ignoreProxyCaller)) {
      int i = 0;
      final outerListReqStrs = parameters.where((e) => e != null && e.isListReqParameter).map((e) => 'a${i++}${e!.parameterValueCode}').join(', ');
      final outerListOptStrs = parameters.where((e) => e != null && e.isListOptParameter).map((e) => 'a${i++}${e!.parameterValueCode}').join(', ');
      final outerNameAnyStrs = parameters.where((e) => e != null && e.isNameAnyParameter).map((e) => '${e!.name}${e.parameterValueCode}').join(', ');
      final outerList = <String>[];
      if (outerListReqStrs.isNotEmpty) outerList.add(outerListReqStrs);
      if (outerListOptStrs.isNotEmpty) outerList.add('[$outerListOptStrs]');
      if (outerNameAnyStrs.isNotEmpty) outerList.add('{$outerNameAnyStrs}');
      i = 0;
      final innerListReqStrs = parameters.where((e) => e != null && e.isListReqParameter).map((e) => e!.isCallerFunctionType ? e.toCallerCode('a${i++}') : 'a${i++}').join(', ');
      final innerListOptStrs = parameters.where((e) => e != null && e.isListOptParameter).map((e) => e!.isCallerFunctionType ? e.toCallerCode('a${i++}') : 'a${i++}').join(', ');
      final innerNameAnyStrs = parameters.where((e) => e != null && e.isNameAnyParameter).map((e) => '${e!.name}: ${e.isCallerFunctionType ? e.toCallerCode(e.name) : e.name}').join(', ');
      final innerList = <String>[];
      if (innerListReqStrs.isNotEmpty) innerList.add(innerListReqStrs);
      if (innerListOptStrs.isNotEmpty) innerList.add(innerListOptStrs);
      if (innerNameAnyStrs.isNotEmpty) innerList.add(innerNameAnyStrs);
      codeParts.add('externalStaticFunctionCaller: (${outerList.join(', ')}) => $className$staticDot$proxyName(${innerList.join(', ')})');
    } else if (isIgnoreProxyMatched(classScope, proxyName, ignoreProxyCaller)) {
      onIgnoreProxyCaller(className, proxyName, classScope?.absoluteFilePath ?? absoluteFilePath);
    }
    if (hasInstanceReader) codeParts.add('externalInstancePropertyReader: ($className instance) => instance.$proxyName');
    if (hasInstanceWriter) codeParts.add('externalInstancePropertyWriter: ($className instance, value) => instance.$proxyName = value');
    if (hasInstanceCaller && !isIgnoreProxyMatched(classScope, proxyName, ignoreProxyCaller)) {
      int i = 0;
      final outerListReqStrs = parameters.where((e) => e != null && e.isListReqParameter).map((e) => 'a${i++}${e!.parameterValueCode}').join(', ');
      final outerListOptStrs = parameters.where((e) => e != null && e.isListOptParameter).map((e) => 'a${i++}${e!.parameterValueCode}').join(', ');
      final outerNameAnyStrs = parameters.where((e) => e != null && e.isNameAnyParameter).map((e) => '${e!.name}${e.parameterValueCode}').join(', ');
      final outerList = <String>['$className instance'];
      if (outerListReqStrs.isNotEmpty) outerList.add(outerListReqStrs);
      if (outerListOptStrs.isNotEmpty) outerList.add('[$outerListOptStrs]');
      if (outerNameAnyStrs.isNotEmpty) outerList.add('{$outerNameAnyStrs}');
      i = 0;
      final innerListReqStrs = parameters.where((e) => e != null && e.isListReqParameter).map((e) => e!.isCallerFunctionType ? e.toCallerCode('a${i++}') : 'a${i++}').join(', ');
      final innerListOptStrs = parameters.where((e) => e != null && e.isListOptParameter).map((e) => e!.isCallerFunctionType ? e.toCallerCode('a${i++}') : 'a${i++}').join(', ');
      final innerNameAnyStrs = parameters.where((e) => e != null && e.isNameAnyParameter).map((e) => '${e!.name}: ${e.isCallerFunctionType ? e.toCallerCode(e.name) : e.name}').join(', ');
      final innerList = <String>[];
      if (innerListReqStrs.isNotEmpty) innerList.add(innerListReqStrs);
      if (innerListOptStrs.isNotEmpty) innerList.add(innerListOptStrs);
      if (innerNameAnyStrs.isNotEmpty) innerList.add(innerNameAnyStrs);
      codeParts.add('externalInstanceFunctionCaller: (${outerList.join(', ')}) => instance.$proxyName(${innerList.join(', ')})');
    } else if (isIgnoreProxyMatched(classScope, proxyName, ignoreProxyCaller)) {
      onIgnoreProxyCaller(className, proxyName, classScope?.absoluteFilePath ?? absoluteFilePath);
    }
    return 'VmProxy(identifier: \'$identifier\', ${codeParts.join(', ')}),';
  }

  ///生成caller源代码
  String toCallerCode(String fieldName) {
    int i = 0;
    final outerListReqStrs = parameters.where((e) => e != null && e.isListReqParameter).map((e) => 'b${i++}${e!.parameterValueCode}').join(', ');
    final outerListOptStrs = parameters.where((e) => e != null && e.isListOptParameter).map((e) => 'b${i++}${e!.parameterValueCode}').join(', ');
    final outerNameAnyStrs = parameters.where((e) => e != null && e.isNameAnyParameter).map((e) => '${e!.name}${e.parameterValueCode}').join(', ');
    final outerList = <String>[];
    if (outerListReqStrs.isNotEmpty) outerList.add(outerListReqStrs);
    if (outerListOptStrs.isNotEmpty) outerList.add('[$outerListOptStrs]');
    if (outerNameAnyStrs.isNotEmpty) outerList.add('{$outerNameAnyStrs}');
    i = 0;
    final innerListReqStrs = parameters.where((e) => e != null && e.isListReqParameter).map((e) => 'b${i++}').join(', ');
    final innerListOptStrs = parameters.where((e) => e != null && e.isListOptParameter).map((e) => 'b${i++}').join(', ');
    final innerNameAnyStrs = parameters.where((e) => e != null && e.isNameAnyParameter).map((e) => '${e!.name}: ${e.name}').join(', ');
    final innerList = <String>[];
    if (innerListReqStrs.isNotEmpty) innerList.add(innerListReqStrs);
    if (innerListOptStrs.isNotEmpty) innerList.add(innerListOptStrs);
    if (innerNameAnyStrs.isNotEmpty) innerList.add(innerNameAnyStrs);
    return '${parameterCanNull ? '$fieldName == null ? null : ' : ''}${callerTemplates ?? ''}(${outerList.join(', ')}) => $fieldName(${innerList.join(', ')})';
  }

  ///是否匹配忽略
  static bool isIgnoreProxyMatched(VmParserBirdgeItemData? classScope, String proxyName, List<String> ignoreProxyNames) {
    if (classScope == null) {
      return ignoreProxyNames.contains(proxyName);
    } else {
      return ignoreProxyNames.contains('${classScope.name}.$proxyName') || classScope._historyclassNames.any((superName) => ignoreProxyNames.contains('$superName.$proxyName'));
    }
  }

  ///格式化标识符
  static String getIdentifier(String key) => key.replaceAll(r'$', r'\$');

  ///格式化扩展名
  static String extensionName(String name) => '\$${name}Extension\$';
}

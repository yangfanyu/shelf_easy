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

  ///解析源代码[source]的内容，生成桥接类型元数据的描述列表，[ignoreExtensions]为要忽略添加extension的目标类名
  static List<VmParserBirdgeItemData?> bridgeSource(String source, {required List<String> ignoreExtensions}) {
    final result = parseString(content: source);
    return result.unit.accept(VmParserBirdger(ignoreExtensions: ignoreExtensions));
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
          VmKeys.$FunctionDeclarationFunctionExpression: node.functionExpression.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitNamedType(NamedType node) => {
        VmKeys.$NamedType: {
          VmKeys.$NamedTypeName: node.name.name,
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitGenericFunctionType(GenericFunctionType node) => {
        VmKeys.$GenericFunctionType: {},
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
          VmKeys.$IndexExpressionTarget: node.target?.accept(this),
          VmKeys.$IndexExpressionIsCascaded: node.isCascaded,
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
  Map<VmKeys, Map<VmKeys, dynamic>> visitCascadeExpression(CascadeExpression node) => {
        VmKeys.$CascadeExpression: {
          VmKeys.$CascadeExpressionTarget: node.target.accept(this),
          VmKeys.$CascadeExpressionCascadeSections: node.cascadeSections.map((e) => e.accept(this)).toList(),
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
  Map<VmKeys, Map<VmKeys, dynamic>>? visitInstanceCreationExpression(InstanceCreationExpression node) => {
        VmKeys.$InstanceCreationExpression: {
          VmKeys.$InstanceCreationExpressionConstructorType: node.constructorName.type.accept(this),
          VmKeys.$InstanceCreationExpressionConstructorName: node.constructorName.name?.name,
          VmKeys.$InstanceCreationExpressionArgumentList: node.argumentList.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, List>> visitFormalParameterList(FormalParameterList node) => {
        VmKeys.$FormalParameterList: {
          VmKeys.$FormalParameterListParameters: node.parameters.map((e) => e.accept(this)).toList(),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitSuperFormalParameter(SuperFormalParameter node) => {
        VmKeys.$SuperFormalParameter: {
          VmKeys.$SuperFormalParameterType: node.type?.accept(this),
          VmKeys.$SuperFormalParameterName: node.name.toString(),
          VmKeys.$SuperFormalParameterIsNamed: node.isNamed,
        },
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitFieldFormalParameter(FieldFormalParameter node) => {
        VmKeys.$FieldFormalParameter: {
          VmKeys.$FieldFormalParameterType: node.type?.accept(this),
          VmKeys.$FieldFormalParameterName: node.name.toString(),
          VmKeys.$FieldFormalParameterIsNamed: node.isNamed,
        },
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitSimpleFormalParameter(SimpleFormalParameter node) => {
        VmKeys.$SimpleFormalParameter: {
          VmKeys.$SimpleFormalParameterType: node.type?.accept(this),
          VmKeys.$SimpleFormalParameterName: node.name?.toString(),
          VmKeys.$SimpleFormalParameterIsNamed: node.isNamed,
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>>? visitFunctionTypedFormalParameter(FunctionTypedFormalParameter node) => {
        VmKeys.$FunctionTypedFormalParameter: {
          VmKeys.$FunctionTypedFormalParameterName: node.name.toString(),
          VmKeys.$FunctionTypedFormalParameterIsNamed: node.isNamed,
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitDefaultFormalParameter(DefaultFormalParameter node) => {
        VmKeys.$DefaultFormalParameter: {
          VmKeys.$DefaultFormalParameterName: node.name?.toString(),
          VmKeys.$DefaultFormalParameterIsNamed: node.isNamed,
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
  Map<VmKeys, Map<VmKeys, dynamic>> visitEmptyFunctionBody(EmptyFunctionBody node) => {
        VmKeys.$EmptyFunctionBody: {},
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitMethodInvocation(MethodInvocation node) => {
        VmKeys.$MethodInvocation: {
          VmKeys.$MethodInvocationTarget: node.target?.accept(this),
          VmKeys.$MethodInvocationIsCascaded: node.isCascaded,
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
          VmKeys.$PropertyAccessTarget: node.target?.accept(this),
          VmKeys.$PropertyAccessIsCascaded: node.isCascaded,
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
        VmKeys.$BreakStatement: {},
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitReturnStatement(ReturnStatement node) => {
        VmKeys.$ReturnStatement: {
          VmKeys.$ReturnStatementExpression: node.expression?.accept(this),
        }
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>>? visitContinueStatement(ContinueStatement node) => {
        VmKeys.$ContinueStatement: {},
      };

  ///
  ///类相关
  ///

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitClassDeclaration(ClassDeclaration node) => {
        VmKeys.$ClassDeclaration: {
          VmKeys.$ClassDeclarationName: node.name.toString(),
          VmKeys.$ClassDeclarationMembers: node.members.map((e) => e.accept(this)).toList(),
          VmKeys.$ClassDeclarationExtendsClause: node.extendsClause?.superclass.accept(this),
        },
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitFieldDeclaration(FieldDeclaration node) => {
        VmKeys.$FieldDeclaration: {
          VmKeys.$FieldDeclarationIsStatic: node.isStatic,
          VmKeys.$FieldDeclarationFields: node.fields.accept(this),
        },
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitConstructorDeclaration(ConstructorDeclaration node) => {
        VmKeys.$ConstructorDeclaration: {
          VmKeys.$ConstructorDeclarationName: node.name?.toString(),
          VmKeys.$ConstructorDeclarationFactoryKeyword: node.factoryKeyword?.toString(),
          VmKeys.$ConstructorDeclarationParameters: node.parameters.accept(this),
          VmKeys.$ConstructorDeclarationInitializers: node.initializers.map((e) => e.accept(this)).toList(),
          VmKeys.$ConstructorDeclarationBody: node.body.accept(this),
        },
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitConstructorFieldInitializer(ConstructorFieldInitializer node) => {
        VmKeys.$ConstructorFieldInitializer: {
          VmKeys.$ConstructorFieldInitializerFieldName: node.fieldName.name,
          VmKeys.$ConstructorFieldInitializerExpression: node.expression.accept(this),
        },
      };

  @override
  Map<VmKeys, Map<VmKeys, dynamic>> visitMethodDeclaration(MethodDeclaration node) => {
        VmKeys.$MethodDeclaration: {
          VmKeys.$MethodDeclarationIsStatic: node.isStatic,
          VmKeys.$MethodDeclarationIsGetter: node.isGetter,
          VmKeys.$MethodDeclarationIsSetter: node.isSetter,
          VmKeys.$MethodDeclarationName: node.name.toString(),
          VmKeys.$MethodDeclarationParameters: node.parameters?.accept(this),
          VmKeys.$MethodDeclarationBody: node.body.accept(this),
        },
      };
}

///
///虚拟机桥接类型的目录扫描生成器（生成字段只包含文件中的显示声明字段，flutter环境可用）
///
class VmParserBirdger extends SimpleAstVisitor {
  ///要忽略的extension类名
  final List<String> ignoreExtensions;

  VmParserBirdger({required this.ignoreExtensions});

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
      name: node.name.toString(),
      isFinal: node.isFinal,
      isConst: node.isConst,
    );
  }

  @override
  VmParserBirdgeItemData? visitFunctionDeclaration(FunctionDeclaration node) {
    return VmParserBirdgeItemData(
      type: VmParserBirdgeItemType.topLevelFunction,
      name: node.name.toString(),
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
      name: node.name.toString(),
      properties: members,
      isAtJS: node.toSource().contains('@JS'),
      isAbstract: node.abstractKeyword != null,
      superclassNames: superclassNames,
    );
  }

  @override
  VmParserBirdgeItemData? visitClassTypeAlias(ClassTypeAlias node) {
    final superclassNames = <String>[];
    superclassNames.add(node.superclass.name.name); //extends最多只有一个
    if (node.implementsClause != null) superclassNames.addAll(node.implementsClause!.interfaces.map((e) => e.name.name).toList()); //implements可以很多个
    superclassNames.addAll(node.withClause.mixinTypes.map((e) => e.name.name).toList()); //with可以很多个
    if (superclassNames.isEmpty) superclassNames.add('Object');
    return VmParserBirdgeItemData(
      type: VmParserBirdgeItemType.classDeclaration,
      name: node.name.toString(),
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
      name: node.name.toString(),
      properties: members,
      isAtJS: node.toSource().contains('@JS'),
      isAbstract: true, //当成抽象类
      superclassNames: superclassNames,
    );
  }

  @override
  VmParserBirdgeItemData? visitEnumDeclaration(EnumDeclaration node) {
    final resultList = node.members.map((e) => e.accept(this)).toList();
    final members = <VmParserBirdgeItemData?>[];
    for (var e in resultList) {
      e is List<VmParserBirdgeItemData?> ? members.addAll(e) : members.add(e);
    }
    final superclassNames = <String>[];
    if (node.implementsClause != null) superclassNames.addAll(node.implementsClause!.interfaces.map((e) => e.name.name).toList()); //implements可以很多个
    if (node.withClause != null) superclassNames.addAll(node.withClause!.mixinTypes.map((e) => e.name.name).toList()); //with可以很多个
    if (superclassNames.isEmpty) superclassNames.add('Enum'); //必然继承自 Enum
    return VmParserBirdgeItemData(
      type: VmParserBirdgeItemType.classDeclaration,
      name: node.name.toString(),
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
    final targetclassName = node.extendedType.toSource().split('<').first;
    if (ignoreExtensions.contains(targetclassName)) return null;
    return VmParserBirdgeItemData(
      type: VmParserBirdgeItemType.classDeclaration,
      name: targetclassName, //使用 on 的目标作为类名s
      properties: members,
      isAtJS: node.toSource().contains('@JS'),
      isAbstract: true, //当成抽象类
      isExtension: true, //extension是私有类
      superclassNames: superclassNames,
    );
  }

  @override
  List<VmParserBirdgeItemData?> visitFieldDeclaration(FieldDeclaration node) {
    final result = node.fields.accept(this) as List<VmParserBirdgeItemData?>; // => visitVariableDeclarationList
    for (var e in result) {
      if (e != null) {
        e.type = node.isStatic ? VmParserBirdgeItemType.classStaticVariable : VmParserBirdgeItemType.classInstanceVariable;
      }
    }
    return result;
  }

  @override
  List<VmParserBirdgeItemData?> visitConstructorDeclaration(ConstructorDeclaration node) {
    final name = node.name?.toString() ?? '';
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
      name: node.name.toString(),
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
    final typeResult = node.type?.accept(this);
    return VmParserBirdgeItemData(
      type: VmParserBirdgeItemType.functionParameter,
      name: node.name.toString(),
      parameters: typeResult is VmParserBirdgeItemData ? typeResult.parameters : const [],
      isNameParameter: node.isNamed,
      isWrapParameter: typeResult is VmParserBirdgeItemData ? typeResult.isWrapParameter : false,
      wrapTemplateStr: typeResult is VmParserBirdgeItemData ? typeResult.wrapTemplateStr : '',
    );
  }

  @override
  VmParserBirdgeItemData? visitFieldFormalParameter(FieldFormalParameter node) {
    final typeResult = node.type?.accept(this);
    return VmParserBirdgeItemData(
      type: VmParserBirdgeItemType.functionParameter,
      name: node.name.toString(),
      parameters: typeResult is VmParserBirdgeItemData ? typeResult.parameters : const [],
      isNameParameter: node.isNamed,
      isWrapParameter: typeResult is VmParserBirdgeItemData ? typeResult.isWrapParameter : false,
      wrapTemplateStr: typeResult is VmParserBirdgeItemData ? typeResult.wrapTemplateStr : '',
    );
  }

  @override
  VmParserBirdgeItemData? visitSimpleFormalParameter(SimpleFormalParameter node) {
    final typeResult = node.type?.accept(this);
    return VmParserBirdgeItemData(
      type: VmParserBirdgeItemType.functionParameter,
      name: node.name.toString(),
      parameters: typeResult is VmParserBirdgeItemData ? typeResult.parameters : const [],
      isNameParameter: node.isNamed,
      isWrapParameter: typeResult is VmParserBirdgeItemData ? typeResult.isWrapParameter : false,
      wrapTemplateStr: typeResult is VmParserBirdgeItemData ? typeResult.wrapTemplateStr : '',
    );
  }

  @override
  VmParserBirdgeItemData? visitFunctionTypedFormalParameter(FunctionTypedFormalParameter node) {
    final returnTypeResult = node.returnType?.accept(this); // => visitNamedType, visitGenericFunctionType
    final isWrapParameter = (returnTypeResult is List<String> && returnTypeResult.isNotEmpty) || node.typeParameters != null; //返回值带泛型或者函数本身带泛型
    return VmParserBirdgeItemData(
      type: VmParserBirdgeItemType.functionParameter,
      name: node.name.toString(),
      parameters: node.parameters.accept(this),
      isNameParameter: node.isNamed,
      isWrapParameter: isWrapParameter,
      wrapTemplateStr: node.typeParameters?.toSource() ?? '', //如 Set.castFrom
    );
  }

  @override
  VmParserBirdgeItemData? visitDefaultFormalParameter(DefaultFormalParameter node) {
    final result = node.parameter.accept(this) as VmParserBirdgeItemData?; // => visitSuperFormalParameter, visitFieldFormalParameter, visitSimpleFormalParameter, visitFunctionTypedFormalParameter
    if (result != null) {
      result.name = node.name.toString();
      result.isNameParameter = node.isNamed;
    }
    return result;
  }

  @override
  VmParserBirdgeItemData? visitGenericFunctionType(GenericFunctionType node) {
    final returnTypeResult = node.returnType?.accept(this); // => visitNamedType, visitGenericFunctionType
    final isWrapParameter = (returnTypeResult is List<String> && returnTypeResult.isNotEmpty) || node.typeParameters != null; //返回值带泛型或者函数本身带泛型
    return VmParserBirdgeItemData(
      name: node.functionKeyword.toString(), //必然为 'Function'
      parameters: node.parameters.accept(this),
      isWrapParameter: isWrapParameter,
      wrapTemplateStr: node.typeParameters?.toSource() ?? '', //如 Set.castFrom
    );
  }

  @override
  List<String>? visitNamedType(NamedType node) {
    return node.typeArguments?.arguments.map((e) => e.toString()).toList();
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

  ///是否为abstract
  bool isExtension;

  ///是否为命名参数
  bool isNameParameter;

  ///是否为包装参数
  bool isWrapParameter;

  ///包装参数的泛型字符串
  String wrapTemplateStr;

  ///类型直接的extends、implements、with的超类
  List<String> superclassNames;

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
    this.isNameParameter = false,
    this.isWrapParameter = false,
    this.wrapTemplateStr = '',
    this.superclassNames = const [],
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
        return parameters.any((e) => e != null && e.isWrapParameter); //遍历判断
      case VmParserBirdgeItemType.classDeclaration:
        return false;
      case VmParserBirdgeItemType.classStaticVariable:
        return false;
      case VmParserBirdgeItemType.classStaticFunction:
        return parameters.any((e) => e != null && e.isWrapParameter); //遍历判断
      case VmParserBirdgeItemType.classInstanceVariable:
        return false;
      case VmParserBirdgeItemType.classInstanceFunction:
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
        return parameters.any((e) => e != null && e.isWrapParameter); //遍历判断
      case VmParserBirdgeItemType.functionParameter:
        return false;
    }
  }

  ///合并同名类型的全部字段
  void combineClass(VmParserBirdgeItemData sameclassData, {required bool ignoreExtension}) {
    if (ignoreExtension && (isExtension || sameclassData.isExtension)) return; //指定忽略添加扩展
    if (sameclassData.name != name) throw ('Unsupport combineClass operator: ${sameclassData.name} not $name');
    for (var e in sameclassData.properties) {
      if (e != null && !e.isPrivate && !e.isClassStaticProperty) {
        properties.add(e); //因为toProxyCode中使用的是Set，所以无需排重
      }
    }
  }

  ///合并全部超类的实例字段
  void extendsSuper({
    required VmParserBirdgeItemData currentClass,
    required Map<String, VmParserBirdgeItemData> publicMap,
    required Map<String, VmParserBirdgeItemData> pirvateMap,
    void Function(String className, String superName, String classPath)? onNoSuper,
  }) {
    for (var superName in currentClass.superclassNames) {
      var superClass = publicMap[superName] ?? pirvateMap[superName];
      if (superClass != null) {
        for (var e in superClass.properties) {
          if (e != null && !e.isPrivate && !e.isClassStaticProperty) {
            properties.add(e); //因为toProxyCode中使用的是Set，所以无需排重
          }
        }
        extendsSuper(currentClass: superClass, publicMap: publicMap, pirvateMap: pirvateMap); //继续向上遍历
      } else {
        if (onNoSuper != null) onNoSuper(currentClass.name, superName, currentClass.absoluteFilePath);
      }
      _historyclassNames.add(superName);
    }
  }

  ///生成VmClass源代码
  String toClassCode({String indent = '', List<String> ignoreProxy = const [], void Function(String className, String proxyName, String classPath)? onIgnore}) {
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
        if (ignoreProxy.contains('$name.${e.name}')) {
          if (onIgnore != null) onIgnore(name, e.name, absoluteFilePath);
          continue;
        }
        final unionParts = unionPartsMap[e.name] = unionPartsMap[e.name] ?? {};
        if (e.isConstructor) {
          if (!isAbstract || e.isFactoryConstructor) {
            e.toProxyCode(className: name, unionParts: unionParts);
          }
        } else {
          e.toProxyCode(className: name, unionParts: unionParts);
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
  String toProxyCode({String className = '', Set<String>? unionParts}) {
    final staticDot = className.isEmpty ? '' : '.';
    final identifier = name.isEmpty ? getIdentifier(className) : getIdentifier(name);
    final proxyName = name.isEmpty ? 'new' : name;
    final codeParts = unionParts ?? <String>{};
    if (hasStaticReader) codeParts.add('externalStaticPropertyReader: () => $className$staticDot$proxyName');
    if (hasStaticWriter) codeParts.add('externalStaticPropertyWriter: (value) => $className$staticDot$proxyName = value');
    if (hasStaticCaller) {
      int i = 0;
      final outerListStrs = parameters.where((e) => e != null && !e.isNameParameter).map((e) => 'a${i++}').join(', ');
      final outerNameStrs = parameters.where((e) => e != null && e.isNameParameter).map((e) => e!.name).join(', ');
      i = 0;
      final innerListStrs = parameters.where((e) => e != null && !e.isNameParameter).map((e) => e!.isWrapParameter ? e.toCallerCode('a${i++}') : 'a${i++}').join(', ');
      final innerNameStrs = parameters.where((e) => e != null && e.isNameParameter).map((e) => '${e!.name}: ${e.isWrapParameter ? e.toCallerCode(e.name) : e.name}').join(', ');
      if (outerListStrs.isNotEmpty && outerNameStrs.isNotEmpty) {
        codeParts.add('externalStaticFunctionCaller: ($outerListStrs, {$outerNameStrs}) => $className$staticDot$proxyName($innerListStrs, $innerNameStrs)');
      } else if (outerListStrs.isNotEmpty) {
        codeParts.add('externalStaticFunctionCaller: ($outerListStrs) => $className$staticDot$proxyName($innerListStrs)');
      } else if (outerNameStrs.isNotEmpty) {
        codeParts.add('externalStaticFunctionCaller: ({$outerNameStrs}) => $className$staticDot$proxyName($innerNameStrs)');
      } else {
        codeParts.add('externalStaticFunctionCaller: () => $className$staticDot$proxyName()');
      }
    }
    if (hasInstanceReader) codeParts.add('externalInstancePropertyReader: ($className instance) => instance.$proxyName');
    if (hasInstanceWriter) codeParts.add('externalInstancePropertyWriter: ($className instance, value) => instance.$proxyName = value');
    if (hasInstanceCaller) {
      int i = 0;
      final outerListStrs = parameters.where((e) => e != null && !e.isNameParameter).map((e) => 'a${i++}').join(', ');
      final outerNameStrs = parameters.where((e) => e != null && e.isNameParameter).map((e) => e!.name).join(', ');
      i = 0;
      final innerListStrs = parameters.where((e) => e != null && !e.isNameParameter).map((e) => e!.isWrapParameter ? e.toCallerCode('a${i++}') : 'a${i++}').join(', ');
      final innerNameStrs = parameters.where((e) => e != null && e.isNameParameter).map((e) => '${e!.name}: ${e.isWrapParameter ? e.toCallerCode(e.name) : e.name}').join(', ');
      if (outerListStrs.isNotEmpty && outerNameStrs.isNotEmpty) {
        codeParts.add('externalInstanceFunctionCaller: ($className instance, $outerListStrs, {$outerNameStrs}) => instance.$proxyName($innerListStrs, $innerNameStrs)');
      } else if (outerListStrs.isNotEmpty) {
        codeParts.add('externalInstanceFunctionCaller: ($className instance, $outerListStrs) => instance.$proxyName($innerListStrs)');
      } else if (outerNameStrs.isNotEmpty) {
        codeParts.add('externalInstanceFunctionCaller: ($className instance, {$outerNameStrs}) => instance.$proxyName($innerNameStrs)');
      } else {
        codeParts.add('externalInstanceFunctionCaller: ($className instance) => instance.$proxyName()');
      }
    }
    return 'VmProxy(identifier: \'$identifier\', ${codeParts.join(', ')}),';
  }

  ///生成caller源代码
  String toCallerCode(String fieldName) {
    int i = 0;
    final outerListStrs = parameters.where((e) => e != null && !e.isNameParameter).map((e) => 'b${i++}').join(', ');
    final outerNameStrs = parameters.where((e) => e != null && e.isNameParameter).map((e) => e!.name).join(', ');
    i = 0;
    final innerListStrs = parameters.where((e) => e != null && !e.isNameParameter).map((e) => 'b${i++}').join(', ');
    final innerNameStrs = parameters.where((e) => e != null && e.isNameParameter).map((e) => '${e!.name}: ${e.name}').join(', ');
    if (outerListStrs.isNotEmpty && outerNameStrs.isNotEmpty) {
      return '$wrapTemplateStr($outerListStrs, {$outerNameStrs}) => $fieldName == null ? null : $fieldName($innerListStrs, $innerNameStrs)';
    } else if (outerListStrs.isNotEmpty) {
      return '$wrapTemplateStr($outerListStrs) => $fieldName == null ? null : $fieldName($innerListStrs)';
    } else if (outerNameStrs.isNotEmpty) {
      return '$wrapTemplateStr({$outerNameStrs}) => $fieldName == null ? null : $fieldName($innerNameStrs)';
    } else {
      return '$wrapTemplateStr() => $fieldName == null ? null : $fieldName()';
    }
  }

  ///格式化标识符
  static String getIdentifier(String key) => key.replaceAll(r'$', r'\$');
}

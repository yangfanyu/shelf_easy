import 'package:analyzer/dart/ast/ast.dart';

///
///AST树生成map的键名
///
enum VmKeys {
  /** ******** CompilationUnit ******** **/

  ///对应[CompilationUnit]
  $CompilationUnit,

  ///对应[CompilationUnit.declarations]
  $CompilationUnitDeclarations,

  /** ******** TopLevelVariableDeclaration ******** **/

  ///对应[TopLevelVariableDeclaration]
  $TopLevelVariableDeclaration,

  ///对应[TopLevelVariableDeclaration.variables]
  $TopLevelVariableDeclarationVariables,

  /** ******** VariableDeclarationList ******** **/

  ///对应[VariableDeclarationList]
  $VariableDeclarationList,

  ///对应[VariableDeclarationList.isLate]
  $VariableDeclarationListIsLate,

  ///对应[VariableDeclarationList.isFinal]
  $VariableDeclarationListIsFinal,

  ///对应[VariableDeclarationList.isConst]
  $VariableDeclarationListIsConst,

  ///对应[VariableDeclarationList.keyword]
  $VariableDeclarationListKeyword,

  ///对应[VariableDeclarationList.type]
  $VariableDeclarationListType,

  ///对应[VariableDeclarationList.variables]
  $VariableDeclarationListVariables,

  /** ******** VariableDeclaration ******** **/

  ///对应[VariableDeclaration]
  $VariableDeclaration,

  ///对应[VariableDeclaration.name]
  $VariableDeclarationName,

  ///对应[VariableDeclaration.initializer]
  $VariableDeclarationInitializer,

  /** ******** FunctionDeclaration ******** **/

  ///对应[FunctionDeclaration]
  $FunctionDeclaration,

  ///对应[FunctionDeclaration.isGetter]
  $FunctionDeclarationIsGetter,

  ///对应[FunctionDeclaration.isSetter]
  $FunctionDeclarationIsSetter,

  ///对应[FunctionDeclaration.name]
  $FunctionDeclarationName,

  ///对应[FunctionDeclaration.returnType]
  $FunctionDeclarationReturnType,

  ///对应[FunctionDeclaration.functionExpression]
  $FunctionDeclarationFunctionExpression,

  /** ******** NamedType ******** **/

  ///对应[NamedType]
  $NamedType,

  ///对应[NamedType.name]
  $NamedTypeName,

  ///对应[NamedType.question]
  $NamedTypeQuestion,

  /** ******** GenericFunctionType ******** **/

  ///对应[GenericFunctionType]
  $GenericFunctionType,

  ///对应[GenericFunctionType].name
  $GenericFunctionTypeName,

  ///对应[GenericFunctionType.question]
  $GenericFunctionTypeQuestion,

  /** ******** SimpleIdentifier ******** **/

  ///对应[SimpleIdentifier]
  $SimpleIdentifier,

  ///对应[SimpleIdentifier.name]
  $SimpleIdentifierName,

  /** ******** PrefixedIdentifier ******** **/

  ///对应[PrefixedIdentifier]
  $PrefixedIdentifier,

  ///对应[PrefixedIdentifier.prefix]
  $PrefixedIdentifierPrefix,

  ///对应[PrefixedIdentifier.identifier]
  $PrefixedIdentifierIdentifier,

  /** ******** DeclaredIdentifier ******** **/

  ///对应[DeclaredIdentifier]
  $DeclaredIdentifier,

  ///对应[DeclaredIdentifier.type]
  $DeclaredIdentifierType,

  ///对应[DeclaredIdentifier.name]
  $DeclaredIdentifierName,

  /** ******** NullLiteral ******** **/

  ///对应[NullLiteral]
  $NullLiteral,

  ///对应[NullLiteral].null
  $NullLiteralValue,

  /** ******** IntegerLiteral ******** **/

  ///对应[IntegerLiteral]
  $IntegerLiteral,

  ///对应[IntegerLiteral.value]
  $IntegerLiteralValue,

  /** ******** DoubleLiteral ******** **/

  ///对应[DoubleLiteral]
  $DoubleLiteral,

  ///对应[DoubleLiteral.value]
  $DoubleLiteralValue,

  /** ******** BooleanLiteral ******** **/

  ///对应[BooleanLiteral]
  $BooleanLiteral,

  ///对应[BooleanLiteral.value]
  $BooleanLiteralValue,

  /** ******** SimpleStringLiteral ******** **/

  ///对应[SimpleStringLiteral]
  $SimpleStringLiteral,

  ///对应[SimpleStringLiteral.value]
  $SimpleStringLiteralValue,

  /** ******** InterpolationString ******** **/

  ///对应[InterpolationString]
  $InterpolationString,

  ///对应[InterpolationString.value]
  $InterpolationStringValue,

  /** ******** StringInterpolation ******** **/

  ///对应[StringInterpolation]
  $StringInterpolation,

  ///对应[StringInterpolation.elements]
  $StringInterpolationElements,

  /** ******** ListLiteral ******** **/

  ///对应[ListLiteral]
  $ListLiteral,

  ///对应[ListLiteral.elements]
  $ListLiteralElements,

  /** ******** SetOrMapLiteral ******** **/

  ///对应[SetOrMapLiteral]
  $SetOrMapLiteral,

  ///对应[SetOrMapLiteral.typeArguments]
  $SetOrMapLiteralTypeArguments,

  ///对应[SetOrMapLiteral.elements]
  $SetOrMapLiteralElements,

  /** ******** MapLiteralEntry ******** **/

  ///对应[MapLiteralEntry]
  $MapLiteralEntry,

  ///对应[MapLiteralEntry.key]
  $MapLiteralEntryKey,

  ///对应[MapLiteralEntry.value]
  $MapLiteralEntryValue,

  /** ******** BinaryExpression ******** **/

  ///对应[BinaryExpression]
  $BinaryExpression,

  ///对应[BinaryExpression.operator]
  $BinaryExpressionOperator,

  ///对应[BinaryExpression.leftOperand]
  $BinaryExpressionLeftOperand,

  ///对应[BinaryExpression.rightOperand]
  $BinaryExpressionRightOperand,

  /** ******** PrefixExpression ******** **/

  ///对应[PrefixExpression]
  $PrefixExpression,

  ///对应[PrefixExpression.operator]
  $PrefixExpressionOperator,

  ///对应[PrefixExpression.operand]
  $PrefixExpressionOperand,

  /** ******** PostfixExpression ******** **/

  ///对应[PostfixExpression]
  $PostfixExpression,

  ///对应[PostfixExpression.operator]
  $PostfixExpressionOperator,

  ///对应[PostfixExpression.operand]
  $PostfixExpressionOperand,

  /** ******** AssignmentExpression ******** **/

  ///对应[AssignmentExpression]
  $AssignmentExpression,

  ///对应[AssignmentExpression.operator]
  $AssignmentExpressionOperator,

  ///对应[AssignmentExpression.leftHandSide]
  $AssignmentExpressionLeftHandSide,

  ///对应[AssignmentExpression.rightHandSide]
  $AssignmentExpressionRightHandSide,

  /** ******** ConditionalExpression ******** **/

  ///对应[ConditionalExpression]
  $ConditionalExpression,

  ///对应[ConditionalExpression.condition]
  $ConditionalExpressionCondition,

  ///对应[ConditionalExpression.thenExpression]
  $ConditionalExpressionThenExpression,

  ///对应[ConditionalExpression.elseExpression]
  $ConditionalExpressionElseExpression,

  /** ******** ParenthesizedExpression ******** **/

  ///对应[ParenthesizedExpression]
  $ParenthesizedExpression,

  ///对应[ParenthesizedExpression.expression]
  $ParenthesizedExpressionExpression,

  /** ******** IndexExpression ******** **/

  ///对应[IndexExpression]
  $IndexExpression,

  ///对应[IndexExpression.target]
  $IndexExpressionTarget,

  ///对应[IndexExpression.index]
  $IndexExpressionIndex,

  /** ******** InterpolationExpression ******** **/

  ///对应[InterpolationExpression]
  $InterpolationExpression,

  ///对应[InterpolationExpression.expression]
  $InterpolationExpressionExpression,

  /** ******** AsExpression ******** **/

  ///对应[AsExpression]
  $AsExpression,

  ///对应[AsExpression.expression]
  $AsExpressionExpression,

  ///对应[AsExpression.type]
  $AsExpressionType,

  /** ******** IsExpression ******** **/

  ///对应[IsExpression]
  $IsExpression,

  ///对应[IsExpression.notOperator]
  $IsExpressionNotOperator,

  ///对应[IsExpression.expression]
  $IsExpressionExpression,

  ///对应[IsExpression.type]
  $IsExpressionType,

  /** ******** ThrowExpression ******** **/

  ///对应[ThrowExpression]
  $ThrowExpression,

  ///对应[ThrowExpression.expression]
  $ThrowExpressionExpression,

  /** ******** FunctionExpression ******** **/

  ///对应[FunctionExpression]
  $FunctionExpression,

  ///对应[FunctionExpression.parameters]
  $FunctionExpressionParameters,

  ///对应[FunctionExpression.body]
  $FunctionExpressionBody,

  ///对应[FunctionExpression.body].isAsynchronous
  $FunctionExpressionBodyIsAsynchronous,

  /** ******** NamedExpression ******** **/

  ///对应[NamedExpression]
  $NamedExpression,

  ///对应[NamedExpression.name]
  $NamedExpressionName,

  ///对应[NamedExpression.expression]
  $NamedExpressionExpression,

  /** ******** FormalParameterList ******** **/

  ///对应[FormalParameterList]
  $FormalParameterList,

  ///对应[FormalParameterList.parameters]
  $FormalParameterListParameters,

  /** ******** SimpleFormalParameter ******** **/

  ///对应[SimpleFormalParameter]
  $SimpleFormalParameter,

  ///对应[SimpleFormalParameter.type]
  $SimpleFormalParameterType,

  ///对应[SimpleFormalParameter.name]
  $SimpleFormalParameterName,

  /** ******** DefaultFormalParameter ******** **/

  ///对应[DefaultFormalParameter]
  $DefaultFormalParameter,

  ///对应[DefaultFormalParameter.name]
  $DefaultFormalParameterName,

  ///对应[DefaultFormalParameter.parameter]
  $DefaultFormalParameterParameter,

  ///对应[DefaultFormalParameter.defaultValue]
  $DefaultFormalParameterDefaultValue,

  /** ******** ExpressionFunctionBody ******** **/

  ///对应[ExpressionFunctionBody]
  $ExpressionFunctionBody,

  ///对应[ExpressionFunctionBody.expression]
  $ExpressionFunctionBodyExpression,

  /** ******** BlockFunctionBody ******** **/

  ///对应[BlockFunctionBody]
  $BlockFunctionBody,

  ///对应[BlockFunctionBody.block]
  $BlockFunctionBodyBlock,

  /** ******** MethodInvocation ******** **/

  ///对应[MethodInvocation]
  $MethodInvocation,

  ///对应[MethodInvocation.target]
  $MethodInvocationTarget,

  ///对应[MethodInvocation.methodName]
  $MethodInvocationMethodName,

  ///对应[MethodInvocation.argumentList]
  $MethodInvocationArgumentList,

  /** ******** ArgumentList ******** **/

  ///对应[ArgumentList]
  $ArgumentList,

  ///对应[ArgumentList.arguments]
  $ArgumentListArguments,

  /** ******** PropertyAccess ******** **/

  ///对应[PropertyAccess]
  $PropertyAccess,

  ///对应[PropertyAccess.target]
  $PropertyAccessTarget,

  ///对应[PropertyAccess.propertyName]
  $PropertyAccessPropertyName,

  /** ******** Block ******** **/

  ///对应[Block]
  $Block,

  ///对应[Block.statements]
  $BlockStatements,

  /** ******** VariableDeclarationStatement ******** **/

  ///对应[VariableDeclarationStatement]
  $VariableDeclarationStatement,

  ///对应[VariableDeclarationStatement.variables]
  $VariableDeclarationStatementVariables,

  /** ******** ExpressionStatement ******** **/

  ///对应[ExpressionStatement]
  $ExpressionStatement,

  ///对应[ExpressionStatement.expression]
  $ExpressionStatementExpression,

  /** ******** IfStatement ******** **/

  ///对应[IfStatement]
  $IfStatement,

  ///对应[IfStatement.condition]
  $IfStatementCondition,

  ///对应[IfStatement.thenStatement]
  $IfStatementThenStatement,

  ///对应[IfStatement.elseStatement]
  $IfStatementElseStatement,

  /** ******** SwitchStatement ******** **/

  ///对应[SwitchStatement]
  $SwitchStatement,

  ///对应[SwitchStatement.expression]
  $SwitchStatementExpression,

  ///对应[SwitchStatement.members]
  $SwitchStatementMembers,

  /** ******** SwitchCase ******** **/

  ///对应[SwitchCase]
  $SwitchCase,

  ///对应[SwitchCase.expression]
  $SwitchCaseExpression,

  ///对应[SwitchCase.statements]
  $SwitchCaseStatements,

  /** ******** SwitchDefault ******** **/

  ///对应[SwitchDefault]
  $SwitchDefault,

  ///对应[SwitchDefault.statements]
  $SwitchDefaultStatements,

  /** ******** ForStatement ******** **/

  ///对应[ForStatement]
  $ForStatement,

  ///对应[ForStatement.forLoopParts]
  $ForStatementForLoopParts,

  ///对应[ForStatement.body]
  $ForStatementBody,

  /** ******** ForPartsWithDeclarations ******** **/

  ///对应[ForPartsWithDeclarations]
  $ForPartsWithDeclarations,

  ///对应[ForPartsWithDeclarations.variables]
  $ForPartsWithDeclarationsVariables,

  ///对应[ForPartsWithDeclarations.condition]
  $ForPartsWithDeclarationsCondition,

  ///对应[ForPartsWithDeclarations.updaters]
  $ForPartsWithDeclarationsUpdaters,

  /** ******** ForEachPartsWithDeclaration ******** **/

  ///对应[ForEachPartsWithDeclaration]
  $ForEachPartsWithDeclaration,

  ///对应[ForEachPartsWithDeclaration.loopVariable]
  $ForEachPartsWithDeclarationLoopVariable,

  ///对应[ForEachPartsWithDeclaration.iterable]
  $ForEachPartsWithDeclarationIterable,

  /** ******** WhileStatement ******** **/

  ///对应[WhileStatement]
  $WhileStatement,

  ///对应[WhileStatement.condition]
  $WhileStatementCondition,

  ///对应[WhileStatement.body]
  $WhileStatementBody,

  /** ******** DoStatement ******** **/

  ///对应[DoStatement]
  $DoStatement,

  ///对应[WhileStatement.body]
  $DoStatementBody,

  ///对应[DoStatement.condition]
  $DoStatementCondition,

  /** ******** BreakStatement ******** **/

  ///对应[BreakStatement]
  $BreakStatement,

  ///对应[BreakStatement.breakKeyword]
  $BreakStatementBreakKeyword,

  /** ******** ReturnStatement ******** **/

  ///对应[ReturnStatement]
  $ReturnStatement,

  ///对应[ReturnStatement.expression]
  $ReturnStatementExpression,

  ///对应[ReturnStatement.returnKeyword]
  $ReturnStatementReturnKeyword,
}

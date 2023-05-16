import 'package:analyzer/dart/ast/ast.dart';

///
///AST树生成map的键名
///
enum VmKeys {
  ///每个节点都有一个源代码字段
  $NodeSourceKey,

  ///每个节点都有一个源代码字段
  $NodeSourceValue,

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

  ///对应[FunctionDeclaration.functionExpression]
  $FunctionDeclarationFunctionExpression,

  /** ******** NamedType ******** **/

  ///对应[NamedType]
  $NamedType,

  ///对应[NamedType.name2]
  $NamedTypeName,

  ///对应[NamedType.question]
  $NamedTypeQuestion,

  /** ******** GenericFunctionType ******** **/

  ///对应[GenericFunctionType]
  $GenericFunctionType,

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

  ///对应[ListLiteral.typeArguments]
  $ListLiteralTypeArguments,

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

  ///对应[IndexExpression.isCascaded]
  $IndexExpressionIsCascaded,

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

  /** ******** CascadeExpression ******** **/

  ///对应[CascadeExpression]
  $CascadeExpression,

  ///对应[CascadeExpression.target]
  $CascadeExpressionTarget,

  ///对应[CascadeExpression.cascadeSections]
  $CascadeExpressionCascadeSections,

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

  /** ******** NamedExpression ******** **/

  ///对应[NamedExpression]
  $NamedExpression,

  ///对应[NamedExpression.name]
  $NamedExpressionName,

  ///对应[NamedExpression.expression]
  $NamedExpressionExpression,

  /** ******** InstanceCreationExpression ******** **/

  ///对应[InstanceCreationExpression]
  $InstanceCreationExpression,

  ///对应[InstanceCreationExpression.constructorName].type.importPrefix
  $InstanceCreationExpressionConstructorType,

  ///对应[InstanceCreationExpression.constructorName].type.name2
  $InstanceCreationExpressionConstructorName,

  ///对应[InstanceCreationExpression.argumentList]
  $InstanceCreationExpressionArgumentList,

  /** ******** FormalParameterList ******** **/

  ///对应[FormalParameterList]
  $FormalParameterList,

  ///对应[FormalParameterList.parameters]
  $FormalParameterListParameters,

  /** ******** SuperFormalParameter ******** **/

  ///对应[SuperFormalParameter]
  $SuperFormalParameter,

  ///对应[SuperFormalParameter.type]
  $SuperFormalParameterType,

  ///对应[SuperFormalParameter.name]
  $SuperFormalParameterName,

  ///对应[SuperFormalParameter.isNamed]
  $SuperFormalParameterIsNamed,

  /** ******** FieldFormalParameter ******** **/

  ///对应[FieldFormalParameter]
  $FieldFormalParameter,

  ///对应[FieldFormalParameter.type]
  $FieldFormalParameterType,

  ///对应[FieldFormalParameter.name]
  $FieldFormalParameterName,

  ///对应[FieldFormalParameter.isNamed]
  $FieldFormalParameterIsNamed,

  /** ******** SimpleFormalParameter ******** **/

  ///对应[SimpleFormalParameter]
  $SimpleFormalParameter,

  ///对应[SimpleFormalParameter.type]
  $SimpleFormalParameterType,

  ///对应[SimpleFormalParameter.name]
  $SimpleFormalParameterName,

  ///对应[SimpleFormalParameter.isNamed]
  $SimpleFormalParameterIsNamed,

  /** ******** FunctionTypedFormalParameter ******** **/

  ///对应[FunctionTypedFormalParameter]
  $FunctionTypedFormalParameter,

  ///对应[FunctionTypedFormalParameter.name]
  $FunctionTypedFormalParameterName,

  ///对应[FunctionTypedFormalParameter.isNamed]
  $FunctionTypedFormalParameterIsNamed,

  /** ******** DefaultFormalParameter ******** **/

  ///对应[DefaultFormalParameter]
  $DefaultFormalParameter,

  ///对应[DefaultFormalParameter.name]
  $DefaultFormalParameterName,

  ///对应[DefaultFormalParameter.isNamed]
  $DefaultFormalParameterIsNamed,

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

  /** ******** EmptyFunctionBody ******** **/

  ///对应[EmptyFunctionBody]
  $EmptyFunctionBody,

  /** ******** MethodInvocation ******** **/

  ///对应[MethodInvocation]
  $MethodInvocation,

  ///对应[MethodInvocation.target]
  $MethodInvocationTarget,

  ///对应[MethodInvocation.isCascaded]
  $MethodInvocationIsCascaded,

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

  ///对应[PropertyAccess.isCascaded]
  $PropertyAccessIsCascaded,

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

  ///对应[IfStatement.expression]
  $IfStatementExpression,

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

  /** ******** ContinueStatement ******** **/

  ///对应[ContinueStatement]
  $ContinueStatement,

  /** ******** ReturnStatement ******** **/

  ///对应[ReturnStatement]
  $ReturnStatement,

  ///对应[ReturnStatement.expression]
  $ReturnStatementExpression,

  /** ******** ClassDeclaration ******** **/

  ///对应[ClassDeclaration]
  $ClassDeclaration,

  ///对应[ClassDeclaration.name]
  $ClassDeclarationName,

  ///对应[ClassDeclaration.members]
  $ClassDeclarationMembers,

  ///对应[ClassDeclaration.extendsClause]
  $ClassDeclarationExtendsClause,

  /** ******** FieldDeclaration ******** **/

  ///对应[FieldDeclaration]
  $FieldDeclaration,

  ///对应[FieldDeclaration.isStatic]
  $FieldDeclarationIsStatic,

  ///对应[FieldDeclaration.fields]
  $FieldDeclarationFields,

  ///对应[FieldDeclaration.fields].variables.names
  $FieldDeclarationFieldsNames,

  /** ******** ConstructorDeclaration ******** **/

  ///对应[ConstructorDeclaration]
  $ConstructorDeclaration,

  ///对应[ConstructorDeclaration.name]
  $ConstructorDeclarationName,

  ///对应[ConstructorDeclaration.factoryKeyword]
  $ConstructorDeclarationFactoryKeyword,

  ///对应[ConstructorDeclaration.parameters]
  $ConstructorDeclarationParameters,

  ///对应[ConstructorDeclaration.initializers]
  $ConstructorDeclarationInitializers,

  ///对应[ConstructorDeclaration.body]
  $ConstructorDeclarationBody,

  /** ******** ConstructorFieldInitializer ******** **/

  ///对应[ConstructorFieldInitializer]
  $ConstructorFieldInitializer,

  ///对应[ConstructorFieldInitializer.fieldName]
  $ConstructorFieldInitializerFieldName,

  ///对应[ConstructorFieldInitializer.expression]
  $ConstructorFieldInitializerExpression,

  /** ******** MethodDeclaration ******** **/

  ///对应[MethodDeclaration]
  $MethodDeclaration,

  ///对应[MethodDeclaration.isStatic]
  $MethodDeclarationIsStatic,

  ///对应[MethodDeclaration.isGetter]
  $MethodDeclarationIsGetter,

  ///对应[MethodDeclaration.isSetter]
  $MethodDeclarationIsSetter,

  ///对应[MethodDeclaration.name]
  $MethodDeclarationName,

  ///对应[MethodDeclaration.parameters]
  $MethodDeclarationParameters,

  ///对应[MethodDeclaration.body]
  $MethodDeclarationBody,
}

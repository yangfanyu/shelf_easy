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

  ///对应[VariableDeclarationList.type].question
  $VariableDeclarationListTypeQuestion,

  ///对应[VariableDeclarationList.type].toSource()
  $VariableDeclarationListTypeToSource,

  ///对应[VariableDeclarationList.variables]
  $VariableDeclarationListVariables,

  /** ******** VariableDeclaration ******** **/

  ///对应[VariableDeclaration]
  $VariableDeclaration,

  ///对应[VariableDeclaration.name]
  $VariableDeclarationName,

  ///对应[VariableDeclaration.initializer]
  $VariableDeclarationInitializer,

  /** ******** NamedType ******** **/

  ///对应[NamedType]
  $NamedType,

  ///对应[NamedType.name]
  $NamedTypeName,

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

  ///对应[IndexExpression.realTarget]
  $IndexExpressionRealTarget,

  ///对应[IndexExpression.index]
  $IndexExpressionIndex,

  /** ******** InterpolationExpression ******** **/

  ///对应[InterpolationExpression]
  $InterpolationExpression,

  ///对应[InterpolationExpression.expression]
  $InterpolationExpressionExpression,

  /** ******** MethodInvocation ******** **/

  ///对应[MethodInvocation]
  $MethodInvocation,

  ///对应[MethodInvocation.target]
  $MethodInvocationTarget,

  ///对应[MethodInvocation.realTarget]
  $MethodInvocationRealTarget,

  ///对应[MethodInvocation.methodName]
  $MethodInvocationMethodName,

  ///对应[MethodInvocation.argumentList]
  $MethodInvocationArgumentList,

  /** ******** ArgumentList ******** **/

  ///对应[ArgumentList]
  $ArgumentList,

  ///对应[ArgumentList.arguments]
  $ArgumentListArguments,
}

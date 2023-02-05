
// ///
// ///生成语法树Map数据
// ///
// class VmParserVisitor extends AstVisitor<Map<VmKeys, dynamic>> {
//   @override
//   Map<VmKeys, dynamic> visitCompilationUnit(CompilationUnit node) => {
//         VmKeys.$CompilationUnit: {
//           VmKeys.$CompilationUnitDeclarations: node.declarations.map((e) => e.accept(this)).toList(),
//         },
//       };

//   @override
//   Map<VmKeys, dynamic> visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) => {
//         VmKeys.$TopLevelVariableDeclaration: {
//           VmKeys.$TopLevelVariableDeclarationVariables: node.variables.accept(this),
//         },
//       };

//   @override
//   Map<VmKeys, dynamic> visitVariableDeclarationList(VariableDeclarationList node) => {
//         VmKeys.$VariableDeclarationList: {
//           VmKeys.$VariableDeclarationListType: node.type?.accept(this),
//           VmKeys.$VariableDeclarationListVariables: node.variables.map((e) => e.accept(this)).toList(),
//         },
//       };

//   @override
//   Map<VmKeys, dynamic> visitFunctionDeclaration(FunctionDeclaration node) => {
//         VmKeys.$FunctionDeclaration: {
//           VmKeys.$FunctionDeclarationReturnType: node.returnType?.accept(this),
//           VmKeys.$FunctionDeclarationIsGetter: node.isGetter,
//           VmKeys.$FunctionDeclarationIsSetter: node.isSetter,
//           VmKeys.$FunctionDeclarationName: node.name.toString(),
//           VmKeys.$FunctionDeclarationFunctionExpression: node.functionExpression.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitClassDeclaration(ClassDeclaration node) => {
//         VmKeys.$ClassDeclaration: {
//           VmKeys.$ClassDeclarationAbstractKeyword: node.abstractKeyword?.toString(),
//           VmKeys.$ClassDeclarationName: node.name.toString(),
//           VmKeys.$ClassDeclarationTypeParameters: node.typeParameters?.accept(this),
//           VmKeys.$ClassDeclarationExtendsClause: node.extendsClause?.accept(this),
//           VmKeys.$ClassDeclarationImplementsClause: node.implementsClause?.accept(this),
//           VmKeys.$ClassDeclarationMembers: node.members.map((e) => e.accept(this)).toList(),
//         },
//       };

//   @override
//   Map<VmKeys, dynamic> visitFieldDeclaration(FieldDeclaration node) => {
//         VmKeys.$FieldDeclaration: {
//           VmKeys.$FieldDeclarationIsStatic: node.isStatic,
//           VmKeys.$FieldDeclarationFields: node.fields.accept(this),
//         },
//       };

//   @override
//   Map<VmKeys, dynamic> visitConstructorDeclaration(ConstructorDeclaration node) => {
//         VmKeys.$ConstructorDeclaration: {
//           VmKeys.$ConstructorDeclarationName: node.name?.toString(),
//           VmKeys.$ConstructorDeclarationConstKeyword: node.constKeyword?.toString(),
//           VmKeys.$ConstructorDeclarationReturnType: node.returnType.accept(this),
//           VmKeys.$ConstructorDeclarationInitializers: node.initializers.map((e) => e.accept(this)).toList(),
//           VmKeys.$ConstructorDeclarationParameters: node.parameters.accept(this),
//         },
//       };

//   @override
//   Map<VmKeys, dynamic> visitConstructorFieldInitializer(ConstructorFieldInitializer node) => {
//         VmKeys.$ConstructorFieldInitializer: {
//           VmKeys.$ConstructorFieldInitializerFieldName: node.fieldName.accept(this),
//           VmKeys.$ConstructorFieldInitializerExpression: node.expression.accept(this),
//         },
//       };

//   @override
//   Map<VmKeys, dynamic> visitFieldFormalParameter(FieldFormalParameter node) => {
//         VmKeys.$FieldFormalParameter: {
//           VmKeys.$FieldFormalParameterName: node.name.toString(),
//           VmKeys.$FieldFormalParameterType: node.type?.accept(this),
//           VmKeys.$FieldFormalParameterParameters: node.parameters?.accept(this),
//         },
//       };

//   @override
//   Map<VmKeys, dynamic> visitMethodDeclaration(MethodDeclaration node) => {
//         VmKeys.$MethodDeclaration: {
//           VmKeys.$MethodDeclarationReturnType: node.returnType?.accept(this),
//           VmKeys.$MethodDeclarationIsStatic: node.isStatic,
//           VmKeys.$MethodDeclarationIsGetter: node.isGetter,
//           VmKeys.$MethodDeclarationIsSetter: node.isSetter,
//           VmKeys.$MethodDeclarationIsOperator: node.isOperator,
//           VmKeys.$MethodDeclarationIsAbstract: node.isAbstract,
//           VmKeys.$MethodDeclarationName: node.name.toString(),
//           VmKeys.$MethodDeclarationParameters: node.parameters?.accept(this),
//           VmKeys.$MethodDeclarationBody: node.body.accept(this),
//         },
//       };

//   @override
//   Map<VmKeys, dynamic> visitEmptyFunctionBody(EmptyFunctionBody node) => {
//         VmKeys.$EmptyFunctionBody: {
//           VmKeys.$EmptyFunctionBodyIsGenerator: node.isGenerator,
//           VmKeys.$EmptyFunctionBodyIsSynthetic: node.isSynthetic,
//           VmKeys.$EmptyFunctionBodyIsSynchronous: node.isSynchronous,
//           VmKeys.$EmptyFunctionBodyIsAsynchronous: node.isAsynchronous,
//         },
//       };

//   @override
//   Map<VmKeys, dynamic> visitExtendsClause(ExtendsClause node) => {
//         VmKeys.$ExtendsClause: {
//           VmKeys.$ExtendsClauseSuperclass: node.superclass.accept(this),
//         },
//       };

//   @override
//   Map<VmKeys, dynamic> visitImplementsClause(ImplementsClause node) => {
//         VmKeys.$ImplementsClause: {
//           VmKeys.$ImplementsClauseInterfaces: node.interfaces.map((e) => e.accept(this)).toList(),
//         },
//       };

//   @override
//   Map<VmKeys, dynamic> visitEnumDeclaration(EnumDeclaration node) => {
//         VmKeys.$EnumDeclaration: {
//           VmKeys.$EnumDeclarationName: node.name.toString(),
//           VmKeys.$EnumDeclarationConstants: node.constants.map((e) => e.accept(this)).toList(),
//         },
//       };

//   @override
//   Map<VmKeys, dynamic> visitEnumConstantDeclaration(EnumConstantDeclaration node) => {
//         VmKeys.$EnumConstantDeclaration: {
//           VmKeys.$EnumConstantDeclarationName: node.name.toString(),
//           VmKeys.$EnumConstantDeclarationArguments: node.arguments?.accept(this),
//         },
//       };

//   @override
//   Map<VmKeys, dynamic> visitTypeParameterList(TypeParameterList node) => {
//         VmKeys.$TypeParameterList: {
//           VmKeys.$TypeParameterListTypeParameters: node.typeParameters.map((e) => e.accept(this)).toList(),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitTypeParameter(TypeParameter node) => {
//         VmKeys.$TypeParameter: {
//           VmKeys.$TypeParameterName: node.name.toString(),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitTypeArgumentList(TypeArgumentList node) => {
//         VmKeys.$TypeArgumentList: {
//           VmKeys.$TypeArgumentListArguments: node.arguments.map((e) => e.accept(this)).toList(),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitNamedType(NamedType node) => {
//         VmKeys.$NamedType: {
//           VmKeys.$NamedTypeName: node.name.accept(this),
//           VmKeys.$NamedTypeTypeArguments: node.typeArguments?.accept(this),
//         },
//       };

//   @override
//   Map<VmKeys, dynamic> visitSimpleIdentifier(SimpleIdentifier node) => {
//         VmKeys.$SimpleIdentifier: {
//           VmKeys.$SimpleIdentifierName: node.name,
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitDeclaredIdentifier(DeclaredIdentifier node) => {
//         VmKeys.$DeclaredIdentifier: {
//           VmKeys.$DeclaredIdentifierType: node.type?.accept(this),
//           VmKeys.$DeclaredIdentifierName: node.name.toString(),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitVariableDeclaration(VariableDeclaration node) => {
//         VmKeys.$VariableDeclaration: {
//           VmKeys.$VariableDeclarationIsConst: node.isConst,
//           VmKeys.$VariableDeclarationIsFinal: node.isFinal,
//           VmKeys.$VariableDeclarationIsLate: node.isLate,
//           VmKeys.$VariableDeclarationName: node.name.toString(),
//           VmKeys.$VariableDeclarationInitializer: node.initializer?.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitBinaryExpression(BinaryExpression node) => {
//         VmKeys.$BinaryExpression: {
//           VmKeys.$BinaryExpressionOperator: node.operator.lexeme,
//           VmKeys.$BinaryExpressionLeftOperand: node.leftOperand.accept(this),
//           VmKeys.$BinaryExpressionRightOperand: node.rightOperand.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitPrefixExpression(PrefixExpression node) => {
//         VmKeys.$PrefixExpression: {
//           VmKeys.$PrefixExpressionOperator: node.operator.lexeme,
//           VmKeys.$PrefixExpressionOperand: node.operand.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitPostfixExpression(PostfixExpression node) => {
//         VmKeys.$PostfixExpression: {
//           VmKeys.$PostfixExpressionOperator: node.operator.lexeme,
//           VmKeys.$PostfixExpressionOperand: node.operand.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitAssignmentExpression(AssignmentExpression node) => {
//         VmKeys.$AssignmentExpression: {
//           VmKeys.$AssignmentExpressionOperator: node.operator.lexeme,
//           VmKeys.$AssignmentExpressionLeftHandSide: node.leftHandSide.accept(this),
//           VmKeys.$AssignmentExpressionRightHandSide: node.rightHandSide.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitAsExpression(AsExpression node) => {
//         VmKeys.$AsExpression: {
//           VmKeys.$AsExpressionAsOperator: node.asOperator.lexeme,
//           VmKeys.$AsExpressionExpression: node.expression.accept(this),
//           VmKeys.$AsExpressionType: node.type.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitIsExpression(IsExpression node) => {
//         VmKeys.$IsExpression: {
//           VmKeys.$IsExpressionIsOperator: node.isOperator.lexeme,
//           VmKeys.$IsExpressionNotOperator: node.notOperator?.toString(),
//           VmKeys.$IsExpressionExpression: node.expression.accept(this),
//           VmKeys.$IsExpressionType: node.type.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitConditionalExpression(ConditionalExpression node) => {
//         VmKeys.$ConditionalExpression: {
//           VmKeys.$ConditionalExpressionCondition: node.condition.accept(this),
//           VmKeys.$ConditionalExpressionThenExpression: node.thenExpression.accept(this),
//           VmKeys.$ConditionalExpressionElseExpression: node.elseExpression.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitParenthesizedExpression(ParenthesizedExpression node) => {
//         VmKeys.$ParenthesizedExpression: {
//           VmKeys.$ParenthesizedExpressionExpression: node.expression.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitIndexExpression(IndexExpression node) => {
//         VmKeys.$IndexExpression: {
//           VmKeys.$IndexExpressionTarget: node.target?.accept(this),
//           VmKeys.$IndexExpressionRealTarget: node.realTarget.accept(this),
//           VmKeys.$IndexExpressionIndex: node.index.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitInterpolationExpression(InterpolationExpression node) => {
//         VmKeys.$InterpolationExpression: {
//           VmKeys.$InterpolationExpressionExpression: node.expression.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitFunctionExpression(FunctionExpression node) => {
//         VmKeys.$FunctionExpression: {
//           VmKeys.$FunctionExpressionParameters: node.parameters?.accept(this),
//           VmKeys.$FunctionExpressionBody: node.body.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitNamedExpression(NamedExpression node) => {
//         VmKeys.$NamedExpression: {
//           VmKeys.$NamedExpressionName: node.name.accept(this),
//           VmKeys.$NamedExpressionExpression: node.expression.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitAwaitExpression(AwaitExpression node) => {
//         VmKeys.$AwaitExpression: {
//           VmKeys.$AwaitExpressionExpression: node.expression.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitSuperExpression(SuperExpression node) => {
//         VmKeys.$SuperExpression: {
//           VmKeys.$SuperExpressionSuperSuperKeyword: node.superKeyword.toString(),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitMethodInvocation(MethodInvocation node) => {
//         VmKeys.$MethodInvocation: {
//           VmKeys.$MethodInvocationTarget: node.target?.accept(this),
//           VmKeys.$MethodInvocationRealTarget: node.realTarget?.accept(this),
//           VmKeys.$MethodInvocationMethodName: node.methodName.accept(this),
//           VmKeys.$MethodInvocationTypeArguments: node.typeArguments?.accept(this),
//           VmKeys.$MethodInvocationArgumentList: node.argumentList.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitLabel(Label node) => {
//         VmKeys.$Label: {
//           VmKeys.$LabelLabel: node.label.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitArgumentList(ArgumentList node) => {
//         VmKeys.$ArgumentList: {
//           VmKeys.$ArgumentListArguments: node.arguments.map((e) => e.accept(this)).toList(),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitFormalParameterList(FormalParameterList node) => {
//         VmKeys.$FormalParameterList: {
//           VmKeys.$FormalParameterListParameters: node.parameters.map((e) => e.accept(this)).toList(),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitSimpleFormalParameter(SimpleFormalParameter node) => {
//         VmKeys.$SimpleFormalParameter: {
//           VmKeys.$SimpleFormalParameterType: node.type?.accept(this),
//           VmKeys.$SimpleFormalParameterName: node.name.toString(),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitDefaultFormalParameter(DefaultFormalParameter node) => {
//         VmKeys.$DefaultFormalParameter: {
//           VmKeys.$DefaultFormalParameterName: node.name?.toString(),
//           VmKeys.$DefaultFormalParameterParameter: node.parameter.accept(this),
//           VmKeys.$DefaultFormalParameterDefaultValue: node.defaultValue?.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitBlock(Block node) => {
//         VmKeys.$Block: {
//           VmKeys.$BlockStatements: node.statements.map((e) => e.accept(this)).toList(),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitBlockFunctionBody(BlockFunctionBody node) => {
//         VmKeys.$BlockFunctionBody: {
//           VmKeys.$BlockFunctionBodyBlock: node.block.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitExpressionFunctionBody(ExpressionFunctionBody node) => {
//         VmKeys.$ExpressionFunctionBody: {
//           VmKeys.$ExpressionFunctionStar: node.star,
//           VmKeys.$ExpressionFunctionIsGenerator: node.isGenerator,
//           VmKeys.$ExpressionFunctionIsSynthetic: node.isSynthetic,
//           VmKeys.$ExpressionFunctionIsSynchronous: node.isSynchronous,
//           VmKeys.$ExpressionFunctionIsAsynchronous: node.isAsynchronous,
//           VmKeys.$ExpressionFunctionBodyExpression: node.expression.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitVariableDeclarationStatement(VariableDeclarationStatement node) => {
//         VmKeys.$VariableDeclarationStatement: {
//           VmKeys.$VariableDeclarationStatementVariables: node.variables.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitExpressionStatement(ExpressionStatement node) => {
//         VmKeys.$ExpressionStatement: {
//           VmKeys.$ExpressionStatementExpression: node.expression.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitIfStatement(IfStatement node) => {
//         VmKeys.$IfStatement: {
//           VmKeys.$IfStatementCondition: node.condition.accept(this),
//           VmKeys.$IfStatementThenStatement: node.thenStatement.accept(this),
//           VmKeys.$IfStatementElseStatement: node.elseStatement?.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitSwitchStatement(SwitchStatement node) => {
//         VmKeys.$SwitchStatement: {
//           VmKeys.$SwitchStatementExpression: node.expression.accept(this),
//           VmKeys.$SwitchStatementMembers: node.members.map((e) => e.accept(this)).toList(),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitSwitchCase(SwitchCase node) => {
//         VmKeys.$SwitchCase: {
//           VmKeys.$SwitchCaseExpression: node.expression.accept(this),
//           VmKeys.$SwitchCaseStatements: node.statements.map((e) => e.accept(this)).toList(),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitSwitchDefault(SwitchDefault node) => {
//         VmKeys.$SwitchDefault: {
//           VmKeys.$SwitchDefaultStatements: node.statements.map((e) => e.accept(this)).toList(),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitForStatement(ForStatement node) => {
//         VmKeys.$ForStatement: {
//           VmKeys.$ForStatementForLoopParts: node.forLoopParts.accept(this),
//           VmKeys.$ForStatementBody: node.body.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitForPartsWithDeclarations(ForPartsWithDeclarations node) => {
//         VmKeys.$ForPartsWithDeclarations: {
//           VmKeys.$ForPartsWithDeclarationsVariables: node.variables.accept(this),
//           VmKeys.$ForPartsWithDeclarationsCondition: node.condition?.accept(this),
//           VmKeys.$ForPartsWithDeclarationsUpdaters: node.updaters.map((e) => e.accept(this)).toList(),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitForEachPartsWithDeclaration(ForEachPartsWithDeclaration node) => {
//         VmKeys.$ForEachPartsWithDeclaration: {
//           VmKeys.$ForEachPartsWithDeclarationLoopVariable: node.loopVariable.accept(this),
//           VmKeys.$ForEachPartsWithDeclarationIterable: node.iterable.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitWhileStatement(WhileStatement node) => {
//         VmKeys.$WhileStatement: {
//           VmKeys.$WhileStatementCondition: node.condition.accept(this),
//           VmKeys.$WhileStatementBody: node.body.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitDoStatement(DoStatement node) => {
//         VmKeys.$DoStatement: {
//           VmKeys.$DoStatementBody: node.body.accept(this),
//           VmKeys.$DoStatementCondition: node.condition.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitBreakStatement(BreakStatement node) => {
//         VmKeys.$BreakStatement: {
//           VmKeys.$BreakStatementBreakKeyword: node.breakKeyword.toString(),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitReturnStatement(ReturnStatement node) => {
//         VmKeys.$ReturnStatement: {
//           VmKeys.$ReturnStatementExpression: node.expression?.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitStringInterpolation(StringInterpolation node) => {
//         VmKeys.$StringInterpolation: {
//           VmKeys.$StringInterpolationElements: node.elements.map((e) => e.accept(this)).toList(),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitInterpolationString(InterpolationString node) => {
//         VmKeys.$InterpolationString: {
//           VmKeys.$InterpolationStringContents: node.contents.toString(),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitIntegerLiteral(IntegerLiteral node) => {VmKeys.$IntegerLiteral: node.value};

//   @override
//   Map<VmKeys, dynamic> visitDoubleLiteral(DoubleLiteral node) => {VmKeys.$DoubleLiteral: node.value};

//   @override
//   Map<VmKeys, dynamic> visitBooleanLiteral(BooleanLiteral node) => {VmKeys.$BooleanLiteral: node.value};

//   @override
//   Map<VmKeys, dynamic> visitSimpleStringLiteral(StringLiteral node) => {VmKeys.$StringLiteral: node.stringValue};

//   @override
//   Map<VmKeys, dynamic> visitListLiteral(ListLiteral node) => {
//         VmKeys.$ListLiteral: {
//           VmKeys.$ListLiteralTypeArguments: node.typeArguments?.accept(this),
//           VmKeys.$ListLiteralElements: node.elements.map((e) => e.accept(this)).toList(),
//         }
//       };
//   @override
//   Map<VmKeys, dynamic> visitSetOrMapLiteral(SetOrMapLiteral node) => {
//         VmKeys.$SetOrMapLiteral: {
//           VmKeys.$SetOrMapLiteralElementsTypeArguments: node.typeArguments?.accept(this),
//           VmKeys.$SetOrMapLiteralElements: node.elements.map((e) => e.accept(this)).toList(),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitMapLiteralEntry(MapLiteralEntry node) => {
//         VmKeys.$MapLiteralEntry: {
//           VmKeys.$MapLiteralEntryKey: node.key.accept(this),
//           VmKeys.$MapLiteralEntryValue: node.value.accept(this),
//         }
//       };

//   @override
//   Map<VmKeys, dynamic> visitNullLiteral(NullLiteral node) => {VmKeys.$NullLiteral: null};
// }



  // /** ******** FunctionDeclaration ******** **/

  // ///对应[FunctionDeclaration]
  // $FunctionDeclaration,

  // ///对应[FunctionDeclaration.returnType]
  // $FunctionDeclarationReturnType,

  // ///对应[FunctionDeclaration.isGetter]
  // $FunctionDeclarationIsGetter,

  // ///对应[FunctionDeclaration.isSetter]
  // $FunctionDeclarationIsSetter,

  // ///对应[FunctionDeclaration.name]
  // $FunctionDeclarationName,

  // ///对应[FunctionDeclaration.functionExpression]
  // $FunctionDeclarationFunctionExpression,

  // /** ******** ClassDeclaration ******** **/

  // ///对应[ClassDeclaration]
  // $ClassDeclaration,

  // ///对应[ClassDeclaration.abstractKeyword]
  // $ClassDeclarationAbstractKeyword,

  // ///对应[ClassDeclaration.name]
  // $ClassDeclarationName,

  // ///对应[ClassDeclaration.typeParameters]
  // $ClassDeclarationTypeParameters,

  // ///对应[ClassDeclaration.extendsClause]
  // $ClassDeclarationExtendsClause,

  // ///对应[ClassDeclaration.implementsClause]
  // $ClassDeclarationImplementsClause,

  // ///对应[ClassDeclaration.members]
  // $ClassDeclarationMembers,

  // /** ******** FieldDeclaration ******** **/

  // ///对应[FieldDeclaration]
  // $FieldDeclaration,

  // ///对应[FieldDeclaration.isStatic]
  // $FieldDeclarationIsStatic,

  // ///对应[FieldDeclaration.fields]
  // $FieldDeclarationFields,

  // /** ******** ConstructorDeclaration ******** **/

  // ///对应[ConstructorDeclaration]
  // $ConstructorDeclaration,

  // ///对应[ConstructorDeclaration.name]
  // $ConstructorDeclarationName,

  // ///对应[ConstructorDeclaration.constKeyword]
  // $ConstructorDeclarationConstKeyword,

  // ///对应[ConstructorDeclaration.returnType]
  // $ConstructorDeclarationReturnType,

  // ///对应[ConstructorDeclaration.initializers]
  // $ConstructorDeclarationInitializers,

  // ///对应[ConstructorDeclaration.parameters]
  // $ConstructorDeclarationParameters,

  // /** ******** ConstructorFieldInitializer ******** **/

  // ///对应[ConstructorFieldInitializer]
  // $ConstructorFieldInitializer,

  // ///对应[ConstructorFieldInitializer.fieldName]
  // $ConstructorFieldInitializerFieldName,

  // ///对应[ConstructorFieldInitializer.expression]
  // $ConstructorFieldInitializerExpression,

  // /** ******** SuperFormalParameter ******** **/

  // ///对应[SuperFormalParameter]
  // $SuperFormalParameter,

  // ///对应[SuperFormalParameter.name]
  // $SuperFormalParameterName,

  // ///对应[SuperFormalParameter.type]
  // $SuperFormalParameterType,

  // ///对应[SuperFormalParameter.parameters]
  // $SuperFormalParameterParameters,

  // /** ******** FieldFormalParameter ******** **/

  // ///对应[FieldFormalParameter]
  // $FieldFormalParameter,

  // ///对应[FieldFormalParameter.name]
  // $FieldFormalParameterName,

  // ///对应[FieldFormalParameter.type]
  // $FieldFormalParameterType,

  // ///对应[FieldFormalParameter.parameters]
  // $FieldFormalParameterParameters,

  // /** ******** MethodDeclaration ******** **/

  // ///对应[MethodDeclaration]
  // $MethodDeclaration,

  // ///对应[MethodDeclaration.returnType]
  // $MethodDeclarationReturnType,

  // ///对应[MethodDeclaration.isStatic]
  // $MethodDeclarationIsStatic,

  // ///对应[MethodDeclaration.isGetter]
  // $MethodDeclarationIsGetter,

  // ///对应[MethodDeclaration.isSetter]
  // $MethodDeclarationIsSetter,

  // ///对应[MethodDeclaration.isOperator]
  // $MethodDeclarationIsOperator,

  // ///对应[MethodDeclaration.isAbstract]
  // $MethodDeclarationIsAbstract,

  // ///对应[MethodDeclaration.name]
  // $MethodDeclarationName,

  // ///对应[MethodDeclaration.parameters]
  // $MethodDeclarationParameters,

  // ///对应[MethodDeclaration.body]
  // $MethodDeclarationBody,

  // /** ******** EmptyFunctionBody ******** **/

  // ///对应[EmptyFunctionBody]
  // $EmptyFunctionBody,

  // ///对应[EmptyFunctionBody.isGenerator]
  // $EmptyFunctionBodyIsGenerator,

  // ///对应[EmptyFunctionBody.isSynthetic]
  // $EmptyFunctionBodyIsSynthetic,

  // ///对应[EmptyFunctionBody.isSynchronous]
  // $EmptyFunctionBodyIsSynchronous,

  // ///对应[EmptyFunctionBody.isAsynchronous]
  // $EmptyFunctionBodyIsAsynchronous,

  // /** ******** ExtendsClause ******** **/

  // ///对应[ExtendsClause]
  // $ExtendsClause,

  // ///对应[ExtendsClause.superclass]
  // $ExtendsClauseSuperclass,

  // /** ******** ImplementsClause ******** **/

  // ///对应[ImplementsClause]
  // $ImplementsClause,

  // ///对应[ImplementsClause.interfaces]
  // $ImplementsClauseInterfaces,

  // /** ******** EnumDeclaration ******** **/

  // ///对应[EnumDeclaration]
  // $EnumDeclaration,

  // ///对应[EnumDeclaration.name]
  // $EnumDeclarationName,

  // ///对应[EnumDeclaration.constants]
  // $EnumDeclarationConstants,

  // /** ******** EnumConstantDeclaration ******** **/

  // ///对应[EnumConstantDeclaration]
  // $EnumConstantDeclaration,

  // ///对应[EnumConstantDeclaration.name]
  // $EnumConstantDeclarationName,

  // ///对应[EnumConstantDeclaration.arguments]
  // $EnumConstantDeclarationArguments,

  // /** ******** TypeParameterList ******** **/

  // ///对应[TypeParameterList]
  // $TypeParameterList,

  // ///对应[TypeParameterList.typeParameters]
  // $TypeParameterListTypeParameters,

  // /** ******** TypeParameter ******** **/

  // ///对应[TypeParameter]
  // $TypeParameter,

  // ///对应[TypeParameter.name]
  // $TypeParameterName,

  // /** ******** TypeArgumentList ******** **/

  // ///对应[TypeArgumentList]
  // $TypeArgumentList,

  // ///对应[TypeArgumentList.arguments]
  // $TypeArgumentListArguments,

  // /** ******** DeclaredIdentifier ******** **/

  // ///对应[DeclaredIdentifier]
  // $DeclaredIdentifier,

  // ///对应[DeclaredIdentifier.type]
  // $DeclaredIdentifierType,

  // ///对应[DeclaredIdentifier.name]
  // $DeclaredIdentifierName,

  // /** ******** BinaryExpression ******** **/

  // ///对应[BinaryExpression]
  // $BinaryExpression,

  // ///对应[BinaryExpression.operator]
  // $BinaryExpressionOperator,

  // ///对应[BinaryExpression.leftOperand]
  // $BinaryExpressionLeftOperand,

  // ///对应[BinaryExpression.rightOperand]
  // $BinaryExpressionRightOperand,

  // /** ******** PrefixExpression ******** **/

  // ///对应[PrefixExpression]
  // $PrefixExpression,

  // ///对应[PrefixExpression.operator]
  // $PrefixExpressionOperator,

  // ///对应[PrefixExpression.operand]
  // $PrefixExpressionOperand,

  // /** ******** PostfixExpression ******** **/

  // ///对应[PostfixExpression]
  // $PostfixExpression,

  // ///对应[PostfixExpression.operator]
  // $PostfixExpressionOperator,

  // ///对应[PostfixExpression.operand]
  // $PostfixExpressionOperand,

  // /** ******** AssignmentExpression ******** **/

  // ///对应[AssignmentExpression]
  // $AssignmentExpression,

  // ///对应[AssignmentExpression.operator]
  // $AssignmentExpressionOperator,

  // ///对应[AssignmentExpression.leftHandSide]
  // $AssignmentExpressionLeftHandSide,

  // ///对应[AssignmentExpression.rightHandSide]
  // $AssignmentExpressionRightHandSide,

  // /** ******** AsExpression ******** **/

  // ///对应[AsExpression]
  // $AsExpression,

  // ///对应[AsExpression.asOperator]
  // $AsExpressionAsOperator,

  // ///对应[AsExpression.expression]
  // $AsExpressionExpression,

  // ///对应[AsExpression.type]
  // $AsExpressionType,

  // /** ******** IsExpression ******** **/

  // ///对应[IsExpression]
  // $IsExpression,

  // ///对应[IsExpression.isOperator]
  // $IsExpressionIsOperator,

  // ///对应[IsExpression.notOperator]
  // $IsExpressionNotOperator,

  // ///对应[IsExpression.expression]
  // $IsExpressionExpression,

  // ///对应[IsExpression.type]
  // $IsExpressionType,

  // /** ******** ConditionalExpression ******** **/

  // ///对应[ConditionalExpression]
  // $ConditionalExpression,

  // ///对应[ConditionalExpression.condition]
  // $ConditionalExpressionCondition,

  // ///对应[ConditionalExpression.thenExpression]
  // $ConditionalExpressionThenExpression,

  // ///对应[ConditionalExpression.elseExpression]
  // $ConditionalExpressionElseExpression,

  // /** ******** ParenthesizedExpression ******** **/

  // ///对应[ParenthesizedExpression]
  // $ParenthesizedExpression,

  // ///对应[ParenthesizedExpression.expression]
  // $ParenthesizedExpressionExpression,

  // /** ******** IndexExpression ******** **/

  // ///对应[IndexExpression]
  // $IndexExpression,

  // ///对应[IndexExpression.target]
  // $IndexExpressionTarget,

  // ///对应[IndexExpression.realTarget]
  // $IndexExpressionRealTarget,

  // ///对应[IndexExpression.index]
  // $IndexExpressionIndex,

  // /** ******** InterpolationExpression ******** **/

  // ///对应[InterpolationExpression]
  // $InterpolationExpression,

  // ///对应[InterpolationExpression.expression]
  // $InterpolationExpressionExpression,

  // /** ******** FunctionExpression ******** **/

  // ///对应[FunctionExpression]
  // $FunctionExpression,

  // ///对应[FunctionExpression.parameters]
  // $FunctionExpressionParameters,

  // ///对应[FunctionExpression.body]
  // $FunctionExpressionBody,

  // /** ******** NamedExpression ******** **/

  // ///对应[NamedExpression]
  // $NamedExpression,

  // ///对应[NamedExpression.name]
  // $NamedExpressionName,

  // ///对应[NamedExpression.expression]
  // $NamedExpressionExpression,

  // /** ******** AwaitExpression ******** **/

  // ///对应[AwaitExpression]
  // $AwaitExpression,

  // ///对应[AwaitExpression.expression]
  // $AwaitExpressionExpression,

  // /** ******** SuperExpression ******** **/

  // ///对应[SuperExpression]
  // $SuperExpression,

  // ///对应[SuperExpression.superKeyword]
  // $SuperExpressionSuperSuperKeyword,

  // /** ******** MethodInvocation ******** **/

  // ///对应[MethodInvocation]
  // $MethodInvocation,

  // ///对应[MethodInvocation.target]
  // $MethodInvocationTarget,

  // ///对应[MethodInvocation.realTarget]
  // $MethodInvocationRealTarget,

  // ///对应[MethodInvocation.methodName]
  // $MethodInvocationMethodName,

  // ///对应[MethodInvocation.typeArguments]
  // $MethodInvocationTypeArguments,

  // ///对应[MethodInvocation.argumentList]
  // $MethodInvocationArgumentList,

  // /** ******** Label ******** **/

  // ///对应[Label]
  // $Label,

  // ///对应[Label.label]
  // $LabelLabel,

  // /** ******** ArgumentList ******** **/

  // ///对应[ArgumentList]
  // $ArgumentList,

  // ///对应[ArgumentList.arguments]
  // $ArgumentListArguments,

  // /** ******** FormalParameterList ******** **/

  // ///对应[FormalParameterList]
  // $FormalParameterList,

  // ///对应[FormalParameterList.parameters]
  // $FormalParameterListParameters,

  // /** ******** SimpleFormalParameter ******** **/

  // ///对应[SimpleFormalParameter]
  // $SimpleFormalParameter,

  // ///对应[SimpleFormalParameter.type]
  // $SimpleFormalParameterType,

  // ///对应[SimpleFormalParameter.name]
  // $SimpleFormalParameterName,

  // /** ******** DefaultFormalParameter ******** **/

  // ///对应[DefaultFormalParameter]
  // $DefaultFormalParameter,

  // ///对应[DefaultFormalParameter.name]
  // $DefaultFormalParameterName,

  // ///对应[DefaultFormalParameter.parameter]
  // $DefaultFormalParameterParameter,

  // ///对应[DefaultFormalParameter.defaultValue]
  // $DefaultFormalParameterDefaultValue,

  // /** ******** Block ******** **/

  // ///对应[Block]
  // $Block,

  // ///对应[Block.statements]
  // $BlockStatements,

  // /** ******** BlockFunctionBody ******** **/

  // ///对应[BlockFunctionBody]
  // $BlockFunctionBody,

  // ///对应[BlockFunctionBody.block]
  // $BlockFunctionBodyBlock,

  // /** ******** ExpressionFunctionBody ******** **/

  // ///对应[ExpressionFunctionBody]
  // $ExpressionFunctionBody,

  // ///对应[ExpressionFunctionBody.expression]
  // $ExpressionFunctionBodyExpression,

  // ///对应[ExpressionFunctionBody.star]
  // $ExpressionFunctionStar,

  // ///对应[ExpressionFunctionBody.isGenerator]
  // $ExpressionFunctionIsGenerator,

  // ///对应[ExpressionFunctionBody.isSynthetic]
  // $ExpressionFunctionIsSynthetic,

  // ///对应[ExpressionFunctionBody.isSynchronous]
  // $ExpressionFunctionIsSynchronous,

  // ///对应[ExpressionFunctionBody.isAsynchronous]
  // $ExpressionFunctionIsAsynchronous,

  // /** ******** VariableDeclarationStatement ******** **/

  // ///对应[VariableDeclarationStatement]
  // $VariableDeclarationStatement,

  // ///对应[VariableDeclarationStatement.variables]
  // $VariableDeclarationStatementVariables,

  // /** ******** ExpressionStatement ******** **/

  // ///对应[ExpressionStatement]
  // $ExpressionStatement,

  // ///对应[IfStatement.expression]
  // $ExpressionStatementExpression,

  // /** ******** IfStatement ******** **/

  // ///对应[IfStatement]
  // $IfStatement,

  // ///对应[IfStatement.condition]
  // $IfStatementCondition,

  // ///对应[IfStatement.thenStatement]
  // $IfStatementThenStatement,

  // ///对应[IfStatement.elseStatement]
  // $IfStatementElseStatement,

  // /** ******** SwitchStatement ******** **/

  // ///对应[SwitchStatement]
  // $SwitchStatement,

  // ///对应[SwitchStatement.expression]
  // $SwitchStatementExpression,

  // ///对应[SwitchStatement.members]
  // $SwitchStatementMembers,

  // /** ******** SwitchCase ******** **/

  // ///对应[SwitchCase]
  // $SwitchCase,

  // ///对应[SwitchCase.expression]
  // $SwitchCaseExpression,

  // ///对应[SwitchCase.statements]
  // $SwitchCaseStatements,

  // /** ******** SwitchDefault ******** **/

  // ///对应[SwitchDefault]
  // $SwitchDefault,

  // ///对应[SwitchDefault.statements]
  // $SwitchDefaultStatements,

  // /** ******** ForStatement ******** **/

  // ///对应[ForStatement]
  // $ForStatement,

  // ///对应[ForStatement.forLoopParts]
  // $ForStatementForLoopParts,

  // ///对应[ForStatement.body]
  // $ForStatementBody,

  // /** ******** ForPartsWithDeclarations ******** **/

  // ///对应[ForPartsWithDeclarations]
  // $ForPartsWithDeclarations,

  // ///对应[ForPartsWithDeclarations.variables]
  // $ForPartsWithDeclarationsVariables,

  // ///对应[ForPartsWithDeclarations.condition]
  // $ForPartsWithDeclarationsCondition,

  // ///对应[ForPartsWithDeclarations.updaters]
  // $ForPartsWithDeclarationsUpdaters,

  // /** ******** ForEachPartsWithDeclaration ******** **/

  // ///对应[ForEachPartsWithDeclaration]
  // $ForEachPartsWithDeclaration,

  // ///对应[ForEachPartsWithDeclaration.loopVariable]
  // $ForEachPartsWithDeclarationLoopVariable,

  // ///对应[ForEachPartsWithDeclaration.iterable]
  // $ForEachPartsWithDeclarationIterable,

  // /** ******** WhileStatement ******** **/

  // ///对应[WhileStatement]
  // $WhileStatement,

  // ///对应[WhileStatement.condition]
  // $WhileStatementCondition,

  // ///对应[WhileStatement.body]
  // $WhileStatementBody,

  // /** ******** DoStatement ******** **/

  // ///对应[DoStatement]
  // $DoStatement,

  // ///对应[WhileStatement.body]
  // $DoStatementBody,

  // ///对应[DoStatement.condition]
  // $DoStatementCondition,

  // /** ******** BreakStatement ******** **/

  // ///对应[BreakStatement]
  // $BreakStatement,

  // ///对应[BreakStatement.breakKeyword]
  // $BreakStatementBreakKeyword,

  // /** ******** ReturnStatement ******** **/

  // ///对应[ReturnStatement]
  // $ReturnStatement,

  // ///对应[ReturnStatement.expression]
  // $ReturnStatementExpression,

  // /** ******** StringInterpolation ******** **/

  // ///对应[StringInterpolation]
  // $StringInterpolation,

  // ///对应[StringInterpolation.elements]
  // $StringInterpolationElements,

  // /** ******** InterpolationString ******** **/

  // ///对应[InterpolationString]
  // $InterpolationString,

  // ///对应[InterpolationString.contents]
  // $InterpolationStringContents,

  // /** ******** IntegerLiteral ******** **/

  // ///对应[IntegerLiteral]
  // $IntegerLiteral,

  // /** ******** DoubleLiteral ******** **/

  // ///对应[DoubleLiteral]
  // $DoubleLiteral,

  // /** ******** BooleanLiteral ******** **/

  // ///对应[BooleanLiteral]
  // $BooleanLiteral,

  // /** ******** StringLiteral ******** **/

  // ///对应[StringLiteral]
  // $StringLiteral,

  // /** ******** ListLiteral ******** **/

  // ///对应[ListLiteral]
  // $ListLiteral,

  // ///对应[ListLiteral.elements]
  // $ListLiteralElements,

  // ///对应[ListLiteral.typeArguments]
  // $ListLiteralTypeArguments,

  // /** ******** SetOrMapLiteral ******** **/

  // ///对应[SetOrMapLiteral]
  // $SetOrMapLiteral,

  // ///对应[SetOrMapLiteral.elements]
  // $SetOrMapLiteralElements,

  // ///对应[ListLiteral.typeArguments]
  // $SetOrMapLiteralElementsTypeArguments,

  // /** ******** MapLiteralEntry ******** **/

  // ///对应[MapLiteralEntry]
  // $MapLiteralEntry,

  // ///对应[MapLiteralEntry.key]
  // $MapLiteralEntryKey,

  // ///对应[MapLiteralEntry.value]
  // $MapLiteralEntryValue,

  // /** ******** NullLiteral ******** **/

  // ///对应[NullLiteral]
  // $NullLiteral,
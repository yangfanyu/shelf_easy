## 2.3.0

- Add the vm _libhtml.dart file to the virtual machine to reduce the volume of the web side.
- Rename the vm_object.dart file to vm_base.dart.
  
## 2.2.4

- Implemented FunctionExpressionInvocation related functions for virtual machines.
- Fix the bug of generic definition of iterable class in virtual machine.
  
## 2.2.3

- Added virtual machine compatibility to the output of the serialized model code generator.

## 2.2.2

- Downgrade `http` library constraints. Add support for '?' to the 'is' and 'as' operators in the virtual machine.
- Bug fixes for virtual machine functions: VmClass.isThisType and VmRunnerCore._scanMethodInvocation.
  
## 2.2.0

- Update dependency library constraints. Add the minLevel option to the toString generation rule of the data model generator.
  
## 2.1.0

- Optimize the filtering rules of the virtual machine's bridge type generator.
  
## 2.0.4

- Optimize the generation rules of the bridging class library of the virtual machine.
- Add an implicit break for the non-empty case of the virtual machine.
  
## 2.0.3

- Fix the bug of _scanInstanceCreationExpression for virtual machines.
  
## 2.0.2

- Remove the VmType class and related content in the virtual machine.
  
## 2.0.0

The content of this submission modification is as follows:
- Add visitSwitchPatternCase support for the virtual machine and convert it to visitSwitchCase.
- Replace deprecated fields in VM parser: name.name to name2.lexeme, IfStatement.condition to IfStatement.expression.
- Upgrade the bridge type generator of the virtual machine, and update the bridge library to `dart_sdk: ^3.0.0`.
- Upgrade sdk to `dart_sdk: ^3.0.0`, update pubspec.yaml to the latest version.
  
The current version of the built-in bridging library for the virtual machine is `dart_sdk: ^3.0.0` and 99% supports the following packages:
- `dart:async`
- `dart:collection`
- `dart:convert`
- `dart:core`
- `dart:math`
- `dart:typed_data`
- `dart:io`
- `dart:isolate`
  
## 1.3.8

- Fix the bug of DbJsonWraper's toJson function.
  
## 1.3.7

- Add global logger configuration options for virtual machines.
  
## 1.3.6

- Optimize the filter parameters of the virtual machine's bridge type generator.
  
## 1.3.3

- Optimize the initialization process of the iterator type of the virtual machine to support the null type.
  
## 1.3.2

- Optimize the handling of private default values ​​in the virtual machine's bridge library generator.
  
## 1.3.1

The content of this submission modification is as follows:
- Parameters with private reference defaults are reserved for virtual machine bridge type generators.
- Optimize the operation expression of the virtual machine.
  
The current version of the built-in bridging library for the virtual machine is `dart_sdk: ^2.19.0` and fully supports the following packages:
- `dart:async`
- `dart:collection`
- `dart:convert`
- `dart:core`
- `dart:math`
- `dart:typed_data`
- `dart:io`
- `dart:isolate`
  
## 1.2.9

- Optimize the identification of internally defined type instances for virtual machines.
  
## 1.2.8

- Add parameters to the EasyVmWare.eval function of the virtual machine.
- Optimize the is expression and as expression of the virtual machine.
- Modify the example file that generates the virtual machine bridge type: test_vmgen.dart.
- Add EasyVmWare.debugVmObjectInfo function for virtual machine.
- Add a default new constructor for the internal definition class of the virtual machine.
  
## 1.2.7

- Fix the bug that multiple cases with the same logic in the switch expression of the virtual machine do not take effect.
  
## 1.2.5

- Add the @nonVirtual annotation to some public methods of the virtual machine's mixin VmSuper.
- Fix a bug in the assignment expression '=' of the virtual machine.
  
## 1.2.3

- Added for virtual machine's bridge type generator: default constructor detection for non-abstract classes.
  
## 1.2.2

- Add null support for index expressions to virtual machines.
- Add string translation extension VmTranslate.
  
## 1.2.0

- Fix the bug that the virtual machine class static scope conflicts with the class name.
  
## 1.1.22

- Fix the bug of anonymous function scope binding of virtual machine.
  
## 1.1.21

- Adjust the debugging information printing method of the virtual machine object stack.
- Fix the bug of reading the defined type attribute inside the virtual machine.
  
## 1.1.20

- Adjust the parameter definition position for calling the main function in the EasyVmWare instance.
- Enhanced type deduction when scanning iterableLiteral for virtual machines.
- Add support for the ! operator to PostfixExpression for virtual machines.
  
## 1.1.18

- Added int to double implicit conversion to virtual machine's bridge type generator.
- Add support for ?. expressions to virtual machines.
- Modify the constraints of dependent packages.
  
## 1.1.16

- Fix the bug that the _scanInstanceCreationExpression function cannot recognize the prefix constructor for the virtual machine.
- Add implicit double conversion to virtual machine's bridge type generato.
- Modify the structure of the export file.
  
## 1.1.13

- Added anonymous function scope support for virtual machines.
- Extended the type retrieval of Super parameters and Field parameters for the bridge type generator of the virtual machine.
- Fix some bugs of the virtual machine.
  
## 1.1.12

- Optimize the bridge type generator of the virtual machine, so that the generated proxy function is more accurate.
- Limit virtual machine to only one instance at a time.
- Optimize the exception capture mechanism of the virtual machine.
- Add Enum and extension parsing for the bridge class generator of the virtual machine.
  
## 1.1.11

- Implemented InstanceCreationExpression related functions for virtual machines.
- Add the reassembly function of internally defined classes to the virtual machine.
- Add a conversion interface for reading native values to virtual machines.

## 1.1.9

- Refactor documentation
- Optimize type speculation speed for virtual machines.
- Modify the VmSuper class so that it can be used by Flutter widgets.
  
## 1.1.5

- Optimize parts related to EasyClient and upgrade mongo_dart.
  
## 1.1.2 

- Implemented a dart-lang runtime virtual machine and improve documents.
  
## 1.0.66

- Modify code generator.
  
## 1.0.63

- Optimize the format of logger. Modify .gitignore.
  
## 1.0.61

- Add generateBaseExports method for code generator.
  
## 1.0.60

- Add custom http route for server and custom http request for client. Optimize the export structure of code.
  
## 1.0.50

- Upgrade dependencies.
  
## 1.0.30

- Extension code generation method.
  
## 1.0.25

- Adjust part of the code.
  
## 1.0.20

- Optimize encryption and decryption methods.
  
## 1.0.19

- Add runZonedGuarded mode for worker.
  
## 1.0.17

- Modify result's success judge rule for mongo's insert, delete, update functions.
  
## 1.0.11

- Implement core functions.

## 0.0.0

- Initial version.

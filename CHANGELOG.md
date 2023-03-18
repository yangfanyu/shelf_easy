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
- The built-in dart bridge library in the virtual machine is adapted to dart-sdk-2.19.4
  
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

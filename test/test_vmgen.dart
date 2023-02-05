import 'dart:mirrors';

// class User {
//   static const sexMale = 1;
//   static const sexFemale = 2;

//   static int getDetaultSex() => sexMale;

//   String aaa;
//   String _test;

//   User(this.aaa, this._test);

//   factory User._hi() {
//     return User('hi', 'man');
//   }

//   factory User.helloWorld() {
//     return User('hello', 'world');
//   }

//   set test(String paramVal) => _test = paramVal;

//   String get aAA => aaa;

//   void myMethod() {}

//   void printTest() {
//     print("test string is: $aaa $_test");
//   }
// }

void main() {
  // final user1 = User('a', 'b');
  // user1.printTest();
  // final user2 = Function.apply(User.new, ['xxx', 'zzzz']) as User;
  // user2.printTest();
  // final user3 = Function.apply(User.helloWorld, []) as User;
  // user3.printTest();
  // final user4 = Function.apply(User._hi, []) as User;
  // user4.printTest();

  print(DateTime.now().toIso8601String());
  print('\n');
  //int
  final int intVar = 1;
  generateInstance(reflect(intVar).type, generateClass(reflectClass(int)));
  //double
  final double doubleVar = 1.0;
  generateInstance(reflect(doubleVar).type, generateClass(reflectClass(double)));
  //num
  final num numVar = 1.0;
  generateInstance(reflect(numVar).type, generateClass(reflectClass(num)));
  //bool
  final bool boolVar = false;
  generateInstance(reflect(boolVar).type, generateClass(reflectClass(bool)));
  //String
  final String strVar = 'hello';
  generateInstance(reflect(strVar).type, generateClass(reflectClass(String)));
  //List
  final List list = [1, 2, 3];
  generateInstance(reflect(list).type, generateClass(reflectClass(List)));
  //Set
  final Set set = <dynamic>{};
  generateInstance(reflect(set).type, generateClass(reflectClass(Set)));
  //Map
  final Map map = <dynamic, dynamic>{};
  generateInstance(reflect(map).type, generateClass(reflectClass(Map)));
  print('\n');
  //Runes
  final Runes runes = Runes('aaa');
  generateInstance(reflect(runes).type, generateClass(reflectClass(Runes)));
  //Symbol
  final Symbol symbol = Symbol('aaa');
  generateInstance(reflect(symbol).type, generateClass(reflectClass(Symbol)));
  print('\n');
}

String generateClass(ClassMirror target) {
  final className = geSymbolName(target.simpleName);
  print('static void _importClass${className[0].toUpperCase()}${className.substring(1)}() {');
  print('importClass<$className>(');
  print('\'$className\',');
  generateClassConstructors(target, className);
  generateClassProperties(target, className);
  generateClassFunctions(target, className);
  return className;
}

void generateInstance(ClassMirror target, String className) {
  generateInstanceProperties(target, className);
  generateInstanceFunctions(target, className);
  print(');');
  print('}');
}

void generateClassConstructors(ClassMirror target, String className) {
  final members = target.declarations;
  final membersKeys = members.keys.toList();
  membersKeys.sort((a, b) => a.toString().compareTo(b.toString()));
  print('classConstructors: {');
  for (var key in membersKeys) {
    final value = members[key];
    if (value is MethodMirror && !value.isPrivate && value.isConstructor) {
      // final keyName = geSymbolName(key);
      final funcName = geSymbolName(value.constructorName);
      print(' \'${funcName.isEmpty ? className : funcName}\': (positionalArguments, [namedArguments]) => Function.apply($className.${funcName.isEmpty ? 'new' : funcName}, positionalArguments, namedArguments),');
    }
  }
  print('},');
}

void generateClassProperties(ClassMirror target, String className) {
  final members = target.staticMembers;
  final membersKeys = members.keys.toList();
  membersKeys.sort((a, b) => a.toString().compareTo(b.toString()));
  print('classProperties: {');
  for (var key in membersKeys) {
    final value = members[key]!;
    if (!value.isPrivate && !value.isRegularMethod && !value.isSetter) {
      final keyName = geSymbolName(key);
      print('    \'$keyName\': () => $className.$keyName,');
    }
  }
  print('},');
}

void generateClassFunctions(ClassMirror target, String className) {
  final members = target.staticMembers;
  final membersKeys = members.keys.toList();
  membersKeys.sort((a, b) => a.toString().compareTo(b.toString()));
  print('classFunctions: {');
  for (var key in membersKeys) {
    final value = members[key]!;
    if (!value.isPrivate && !value.isSetter && !value.isGetter && !value.isOperator) {
      final keyName = geSymbolName(key);
      print('    \'$keyName\': (positionalArguments, [namedArguments]) => Function.apply($className.$keyName, positionalArguments, namedArguments),');
    }
  }
  print('},');
}

void generateInstanceProperties(ClassMirror target, String className) {
  final members = target.instanceMembers;
  final membersKeys = members.keys.toList();
  membersKeys.sort((a, b) => a.toString().compareTo(b.toString()));
  print('instanceProperties: {');
  for (var key in membersKeys) {
    final value = members[key]!;
    if (!value.isPrivate && !value.isRegularMethod && !value.isSetter) {
      final keyName = geSymbolName(key);
      print('    \'$keyName\': (instance) => instance.$keyName,');
    }
  }
  print('},');
}

void generateInstanceFunctions(ClassMirror target, String className) {
  final members = target.instanceMembers;
  final membersKeys = members.keys.toList();
  membersKeys.sort((a, b) => a.toString().compareTo(b.toString()));
  print('instanceFunctions: {');
  for (var key in membersKeys) {
    final value = members[key]!;
    if (!value.isPrivate && !value.isSetter && !value.isGetter && !value.isOperator) {
      final keyName = geSymbolName(key);
      if (keyName == '>>>') continue;
      print('    \'$keyName\': (instance, positionalArguments, [namedArguments]) => Function.apply(instance.$keyName, positionalArguments, namedArguments),');
    }
  }
  print('},');
}

String geSymbolName(Symbol val) {
  final str = val.toString();
  return str.substring(8, str.length - 2);
}

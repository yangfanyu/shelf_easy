// ignore_for_file: unnecessary_type_check, prefer_typing_uninitialized_variables

import 'dart:async';

void main() {
  final value = D();

  print(value is A); //true
  print(value is B); //true
  print(value is C); //true
  print(value is D); //true
  print(value.runtimeType); //D

  final value1 = D()..fields['name'] = 'Tom';
  final value2 = D()..fields['name'] = 'Jack';

  print(value1.name); //Tom
  print(value2.name); //Jack
  print(value1.buildB()); //I am buildB [Tom]
  print(value2.buildC()); //I am buildC [Jack]

  var a;
  print('========> ${a is FutureOr}'); //true

  var b = [];
  print('========> ${b.every((element) => element > 3)}'); //true

  var test = Test<int>();
  var from = <dynamic>[1, 2, 3];
  var toL = test.toTypeList(from);
  var toS = test.toTypeSet(from);
  print('test ========> ${test.type}');
  print('from ========> ${from.runtimeType} $from');
  print('toL ========> ${toL.runtimeType} $toL');
  print('toS ========> ${toS.runtimeType} $toS');

  var test2 = Test<String>();
  var from2 = <dynamic, dynamic>{1: 'a', 2: 'b', 3: 'c'};
  var toM = test.toTypeMap(from2, test2);
  print('test2 ========> ${test2.type}');
  print('from2 ========> ${from2.runtimeType} $from2');
  print('toM ========> ${toM.runtimeType} $toM');

  Test test3 = test;
  Test test4 = test2;
  var toL2 = test3.toTypeList(from);
  var toS2 = test3.toTypeSet(from);
  var toM2 = test3.toTypeMap(from2, test4);
  print('toL2 ========> ${toL2.runtimeType} $toL2');
  print('toS2 ========> ${toS2.runtimeType} $toS2');
  print('toM2 ========> ${toM2.runtimeType} $toM2');

  Future.microtask(func1);

  // Function.apply(Future.microtask, [func1]);//Fuck: type '() => int' is not a subtype of type '() => FutureOr<Y0>' of 'computation'
}

mixin A {
  final fields = <String, dynamic>{};

  String? get name => fields['name'];
}

abstract class B {
  dynamic buildB();
}

abstract class C {
  dynamic buildC();
}

class D extends B with A implements C {
  @override
  buildB() {
    return 'I am buildB ${fields.values.toList()}';
  }

  @override
  buildC() {
    return 'I am buildC ${fields.values.toList()}';
  }
}

class Test<T> {
  List<T> toTypeList(List<dynamic> from) {
    return from.map((e) => e as T).toList();
  }

  Set<T> toTypeSet(List<dynamic> from) {
    return from.map((e) => e as T).toSet();
  }

  Map<T, dynamic> toTypeMap(Map from, Test valTest) {
    // return from.map((key, value) => MapEntry(key as T, value as M));
    final keysRes = toTypeList(from.keys.toList());
    final valsRes = valTest.toTypeList(from.values.toList());
    print('keysRes: ${keysRes.runtimeType},   valsRes: ${valsRes.runtimeType}');
    return Map.fromIterables(keysRes, valsRes);
  }

  Type get type => T;
}

int func1() {
  print('func1 --------> hello');
  return 1;
}

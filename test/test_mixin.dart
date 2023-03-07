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

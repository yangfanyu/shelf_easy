// ignore_for_file: unnecessary_type_check

void main() {
  final value = D();

  print(value is A);
  print(value is B);
  print(value is C);
  print(value is D);
  print(value.runtimeType);

  final value1 = D()..fields['name'] = 'Tom';
  final value2 = D()..fields['name'] = 'Jack';

  print(value1.name);
  print(value2.name);
  print(value1.buildB());
  print(value2.buildC());
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

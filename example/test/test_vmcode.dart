// ignore_for_file: prefer_if_null_operators, unnecessary_type_check, unnecessary_cast, prefer_typing_uninitialized_variables, unnecessary_null_in_if_null_operators, avoid_init_to_null, unnecessary_null_comparison, prefer_collection_literals, use_function_type_syntax_for_parameters

import 'dart:math';

///
/// 变量定义测试区
///

int? a;
double? b;
num? c;
bool? d;
String? e;
List? f;
Map? g;
Set? h;
dynamic k;
var l;

int? a1 = 1, a2 = null;
double? b1 = 2, b2 = 2.0;
num? c1 = 3, c2 = 3.0;
bool? d1 = true, d2 = false;
String? e1 = 'hello', e2 = 'a';
List? f1 = [1, 2, 3],
    f2 = [
      [1, 1, 1],
      [2, 2, 2],
      [3, 3, 3]
    ],
    f3 = [];
Map? g1 = {1: 'a', 2: 'b', 3: 'c'}, g2 = {};
Set? h1 = {1, 2, 3}, h2 = {};
dynamic k1 = 1;
var l1 = 2;
final m1 = 3;
const n1 = 4;
final int o1 = 5;
const int p1 = 6;
late var q1;
late final r1;

List<String>? aaa1, aaa2 = ['a', 'b', 'c'];
Map<int, String>? bbb1, bbb2 = {1: 'a', 2: 'b', 3: 'c'};
Set<int>? ccc1, ccc2 = {1, 2, 3};
final ddd1 = <String>[], ddd2 = ['a', 'b', 'c'], ddd3 = <String>['a'], ddd4 = <String?>['a', null, 'b', null];
final eee1 = <String, int>{}, eee2 = {1: 'a', 2: 'b', 3: 'c'}, eee3 = <int, String>{1: 'a'}, eee4 = <int?, String?>{1: 'a'};
final fff1 = <int>{}, fff2 = {1, 2, 3}, fff3 = <int>{1}, fff4 = <int?>{1, null, 2};
final ggg1 = <int, Map<double, Map<bool, String>>>{}, ggg2 = <List<List<Set<List<int>>>>>[], ggg3 = <Set<List<Set<int>>>>{};
final hhh1 = {
      1: [
        {'a', 'b', 'c'}
      ]
    },
    hhh2 = [
      {
        {1: 'a', 2: 'b'}
      }
    ],
    hhh3 = {
      {
        1: ['a', 'b']
      }
    };
List<List<List<int>>>? iii1 = [
  [
    [1]
  ],
  [
    [2]
  ],
  [
    [3]
  ]
];
final jjj1 = {};
final kkk1 = <dynamic>{};
final Map lll1 = {};
final Set mmm1 = {};
var nnn1 = const {1: 'a'}, nnn2 = const {2};

///
/// 运算表达式测试区
///

final aaaaa1 = 11 + 22; //33
final bbbbb1 = 22 - 11; //11
final ccccc1 = 2 * 3; //6
final ddddd1 = 8 / 2; //4.0
final eeeee1 = 10 % 3; //1
final fffff1 = 10 ~/ 3; //3
final ggggg1 = 100 > 88, ggggg2 = 66 > 99; //true, false
final hhhhh1 = 100 < 88, hhhhh2 = 66 < 99; //false, true
final iiiii1 = 100 >= 88, iiiii2 = 66 >= 99, iiiii3 = 88 >= 88; //true, false, true
final jjjjj1 = 100 <= 88, jjjjj2 = 66 <= 99, jjjjj3 = 88 <= 88; //false, true, true
final kkkkk1 = 100 == 88, kkkkk2 = 66 == 66, kkkkk3 = 88 == null; //false, true, false
final lllll1 = 100 != 88, lllll2 = 66 != 66, lllll3 = 88 != null; //true, false, true
final mmmmm1 = true && false, mmmmm2 = true && true; //false, true
final nnnnn1 = false || false, nnnnn2 = false || true; //false, true
final ooooo1 = null ?? 88; //88
final ppppp1 = 0x0100 >> 1, ppppp2 = 0x0100 >> 2; //128, 64
final qqqqq1 = 0x0001 << 1, qqqqq2 = 0x0001 << 2; //2, 4
final rrrrr1 = 0x0001 & 0x0003; //0b00000001 & 0b00000011 => 1
final sssss1 = 0x0001 | 0x0003; //0b00000001 | 0b00000011 => 3
final ttttt1 = 0x0001 ^ 0x0003; //0b00000001 ^ 0b00000011 => 2
final uuuuu1 = 0x22 >>> 4; //0x000000100010 >>> 4 => 2
final vvvvv1 = aaaaa1 + bbbbb1 + 55; //99

final aaaaaaa1 = -22, aaaaaaa2 = -aaaaaaa1; //-22, 22
final bbbbbbb1 = false, bbbbbbb2 = !bbbbbbb1; //false, true
final ccccccc1 = ~0x0001, ccccccc2 = ~ccccccc1; //-2, 1
int ddddddd1 = 8, ddddddd2 = ++ddddddd1, ddddddd3 = ddddddd1; //9, 9, 9
int eeeeeee1 = 8, eeeeeee2 = --eeeeeee1, eeeeeee3 = eeeeeee1; //7, 7, 7
int fffffff1 = 5, fffffff2 = fffffff1++, fffffff3 = fffffff1; //6, 5, 6
int ggggggg1 = 5, ggggggg2 = ggggggg1--, ggggggg3 = ggggggg1; //4, 5, 4

num? assignN;
num assignT = 0;
int assignZ = 33;
final assign1 = assignT += 10; //10
final assign2 = assignT -= 1; //9
final assign3 = assignT *= 2; //18
final assign4 = assignT /= 3; //6.0
final assign5 = assignT %= 5; //1.0
final assign6 = assignT ~/= 0.3; //3
final assign7 = assignN ??= assignT; //3
final assign8 = assignZ >>= 1; //16
final assign9 = assignZ <<= 1; //32
final assignA = assignZ &= 32; //32
final assignB = assignZ |= 3; //35
final assignC = assignZ ^= 7; //36
final assignD = assignZ >>>= 1; //18
Object assignE = 1;
Object assignF = assignE = 'Hello world';

final conditionalN = null; //null
const conditionalY = 2; //2
final conditionalB = false; //false
final conditional1 = conditionalN == null ? 10 : conditionalY + 2; //10
final conditional2 = conditionalB ? conditionalN : conditional1; //10

final parenthesized1 = 1 + 2 * (5 - 1); //9
final parenthesized2 = (1 + 6) * parenthesized1 + 2 * (5 - 1); //71

const indexeVal1 = [1, 2, 3];
final indexeVal2 = indexeVal1[0] + indexeVal1[1] + [4, 5, 6][2]; //9

const interpolation1 = 'Hello';
const interpolation2 = 'world';
const interpolationA = 18;
const interpolation3 = '$interpolation1 $interpolation2, I am $interpolationA years old. ${interpolation2.length + 1} hei.'; // Hello world, I am 18 years old. 6 hei.

///
/// 属性与方法调用测试区
///

final methodInvocationSymbol = Symbol('aaa');
final methodInvocationList = List.from([4, 5, 6]); // after is => [92, 6]
final methodInvocationSet1 = Set.from({7, 8, 9, 10}); // after is => {7, 9, 10}
final methodInvocationMap1 = Map.of({1: 'a', 2: 'b', 3: 'c'}); // after is => {2: b, 3: c}
final methodInvocationRes1 = methodInvocationList.removeAt(1); //5
final methodInvocationRes2 = methodInvocationSet1.remove(8); //true
final methodInvocationRes3 = methodInvocationList.length; //2
final methodInvocationRes4 = methodInvocationSet1.length; //3
final methodInvocationRes5 = methodInvocationMap1.keys.first.bitLength.toDouble().toString().length; //3
final methodInvocationRes6 = List.from.runtimeType.toString().length; //52
final methodInvocationRes7 = methodInvocationList.first += List.from([4, 5, 6]).last = 88; //92
final methodInvocationRes8 = Duration(days: 0, hours: 1, minutes: 2, seconds: 3); //Duration 1:02:03.000000
final methodInvocationRes9 = DateTime(2023, 08, 01); //DateTime 2023-08-01 00:00:00.000
final methodInvocationResA = print;
final methodInvocationResB = print.runtimeType; // (Object?) => void
final methodInvocationResC = Set.new.toString().length; //56
final methodInvocationResD = Set; //Set
final methodInvocationResE = methodInvocationResC.toString(); //56
final methodInvocationResF = methodInvocationResD.runtimeType; //VmType
final methodInvocationResG = methodInvocationMap1.remove(1); //a
final methodInvocationResH = max(100, 99); //100
final methodInvocationResI = Random().nextDouble();
final methodInvocationResJ = pi; //3.141592653589793
final methodInvocationResK = methodInvocationResA('0000000000000000');

///
/// 函数定义与语句测试区
///

void funcA0() {}

int funcA1(int a, {int b = 2, required int c, int? d}) => d ?? (a + b + c);

dynamic funcA2(int a, int b, {required int c, int d = 0, int? e}) {
  final aaa = 888;
  final str = 'hello world a=$a, b=$b, c=$c, d=$d, e=$e, aaa=$aaa';
  print('\n');
  print('e?.bitLength => ${e?.bitLength} ${e?.bitLength.toString().length}');
  // print('e!.bitLength => ${e!.bitLength} ${e.bitLength.toString().length}');
  // if (e != null) print('e!.bitLength => ${e!.bitLength} ${e.bitLength.toString().length}');
  print(str);

  if (a == 0) print('if a == 0');

  if (a == 1) {
    print('if a == 1');
    return 1;
  } else if (a == 2) {
    print('if a == 2');
    return 2;
  } else if (a == 3) {
    print('if a == 3');
    return 3;
  } else {
    final str = 'else';
    print(str);
  }

  switch (a) {
    case 4:
      final str = 'haha';
      print('case a: 4 $str');
      break;
    case 5:
      print('case a: 5');
      break;
    case 6:
    case 7:
      print('case a: 6 or 7');
      break;
    default:
      final str = 'default';
      print(str);
      break;
  }

  int sum = 0;
  for (var i = 0; i < a; i++) {
    final str = 'for part';
    sum += i;
    print('$str sum is $sum');
  }

  final arr = ['a', 'b', 'c'];
  for (String s in arr) {
    final str = 'for each';
    print('$str arr item $s');
  }

  int kkk = 0;
  while (kkk < 3) {
    final str = 'while';
    print('$str kkk is $kkk < 3');
    kkk++;
  }

  int mmm = 0;
  do {
    final str = 'do while';
    print('$str mmm is $mmm < 2');
    mmm++;
  } while (mmm < 2);

  if (a >= 8) {
    funcA4(funcA3, (str) {
      final nnn = [1, 2, 3, 4];
      final ppp = nnn.reduce((value, element) => value + element);
      print('$str --- $ppp ${print.toString()}'); //funcA4: 21 --- 10 Closure: (Object?) => void from Function 'print': static.
    });

    for (int zzz1 = 0; zzz1 < 6; zzz1++) {
      print('zzz1 $zzz1');
      if (zzz1 >= 1) continue;
      for (int zzz2 = 0; zzz2 < 6; zzz2++) {
        print('zzz1 $zzz1 zzz2 $zzz2');
        if (zzz2 >= 2) continue;
        for (int zzz3 = 0; zzz3 < 6; zzz3++) {
          print('zzz1 $zzz1 zzz2 $zzz2 zzz3 $zzz3');
          if (zzz3 >= 3) break;
        }
      }
    }
  }

  return str;
}

int funcA3(int a, {required int b}) => a * b;

void funcA4(int Function(int a, {required int b}) cb, void pipline(String val)) {
  pipline('funcA4: ${cb(3, b: 7)}');
}

int funcA5() {
  Future(() {
    return 'I am Future.new';
  }).then((value) => print(value));

  Future.delayed(Duration.zero, () {
    return 'I am Future.delayed';
  }).then((value) => print(value));

  Future.microtask(() {
    return 'I am Future.microtask';
  }).then((value) => print(value));

  Future.sync(() {
    return 'I am Future.sync';
  }).then((value) => print(value));

  Future.doWhile(() {
    return false;
  }).then((_) => print('I am Future.doWhile'));

  print('-----> Future start');
  Future.delayed(Duration(seconds: 2), () {
    print('-----> Future end 0');
    return true;
  }).then((value) {
    print('-----> Future end 1 $value');
    return 'hi';
  }).then<int?>((value) {
    print('-----> Future end 2 $value');
    throw ('-----> I am Future then error 2');
  }).catchError((error, stack) {
    print('-----> Future catchError: 3 $error');
    return 10000;
  }).then((value) {
    print('-----> Future end 4 $value');
  }).whenComplete(() {
    final a = 66;
    print('-----> whenComplete $a is String: ${a is String}'); //false
    print('-----> whenComplete $a is int: ${a is int}'); //true
    print('-----> whenComplete $a is num: ${a is num}'); //true
    print('-----> whenComplete $a is! int: ${a is! int}'); //false
    print('-----> whenComplete $a is! bool: ${a is! bool}'); //true
  });

  Future.value('hello').then((value) => '$value world').then((a) {
    print('++++++> then $a is String: ${a is String}'); //true
    print('++++++> then $a is int: ${a is int}'); //false
    print('++++++> then $a is num: ${a is num}'); //false
    print('++++++> then $a is! int: ${a is! int}'); //true
    print('++++++> then $a is! bool: ${a is! bool}'); //true
    print((a as double).toString());
  }).catchError((error, stack) {
    print('++++++> Future catchError: $error');
  }).then((value) {
    final names = {1: 'a', 2: 'b', 3: 'c'};
    final namesStr = names.map((key, value) => MapEntry(key, '$key -> $value')).toString();
    print(namesStr);
  });

  return 1;
}

Set funcA6(Duration a, {void b(String c)?}) {
  if (b != null) b('funcA6 ------------> Set.castFrom outer');
  final res = Set.castFrom({a.inHours, a.inMinutes, a.inSeconds}, newSet: <int>() {
    if (b != null) b('funcA6 >>>>>>>>>>>>> Set.castFrom inter');
    return {};
  });
  if (b != null) b('funcA6 ------------> Set.castFrom $res');
  return res;
}

List funcA7(Duration a, [void b(String d)?, int c = 2]) {
  final res = [a.inHours, a.inMinutes, a.inSeconds];
  res.add(c);
  if (b != null) b('funcA7 ------------> $res');
  return res;
}

final funcResA1_1 = funcA1(1, c: 3); //6
final funcResA2_0 = funcA2(0, 100, c: 200); //hello world a=0, b=100, c=200, d=0, e=null, aaa=888
final funcResA2_1 = funcA2(1, 100, c: 200, e: 666); //1
final funcResA2_2 = funcA2(2, 100, c: 200); //2
final funcResA2_3 = funcA2(3, 100, c: 200); //3
final funcResA2_4 = funcA2(4, 100, c: 200); //hello world a=4, b=100, c=200, d=0, e=null, aaa=888
final funcResA2_5 = funcA2(5, 100, c: 200); //hello world a=5, b=100, c=200, d=0, e=null, aaa=888
final funcResA2_6 = funcA2(6, 100, c: 200); //hello world a=6, b=100, c=200, d=0, e=null, aaa=888
final funcResA2_7 = funcA2(7, 100, c: 200); //hello world a=7, b=100, c=200, d=0, e=null, aaa=888
final funcResA2_8 = funcA2(8, 100, c: 200); //hello world a=8, b=100, c=200, d=0, e=null, aaa=888
final funcResA5_0 = funcA5(); //1
final funcResA6_0 = funcA6(Duration(hours: 1, minutes: 1, seconds: 1), b: print); //{1, 61, 3661}
final funcResA7_0 = funcA7(Duration(hours: 1, minutes: 1, seconds: 1), print); //[1, 61, 3661, 2]
final funcResA7_1 = funcA7(Duration(hours: 1, minutes: 1, seconds: 1), print, 999); //[1, 61, 3661, 999]

///
/// 类定义与实例测试区
///

class TestEmpty {}

final emptyInstance = TestEmpty();

class TestUser {
  static const sexMale = 1;
  static const sexFemale = 2;

  final int id;
  final String name;
  final int sex;
  final int age;
  String _desc, xxx = 'xxxxxxxx';
  String _info;
  List<int> _haha;

  TestUser(
    this.id,
    int no, {
    required this.name,
    this.sex = sexMale,
    int? age,
    aaa,
  })  : age = age ?? 18,
        _desc = '$no desc',
        _info = '$no info',
        _haha = [0, 1, 2, 3];

  TestUser.a(
    this.id,
    int no, {
    required this.name,
    this.sex = sexMale,
    int? age,
    aaa,
  })  : age = age ?? 18,
        _desc = '$no desc',
        _info = '$no info',
        _haha = [0, 1, 2, 3];

  factory TestUser.fromTest() {
    return TestUser(11111, 22222, name: 'Test', sex: sexFemale, age: 10);
  }

  void readSex() => sex;

  void writeDesc(String value) => _desc = '666 $value';

  String printInfo() {
    _haha
      ..[0] += 10
      ..[1] *= 100
      ..[2] -= 100;
    _haha[3] = 999;
    final str = 'id=$id, name=$name, sex=$sex, age=$age, desc=$desc, info=$info, _haha=$_haha';
    print('$sexMale $str $xxx');
    return str;
  }

  String get desc => _desc;

  String get info => _info;

  set desc(String value) => writeDesc(value);

  static int get getFemaleSexValue => sexFemale;
}

final userInstance0 = TestUser(1, 2, name: 'Jack', sex: 3, age: 4);
final userInstance1 = TestUser(10, 20, name: 'Tom', sex: TestUser.getFemaleSexValue);
final userInstance2 = userInstance0;
final userInstance3 = userInstance2.printInfo(); //id=1, name=Jack, sex=3, age=4, desc=2 desc, info=2 info, _haha=[10, 100, -98, 999]
final userInstance4 = TestUser(30, 40, name: 'Rose').printInfo(); //id=30, name=Rose, sex=1, age=18, desc=40 desc, info=40 info, _haha=[10, 100, -98, 999]
final userInstance5 = TestUser.fromTest().printInfo(); //id=11111, name=Test, sex=2, age=10, desc=22222 desc, info=22222 info, _haha=[10, 100, -98, 999]
final userInstance6 = TestUser(50, 60, name: 'Cascade', sex: 3, age: 80)
  ..desc = 'Hello world!'
  .._info = 'I am Dart'
  ..printInfo();
dynamic userInstance7;
var userInstance8 = userInstance7 ??= userInstance0;
dynamic userInstance9 = userInstance8;
final userInstance10 = (userInstance9 as TestUser).printInfo(); // String id=1, name=Jack, sex=3, age=4, desc=2 desc, info=2 info, _haha=[20, 10000, -198, 999]
final userInstance11 = [userInstance0, userInstance1];
final userInstance12 = {userInstance0, userInstance1};
final userInstance13 = {0: userInstance0, 1: userInstance1};
final userInstance14 = userInstance11.map((e) => e.printInfo()).toList();

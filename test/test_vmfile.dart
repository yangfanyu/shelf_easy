// ignore_for_file: prefer_if_null_operators, unnecessary_type_check, unnecessary_cast, prefer_typing_uninitialized_variables, unnecessary_null_in_if_null_operators, avoid_init_to_null, unnecessary_null_comparison, prefer_collection_literals

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
final ddd1 = <String>[], ddd2 = ['a', 'b', 'c'];
final eee1 = <String, int>{}, eee2 = {1: 'a', 2: 'b', 3: 'c'};
final fff1 = <int>{}, fff2 = {1, 2, 3};
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
const interpolation3 = '$interpolation1 $interpolation2, I am $interpolationA years old. ${interpolation2.length + 1} hei.';

///
/// 属性与方法调用测试区
///

final methodInvocationSymbol = Symbol('aaa');
final methodInvocationList = List.from([4, 5, 6]);
final methodInvocationSet1 = Set.from({7, 8, 9, 10});
final methodInvocationMap1 = Map.of({1: 'a', 2: 'b', 3: 'c'});
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
final methodInvocationResB = print.runtimeType;
final methodInvocationResC = Set.new.toString().length;
final methodInvocationResD = Set;
final methodInvocationResE = methodInvocationResC.toString();

///
/// 普通函数定义与语句测试区
///

int funcA1(int a, {int b = 2, required int c, int? d}) => d ?? (a + b + c);

dynamic funcA2(int a, int b, {required int c, int d = 0, int? e}) {
  final aaa = 888;
  final str = 'hello world a=$a, b=$b, c=$c, d=$d, e=$e, aaa=$aaa';
  print('\n');
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
      print('case a: 6');
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
      print('$str --- $ppp ${print.toString()}');
    });

    for (int zzz1 = 0; zzz1 < 6; zzz1++) {
      print('zzz1 $zzz1');
      if (zzz1 >= 1) break;
      for (int zzz2 = 0; zzz2 < 6; zzz2++) {
        print('zzz1 $zzz1 zzz2 $zzz2');
        if (zzz2 >= 2) break;
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

void funcA4(int Function(int a, {required int b}) cb, void Function(String val) pipline) {
  pipline('funcA4: ${cb(3, b: 7)}');
}

int funcA5() {
  print('-----> Future start');
  Future.delayed(Duration(seconds: 2)).then((value) {
    print('-----> Future end 1');
    // throw ('I am Future then error 1');
  }).then((value) {
    print('-----> Future end 2');
    throw ('-----> I am Future then error 2');
  }).catchError((error, stack) {
    print('-----> Future catchError $error');
  }).whenComplete(() {
    int a = 100;
    print('++++++> try a is String: ${a is String}'); //false
    print('++++++> try a is int: ${a is int}'); //true
    print('++++++> try a is num: ${a is num}'); //true
    print('++++++> try a is! int: ${a is! int}'); //false
    print('++++++> try a is! bool: ${a is! bool}'); //true
  });

  // Future.sync(() {
  //   int a = 100;
  //   print('++++++> try a is String: ${a is String}');
  //   print('++++++> try a is int: ${a is int}');
  //   print('++++++> try a is num: ${a is num}');
  //   print('++++++> try a is! int: ${a is! int}');
  //   print('++++++> try a is! bool: ${a is! bool}');
  //   print((a as String).length);
  // }).catchError((error, stack) {
  //   print('++++++> Future catchError $error');
  // });

  return 1;
}

final funcResA1_1 = funcA1(1, c: 3); //6
final funcResA2_0 = funcA2(0, 100, c: 200); //hello world a=0, b=100, c=200, d=0, e=null, aaa=888
final funcResA2_1 = funcA2(1, 100, c: 200); //1
final funcResA2_2 = funcA2(2, 100, c: 200); //2
final funcResA2_3 = funcA2(3, 100, c: 200); //3
final funcResA2_4 = funcA2(4, 100, c: 200); //hello world a=4, b=100, c=200, d=0, e=null, aaa=888
final funcResA2_5 = funcA2(5, 100, c: 200); //hello world a=5, b=100, c=200, d=0, e=null, aaa=888
final funcResA2_6 = funcA2(6, 100, c: 200); //hello world a=6, b=100, c=200, d=0, e=null, aaa=888
final funcResA2_7 = funcA2(7, 100, c: 200); //hello world a=7, b=100, c=200, d=0, e=null, aaa=888
final funcResA2_8 = funcA2(8, 100, c: 200); //hello world a=8, b=100, c=200, d=0, e=null, aaa=888
final funcResA5_0 = funcA5();

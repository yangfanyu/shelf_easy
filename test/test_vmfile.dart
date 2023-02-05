// ignore_for_file: prefer_if_null_operators, unnecessary_type_check, unnecessary_cast, prefer_typing_uninitialized_variables, unnecessary_null_in_if_null_operators, avoid_init_to_null, unnecessary_null_comparison, prefer_collection_literals

///
/// 普通变量定义测试区
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
/// 普通运算表达式测试区
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
final uuuuu1 = aaaaa1 + bbbbb1 + 55; //99

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
/// 试区
///
final methodInvocationSymbol = Symbol('aaa');
final methodInvocationList = List.from([4, 5, 6]);
final methodInvocationSet1 = Set.from({7, 8, 9, 10});
final methodInvocationRes1 = methodInvocationList.removeAt(1); //5
final methodInvocationRes2 = methodInvocationSet1.remove(8); //true
final methodInvocationRes3 = methodInvocationList.length; //2
final methodInvocationRes4 = methodInvocationSet1.length;//3


// int f0(int a, {int b = 1, required int c, int? d}) => d ?? (a + b + c);

// num f1(int a, [int b = 1, double? c, String? d]) {
//   final e = a + b;
//   if (c == null) {
//     b++;
//   } else if (d == null) {
//     b--;
//   } else {
//     b = 0;
//   }

//   switch (a) {
//     case 1:
//       b++;
//       break;
//     case 2:
//       b--;
//       break;
//     default:
//       b = 0;
//       break;
//   }

//   for (int i = 0, j = 1; i < 10; i++, j += 2) {
//     b++;
//     b += j;
//   }

//   var data = [1, 2, 3, 4];
//   for (int e in data) {
//     b += e;
//   }

//   b = 0;
//   while (b < 10) {
//     b++;
//     break;
//   }

//   b = 0;
//   do {
//     b++;
//   } while (b < 10);

//   return c ?? e;
// }

// T f2<T>(T a, {T? b}) => b ?? a;

// Function ff=f2;

// Future<T> f3<T>(T a, {T? b}) async => b ?? a;

// Future<int> f3(int a, {int b = 2}) async {
//   await Future.delayed(Duration(seconds: 1), () async {
//     a++;
//     return a;
//   });
//   // await (f2<int>(a, b: b)) ;
//   return a + b;
// }

// String f4(String name, int sex, {required int age, String country = 'China'}) {
//   int time = 1;
//   return 'My name is $name and I am $sex and $age yeas old. I am in $country. Current time is $time.';
// }

// const z0 = 0;

// final z1 = a1 << 1;

// var z2 = ++a1;

// dynamic z3 = a1++;

// final z4 = a1 & a2;

// final z5 = a1 ^ a2;

// final z6 = a1 | a2;

// final z7 = a1 += 2;

// final z8 = a1 >= 2;

// final z9 = a1 as num;

// final z10 = a1 is num;

// final z11 = a1 is! num;

// final z12 = a ?? a1;

// final z13 = a == null ? a1 : a;

// final z14 = a..runtimeType;

// enum Vehicle implements Comparable<Vehicle> {
//   car(tires: 4, passengers: 5, carbonPerKilometer: 400),
//   bus(tires: 6, passengers: 50, carbonPerKilometer: 800),
//   bicycle(tires: 2, passengers: 1, carbonPerKilometer: 0);

//   const Vehicle({
//     required this.tires,
//     required this.passengers,
//     required this.carbonPerKilometer,
//   });

//   final int tires;
//   final int passengers;
//   final int carbonPerKilometer;

//   int get carbonFootprint => (carbonPerKilometer / passengers).round();

//   @override
//   int compareTo(Vehicle other) => carbonFootprint - other.carbonFootprint;
// }

// enum Sex {
//   male,
//   female,
//   unkow,
// }

// abstract class Base<T extends Sex> {
//   void say(int age);
// }

// class User<T> implements Base<Sex> {
//   final int zzz;

//   User({required this.zzz});

//   @override
//   void say(int age) {
//     print(age);
//   }
// }

// class Role extends User<int> implements Base<Sex> {
//   static const String type = 'Role';
//   static final String type2 = 'Name';

//   int a = 0;
//   final int b;

//   Role({required super.zzz, required this.b,required int c}) : a = 2;

//   @override
//   void say(int age) {
//     super.say(age);
//     print(age + 10);
//   }

//   int get aaa => a;
// }

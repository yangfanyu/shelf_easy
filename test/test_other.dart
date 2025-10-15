// ignore_for_file: collection_methods_unrelated_type

import 'dart:convert';

import 'package:shelf_easy/shelf_deps.dart';
import 'package:shelf_easy/shelf_easy.dart';

void main() {
  // Assign compile-time constant to p0.
  Point p0 = Point.origin0;
  // Create new point using const constructor.
  Point p1 = Point(0, 0);
  // Create new point using non-const constructor.
  Point p2 = Point.clone(p0);
  // Assign (the same) compile-time constant to p3.
  Point p3 = const Point(0, 0);

  // Compare
  print(p0 == p1); // false
  print(p0 == p2); // false
  print(p0 == p3); // true
  print('\n');
  print(identical(p0, p1)); // false
  print(identical(p0, p2)); // false
  print(identical(p0, p3)); // true
  print('\n');
  print(p0.method == p1.method); // false
  print(p0.method == p2.method); // false
  print(p0.method == p3.method); // true
  print('\n');
  print(Point.origin0 == Point.origin1); // false
  print(Point.origin0 == Point.from(Point.origin0)); // false
  print(Point.origin0 == Point.origin2); // true
  print('\n');
  try {
    p1.msg.add('aaaaaa'); //Unsupported operation: Cannot add to an unmodifiable list
  } catch (e) {
    print(e);
  }
  p2.msg.add('bbbbbb'); //[[bbbbbb]]
  print([p2.msg]);
  try {
    Point.origin2.msg.add('cccccc'); //Unsupported operation: Cannot add to an unmodifiable list
  } catch (e) {
    print(e);
  }
  try {
    Point.from(Point.origin0).msg.add('dddddd'); //Unsupported operation: Cannot add to an unmodifiable list
  } catch (e) {
    print(e);
  }

  final map1 = {'\$ne': 1};
  final map2 = {r'$ne': 1};
  print(map1);
  print(map2);
  print(map1.keys.first == map2.keys.first);

  Set<int> set1 = {1, 2, 3, 4};
  print(set1.toList());
  Set<int> set2 = {4, 3, 2, 1};
  print(set2.toList());
  Set<int> set3 = {4, 3, 5, 2, 1};
  print(set3.toList());
  Set<String> set4 = {'4', '3', '5', '2', '1'};
  print(set4.toList());

  final list = ['a1', 'a2', 'a3', 'a', 'a6', 'a5', 'a4'];
  list.sort((a, b) => a.compareTo(b));
  print(list);

  final objId1 = DbQueryField.hexstr2ObjectId('000000000000000000000000');
  final objId2 = DbQueryField.hexstr2ObjectId('000000000000000000000000');
  final objId3 = DbQueryField.hexstr2ObjectId('000000000000000000000001');

  print('objId1 == objId2 => ${objId1 == objId2}');
  print('objId1 == objId3 => ${objId1 == objId3}');

  //ObjectId
  Map<String, ObjectId> map3 = {
    'a': ObjectId(),
    'b': ObjectId(),
  };
  print("ObjectId Map to JsonStr: ${jsonEncode(map3)}");
  print("JsonStr to ObjectId Map: ${jsonDecode(jsonEncode(map3))}  ${jsonDecode(jsonEncode(map3))['a']} ${jsonDecode(jsonEncode(map3))['a'] is String}"); //xxx xxx true 转换回来变成字符串了

  Map<ObjectId, int> map3x = {};
  map3x[objId1] = 0;
  map3x[objId3] = 1;
  print("ObjectId Map : $map3x ${map3x['000000000000000000000000']} ${map3x[DbQueryField.hexstr2ObjectId('000000000000000000000000')]} ${map3x[objId3]}");
  print("${map3x.containsKey(objId1)} ${map3x.containsKey(DbQueryField.hexstr2ObjectId('000000000000000000000000'))} ${map3x.containsKey('000000000000000000000000')}"); //true true false
  print("${map3x.keys.toSet().contains(objId1)} ${map3x.keys.toSet().contains(DbQueryField.hexstr2ObjectId('000000000000000000000000'))} ${map3x.keys.toSet().contains('000000000000000000000000')}"); //true true false

  Map<String, int> map3z = {};
  map3z['000000000000000000000000'] = 2;
  map3z['000000000000000000000001'] = 3;
  print("ObjectId Map : $map3z ${map3z['000000000000000000000000']} ${map3z[objId3]} ${map3z[objId3.oid]}");

  //jsonEncode操作Map时只支持以字符串为键
  Map<int, int> map4 = {
    1: 123,
    2: 3452,
  };
  print("Int Key Map to JsonStr : ${jsonEncode(map4)}"); //Converting object to an encodable object failed: _LinkedHashMap len:2
}

class Point {
  static final Point origin0 = const Point(0, 0);
  static final Point origin1 = const Point(0, 1);
  static const Point origin2 = Point(0, 0);
  final int x;
  final int y;
  final List<String> msg;
  const Point(this.x, this.y) : msg = const [];
  Point.clone(Point other)
      : x = other.x,
        y = other.y,
        msg = [];
  factory Point.from(Point other) {
    return Point(other.x, other.y);
  }

  void method() {}
}


// import 'model/user.dart';

// typedef VarArgsCallback = void Function(List<dynamic> args, Map<String, dynamic> kwargs);

// class VarArgsFunction {
//   final VarArgsCallback callback;
//   static final _offset = 'Symbol("'.length;

//   VarArgsFunction(this.callback);

//   // void call() => callback([], {});

//   @override
//   dynamic noSuchMethod(Invocation inv) {
//     return callback(
//       inv.positionalArguments,
//       inv.namedArguments.map(
//         (_k, v) {
//           var k = _k.toString();
//           return MapEntry(k.substring(_offset, k.length - 2), v);
//         },
//       ),
//     );
//   }
// }

// void main() {
//     dynamic myFunc = VarArgsFunction((args, kwargs) {
//       print('Got args: $args, kwargs: $kwargs');
//     });
//     myFunc(1, 2, x: User(), y: false); // Got args: [1, 2], kwargs: {x: true, y: false}
// }
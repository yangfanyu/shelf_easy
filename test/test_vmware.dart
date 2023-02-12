import 'dart:io';

// import 'package:dart_eval/dart_eval.dart';

import 'package:shelf_easy/shelf_easy.dart';
import 'package:shelf_easy/src/vm/vm_keys.dart';
import 'package:shelf_easy/src/vm/vm_parser.dart';
import 'package:shelf_easy/src/vm/vm_runner.dart';

void main() {
  // watchDartEval();
  watchShelfEasy();
}

// void watchDartEval() {
//   final watch = Stopwatch()..start();
//   final source = '''
//  int main() {
//         var count = 0;
//         for (var i = 0; i < 10000; i = i + 1) {
//           count = count + i;
//         }
//         return count;
//       }
// ''';
//   final result = eval(source, function: 'main');
//   print('dart_eval 用时 ${watch.elapsed}; result= ${result.runtimeType} $result');
// }

void watchShelfEasy() {
  final watch = Stopwatch()..start();
  final source = '''
 int main() {
        var count = 0;
        for (var i = 0; i < 10000; i = i + 1) {
          count = count + i;
        }
        return count;
      }
''';
  final parseResult = VmParser.parseSource(source);
  final runner = VmRunner();
  runner.initLibrary();
  runner.initRuntime(parseResult);
  final result = runner.callFunction<int>('main');
  print('shelf_easy 用时 ${watch.elapsed}; result= ${result.runtimeType} $result');
}

void testFromFile() {
  final source = File('${Directory.current.path}/test/test_vmfile.dart').readAsStringSync();
  final routeList = <String>[];
  final parseResult = VmParser.parseSource(source, routeList: routeList, routeLogger: (route) => print(route));

  final encoder = JsonEncoder.withIndent('  ');
  print(encoder.convert(DbQueryField.toBaseType(parseResult)));
  print(encoder.convert(routeList));

  print('\n');
  print(VmKeys.values.length);
  print('\n');

  final runner = VmRunner();
  runner.initLibrary();
  runner.initRuntime(parseResult);
  print('\n');
  print(encoder.convert(runner));
}

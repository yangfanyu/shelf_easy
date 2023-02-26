import 'dart:io';

// import 'package:dart_eval/dart_eval.dart';

import 'package:shelf_easy/shelf_easy.dart';
import 'package:shelf_easy/src/vm/vm_keys.dart';
import 'package:shelf_easy/src/vm/vm_parser.dart';
import 'package:shelf_easy/src/vm/vm_runner.dart';

void main() {
  // watchDartEval();
  // watchShelfEasy();
  testEasyVmVare();
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
  VmRunner.loadGlobalLibrary();
  final runner = VmRunner(moduleTree: VmParser.parseSource(source));
  final result = runner.callFunction<int>('main');
  print('shelf_easy 用时 ${watch.elapsed}; result= ${result.runtimeType} $result');
}

void testEasyVmVare() {
  print('\n');
  print(VmKeys.values.length);
  print('\n');

  VmRunner.loadGlobalLibrary();
  final vmware = EasyVmWare(
    config: EasyVmWareConfig(
      allModules: {
        'main': File('${Directory.current.path}/test/test_vmfile.dart').readAsStringSync(),
      },
    ),
  );
  vmware.debugObjectStack();
  vmware.call(moduleName: 'main', methodName: 'funcA2', positionalArguments: [100, 200], namedArguments: {#c: 300, #d: 400, #e: 500});
}

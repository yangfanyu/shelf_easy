import 'dart:io';

import 'package:shelf_easy/shelf_easy.dart';
import 'package:shelf_easy/src/vm/vm_keys.dart';
import 'package:shelf_easy/src/vm/vm_library.dart';
import 'package:shelf_easy/src/vm/vm_parser.dart';
import 'package:shelf_easy/src/vm/vm_runner.dart';

main() {
  VmLibrary.importDartCore();

  final source = File('${Directory.current.path}/test/test_vmfile.dart').readAsStringSync();
  final routeList = <String>[];
  final parseResult = VmParser.parseSource(source, routeList: routeList, routeLogger: (route) => print(route));

  final encoder = JsonEncoder.withIndent('  ');
  print(encoder.convert(DbQueryField.toBaseType(parseResult)));
  print(encoder.convert(routeList));

  print(VmKeys.values.length);

  final runner = VmRunner();
  runner.scanAstTree(parseResult);
  print(encoder.convert(runner));

  // int? a;
  // int? b = 1;
  // int c = 2;

  // print(a.runtimeType);
  // print(b.runtimeType);
  // print(c.runtimeType);

  // print(10 ~/ 3);
  // print(10 % 3);
}

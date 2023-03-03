import 'dart:io';

import 'package:shelf_easy/shelf_gens.dart';

import '../model/all.dart';

void main() {
  final vmgen = EasyVmGen(
    targetClassList: [
      MapEntry(Constant, Constant()),
      MapEntry(Location, Location()),
      MapEntry(User, User()),
    ],
  );
  vmgen.generateTargetLibrary(
    outputFile: '${Directory.current.path}/bridge/model_library.dart',
    outputClass: 'ModelLibrary',
    importList: ['../model/all.dart'],
  );
}

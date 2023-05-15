// ignore_for_file: unnecessary_constructor_name, deprecated_member_use, invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'vm_object.dart';

///
///Dart核心库桥接类
///
class VmLibrary {
  ///all class list
  static final libraryClassList = <VmClass>[];

  ///all proxy list
  static final libraryProxyList = <VmProxy<void>>[];
}

import 'vm_base.dart';

///
///减小web端打包体积的空库
///
class VmLibrary {
  static final libraryClassList = <VmClass>[];
  static final libraryProxyList = <VmProxy<void>>[];
}

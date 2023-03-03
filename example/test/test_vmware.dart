// import 'dart:io';

import 'package:shelf_easy/shelf_easy.dart';

import '../bridge/model_library.dart';
import '../model/all.dart';

void main() {
  ///必须先导入核心类库，全局只需要调用一次
  ///
  ///在这里我们将生成的模型桥接库导入，就可以在虚拟机中愉快的使用模型了
  EasyVmWare.loadGlobalLibrary(
    customClassList: ModelLibrary.libraryClassList,
    customProxyList: ModelLibrary.libraryProxyList,
  );

  ///简洁的执行动态代码
  final source = '''
 int main() {
        var count = 0;
        for (var i = 0; i < 10000; i = i + 1) {
          count = count + i;
        }
        return count;
      }
''';
  final result1 = EasyVmWare.eval<int>(moduleCode: source, methodName: 'main');
  print('result1 ===========> $result1');

  ///以应用程序的形式执行动态代码
  final vmwareApp = EasyVmWare(
    config: EasyVmWareConfig(
      allModules: {
        'main': '''
          int main(){
            print('hello world!');
            return 1;
          }
          ''',
        'test': '''
          DateTime current(){
            return DateTime.now();
          }
          User createUser(){
            print(Location());
            return User();
          }
          ''',
        //支持的全部语法都在这个文件中，可取消下面这行代码的注释，然后运行查看控制台的输出
        // 'code': File('${Directory.current.path}/test/test_vmcode.dart').readAsStringSync(),
      },
    ),
  );

  final result2 = vmwareApp.main();
  vmwareApp.logWarn(['result2 =>', result2]);

  final result3 = vmwareApp.call<DateTime>(moduleName: 'test', methodName: 'current');
  vmwareApp.logWarn(['result3 =>', result3]);

  final result4 = vmwareApp.call<User>(moduleName: 'test', methodName: 'createUser');
  vmwareApp.logWarn(['result4 =>', result4]);

  vmwareApp.debugObjectStack(); //打印虚拟机中的作用域堆栈信息
}

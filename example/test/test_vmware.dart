// import 'dart:io';

import 'package:shelf_easy/shelf_easy.dart';

import '../bridge/model_library.dart';
import '../model/all.dart';

///
///要在虚拟机中继承外部类的话，需要添加[VmSuper]扩展，并且这个类不能为abstract，不能为内部定义的类
///
class OuterClass with VmSuper {
  final String key1;
  final String key2;
  int inc1 = 100;
  int inc2 = 200;

  OuterClass(
    this.key1, {
    required this.key2,
  });

  int sayHello(String name, {required String sex}) {
    print('OuterClass.sayHello: hello world => $key1 $key2 $inc1 $inc2 $name $sex');
    return 111111;
  }
}

void main() {
  ///必须先导入核心类库，全局只需要调用一次
  EasyVmWare.loadGlobalLibrary(
    customClassList: [
      //在这里我们将之前生成的数据模型桥接库导入，就可以在虚拟机中愉快的使用数据模型了
      ...ModelLibrary.libraryClassList,
      //桥接OuterClass，使得在可以在虚拟机里面继承它，一般来讲桥接库可以通过EasyVmGen来生成
      VmClass<OuterClass>(
        identifier: 'OuterClass',
        externalProxyMap: {
          'OuterClass': VmProxy(identifier: 'OuterClass', externalStaticPropertyReader: () => OuterClass.new),
          'key1': VmProxy(identifier: 'key1', externalInstancePropertyReader: (instance) => instance.key1),
          'key2': VmProxy(identifier: 'key2', externalInstancePropertyReader: (instance) => instance.key2),
          'inc1': VmProxy(identifier: 'inc1', externalInstancePropertyReader: (instance) => instance.inc1, externalInstancePropertyWriter: (instance, value) => instance.inc1 = value),
          'inc2': VmProxy(identifier: 'inc2', externalInstancePropertyReader: (instance) => instance.inc2, externalInstancePropertyWriter: (instance, value) => instance.inc2 = value),
          'sayHello': VmProxy(identifier: 'sayHello', externalInstancePropertyReader: (instance) => instance.sayHello),
        },
      ),
    ],
    customProxyList: [
      ...ModelLibrary.libraryProxyList,
    ],
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
  print('result1 ===========> $result1'); //print: result1 ===========> 49995000

  ///以应用程序的形式执行动态代码
  final vmwareApp = EasyVmWare(
    config: EasyVmWareConfig(
      allModules: {
        //main module
        'main': '''
          int main(){
            print('hello world!');
            return 1;
          }
          ''',
        //test module
        'test': '''
          DateTime current(){
            return DateTime.now();
          }
          User createUser(){
            print(Location());
            return User();
          }
          ''',
        //home module
        'home': '''          
          class InnerClass extends OuterClass {
            final String value;
            InnerClass(
              super.key1, {
              required super.key2,
              required this.value,
            });
            @override
            int sayHello(String name, {required String sex}) {
              print('InnerClass.sayHello: hello world => \$key1 \$key2 \$inc1 \$inc2 \$name \$sex \$value');
              return 222222;
            }
          } 
          class EmptyClass extends OuterClass {
            EmptyClass(
              super.key1, {
              required super.key2,
            });
          }
          
          final outer = OuterClass('aa1', key2: 'bb1');
          final inner = InnerClass('aa2', key2: 'bb2', value: 'cc2'); 
          final empty = EmptyClass('aa3', key2: 'bb3');

          int start1() {
            return outer.sayHello('111', sex: 'male');
          }
          int start2() {
            inner.inc1++;
            inner.inc2++;
            return inner.sayHello('222', sex: 'female');
          }
          int start3() {
            empty.inc1+=10;
            empty.inc2+=10;
            return empty.sayHello('333', sex: 'unknow');
          }
          ''',
        //支持的全部语法都在这个文件中，可取消下面这行代码的注释，然后运行查看控制台的输出
        // 'code': File('${Directory.current.path}/test/test_vmcode.dart').readAsStringSync(),
      },
    ),
  );

  final result2 = vmwareApp.main<int>(); //print: hello world!
  vmwareApp.logWarn(['result2 =>', result2]); //print: result2 => 1

  final result3 = vmwareApp.call<DateTime>(moduleName: 'test', methodName: 'current');
  vmwareApp.logWarn(['result3 =>', result3]); //print: result3 => xxxx-xx-xx xx:xx:xx.xxxxxx

  final result4 = vmwareApp.call<User>(moduleName: 'test', methodName: 'createUser'); //print: Location(xxxxxx)
  vmwareApp.logWarn(['result4 =>', result4]); //print: result4 => User(xxxxxx)

  final result5 = vmwareApp.call<int>(moduleName: 'home', methodName: 'start1'); //print: OuterClass.sayHello: hello world => aa1 bb1 100 200 111 male
  vmwareApp.logWarn(['result5 =>', result5]); //print: result5 => 111111

  final result6 = vmwareApp.call<int>(moduleName: 'home', methodName: 'start2'); //print: InnerClass.sayHello: hello world => aa2 bb2 101 201 222 female cc2
  vmwareApp.logWarn(['result6 =>', result6]); //print: result6 => 222222

  final result7 = vmwareApp.call<int>(moduleName: 'home', methodName: 'start3'); //print: OuterClass.sayHello: hello world => aa3 bb3 110 210 333 unknow
  vmwareApp.logWarn(['result7 =>', result7]); //print: result7 => 111111

  vmwareApp.debugObjectStack(moduleName: 'home'); //打印虚拟机中的home模块作用域堆栈信息

  // vmwareApp.debugObjectStack(moduleName: 'code'); //打印虚拟机中的home模块作用域堆栈信息

  // vmwareApp.debugVmWareInfo(moduleName: 'home'); //打印虚拟机中的home模块作用域堆栈信息
}

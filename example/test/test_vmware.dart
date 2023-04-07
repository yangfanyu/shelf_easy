import 'dart:io';

import 'package:shelf_easy/shelf_easy.dart';

import '../bridge/model_library.dart';
import '../model/all.dart';

///定义能在虚拟机中被继承的类，需要添加[VmSuper]扩展，这个类不能是abstract，并且具有公开的构造函数
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
    print('OuterClass.sayHello: hello world => $key1 $key2 $inc1 $inc2 $name $sex $hashCode $isInitedByVmware');
    return 111111;
  }
}

///定义OuterClass桥接类，使得在可以在虚拟机里面继承它，一般来讲桥接库可以通过EasyCoder来生成
final bridgeOuterClass = VmClass<OuterClass>(
  identifier: 'OuterClass',
  superclassNames: ['Object', 'VmSuper'],
  externalProxyMap: {
    'new': VmProxy(identifier: 'new', externalStaticPropertyReader: () => OuterClass.new),
    'getProperty': VmProxy(identifier: 'getProperty', externalInstancePropertyReader: (OuterClass instance) => instance.getProperty),
    'hasChildProperty': VmProxy(identifier: 'hasChildProperty', externalInstancePropertyReader: (OuterClass instance) => instance.hasChildProperty),
    'hashCode': VmProxy(identifier: 'hashCode', externalInstancePropertyReader: (OuterClass instance) => instance.hashCode),
    'hasSuperProperty': VmProxy(identifier: 'hasSuperProperty', externalInstancePropertyReader: (OuterClass instance) => instance.hasSuperProperty),
    'inc1': VmProxy(identifier: 'inc1', externalInstancePropertyReader: (OuterClass instance) => instance.inc1, externalInstancePropertyWriter: (OuterClass instance, value) => instance.inc1 = value),
    'inc2': VmProxy(identifier: 'inc2', externalInstancePropertyReader: (OuterClass instance) => instance.inc2, externalInstancePropertyWriter: (OuterClass instance, value) => instance.inc2 = value),
    'isInitedByVmware': VmProxy(identifier: 'isInitedByVmware', externalInstancePropertyReader: (OuterClass instance) => instance.isInitedByVmware),
    'key1': VmProxy(identifier: 'key1', externalInstancePropertyReader: (OuterClass instance) => instance.key1),
    'key2': VmProxy(identifier: 'key2', externalInstancePropertyReader: (OuterClass instance) => instance.key2),
    'noSuchMethod': VmProxy(identifier: 'noSuchMethod', externalInstancePropertyReader: (OuterClass instance) => instance.noSuchMethod),
    'runtimeType': VmProxy(identifier: 'runtimeType', externalInstancePropertyReader: (OuterClass instance) => instance.runtimeType),
    'sayHello': VmProxy(identifier: 'sayHello', externalInstancePropertyReader: (OuterClass instance) => instance.sayHello),
    'toJson': VmProxy(identifier: 'toJson', externalInstancePropertyReader: (OuterClass instance) => instance.toJson),
    'toString': VmProxy(identifier: 'toString', externalInstancePropertyReader: (OuterClass instance) => instance.toString),
  },
);

void main() {
  ///必须先调用loadGlobalLibrary导入桥接类库，全局只能调用一次
  ///
  ///当前已经内置的库:
  ///  dart:async
  ///  dart:collection
  ///  dart:convert
  ///  dart:core
  ///  dart:math
  ///  dart:typed_data
  ///  dart:io
  ///  dart:isolate
  ///
  /// 在这里我们将之前生成的数据模型桥接库导入，就可以在虚拟机中愉快的使用他们了
  ///
  /// 注意：需要保证桥接类型[VmClass]与桥接代理[VmProxy]的标识符[identifier]全局唯一
  ///
  EasyVmWare.loadGlobalLibrary(
    customClassList: [
      ...ModelLibrary.libraryClassList,
      bridgeOuterClass,
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
  final result1 = EasyVmWare.eval<int>(sourceCode: source, methodName: 'main');
  print('result1 ===========> $result1'); //print: result1 ===========> 49995000

  ///以应用程序的形式执行动态代码
  final vmwareApp = EasyVmWare(
    config: EasyVmWareConfig(
      sourceCodes: {
        ///main module
        'main': '''
          int main(){
            print('hello world, user tableName is => \${UserQuery.\$tableName}');
            return 1;
          }
          ''',

        ///test module
        'test': '''
          DateTime current(){
            return DateTime.now();
          }
          User createUser(){
            print(Location());
            return User();
          }
          ''',

        ///home module
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
              print('InnerClass.sayHello: hello world => \$key1 \$key2 \$inc1 \$inc2 \$name \$sex \$value \$hashCode --- \$isInitedByVmware');
              return 222222;
            }
          } 
          class EmptyClass extends OuterClass {
            EmptyClass(
              super.key1, {
              required super.key2,
            });
            static void sayGoodBye(int a, {required String b}){
              print('EmptyClass.sayGoodBye => \$a \$b');
            }
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

        ///支持的其他语法在这个文件中，可取消下面这行代码的注释，然后运行查看控制台的输出
        'code': File('${Directory.current.path}/test/test_vmcode.dart').readAsStringSync(),
      },
    ),
  );

  final result2 = vmwareApp.main<int>(); //print: hello world, user tableName is => user
  vmwareApp.logWarn(['result2 =>', result2]); //print: result2 => 1

  final result3 = vmwareApp.call<DateTime>(methodName: 'current');
  vmwareApp.logWarn(['result3 =>', result3]); //print: result3 => xxxx-xx-xx xx:xx:xx.xxxxxx

  final result4 = vmwareApp.call<User>(methodName: 'createUser'); //print: Location(xxxxxx)
  vmwareApp.logWarn(['result4 =>', result4]); //print: result4 => User(xxxxxx)

  final result5 = vmwareApp.call<int>(methodName: 'start1'); //print: OuterClass.sayHello: hello world => aa1 bb1 100 200 111 male xxxxxx
  vmwareApp.logWarn(['result5 =>', result5]); //print: result5 => 111111

  final result6 = vmwareApp.call<int>(methodName: 'start2'); //print: InnerClass.sayHello: hello world => aa2 bb2 101 201 222 female cc2 xxxxxx
  vmwareApp.logWarn(['result6 =>', result6]); //print: result6 => 222222

  final result7 = vmwareApp.call<int>(methodName: 'start3'); //print: OuterClass.sayHello: hello world => aa3 bb3 110 210 333 unknow xxxxxx
  vmwareApp.logWarn(['result7 =>', result7]); //print: result7 => 111111

  final result8 = vmwareApp.call<int>(methodName: 'inner.sayHello', positionalArguments: ['666'], namedArguments: {#sex: 'shemale'}); //print: InnerClass.sayHello: hello world => aa2 bb2 101 201 666 shemale cc2 xxxxxx
  vmwareApp.logWarn(['result8 =>', result8]); //print: result8 => 222222

  final result9 = vmwareApp.call<double>(methodName: 'inner.inc1.toDouble');
  vmwareApp.logWarn(['result9 =>', result9]); //print: result9 => 101.0

  vmwareApp.call<void>(methodName: 'EmptyClass.sayGoodBye', positionalArguments: [10], namedArguments: {#b: '999'}); //print: EmptyClass.sayGoodBye => 10 999

  // vmwareApp.debugObjectStack(); //打印虚拟机中的作用域堆栈信息
  // vmwareApp.debugObjectStack(index: 2, simple: true); //打印虚拟机中的作用域堆栈信息
  // vmwareApp.debugSourceTrees(key: 'main'); //打印虚拟机中的main模块的语法树信息
  vmwareApp.debugVmObjectInfo(key: 'TestEmpty'); //打印虚拟机中的某个标识符的详细信息
}

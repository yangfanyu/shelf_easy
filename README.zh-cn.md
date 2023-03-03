
语言:  [English](https://github.com/yangfanyu/shelf_easy/blob/main/README.md) | 中文 

本库包含Json数据模型生成模块、统一的Database操作接口模块、web服务器模块、Websocket服务器模块、配套的客户端模块、可在AOT环境下执行Dart动态代码的虚拟机模块、日志模块。

每个模块都可以单独使用，是一个综合性的轻量级框架。

# 目录

- [目录](#目录)
- [1、用于Json序列化的数据模型生成模块。](#1用于json序列化的数据模型生成模块)
- [2、用于Database操作的数据库统一接口模块。（当前仅支持Mongodb，计划支持postgre）](#2用于database操作的数据库统一接口模块当前仅支持mongodb计划支持postgre)
- [3、Web服务器模块、Websocket服务器模块、配套的客户端模块。（服务器支持集群部署）](#3web服务器模块websocket服务器模块配套的客户端模块服务器支持集群部署)
  - [Web服务器](#web服务器)
  - [Web客户端](#web客户端)
  - [Websocket服务器](#websocket服务器)
  - [Websocket客户端](#websocket客户端)
- [4、用于执行Dart子集的虚拟机模块（提供了在AOT环境下动态推送dart代码的底层支持）。](#4用于执行dart子集的虚拟机模块提供了在aot环境下动态推送dart代码的底层支持)
  - [桥接类型的生成](#桥接类型的生成)
  - [Dart子集的虚拟机用法](#dart子集的虚拟机用法)
- [5、日志模块。](#5日志模块)
- [6、在集群环境下的工程的简单示范。](#6在集群环境下的工程的简单示范)
  - [集群服务器](#集群服务器)
  - [集群客户端](#集群客户端)
  - [集群测试](#集群测试)

下面来展示各个模块的用法，具体代码可到查看本库的 [example](https://github.com/yangfanyu/shelf_easy) 目录。

# 1、用于Json序列化的数据模型生成模块。

在 `example` 目录下创建 `generator.dart` 文件，代码如下：

```dart
import 'dart:io';

import 'package:shelf_easy/shelf_easy.dart';
import 'package:shelf_easy/shelf_gens.dart';

void main() {
  final coder = EasyCoder(
    config: EasyCoderConfig(
      absFolder: '${Directory.current.path}/model',
    ),
  );
  //常量
  coder.generateModel(EasyCoderModelInfo(
    importList: [],
    classDesc: ['', '常量', ''],
    className: 'Constant',
    constFields: [
      EasyCoderFieldInfo(type: 'int', name: 'sexMale', desc: ['性别：男性'], defVal: '101', zhText: '男', enText: 'Male'),
      EasyCoderFieldInfo(type: 'int', name: 'sexFemale', desc: ['性别：女性'], defVal: '102', zhText: '女', enText: 'Female'),
      EasyCoderFieldInfo(type: 'int', name: 'sexUnknow', desc: ['性别：未知'], defVal: '103', zhText: '未知', enText: 'Unknow'),
    ],
    constMap: true,
  ));
  //地址
  coder.generateModel(EasyCoderModelInfo(
    importList: [],
    classDesc: ['', '位置', ''],
    className: 'Location',
    classFields: [
      EasyCoderFieldInfo(type: 'ObjectId', name: '_id', desc: ['唯一标志']),
      EasyCoderFieldInfo(type: 'String', name: 'country', desc: ['国家']),
      EasyCoderFieldInfo(type: 'String', name: 'province', desc: ['省']),
      EasyCoderFieldInfo(type: 'String', name: 'city', desc: ['市']),
      EasyCoderFieldInfo(type: 'String', name: 'district', desc: ['区']),
      EasyCoderFieldInfo(type: 'double', name: 'latitude', desc: ['纬度'], defVal: '16.666666'),
      EasyCoderFieldInfo(type: 'double', name: 'longitude', desc: ['经度'], defVal: '116.666666'),
      EasyCoderFieldInfo(type: 'double', name: 'altitude', desc: ['海拔'], defVal: '1'),
      EasyCoderFieldInfo(type: 'int', name: '_time', desc: ['创建时间'], defVal: 'DateTime.now().millisecondsSinceEpoch'),
    ],
  ));
  //用户
  coder.generateModel(EasyCoderModelInfo(
    importList: ['constant.dart', 'location.dart'],
    classDesc: ['', '用户', ''],
    className: 'User',
    classFields: [
      EasyCoderFieldInfo(type: 'ObjectId', name: '_id', desc: ['唯一标志']),
      EasyCoderFieldInfo(type: 'String', name: 'no', desc: ['账号']),
      EasyCoderFieldInfo(type: 'String', name: 'pwd', desc: ['密码'], secrecy: true),
      EasyCoderFieldInfo(type: 'int', name: 'sex', desc: ['性别'], defVal: 'Constant.sexUnknow'),
      EasyCoderFieldInfo(type: 'int', name: 'age', desc: ['年龄'], defVal: '18'),
      EasyCoderFieldInfo(type: 'Location', name: 'location', desc: ['当前位置'], nullAble: true),
      EasyCoderFieldInfo(type: 'List<Location>', name: 'locationList', desc: ['位置列表'], nullAble: true),
      EasyCoderFieldInfo(type: 'Map<int, Location>', name: 'locationMap', desc: ['位置集合'], nullAble: true),
      EasyCoderFieldInfo(type: 'int', name: '_time', desc: ['创建时间'], defVal: 'DateTime.now().millisecondsSinceEpoch'),
    ],
  ));
  //导出文件
  coder.generateBaseExports();
}
```

然后在 `example` 目录中执行 `dart generator.dart` 生成的代码如下图：

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_0.png)

现在我们来对Json序列化进行演示，在 `example` 目录下建立 `test/test_model.dart`，内容如下：

```dart
import 'package:shelf_easy/shelf_easy.dart';

import '../model/all.dart';

void main() {
  final logger = EasyLogger();
  final encoder = JsonEncoder.withIndent('  ');

  final user1 = User(
    no: 'aaa',
    pwd: '111',
    location: Location(
      country: 'xx国',
      province: 'xx省',
      city: 'xx市',
      district: 'xx区',
    ),
    locationList: [
      Location(district: 'List项1'),
      Location(district: 'List项2'),
    ],
  );
  final user1String = encoder.convert(user1);
  logger.logInfo(['user1 =>', user1String]);

  final user2 = User.fromJson(jsonDecode(user1String))
    ..locationList = null
    ..locationMap = {
      1: Location(district: 'Map项1'),
      2: Location(district: 'Map项2'),
    };
  final user2String = encoder.convert(user2);
  logger.logInfo(['user2 =>', user2String]);
}
```

然后在 `example` 目录中执行 `dart test/test_model.dart` 输出结果如下图：

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_1.png)

数据模型生成的更多规则请查看相关类的源代码注释。

关于日志功能 `EasyLoggger` 的用法将在后文介绍。

# 2、用于Database操作的数据库统一接口模块。（当前仅支持Mongodb，计划支持postgre）

在 `example` 目录下创建 `test/test_database.dart` 文件，内容如下：

```dart 
import 'dart:io';

import 'package:shelf_easy/shelf_easy.dart';

import '../model/all.dart';

void main() {
  final unidb = EasyUniDb(
    config: EasyUniDbConfig(
      driver: EasyUniDbDriver.mongo,
      host: 'localhost',
      port: 27017,
      db: 'shelf_easy_example',
      params: {},
    ),
  );
  unidb.connect().then((value) async {
    await unidb.insertOne(UserQuery.$tableName, User(no: 'aaa'));

    await unidb.insertMany(UserQuery.$tableName, [User(no: 'bbb'), User(no: 'ccc'), User(no: 'ddd'), User(no: 'eee'), User(no: 'fff')]);

    await unidb.deleteOne(
      UserQuery.$tableName,
      DbFilter({
        UserQuery.no..$eq('fff'),
      }),
    );

    await unidb.deleteMany(
      UserQuery.$tableName,
      DbFilter(
        null,
        $or: [
          {UserQuery.no..$eq('ddd')},
          {UserQuery.no..$eq('eee')}
        ],
      ),
    );

    final userBBB = (await unidb.findOne(UserQuery.$tableName, DbFilter({UserQuery.no..$eq('bbb')}), converter: User.fromJson)).result;
    unidb.logWarn(['userBBB =>', userBBB]);

    final userList = (await unidb.findMany(UserQuery.$tableName, DbFilter({}), converter: User.fromJson)).resultList;
    unidb.logWarn(['userList =>', userList]);

    final deleteAllCount = (await unidb.deleteMany(UserQuery.$tableName, DbFilter({}))).rescode;
    unidb.logWarn(['deleteAllCount =>', deleteAllCount]);

    final afterDelAllTotal = (await unidb.count(UserQuery.$tableName, DbFilter({}))).rescode;
    unidb.logWarn(['afterDelAllTotal =>', afterDelAllTotal]);
    //关闭连接
    await unidb.destroy().then((value) => exit(0));
  });
  //sigint
  ProcessSignal.sigint.watch().listen((signal) {
    unidb.destroy().then((value) => exit(0));
  });
}
```

然后在 `example` 目录中执行 `dart test/test_database.dart` 输出结果如下图：

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_2.png)

序列化代码生成器生成的数据库辅助类如 `UserQuery` 结合统一数据库操作类 `EasyUniDb`，可以发挥 `dart强类型` 语言优点， 尽可能的避免 `Map<String, dynamic>` 或 `sql语句` 相关的`字符串key`操作。

`EasyUniDb` 接口风格与 `mongo shell` 基本保持一致，当前仅支持Mongodb，计划支持postgre。

注意：上面的示例代码仅仅是个演示，`EasyUniDb` 的每个接口返回的结果都为 `DbResult<T>` 类型的对象，真实场景下可以根据 `DbResult<T>` 的字段来判断数据库操作结果状态。具体请查看相关类的源代码注释。

# 3、Web服务器模块、Websocket服务器模块、配套的客户端模块。（服务器支持集群部署）

## Web服务器

在 `example` 目录下创建 `test/test_webserver.dart` 文件，内容如下：

```dart
import 'dart:io';

import 'package:shelf_easy/shelf_deps.dart';
import 'package:shelf_easy/shelf_easy.dart';

import '../model/all.dart';

void main() {
  final server = EasyServer(
    config: EasyServerConfig(
      logLevel: EasyLogLevel.info,
      host: 'localhost',
      port: 8080,
      pwd: '12345678', //AES加密密码
      binary: true, //使用二进制发送AES数据包
    ),
  );
  final rootPath = Directory.current.path;

  ///普通get请求
  server.get('/hello', (Request request) {
    return Response.ok('hello world by get.');
  });

  ///普通get请求
  server.get('/user/<no>/<pwd>', (Request request, String no, String pwd) {
    return Response.ok('I am $no, my pwd is $pwd');
  });

  ///普通post请求
  server.post('/test/one', (Request request) async {
    final data = await request.readAsString();
    return Response.ok('I am received: $data');
  });

  ///AES加密post请求
  server.httpRoute('/location', (request, packet) async {
    final no = packet.data!['no'] as String;
    final location = packet.data!['location'] as Map<String, dynamic>;
    return packet.responseOk(
      data: {
        'user': User(no: no, location: Location.fromJson(location)),
        'time': DateTime.now().toIso8601String(),
      },
    );
  });

  ///AES加密post上传
  server.httpUpload('/doUpload', (request, packet, files) async {
    final aaa = packet.data!['aaa'] as int;
    final bbb = packet.data!['bbb'] as int;
    return packet.responseOk(
      data: {
        'aaa': aaa,
        'bbb': bbb,
        'paths': files.map((e) => e.path.replaceFirst(rootPath, '')).toList(),
      },
    );
  }, destinationFolder: () => '$rootPath/upload');

  ///挂载根目录，并设置listDirectories启用文件夹浏览功能
  server.mount('/', rootPath, listDirectories: true);

  server.start();

  //sigint
  ProcessSignal.sigint.watch().listen((signal) {
    server.close().then((value) => exit(0));
  });
}
```

然后在 `example` 目录中执行 `dart test/test_webserver.dart` 启动服务器，输出结果如下图：

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_3.png)

普通get请求与普通post请求测试结果如下图：

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_4.png)

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_5.png)

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_6.png)

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_7.png)


此时服务器控制台输出结果如下图：

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_8.png)


## Web客户端

在 `example` 目录下创建 `test/test_webclient.dart` 文件，内容如下：

```dart
import 'dart:io';

import 'package:shelf_easy/shelf_deps.dart';
import 'package:shelf_easy/shelf_easy.dart';

import '../model/all.dart';

void main() async {
  final client = EasyClient(
    config: EasyClientConfig(
      logLevel: EasyLogLevel.debug,
      url: 'http://localhost:8080',
      pwd: '12345678', //AES加密密码
      binary: true, //使用二进制发送AES数据包
    ),
  );

  ///普通请求通过类方法处理
  final resp1 = await EasyClient.get('${client.url}/hello');
  final resp2 = await EasyClient.get('${client.url}/user/aaa/bbb');
  final resp3 = await EasyClient.post('${client.url}/test/one', body: 'hello world!');
  client.logWarn(['resp1 =>', resp1.body]);
  client.logWarn(['resp2 =>', resp2.body]);
  client.logWarn(['resp3 =>', resp3.body]);

  ///AES加密post请求
  final resp4 = await client.httpRequest('/location', data: {'no': 'ccc', 'location': Location(latitude: 11.111111, longitude: 111.111111)});
  client.logWarn(['resp4 =>', resp4.data]);

  ///AES加密post上传
  final resp5 = await client.httpRequest(
    '/doUpload',
    data: {'aaa': 111, 'bbb': 222},
    fileBytes: [
      File('${Directory.current.path}/screenshot/step_0.png').readAsBytesSync(),
      File('${Directory.current.path}/screenshot/step_1.png').readAsBytesSync(),
    ],
    mediaType: MediaType.parse('image/png'),
  );
  client.logWarn(['resp5 =>', resp5.data]);
}
```

然后在 `example` 目录中执行 `dart test/test_webclient.dart` 输出结果如下图：

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_9.png)

图片会被上传到自定义的 `example` 的 `upload` 目录下：

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_10.png)


## Websocket服务器

在 `example` 目录下创建 `test/test_wssserver.dart` 文件，内容如下：

```dart
import 'dart:io';

import 'package:shelf_easy/shelf_easy.dart';

import '../model/all.dart';

void main() {
  final server = EasyServer(
    config: EasyServerConfig(
      logLevel: EasyLogLevel.info,
      host: 'localhost',
      port: 8080,
      pwd: '12345678', //AES加密密码
      binary: true, //使用二进制发送AES数据包
    ),
  );

  server.websocketRoute('location', (session, packet) async {
    final no = packet.data!['no'] as String;
    final location = packet.data!['location'] as Map<String, dynamic>;
    return packet.responseOk(
      data: {
        'user': User(no: no, location: Location.fromJson(location)),
        'time': DateTime.now().toIso8601String(),
      },
    );
  });

  server.websocketRoute('currentTime', (session, packet) async {
    return packet.responseOk(desc: DateTime.now().toIso8601String());
  });

  server.start();

  //sigint
  ProcessSignal.sigint.watch().listen((signal) {
    server.close().then((value) => exit(0));
  });
}
```

然后在 `example` 目录中执行 `dart test/test_wssserver.dart` 启动服务器，输出结果如下图：

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_11.png)

## Websocket客户端

在 `example` 目录下创建 `test/test_wssclient.dart` 文件，内容如下：

```dart
import 'dart:io';

import 'package:shelf_easy/shelf_easy.dart';

import '../model/all.dart';

void main() async {
  final client = EasyClient(
    config: EasyClientConfig(
      logLevel: EasyLogLevel.debug,
      url: 'ws://localhost:8080',
      pwd: '12345678', //AES加密密码
      binary: true, //使用二进制发送AES数据包
    ),
  );

  client.connect(
    onopen: () async {
      final resp4 = await client.websocketRequest('location', data: {'no': 'ccc', 'location': Location(latitude: 11.111111, longitude: 111.111111)});
      client.logWarn(['resp4 =>', resp4.data]);

      await Future.delayed(Duration(seconds: 5));

      await client.destroy().then((value) => exit(0));
    },
    onheart: (second, delay) async {
      final resp5 = await client.websocketRequest('currentTime', data: {});
      client.logWarn(['resp5 =>', resp5.desc]);
    },
  );

  //sigint
  ProcessSignal.sigint.watch().listen((signal) {
    client.destroy().then((value) => exit(0));
  });
}
```

然后在 `example` 目录中执行 `dart test/test_wssclient.dart` 输出结果如下图：

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_12.png)

此时服务器控制台输出结果如下图：

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_13.png)

# 4、用于执行Dart子集的虚拟机模块（提供了在AOT环境下动态推送dart代码的底层支持）。

## 桥接类型的生成

在dart环境下，可以通过 `EasyVmGen` 类来生成桥接类型。

在 `example` 目录下创建 `test/test_vmgen.dart` 文件，内容如下：

```dart
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
```

然后在 `example` 目录中执行 `dart test/test_vmgen.dart` 生成结果如下图：

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_14.png)

注意：flutter环境由于不能使用 `dart:mirrors`，如有需要请手写桥接类（得益于flutter声明式ui，widget的桥接类型都不复杂，一般情况下每个widget 只需几行代码桥接构造函数就足够了）。

## Dart子集的虚拟机用法

在 `example` 目录下创建 `test/test_vmware.dart` 文件，内容如下：

```dart
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
```


然后在 `example` 目录中执行 `dart test/test_vmware.dart` 输出结果如下图：

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_15.png)

注意：虚拟机所支持的全部语法都表现在这个文件里面了：

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_16.png)


# 5、日志模块。

使用非常简单，在 `example` 目录下创建 `test/test_logger.dart` 文件，内容如下：

```dart
import 'dart:io';

import 'package:shelf_easy/shelf_easy.dart';


void main() {
  final logger = EasyLogger(
    logger: EasyLogger.printAndWriteLogger, //这里设置为：同时输出到控制台和文件（默认情况下输出到控制台）
    logLevel: EasyLogLevel.trace,
    logTag: 'HelloLogger',
    logFilePath: '${Directory.current.path}/logs/test_logger', //日志文件输出路径
  );
  logger.logTrace(['hello', 'world', DateTime.now().toUtc()]);
  logger.logDebug(['hello', 'world', DateTime.now().toUtc()]);
  logger.logInfo(['hello', 'world', DateTime.now().toUtc()]);
  logger.logWarn(['hello', 'world', DateTime.now().toUtc()]);
  logger.logError(['hello', 'world', DateTime.now().toUtc()]);
  logger.logFatal(['hello', 'world', DateTime.now().toUtc()]);
}
```

然后在 `example` 目录中执行 `dart test/test_logger.dart` 控制台输出结果如下图：

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_17.png)

文件输出结果如下图：

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_18.png)

# 6、在集群环境下的工程的简单示范。

在 `example` 目录下创建 `app/` 子目录，内容如图：

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_19.png)

## 集群服务器

 `app_server.dart` 为服务器的启动文件，内容如下：

```dart
import 'dart:io';

import 'package:shelf_easy/shelf_easy.dart';

import 'http_route.dart';
import 'inner_route.dart';
import 'outer_route.dart';

void main() {
  ///多台物理设备情况下可以通过[machineBind]与[machineFile]参数来进行主机名称匹配，启动对应[host]的进程
  Easy.startClusterServers(
    // machineBind: true,
    // machineFile: '${Directory.current.path}/hostname.txt',
    // environment: 'release',
    environment: 'develop',
    envClusterServerConfig: {
      'develop': {
        'http': [
          EasyServerConfig(host: '127.0.0.1', port: 8080, links: ['outer', 'inner'], instances: 4),
        ],
        'outer': [
          EasyServerConfig(host: '127.0.0.1', port: 8001, links: ['inner']),
          EasyServerConfig(host: '127.0.0.1', port: 8002, links: ['inner']),
          EasyServerConfig(host: '127.0.0.1', port: 8003, links: ['inner']),
        ],
        'inner': [
          EasyServerConfig(host: '127.0.0.1', port: 9001, links: ['outer']),
          EasyServerConfig(host: '127.0.0.1', port: 9002, links: ['outer']),
          EasyServerConfig(host: '127.0.0.1', port: 9003, links: ['outer']),
        ]
      },
      'release': {
        'http': [
          EasyServerConfig(host: 'localhost', port: 8080, links: ['outer', 'inner'], instances: 4),
        ],
        'outer': [
          EasyServerConfig(host: 'localhost', port: 8001, links: ['inner']),
          EasyServerConfig(host: 'localhost', port: 8002, links: ['inner']),
          EasyServerConfig(host: 'localhost', port: 8003, links: ['inner']),
        ],
        'inner': [
          EasyServerConfig(host: 'localhost', port: 9001, links: ['outer']),
          EasyServerConfig(host: 'localhost', port: 9002, links: ['outer']),
          EasyServerConfig(host: 'localhost', port: 9003, links: ['outer']),
        ]
      }
    },
    envClusterServerEntryPoint: {
      'develop': {
        'http': httpServerEntryPoint,
        'outer': outerServerEntryPoint,
        'inner': innerServerEntryPoint,
      },
      'release': {
        'http': httpServerEntryPoint,
        'outer': outerServerEntryPoint,
        'inner': innerServerEntryPoint,
      },
    },
    envDefaultDatabaseConfig: {
      'develop': EasyUniDbConfig(driver: EasyUniDbDriver.mongo, host: '127.0.0.1', port: 27017, db: 'shelf_easy_example', params: {}),
      'release': EasyUniDbConfig(driver: EasyUniDbDriver.mongo, host: 'localhost', port: 27017, db: 'shelf_easy_example', params: {}),
    },
    logger: EasyLogger.printAndWriteLogger,
    logLevel: EasyLogLevel.info,
    logFolder: '${Directory.current.path}/logs',
    logFileBackup: 3,
    logFileMaxBytes: 10 * 1024,
    pwd: '12345678',
    secret: EasySecurity.uuid.v4(),
    binary: true,
    //异步Error捕获测试，生产环境下建议使用默认值
    runErrorsZone: false,
    errorsAreFatal: false,
  );

  //sigint
  ProcessSignal.sigint.watch().listen((signal) {
    Easy.closeClusterServers().then((value) => exit(0));
  });
}

void httpServerEntryPoint(String environment, String cluster, EasyServer server, EasyUniDb? database) => HttpRoute(server, database!).start();

void outerServerEntryPoint(String environment, String cluster, EasyServer server, EasyUniDb? database) => OuterRoute(server, database!).start();

void innerServerEntryPoint(String environment, String cluster, EasyServer server, EasyUniDb? database) => InnerRoute(server, database!).start();
```

从代码可以看出来，上面的服务器包含两种环境，分别为： `develop` 、`release`，可以根据实际需求自定义很多种。

上面的服务器包含三种服务集群，分别为： 公开的Web服务集群 `http` 、公开的长连接Websocket服务集群 `outer` 、内部的服务集群 `inner`。

`http_route.dart` 对应 `http` 服务（文件名、类名、服务名并无关联，可以自由定义），代码如下：

```dart
import 'package:shelf_easy/shelf_easy.dart';

class HttpRoute {
  ///服务器
  final EasyServer server;

  final EasyUniDb database;

  HttpRoute(this.server, this.database);

  void start() {
    ///推送广播消息
    server.httpRoute('/webPushAll', (request, packet) async {
      server.callRemote('inner', route: 'pushAll', data: packet.data);
      return packet.responseOk();
    });

    ///推送分组消息
    server.httpRoute('/webPushGRP', (request, packet) async {
      server.callRemote('inner', route: 'pushGRP', data: packet.data);
      return packet.responseOk();
    });

    ///推送点对点消息
    server.httpRoute('/webPushP2P', (request, packet) async {
      server.callRemote('inner', route: 'pushP2P', data: packet.data);
      return packet.responseOk();
    });

    ///获取当前的时间
    server.httpRoute('/webTimeNow', (request, packet) async {
      final result = await server.callRemoteForResult('inner', route: 'timeNow');
      return packet.responseOk(data: result.data);
    });

    ///Asynchronous error test
    Future.delayed(Duration(seconds: 13), () {
      throw ('http async error');
    });
  }
}
```

`http_route.dart` 里面定义了4个公开的接口。

前三个接口 `/webPushXXX` 通过调用 `inner` 服务来推送数据到 `outer` 服务长连接的客户端。

后一个接口 `/webTimeNow` 通过调用 `inner` 服务来获取当前时间并返回。

`outer_route.dart` 对应 `outer` 服务（文件名、类名、服务名并无关联，可以自由定义），代码如下：

```dart
import 'package:shelf_easy/shelf_easy.dart';

class OuterRoute {
  ///服务器
  final EasyServer server;

  final EasyUniDb database;

  OuterRoute(this.server, this.database);

  void start() {
    ///绑定uid
    server.websocketRoute('enter', (session, packet) async {
      final uid = packet.data!['uid'] as String; //读取用户id
      final token = EasySecurity.uuid.v4(); //生成随机的数据传输加密口令

      //延迟操作确保响应数据发送完成后再绑定会话信息
      Future.delayed(Duration.zero, () {
        server.bindUser(session, uid, token: token, closeold: true); //closeold参数为true表示踢掉本线程重复uid的连接
      });

      return packet.responseOk(data: {'uid': uid, 'token': token});
    });

    ///加入分组
    server.websocketRoute('joinTeam', (session, packet) async {
      final cid = packet.data!['cid'] as String; //读取分组id
      server.joinChannel(session, cid);
      return packet.responseOk();
    });

    ///退出分组
    server.websocketRoute('quitTeam', (session, packet) async {
      final cid = packet.data!['cid'] as String; //读取分组id
      server.quitChannel(session, cid);
      return packet.responseOk();
    });

    ///解绑uid
    server.websocketRoute('leave', (session, packet) async {
      //延迟操作确保响应数据发送完成后再解绑会话信息
      Future.delayed(Duration.zero, () {
        server.unbindUser(session);
      });

      return packet.responseOk();
    });

    //Asynchronous error test
    Future.delayed(Duration(seconds: 14), () {
      throw ('outer async error');
    });
  }
}
```

`outer_route.dart` 里面定义了4个公开的接口。

注意：在 `outer_route.dart` 服务里面同样可以像上面的 `http_route.dart` 那样调用远程方法，更多api请看 `EasyServer` 源代码与注释。

`inner_route.dart` 对应 `inner` 服务（文件名、类名、服务名并无关联，可以自由定义），代码如下：

```dart
import 'package:shelf_easy/shelf_easy.dart';

class InnerRoute {
  ///服务器
  final EasyServer server;

  final EasyUniDb database;

  InnerRoute(this.server, this.database);

  void start() {
    ///推送广播消息 - 内部方法
    server.websocketRemote('pushAll', (session, packet) async {
      server.clusterBroadcast('outer', route: 'onPushAll', data: packet.data);
      return packet.responseOk();
    });

    ///推送分组消息 - 内部方法
    server.websocketRemote('pushGRP', (session, packet) async {
      final toCid = packet.data!['toCid'] as String;
      server.pushClusterChannel('outer', route: 'onPushGRP', ucid: toCid, data: packet.data);
      return packet.responseOk();
    });

    ///推送点对点消息 - 内部方法
    server.websocketRemote('pushP2P', (session, packet) async {
      final toUid = packet.data!['toUid'] as String;
      server.pushClusterSession('outer', route: 'onPushP2P', ucid: toUid, data: packet.data);
      return packet.responseOk();
    });

    ///获取当前的时间 - 内部方法
    server.websocketRemote('timeNow', (session, packet) async {
      return packet.responseOk(data: {'time': DateTime.now().toString()});
    });

    //Asynchronous error test
    Future.delayed(Duration(seconds: 15), () {
      throw ('inner async error');
    });
  }
}
```

`outer_route.dart` 里面定义了4个内部方法。

## 集群客户端

 `app_client.dart` 为客户端的代码文件，内容如下：

```dart
import 'dart:io';

import 'package:shelf_easy/shelf_easy.dart';

void main(List<String> args) async {
  if (args.isEmpty) throw ('启动格式为: dart app/app_client.dart <port>');
  final port = args.first;
  switch (port) {
    case '8001':
      await userClient800X(port: port, uid: 'aaa', cid: 'cat'); //启动后加入到分组cat
      break;
    case '8002':
      await userClient800X(port: port, uid: 'bbb', cid: 'cat'); //启动后加入到分组cat
      break;
    case '8003':
      await userClient800X(port: port, uid: 'ccc', cid: 'dog'); //启动后加入到分组dog
      break;
    case '8080':
      await pushClient8080();
      break;
  }
}

///启动为长连接客户端
Future<void> userClient800X({required String port, required String uid, required String cid}) async {
  final client = EasyClient(
    config: EasyClientConfig(
      logTag: uid,
      logLevel: EasyLogLevel.debug,
      url: 'ws://localhost:$port',
      pwd: '12345678', //AES加密密码
      binary: true, //使用二进制发送AES数据包
    ),
  );
  //绑定推送监听
  client.addListener('onPushAll', (packet) => client.logWarn(['onPushAll =>', packet.data]));
  client.addListener('onPushGRP', (packet) => client.logWarn(['onPushGRP =>', packet.data]));
  client.addListener('onPushP2P', (packet) => client.logWarn(['onPushP2P =>', packet.data]));
  //连接服务器
  client.connect(
    onopen: () async {
      final result = await client.websocketRequest('enter', data: {'uid': uid});
      if (result.ok) {
        client.bindUser(uid, token: result.data!['token']); //绑定客户端uid与服务器返回的数据加密口令token
        await client.websocketRequest('joinTeam', data: {'cid': cid}); //加入分组
      }
    },
  );

  //sigint
  ProcessSignal.sigint.watch().listen((signal) {
    client.destroy().then((value) => exit(0));
  });
}

///启动为http客户端
Future<void> pushClient8080() async {
  final client = EasyClient(
    config: EasyClientConfig(
      logLevel: EasyLogLevel.debug,
      url: 'http://localhost:8080',
      pwd: '12345678', //AES加密密码
      binary: true, //使用二进制发送AES数据包
    ),
  );

  final resp1 = await client.httpRequest('/webPushAll', data: {'type': 'all', 'body': 'Hello broadcast msg! '});
  client.logWarn(['resp1 =>', resp1.desc]);
  final resp2 = await client.httpRequest('/webPushGRP', data: {'type': 'grp', 'body': 'Hello channel msg!', 'toCid': 'cat'});
  client.logWarn(['resp2 =>', resp2.desc]);
  final resp3 = await client.httpRequest('/webPushP2P', data: {'type': 'p2p', 'body': 'Hello point to point msg!', 'toUid': 'aaa'});
  client.logWarn(['resp3 =>', resp3.desc]);
  final resp4 = await client.httpRequest('/webTimeNow');
  client.logWarn(['resp4 =>', resp4.data]);
}
```

## 集群测试

先在 `example` 目录中执行 `dart app/app_server.dart` 启动服务器

然后执行 `dart app/app_client.dart 8001` 启动 `cat` 分组的用户 `aaa` 的长连接客户端

然后执行 `dart app/app_client.dart 8002` 启动 `cat` 分组的用户 `bbb` 的长连接客户端

然后执行 `dart app/app_client.dart 8003` 启动 `dog` 分组的用户 `ccc` 的长连接客户端

此时控制台输出情况如下图：

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_20.png)

最后执行 `dart app/app_client.dart 8080` 启动http客户端，推送数据，此时控制台输出情况如下图：

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_21.png)
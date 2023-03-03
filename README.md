
Language: English | [中文](https://github.com/yangfanyu/shelf_easy/blob/main/README.zh-cn.md)

This library includes a Json data model generation module, a unified Database operation interface module, a web server module, a Websocket server module, a supporting client module, a virtual machine module that can execute Dart dynamic code in an AOT environment, and a log module.

Each module can be used independently and is a comprehensive lightweight framework.

# Table of contents

- [Table of contents](#table-of-contents)
- [1. Data model generation module for Json serialization.](#1-data-model-generation-module-for-json-serialization)
- [2. The database unified interface module for Database operation. (Currently only supports Mongodb, plan to support postgre)](#2-the-database-unified-interface-module-for-database-operation-currently-only-supports-mongodb-plan-to-support-postgre)
- [3. Web server module, Websocket server module, supporting client module. (The server supports cluster deployment)](#3-web-server-module-websocket-server-module-supporting-client-module-the-server-supports-cluster-deployment)
  - [Web server](#web-server)
  - [Web client](#web-client)
  - [Websocket server](#websocket-server)
  - [Websocket client](#websocket-client)
- [4. A virtual machine module for executing a subset of Dart (provides the underlying support for dynamically pushing dart code in an AOT environment).](#4-a-virtual-machine-module-for-executing-a-subset-of-dart-provides-the-underlying-support-for-dynamically-pushing-dart-code-in-an-aot-environment)
  - [Generation of bridge types](#generation-of-bridge-types)
  - [Virtual machine usage for a subset of Dart](#virtual-machine-usage-for-a-subset-of-dart)
- [5. Log module.](#5-log-module)
- [6. A simple demonstration of projects in a cluster environment.](#6-a-simple-demonstration-of-projects-in-a-cluster-environment)
  - [Cluster server](#cluster-server)
  - [Cluster client](#cluster-client)
  - [Cluster test](#cluster-test)

The usage of each module is shown below. The specific code can be viewed in the [example](https://github.com/yangfanyu/shelf_easy) directory of this library.

# 1. Data model generation module for Json serialization.

Create a `generator.dart` file in the `example` directory, the code is as follows:

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

Then execute the `dart generator.dart` generated code in the `example` directory as shown below:

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_0.png)

Now let's demonstrate Json serialization, create `test/test_model.dart` under the `example` directory, the content is as follows:

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

Then execute `dart test/test_model.dart` in the `example` directory, and the output result is as follows:

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_1.png)

For more rules of data model generation, please refer to the source code comments of related classes.

The usage of the logging function `EasyLoggger` will be introduced later.

# 2. The database unified interface module for Database operation. (Currently only supports Mongodb, plan to support postgre)

Create a `test/test_database.dart` file in the `example` directory with the following content:

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

Then execute `dart test/test_database.dart` in the `example` directory, and the output result is as follows:

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_2.png)

The database auxiliary classes such as `UserQuery` generated by the serialization code generator combined with the unified database operation class `EasyUniDb` can take advantage of the language advantages of `dart strong type` and avoid `Map<String, dynamic>` or `sql statement` as much as possible The associated `string key` operation.

The interface style of `EasyUniDb` is basically consistent with that of `mongo shell`, currently only supports Mongodb, and plans to support postgre.

Note: The sample code above is just a demonstration. The result returned by each interface of `EasyUniDb` is an object of type `DbResult<T>`. In real scenarios, the database operation result can be judged according to the field of `DbResult<T>` state. For details, see the source code comments of the relevant classes.

# 3. Web server module, Websocket server module, supporting client module. (The server supports cluster deployment)

## Web server

Create a `test/test_webserver.dart` file in the `example` directory with the following content:

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

Then execute `dart test/test_webserver.dart` in the `example` directory to start the server, and the output is as follows:

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_3.png)

The test results of ordinary get requests and ordinary post requests are as follows:

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_4.png)

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_5.png)

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_6.png)

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_7.png)


At this time, the server console output results are as follows:

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_8.png)


## Web client

Create a `test/test_webclient.dart` file in the `example` directory with the following content:

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

Then execute `dart test/test_webclient.dart` in the `example` directory, and the output results are as follows:

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_9.png)

The image will be uploaded to the `upload` directory of the custom `example`:

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_10.png)


## Websocket server

Create a `test/test_wssserver.dart` file in the `example` directory with the following content:

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

Then execute `dart test/test_wssserver.dart` in the `example` directory to start the server, and the output is as follows:

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_11.png)

## Websocket client

Create a `test/test_wssclient.dart` file in the `example` directory with the following content:

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

Then execute `dart test/test_wssclient.dart` in the `example` directory, the output result is as follows:

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_12.png)

At this time, the server console output results are as follows:

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_13.png)

# 4. A virtual machine module for executing a subset of Dart (provides the underlying support for dynamically pushing dart code in an AOT environment).

## Generation of bridge types

In the dart environment, bridge types can be generated through the `EasyVmGen` class.

Create a `test/test_vmgen.dart` file in the `example` directory with the following content:

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

Then execute `dart test/test_vmgen.dart` in the `example` directory to generate the result as shown below:

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_14.png)

Note: `dart:mirrors` cannot be used in the flutter environment, if necessary, please write the bridge class by hand (thanks to the flutter declarative ui, the bridge type of the widget is not complicated, and in general, each widget only needs a few lines of code to bridge the structure function is sufficient).

## Virtual machine usage for a subset of Dart

Create a `test/test_vmware.dart` file in the `example` directory with the following content:

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


Then execute `dart test/test_vmware.dart` in the `example` directory, and the output result is as follows:

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_15.png)

Note: All syntax supported by the virtual machine is shown in this file:

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_16.png)


# 5. Log module.

It is very simple to use, create a `test/test_logger.dart` file in the `example` directory, the content is as follows:

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

Then execute `dart test/test_logger.dart` in the `example` directory, and the console output results are as follows:

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_17.png)

The file output results are as follows:

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_18.png)

# 6. A simple demonstration of projects in a cluster environment.

Create an `app/` subdirectory under the `example` directory, as shown in the figure:

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_19.png)

## Cluster server

`app_server.dart` is the startup file of the server, the content is as follows:

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

As can be seen from the code, the above server contains two environments, namely: `develop` and `release`, which can be customized according to actual needs.

The server above contains three service clusters, namely: the public web service cluster `http`, the public persistent connection Websocket service cluster `outer`, and the internal service cluster `inner`.

`http_route.dart` corresponds to the `http` service (the file name, class name, and service name are not related and can be defined freely), the code is as follows:

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

`http_route.dart` defines 4 public interfaces.

The first three interfaces `/webPushXXX` call the `inner` service to push data to the client of the `outer` service persistent connection.

The latter interface `/webTimeNow` gets the current time by calling the `inner` service and returns it.

`outer_route.dart` corresponds to the `outer` service (the file name, class name, and service name are not related and can be defined freely), the code is as follows:

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

`outer_route.dart` defines 4 public interfaces.

Note: In the `outer_route.dart` service, remote methods can also be called like `http_route.dart` above. For more APIs, please refer to `EasyServer` source code and comments.

`inner_route.dart` corresponds to the `inner` service (the file name, class name, and service name are not related and can be defined freely), the code is as follows:

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

`outer_route.dart` defines 4 internal methods.

## Cluster client

 `app_client.dart` is the code file of the client, the content is as follows:

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

## Cluster test

First execute `dart app/app_server.dart` in the `example` directory to start the server

Then execute `dart app/app_client.dart 8001` to start the long-term connection client of user `aaa` grouped by `cat`

Then execute `dart app/app_client.dart 8002` to start the persistent connection client of user `bbb` grouped by `cat`

Then execute `dart app/app_client.dart 8003` to start the persistent connection client of user `ccc` of `dog` group

At this time, the console output is as follows:

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_20.png)

Finally, execute `dart app/app_client.dart 8080` to start the http client and push data. At this time, the console output is as follows:

![image](https://github.com/yangfanyu/shelf_easy/raw/main/example/screenshot/step_21.png)
import 'dart:io';

import 'package:shelf_easy/shelf_easy.dart';

import 'http_route.dart';
import 'inner_route.dart';
import 'outer_route.dart';

void main() {
  ///跨域与其它响应请求头
  const httpHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': '*',
    'Access-Control-Allow-Methods': '*',
    'Access-Control-Request-Private-Network': 'true',
    'Access-Control-Allow-Private-Network': 'true',
    'X-Frame-Options': 'ALLOWALL',
    // 'Referrer-Policy': 'origin-when-cross-origin',
  };

  ///多台物理设备情况下可以通过[machineBind]与[machineFile]参数来进行主机名称匹配，启动对应[host]的进程
  Easy.startClusterServers(
    // machineBind: true,
    // machineFile: '${Directory.current.path}/hostname.txt',
    // environment: 'release',
    environment: 'develop',
    envClusterServerConfig: {
      'develop': {
        'http': [
          EasyClusterNodeConfig(host: 'anyIPv4', port: 8080, links: ['outer', 'inner'], httpHeaders: httpHeaders, isolateInstances: 4),
        ],
        'outer': [
          EasyClusterNodeConfig(host: '127.0.0.1', port: 8001, links: ['inner']),
          EasyClusterNodeConfig(host: '127.0.0.1', port: 8002, links: ['inner']),
          EasyClusterNodeConfig(host: '127.0.0.1', port: 8003, links: ['inner']),
        ],
        'inner': [
          EasyClusterNodeConfig(host: '127.0.0.1', port: 9001, links: ['outer']),
          EasyClusterNodeConfig(host: '127.0.0.1', port: 9002, links: ['outer']),
          EasyClusterNodeConfig(host: '127.0.0.1', port: 9003, links: ['outer']),
        ]
      },
      'release': {
        'http': [
          EasyClusterNodeConfig(host: 'localhost', port: 8080, links: ['outer', 'inner'], httpHeaders: httpHeaders, isolateInstances: 4),
        ],
        'outer': [
          EasyClusterNodeConfig(host: 'localhost', port: 8001, links: ['inner']),
          EasyClusterNodeConfig(host: 'localhost', port: 8002, links: ['inner']),
          EasyClusterNodeConfig(host: 'localhost', port: 8003, links: ['inner']),
        ],
        'inner': [
          EasyClusterNodeConfig(host: 'localhost', port: 9001, links: ['outer']),
          EasyClusterNodeConfig(host: 'localhost', port: 9002, links: ['outer']),
          EasyClusterNodeConfig(host: 'localhost', port: 9003, links: ['outer']),
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
    envDefaultServerConfig: {
      'develop': EasyClusterNodeConfig(
        logger: EasyLogger.printAndWriteLogger,
        logLevel: EasyLogLevel.info,
        logFileBackup: 3,
        logFileMaxBytes: 10 * 1024,
        pwd: '12345678',
        secret: EasySecurity.uuid.v4(),
        binary: true,
        uniDbConfig: EasyUniDbConfig(driver: EasyUniDbDriver.mongo, host: '127.0.0.1', port: 27017, db: 'shelf_easy_example', params: {}),
      ),
      'release': EasyClusterNodeConfig(
        logger: EasyLogger.printAndWriteLogger,
        logLevel: EasyLogLevel.info,
        logFileBackup: 3,
        logFileMaxBytes: 10 * 1024,
        pwd: '12345678',
        secret: EasySecurity.uuid.v4(),
        binary: true,
        uniDbConfig: EasyUniDbConfig(driver: EasyUniDbDriver.mongo, host: '127.0.0.1', port: 27017, db: 'shelf_easy_example', params: {}),
      ),
    },
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

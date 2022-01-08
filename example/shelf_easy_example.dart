import 'package:shelf_easy/shelf_easy.dart';
import 'package:universal_io/io.dart';

void main() {
  Easy.startClusterServers(
    // machineBind: true,
    // machineFile: '${Directory.current.path}/example/hostname.txt',
    // environment: 'production',
    environment: 'development',
    envClusterServerConfig: {
      'development': {
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
      'production': {
        'http': [
          EasyServerConfig(host: 'localhost', port: 8080, links: ['outer', 'outer']),
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
      'development': {
        'http': httpServerEntryPoint,
        'outer': outerServerEntryPoint,
        'inner': innerServerEntryPoint,
      },
      'production': {
        'http': httpServerEntryPoint,
        'outer': outerServerEntryPoint,
        'inner': innerServerEntryPoint,
      },
    },
    envDefaultDatabaseConfig: {
      'development': EasyUniDbConfig(driver: EasyUniDbDriver.mongo, host: '127.0.0.1', port: 27017, db: 'shelf_easy_example', params: {}),
      'production': EasyUniDbConfig(driver: EasyUniDbDriver.mongo, host: 'localhost', port: 27017, db: 'shelf_easy_example', params: {}),
    },
    logger: EasyLogger.printAndWriteLogger,
    logLevel: EasyLogLevel.info,
    logFolder: '${Directory.current.path}/example/logs',
    logFileBackup: 3,
    logFileMaxBytes: 10 * 1024,
    pwd: '123',
    secret: EasySecurity.uuid.v4(),
    binary: true,
  );

  //sigint
  ProcessSignal.sigint.watch().listen((signal) {
    Easy.closeClusterServers().then((value) => exit(0));
  });
}

void httpServerEntryPoint(String environment, String cluster, EasyServer server, EasyUniDb? database) {
  final rootPath = '${Directory.current.path}/example';
  server.httpRoute('/login/<user>/<pwd>', (request, packet) async {
    return packet.responseOk(data: {'hello': 1, 'world': 2});
  });
  server.httpUpload('/upload', (request, packet, files) async {
    return packet.responseOk(data: {'hello': 1, 'upload': 2});
  }, destinationFolder: () => '$rootPath/upload');
  server.httpMount(
    '/',
    rootPath,
    listDirectories: true,
  );
}

void outerServerEntryPoint(String environment, String cluster, EasyServer server, EasyUniDb? database) {
  server.websocketRoute('enter', (session, packet) async {
    return packet.responseOk(data: {'aaa': 1, 'bbb': 2});
  });
  server.websocketRoute('leave', (session, packet) async {
    return packet.responseOk(data: {'ccc': 1, 'ddd': 2});
  });
  server.websocketRoute('datatime', (session, packet) async {
    return server.callRemoteForResult('inner', route: 'now');
  });
}

void innerServerEntryPoint(String environment, String cluster, EasyServer server, EasyUniDb? database) {
  server.websocketRemote('now', (session, packet) async {
    // return packet.responseOk(data: {'time': DateTime.now()});// error because of DateTime not implements toJson() method
    return packet.responseOk(data: {'time': DateTime.now().toString()});
  });
}

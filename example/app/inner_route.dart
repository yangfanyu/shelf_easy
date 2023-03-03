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

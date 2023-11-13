import 'dart:io';

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

    ///挂载静态目录
    server.mount('/', '${Directory.current.path}/app/web', listDirectories: false, defaultDocument: 'index.html');

    ///Asynchronous error test
    Future.delayed(Duration(seconds: 13), () {
      throw ('http async error');
    });
  }
}

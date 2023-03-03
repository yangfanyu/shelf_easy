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

import 'dart:io';

import 'package:shelf_easy/shelf_easy.dart';

import '../model/all.dart';

void main() async {
  final client = EasyClient(
    config: EasyClientConfig(
      logLevel: EasyLogLevel.debug,
      host: 'localhost',
      port: 8080,
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

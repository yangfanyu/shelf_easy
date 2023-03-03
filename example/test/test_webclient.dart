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

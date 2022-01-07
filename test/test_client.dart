import 'dart:io';

import 'package:http_parser/http_parser.dart';
import 'package:shelf_easy/shelf_easy.dart';

void main() async {
  final client = EasyClient(
    config: EasyClientConfig(
      logLevel: EasyLogLevel.trace,
      url: 'ws://127.0.0.1:8001/',
      pwd: '123',
      binary: true,
    ),
  );
  client.connect(onopen: () {
    //websocketRequest
    client.websocketRequest('enter', data: {});
    client.websocketRequest('leave', data: {});
    client.websocketRequest('datatime', data: {});
    //httpRequest
    client.httpRequest('http://127.0.0.1:8080/login/aaa/123', data: {'aaa': 1, 'bbb': 2});
    client.httpRequest('http://127.0.0.1:8080/login/user/bbb/ccc', data: {'aaa': 1, 'bbb': 2});
    //upload
    final filepath = '${Directory.current.path}/example/icon.png';
    client.httpRequest(
      'http://127.0.0.1:8080/upload',
      data: {'aaa': 1, 'bbb': 2},
      fileBytes: [
        File(filepath).readAsBytesSync(),
        File(filepath).readAsBytesSync(),
        File(filepath).readAsBytesSync(),
      ],
      mediaType: MediaType.parse('image/png'),
    );
  });

  //sigint
  ProcessSignal.sigint.watch().listen((signal) {
    client.destroy().then((value) => exit(0));
  });
}

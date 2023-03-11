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

  ///挂载根目录，并设置listDirectories启用文件夹浏览功能，生产环境建议关闭这个选项
  server.mount('/', rootPath, listDirectories: true);

  server.start();

  //sigint
  ProcessSignal.sigint.watch().listen((signal) {
    server.close().then((value) => exit(0));
  });
}

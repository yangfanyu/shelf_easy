import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_easy/shelf_easy.dart';
import 'package:shelf_router/shelf_router.dart';

void main() {
  //wssserver
  final wssServer = EasyServer(
    config: EasyServerConfig(
      host: InternetAddress.anyIPv4.host,
      port: 8080,
      pwd: '123',
      binary: true,
      heart: 30 * 1000,
    ),
  )..start();
  //webserver
  final webserver = EasyServer(
    config: EasyServerConfig(
      host: InternetAddress.anyIPv4.host,
      port: 8081,
    ),
  )..start(
      httpRouter: Router()
        ..get('/hello', (request) {
          return Response.ok('hello-world');
        })
        ..get('/user/<user>', (request, String user) {
          return Response.ok('hello $user');
        }),
    );
  //sigint
  ProcessSignal.sigint.watch().listen((signal) {
    wssServer.close(() => webserver.close(() => exit(0)));
  });
}

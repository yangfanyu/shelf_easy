import 'dart:io';

import 'package:shelf_easy/shelf_easy.dart';

void main() {
  final client = EasyClient(
    config: EasyClientConfig(
      url: 'ws://192.168.2.6:8080/',
      pwd: '123',
      binary: true,
      heartick: 30,
    ),
  );
  client.connect();

  //sigint
  ProcessSignal.sigint.watch().listen((signal) {
    client.destroy().then((value) => exit(0));
  });
}

// import 'package:http/http.dart' as http;

// main() async {
//   final response1 = await http.get(Uri.parse('http://192.168.2.6:8080/hello'));
//   print('Response status: ${response1.statusCode}');
//   print('Response body: ${response1.body}');
//   final response2 = await http.get(Uri.parse('http://192.168.2.6:8080/user/aaa'));
//   print('Response status: ${response2.statusCode}');
//   print('Response body: ${response2.body}');
// }

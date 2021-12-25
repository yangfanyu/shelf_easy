import 'dart:convert';
import 'package:shelf_easy/shelf_easy.dart';

void main() {
  testJson();
  testSecurity();
}

void testJson() {
  final secret = '123';
  print('--------------------------------------------------testJson');
  final packet1 = EasyPacket.request(route: 'test route', id: 10000, desc: '测试数据包', data: null);
  final encRes1 = jsonEncode(packet1);
  print('encRes1-> $encRes1');
  final desRes1 = EasyPacket.fromJson(jsonDecode(encRes1));
  print('desRes1-> $desRes1');

  final packet2 = EasyPacket.signature(secret, route: 'test route', code: 200, desc: 'test desc', data: packet1.toJson(), ucid: 'test ucid');
  final encRes2 = jsonEncode(packet2);
  print('encRes2-> $encRes2');
  final desRes2 = EasyPacket.fromJson(jsonDecode(encRes2));
  print('desRes2-> $desRes2 ${desRes2.isSignError(secret)}');
}

void testSecurity() {
  // final pwd = null;
  final pwd = '123';
  print('--------------------------------------------------testSecurity');
  final packet1 = EasyPacket.request(route: 'test route', id: 10000, desc: '测试数据包', data: null);

  final encRes1 = EasySecurity.encrypt(packet1, pwd, false);
  print('encRes1-> $encRes1 ${encRes1.length}');
  final desRes1 = EasySecurity.decrypt(encRes1, pwd);
  print('desRes1-> $desRes1');

  final encRes2 = EasySecurity.encrypt(packet1, pwd, true);
  print('encRes2-> $encRes2 ${encRes2.length}\n${String.fromCharCodes(encRes2)}');
  final desRes2 = EasySecurity.decrypt(encRes2, pwd);
  print('desRes1-> $desRes2');
}

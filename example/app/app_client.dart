import 'dart:io';

import 'package:shelf_easy/shelf_easy.dart';

void main(List<String> args) async {
  if (args.isEmpty) throw ('启动格式为: dart app/app_client.dart <port>');
  final port = args.first;
  switch (port) {
    case '8001':
      await userClient800X(port: 8001, uid: 'aaa', cid: 'cat'); //启动后加入到分组cat
      break;
    case '8002':
      await userClient800X(port: 8002, uid: 'bbb', cid: 'cat'); //启动后加入到分组cat
      break;
    case '8003':
      await userClient800X(port: 8003, uid: 'ccc', cid: 'dog'); //启动后加入到分组dog
      break;
    case '8080':
      await pushClient8080();
      break;
  }
}

///启动为长连接客户端
Future<void> userClient800X({required int port, required String uid, required String cid}) async {
  final client = EasyClient(
    config: EasyClientConfig(
      logTag: uid,
      logLevel: EasyLogLevel.debug,
      host: 'localhost',
      port: port,
      pwd: '12345678', //AES加密密码
      binary: true, //使用二进制发送AES数据包
    ),
  );
  //绑定推送监听
  client.addListener('onPushAll', (packet) => client.logWarn(['onPushAll =>', packet.data]));
  client.addListener('onPushGRP', (packet) => client.logWarn(['onPushGRP =>', packet.data]));
  client.addListener('onPushP2P', (packet) => client.logWarn(['onPushP2P =>', packet.data]));
  //连接服务器
  client.connect(
    onopen: () async {
      final result = await client.websocketRequest('enter', data: {'uid': uid});
      if (result.ok) {
        client.bindUser(uid, token: result.data!['token']); //绑定客户端uid与服务器返回的数据加密口令token
        await client.websocketRequest('joinTeam', data: {'cid': cid}); //加入分组
      }
    },
  );

  //sigint
  ProcessSignal.sigint.watch().listen((signal) {
    client.destroy().then((value) => exit(0));
  });
}

///启动为http客户端
Future<void> pushClient8080() async {
  final client = EasyClient(
    config: EasyClientConfig(
      logLevel: EasyLogLevel.debug,
      host: 'localhost',
      port: 8080,
      pwd: '12345678', //AES加密密码
      binary: true, //使用二进制发送AES数据包
    ),
  );

  final resp1 = await client.httpRequest('/webPushAll', data: {'type': 'all', 'body': 'Hello broadcast msg! '});
  client.logWarn(['resp1 =>', resp1.desc]);
  final resp2 = await client.httpRequest('/webPushGRP', data: {'type': 'grp', 'body': 'Hello channel msg!', 'toCid': 'cat'});
  client.logWarn(['resp2 =>', resp2.desc]);
  final resp3 = await client.httpRequest('/webPushP2P', data: {'type': 'p2p', 'body': 'Hello point to point msg!', 'toUid': 'aaa'});
  client.logWarn(['resp3 =>', resp3.desc]);
  final resp4 = await client.httpRequest('/webTimeNow');
  client.logWarn(['resp4 =>', resp4.data]);
}

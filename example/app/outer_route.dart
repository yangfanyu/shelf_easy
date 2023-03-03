import 'package:shelf_easy/shelf_easy.dart';

class OuterRoute {
  ///服务器
  final EasyServer server;

  final EasyUniDb database;

  OuterRoute(this.server, this.database);

  void start() {
    ///绑定uid
    server.websocketRoute('enter', (session, packet) async {
      final uid = packet.data!['uid'] as String; //读取用户id
      final token = EasySecurity.uuid.v4(); //生成随机的数据传输加密口令

      //延迟操作确保响应数据发送完成后再绑定会话信息
      Future.delayed(Duration.zero, () {
        server.bindUser(session, uid, token: token, closeold: true); //closeold参数为true表示踢掉本线程重复uid的连接
      });

      return packet.responseOk(data: {'uid': uid, 'token': token});
    });

    ///加入分组
    server.websocketRoute('joinTeam', (session, packet) async {
      final cid = packet.data!['cid'] as String; //读取分组id
      server.joinChannel(session, cid);
      return packet.responseOk();
    });

    ///退出分组
    server.websocketRoute('quitTeam', (session, packet) async {
      final cid = packet.data!['cid'] as String; //读取分组id
      server.quitChannel(session, cid);
      return packet.responseOk();
    });

    ///解绑uid
    server.websocketRoute('leave', (session, packet) async {
      //延迟操作确保响应数据发送完成后再解绑会话信息
      Future.delayed(Duration.zero, () {
        server.unbindUser(session);
      });

      return packet.responseOk();
    });

    //Asynchronous error test
    Future.delayed(Duration(seconds: 14), () {
      throw ('outer async error');
    });
  }
}

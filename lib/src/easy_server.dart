import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:http_parser/http_parser.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_multipart/multipart.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'easy_class.dart';
import 'easy_client.dart';

///websocket服务器心跳循环监听器
typedef ServerHeartListener = void Function(int totalSocket, int totalSession);

///websocket会话关闭监听器
typedef SessionCloseListener = void Function(EasyServerSession session, int? code, String? reason);

///http请求时，根据请求头easy-security-identity的值获取用户的token
typedef HttpTokenConverter = Future<String> Function(String identity);

///http路由处理方法
typedef HttpRouteHandler = Future<EasyPacket?> Function(Request request, EasyPacket packet);

///http上传处理方法
typedef HttpUploadHandler = Future<EasyPacket?> Function(Request request, EasyPacket packet, List<File> files);

///websocket路由处理方法
typedef WebsocketRouteHandler = Future<EasyPacket?> Function(EasyServerSession session, EasyPacket packet);

///websocket远程路由处理方法
typedef WebsocketMessageCustomer = Map<String, dynamic> Function(String? uid, Map<String, dynamic>? data);

///集群节点分配函数
typedef ClusterClientDispatcher = int Function(String cluster, String? ucid, Map<String, dynamic>? data);

///
///服务器
///
class EasyServer extends EasyLogger {
  ///配置信息
  final EasyServerConfig _config;

  ///集群连接客户端
  final Map<String, List<EasyClient>> _clusterClientMap;

  ///websocket路由方法
  final Map<String, WebsocketRouteHandler> _websocketRouteMap;

  ///websocket远程方法
  final Map<String, WebsocketRouteHandler> _websoketRemoteMap;

  ///全部websocket的session，每个websocket对应一个session, 包括未绑定用户信息的session
  final Map<int, EasyServerSession> _websoketMap;

  ///websocket已绑定用户信息的session
  final Map<String, EasyServerSession> _websoketSessionMap;

  ///websocket自定义消息推送组（如：聊天室、游戏房间等）
  final Map<String, Map<int, EasyServerSession>> _websoketChannelMap;

  ///websocket服务心跳循环的监听器
  ServerHeartListener? _serverHeartListener;

  ///websocket会话关闭的监听器
  SessionCloseListener? _sessionCloseListener;

  ///心跳计时器
  Timer? _ticker;

  ///http服务器
  HttpServer? _server;

  ///http请求路由
  Router? _router;

  ///读取配置信息
  EasyServerConfig get config => _config;

  EasyServer({required EasyServerConfig config})
      : _config = config,
        _clusterClientMap = {},
        _websocketRouteMap = {},
        _websoketRemoteMap = {},
        _websoketMap = {},
        _websoketSessionMap = {},
        _websoketChannelMap = {},
        super(
          logger: config.logger,
          logLevel: config.logLevel,
          logTag: config.logTag ?? '${config.host}:${config.port}',
          logFilePath: config.logFilePath,
          logFileBackup: config.logFileBackup,
          logFileMaxBytes: config.logFileMaxBytes,
        ) {
    if (_config.heart < 30 * 1000) throw ('_config.heart < 30 * 1000');
    if (_config.timeout < _config.heart * 2) throw ('_config.timeout < _config.heart * 2');
    if (_config.reqIdCache < 16) throw ('_config.reqIdCache < 16');
  }

  ///设置事件监听器
  void setListener({ServerHeartListener? serverHeartListener, SessionCloseListener? sessionCloseListener}) {
    _serverHeartListener = serverHeartListener;
    _sessionCloseListener = sessionCloseListener;
  }

  ///设置Http服务的动态请求路由，当设置过http路由时启动为web服务器。否则启动为websocket服务器
  void httpRoute(String route, HttpRouteHandler handler, {HttpTokenConverter? tokenConverter, Map<String, Object>? responseHeaders}) {
    _router ??= Router();
    _router?.post(route, (Request request) async {
      logTrace(['_onHttpRoute <=', request.headers]);
      //解析请求数据
      final requestData = _config.binary ? (await request.read().toList()).first : await request.readAsString();
      logTrace(['_onHttpRoute <=', requestData]);
      final requestUid = (request.headers['easy-security-identity'] ?? '').trim();
      final requestToken = (tokenConverter == null || requestUid.isEmpty) ? null : await tokenConverter(requestUid);
      final requestPacket = EasySecurity.decrypt(requestData, requestToken ?? _config.pwd);
      if (requestPacket == null) {
        return Response.internalServerError(headers: responseHeaders);
      }
      logDebug(['_onHttpRoute <<<<<<', requestPacket]);
      //路由响应数据
      final responsePacket = await handler(request, requestPacket) ?? requestPacket.responseOk();
      logDebug(['_onHttpRoute >>>>>>', responsePacket]);
      final responseData = EasySecurity.encrypt(responsePacket, requestToken ?? _config.pwd, _config.binary);
      if (responseData == null) {
        return Response.internalServerError(headers: responseHeaders);
      }
      logTrace(['_onHttpRoute =>', responseData]);
      return Response.ok(responseData, headers: {'content-type': _config.binary ? 'application/octet-stream' : 'text/plain'}..addAll(responseHeaders ?? {}));
    });
  }

  ///设置Http服务的文件上传路由，当设置过http路由时启动为web服务器。否则启动为websocket服务器
  void httpUpload(String route, HttpUploadHandler handler, {required String Function() destinationFolder, String defaultMediatype = 'application/octet-stream', HttpTokenConverter? tokenConverter, Map<String, Object>? responseHeaders}) {
    _router ??= Router();
    _router?.post(route, (Request request) async {
      logTrace(['_onHttpUpload <=', request.headers]);
      //读取表单数据
      final requestBytesList = <List<int>>[];
      final requestMediaTypes = <MediaType>[];
      await for (final part in request.parts) {
        requestBytesList.add(await part.readBytes());
        requestMediaTypes.add(MediaType.parse(part.headers['content-type'] ?? defaultMediatype));
      }
      logTrace(['_onHttpUpload <=', requestBytesList.first]);
      //解析请求数据
      final requestUid = (request.headers['easy-security-identity'] ?? '').trim();
      final requestToken = (tokenConverter == null || requestUid.isEmpty) ? null : await tokenConverter(requestUid);
      final requestPacket = EasySecurity.decrypt(requestBytesList.first, requestToken ?? _config.pwd);
      final requestFiles = <File>[];
      for (var i = 1; i < requestBytesList.length; i++) {
        final file = File('${destinationFolder()}/${EasySecurity.uuid.v4()}.${requestMediaTypes[i].subtype}')
          ..createSync(recursive: true) //同步创建
          ..writeAsBytesSync(requestBytesList[i]); //同步写入
        requestFiles.add(file);
      }
      if (requestPacket == null) {
        return Response.internalServerError(headers: responseHeaders);
      }
      logDebug(['_onHttpUpload <<<<<<', requestPacket, '\n', requestFiles]);
      //路由响应数据
      final responsePacket = await handler(request, requestPacket, requestFiles) ?? requestPacket.responseOk();
      logDebug(['_onHttpUpload >>>>>>', responsePacket]);
      final responseData = EasySecurity.encrypt(responsePacket, requestToken ?? _config.pwd, _config.binary);
      if (responseData == null) {
        return Response.internalServerError(headers: responseHeaders);
      }
      logTrace(['_onHttpUpload =>', responseData]);
      return Response.ok(responseData, headers: {'content-type': _config.binary ? 'application/octet-stream' : 'text/plain'}..addAll(responseHeaders ?? {}));
    });
  }

  ///设置Http服务的静态文件路由，当设置过http路由时启动为web服务器。否则启动为websocket服务器
  void httpMount(String route, String path, {bool serveFilesOutsidePath = false, String? defaultDocument, bool listDirectories = false, bool useHeaderBytesForContentType = false}) {
    _router ??= Router();
    _router?.mount(
      route,
      createStaticHandler(
        path,
        serveFilesOutsidePath: serveFilesOutsidePath,
        defaultDocument: defaultDocument,
        listDirectories: listDirectories,
        useHeaderBytesForContentType: useHeaderBytesForContentType,
      ),
    );
  }

  ///设置Websocket服务的路由监听器
  void websocketRoute(String route, WebsocketRouteHandler handler) => _websocketRouteMap[route] = handler;

  ///设置Websocket服务的远程监听器
  void websocketRemote(String route, WebsocketRouteHandler handler) => _websoketRemoteMap[route] = handler;

  ///绑定用户信息到session。[token]是数据加解密密钥，为null时，使用[EasyServerConfig.pwd]进行加解密
  void bindUser(EasyServerSession session, String uid, {required String? token, bool closeold = false}) {
    //旧session处理
    final sessionOld = _websoketSessionMap[uid];
    if (sessionOld != null) {
      unbindUser(sessionOld); //解绑uid对应的旧session（此步骤务必在close之前执行，否则close异步事件中，会将uid对应的新session移除掉）
      if (closeold) sessionOld.close(EasyConstant.serverCloseByNewbindError.code, EasyConstant.serverCloseByNewbindError.desc); //关闭旧的session
    }
    //新session处理
    unbindUser(session); //新session解绑旧的用户信息
    session.bindUser(uid, token: token); //新session绑定新的用户信息
    _websoketSessionMap[uid] = session; //新session绑定到_websoketSessionMap
    logDebug(['bindUser =>', session.info]);
  }

  ///解绑session的用户信息
  void unbindUser(EasyServerSession session) {
    if (!session.isBinded()) return;
    logDebug(['unbindUser =>', session.info]);
    _websoketSessionMap.remove(session.uid); //从_websoketSessionMap中移除
    session.unbindUser(); //在从_websoketSessionMap中移除后调用
  }

  ///加入本节点的某个消息推送组
  void joinChannel(EasyServerSession session, String cid) {
    final channel = _websoketChannelMap[cid] ?? {};
    channel[session.id] = session;
    session.joinChannel(cid);
    _websoketChannelMap[cid] = channel;
    logDebug(['joinChannel =>', session.info, cid]);
  }

  ///退出本节点的某个消息推送组
  void quitChannel(EasyServerSession session, String cid) {
    final channel = _websoketChannelMap[cid];
    if (channel == null) return;
    channel.remove(session.id);
    session.quitChannel(cid);
    if (channel.isEmpty) _websoketChannelMap.remove(cid);
    logDebug(['quitChannel =>', session.info, cid]);
  }

  ///删除本节点的某个消息推送组
  void deleteChannel(String cid) {
    final channel = _websoketChannelMap[cid];
    if (channel == null) return;
    channel.forEach((id, session) => session.quitChannel(cid));
    _websoketChannelMap.remove(cid);
    logDebug(['deleteChannel =>', cid]);
  }

  ///推送初始化消息到本节点的指定session
  void pushInitiate(EasyServerSession session) {
    final packet = EasyPacket.pushdata(route: EasyConstant.routeInitiate, data: null);
    logDebug(['pushInitiate >>>>>>', session.info, packet]);
    session.send(EasySecurity.encrypt(packet, session.token ?? _config.pwd, _config.binary));
  }

  ///推送心跳包消息到本节点的指定session
  void pushHeartick(EasyServerSession session, EasyPacket heartick) {
    final packet = EasyPacket.pushresp(route: EasyConstant.routeHeartick, id: heartick.id, code: heartick.code, desc: heartick.desc, data: heartick.data);
    logTrace(['pushHeartick >>>>>>', session.info, packet]);
    session.send(EasySecurity.encrypt(packet, session.token ?? _config.pwd, _config.binary));
  }

  ///响应本节点的某个session的请求
  void pushResponse(EasyServerSession session, EasyPacket request, {required EasyPacket response}) {
    final packet = EasyPacket.pushresp(route: EasyConstant.routeResponse, id: request.id, code: response.code, desc: response.desc, data: response.data);
    logDebug(['pushResponse >>>>>>', session.info, packet]);
    session.send(EasySecurity.encrypt(packet, session.token ?? _config.pwd, _config.binary));
  }

  ///推送消息到本节点的某个session
  void pushSession(String uid, {required String route, Map<String, dynamic>? data}) {
    final session = _websoketSessionMap[uid];
    if (session == null) return;
    final packet = EasyPacket.pushdata(route: route, data: data);
    logDebug(['pushSession >>>>>>', session.info, packet]);
    session.send(EasySecurity.encrypt(packet, session.token ?? _config.pwd, _config.binary));
  }

  ///推送消息到本节点的某批session
  void pushSessionBatch(List<String> uids, {required String route, Map<String, dynamic>? data}) {
    final packet = EasyPacket.pushdata(route: route, data: data);
    logDebug(['pushSessionBatch >>>>>>', uids, packet]);
    for (var uid in uids) {
      final session = _websoketSessionMap[uid];
      if (session != null) {
        session.send(EasySecurity.encrypt(packet, session.token ?? _config.pwd, _config.binary));
      }
    }
  }

  ///推送消息到本节点的某个消息推送组
  void pushChannel(String cid, {required String route, Map<String, dynamic>? data}) {
    final channel = _websoketChannelMap[cid];
    if (channel == null) return;
    final packet = EasyPacket.pushdata(route: route, data: data);
    logDebug(['pushChannel >>>>>>', cid, packet]);
    channel.forEach((id, session) {
      session.send(EasySecurity.encrypt(packet, session.token ?? _config.pwd, _config.binary));
    });
  }

  ///推送消息到本节点的某个消息推送组，每个成员的数据都进过差异处理
  void pushChannelCustom(String cid, {required String route, Map<String, dynamic>? data, required WebsocketMessageCustomer customer}) {
    final channel = _websoketChannelMap[cid];
    if (channel == null) return;
    channel.forEach((id, session) {
      final packet = EasyPacket.pushdata(route: route, data: customer(session.uid, data));
      logDebug(['pushChannelCustom >>>>>>', cid, packet]);
      session.send(EasySecurity.encrypt(packet, session.token ?? _config.pwd, _config.binary));
    });
  }

  ///推送消息到本节点的session，[binded]为true时只推送给已经绑定过用户信息的session，[binded]为false时推送到所有的session
  void broadcast({required String route, Map<String, dynamic>? data, bool binded = true}) {
    final packet = EasyPacket.pushdata(route: route, data: data);
    logDebug(['broadcast >>>>>>', binded, packet]);
    if (binded) {
      _websoketSessionMap.forEach((uid, session) {
        session.send(EasySecurity.encrypt(packet, session.token ?? _config.pwd, _config.binary));
      });
    } else {
      _websoketMap.forEach((id, session) {
        session.send(EasySecurity.encrypt(packet, session.token ?? _config.pwd, _config.binary));
      });
    }
  }

  ///推送消息到集群的某个session，[dispatcher]为null时，对该集群的全部节点进行遍历发送
  void pushClusterSession(String cluster, {required String route, Map<String, dynamic>? data, required String ucid, ClusterClientDispatcher? dispatcher}) {
    final clientList = _clusterClientMap[cluster];
    if (clientList == null) return;
    final packet = EasyPacket.pushsign(_config.secret, route: route, data: data, ucid: ucid);
    if (dispatcher != null) {
      final client = clientList[dispatcher(cluster, ucid, data)];
      logDebug(['pushClusterSession >>>>>>', cluster, client.url, packet]);
      client.websocketRequest(EasyConstant.routeInnerP2P, data: packet.toJson(), waitCompleter: false);
    } else {
      for (var client in clientList) {
        logDebug(['pushClusterSession >>>>>>', cluster, client.url, packet]);
        client.websocketRequest(EasyConstant.routeInnerP2P, data: packet.toJson(), waitCompleter: false);
      }
    }
  }

  ///推送消息到集群的某个消息推送组，[dispatcher]为null时，对该集群的全部节点进行遍历发送
  void pushClusterChannel(String cluster, {required String route, Map<String, dynamic>? data, required String ucid, ClusterClientDispatcher? dispatcher}) {
    final clientList = _clusterClientMap[cluster];
    if (clientList == null) return;
    final packet = EasyPacket.pushsign(_config.secret, route: route, data: data, ucid: ucid);
    if (dispatcher != null) {
      final client = clientList[dispatcher(cluster, ucid, data)];
      logDebug(['pushClusterChannel >>>>>>', cluster, client.url, packet]);
      client.websocketRequest(EasyConstant.routeInnerGRP, data: packet.toJson(), waitCompleter: false);
    } else {
      for (var client in clientList) {
        logDebug(['pushClusterChannel >>>>>>', cluster, client.url, packet]);
        client.websocketRequest(EasyConstant.routeInnerGRP, data: packet.toJson(), waitCompleter: false);
      }
    }
  }

  ///推送消息到集群的session，对该集群的全部节点进行遍历发送，[binded]为true时只推送给已经绑定过用户信息的session，[binded]为false时推送到所有的session
  void clusterBroadcast(String cluster, {required String route, Map<String, dynamic>? data, bool binded = true}) {
    final clientList = _clusterClientMap[cluster];
    if (clientList == null) return;
    final packet = EasyPacket.pushsign(_config.secret, route: route, data: data, ucid: binded.toString());
    for (var client in clientList) {
      logDebug(['clusterBroadcast >>>>>>', cluster, client.url, packet]);
      client.websocketRequest(EasyConstant.routeInnerALL, data: packet.toJson(), waitCompleter: false);
    }
  }

  ///集群节点间远程路由异步调用，[dispatcher]为null时，从该集群的全部节点中随机选择一个节点
  void callRemote(String cluster, {required String route, Map<String, dynamic>? data, String? ucid, ClusterClientDispatcher? dispatcher}) {
    final clientList = _clusterClientMap[cluster];
    if (clientList == null) return;
    final packet = EasyPacket.pushsign(_config.secret, route: route, data: data, ucid: ucid);
    final client = clientList[dispatcher == null ? Random().nextInt(clientList.length) : dispatcher(cluster, ucid, data)];
    logDebug(['callRemote >>>>>>', cluster, client.url, packet]);
    client.websocketRequest(EasyConstant.routeInnerRMC, data: packet.toJson(), waitCompleter: false);
  }

  ///集群节点间远程路由异步调用，并返回结果，[dispatcher]为null时，从该集群的全部节点中随机选择一个节点
  Future<EasyPacket> callRemoteForResult(String cluster, {required String route, Map<String, dynamic>? data, String? ucid, ClusterClientDispatcher? dispatcher}) {
    final clientList = _clusterClientMap[cluster];
    if (clientList == null) return Future.value(EasyConstant.serverCloseBySocketError);
    final packet = EasyPacket.pushsign(_config.secret, route: route, data: data, ucid: ucid);
    final client = clientList[dispatcher == null ? Random().nextInt(clientList.length) : dispatcher(cluster, ucid, data)];
    logDebug(['callRemoteForResult >>>>>>', cluster, client.url, packet]);
    return client.websocketRequest(EasyConstant.routeInnerRMC, data: packet.toJson(), waitCompleter: true);
  }

  ///开启服务器，当设置过http路由时启动为web服务器。否则启动为websocket服务器
  Future<void> start() {
    final completer = Completer();
    //创建关联的集群节点
    _config.clusterConfigs.forEach((cluster, serverList) {
      final clientList = <EasyClient>[];
      for (var server in serverList) {
        clientList.add(EasyClient(
          config: EasyClientConfig(
            logger: _config.logger,
            logLevel: _config.logLevel,
            logTag: '$logTag [${server.websocketUrl}]',
            logFilePath: _config.logFilePath,
            logFileBackup: _config.logFileBackup,
            logFileMaxBytes: _config.logFileMaxBytes,
            url: server.websocketUrl,
            pwd: server.pwd,
            binary: server.binary,
            heartick: (server.heart / 1000).floor(),
            conntick: 3,
          ),
        ));
      }
      if (clientList.isNotEmpty) {
        _clusterClientMap[cluster] = clientList;
      }
    });
    //处理器
    final handler = _httpRequestLogger().addHandler((request) {
      if (_router != null) {
        return _router!(request);
      } else {
        return webSocketHandler((WebSocketChannel websocket) => _onWebSocketConnect(websocket, request))(request);
      }
    });
    final securityContext = _config.sslsEnable
        ? (SecurityContext()
          ..usePrivateKey(_config.sslKeyFile!)
          ..useCertificateChain(_config.sslCerFile!))
        : null;
    serve(handler, _config.host, _config.port, securityContext: securityContext, shared: _config.instances > 1).then((server) {
      if (_router != null) {
        logInfo(['web server is listening...']);
      } else {
        logInfo(['websocket server is listening...']);
      }
      //保存http服务器实例
      _server = server;
      //连接关联的集群节点
      _clusterClientMap.forEach((cluster, clientList) {
        for (var client in clientList) {
          client.connect(now: false);
        }
      });
      //开启心跳循环
      if (_router == null) {
        _ticker = Timer.periodic(Duration(milliseconds: _config.heart), (timer) => _onServerHeart());
      }
      //启动完成
      completer.complete();
    });
    return completer.future;
  }

  ///关闭服务器
  Future<void> close() async {
    final completer = Completer();
    //销毁心跳循环
    _ticker?.cancel();
    _ticker = null;
    //断开集群连接
    final allClientList = <EasyClient>[];
    _clusterClientMap.forEach((cluster, clientList) => allClientList.addAll(clientList));
    for (var client in allClientList) {
      await client.destroy();
    }
    //关闭server
    _server?.close(force: true).then((value) {
      if (_router != null) {
        logInfo(['web server was closed.']);
      } else {
        logInfo(['websocket server was closed.']);
      }
      //释放http服务器实例
      _server = null;
      //关闭完成
      completer.complete();
    });
    return completer.future;
  }

  ///获取请求的ip地址
  String getRequestIp(Request request) {
    try {
      logTrace(['getRequestIp =>', request.headers]);
      return request.headers[_config.ipHeader] ?? (request.context['shelf.io.connection_info'] as HttpConnectionInfo?)?.remoteAddress.address ?? '0.0.0.0';
    } catch (error, stack) {
      logError(['getRequestIp =>', error, '\n', stack]);
      return '0.0.0.0';
    }
  }

  void _onServerHeart() {
    _websoketMap.forEach((id, session) {
      if (session.isExpired(_config.timeout)) {
        session.close(EasyConstant.serverCloseByTimeoutError.code, EasyConstant.serverCloseByTimeoutError.desc); //清除超时的链接
      }
    });
    logInfo(['_onServerHeart => total', _websoketMap.length, 'socket, total', _websoketSessionMap.length, 'session']);
    //回调上层绑定的监听器
    if (_serverHeartListener != null) _serverHeartListener!(_websoketMap.length, _websoketSessionMap.length);
  }

  void _onWebSocketConnect(WebSocketChannel websocket, Request request) {
    final session = EasyServerSession(socket: websocket, ip: getRequestIp(request));
    _websoketMap[session.id] = session; //绑定到_socketMap
    websocket.stream.listen((data) {
      logTrace(['_onWebSocketData <=', session.info, data]);
      _onWebSocketMessage(session, data);
    }, onError: (Object error, StackTrace stack) {
      logError(['_onWebSocketError =>', session.info, error, '\n', stack]);
      session.close(EasyConstant.serverCloseBySocketError.code, EasyConstant.serverCloseBySocketError.desc);
    }, onDone: () {
      logDebug(['_onWebSocketDone =>', session.info, session.closeCode, session.closeReason]);
      //回调上层绑定的监听器
      if (_sessionCloseListener != null) _sessionCloseListener!(session, session.closeCode, session.closeReason);
      //统一进行内存清理操作
      session.eachChannel((cid) => {quitChannel(session, cid)}); //退出已加入的所有分组
      unbindUser(session); //可能已经绑定了用户信息，需要进行解绑操作
      _websoketMap.remove(session.id); //从_socketMap中移除
    }, cancelOnError: false);
    logDebug(['_onWebSocketOpen =>', session.info]);
    pushInitiate(session);
  }

  void _onWebSocketMessage(EasyServerSession session, dynamic data) {
    final watch = Stopwatch()..start();
    final packet = EasySecurity.decrypt(data, session.token ?? _config.pwd);
    //解析数据包
    if (packet == null) {
      logError(['_onWebSocketMessage <<<<<<', session.info, EasyConstant.serverCloseByParseError.codeDesc, packet]);
      session.close(EasyConstant.serverCloseByParseError.code, EasyConstant.serverCloseByParseError.desc);
      return;
    }
    //校验重复包
    if (session.isRepeat(packet.id, _config.reqIdCache)) {
      logError(['_onWebSocketMessage <<<<<<', session.info, EasyConstant.serverCloseByRepeatError.codeDesc, packet]);
      session.close(EasyConstant.serverCloseByRepeatError.code, EasyConstant.serverCloseByRepeatError.desc);
      return;
    }
    //收到心跳包
    if (packet.route == EasyConstant.routeHeartick) {
      logTrace(['_onWebSocketMessage <<<<<<', session.info, packet]);
      session.heartick(); //更新本次心跳时间戳
      pushHeartick(session, packet); //反馈心跳包
      return;
    }
    //集群内部包
    if (packet.route == EasyConstant.routeInnerP2P || packet.route == EasyConstant.routeInnerGRP || packet.route == EasyConstant.routeInnerALL || packet.route == EasyConstant.routeInnerRMC) {
      try {
        //校验子数据包签名
        final child = EasyPacket.fromJson(packet.data!);
        if (child.isSignError(_config.secret)) {
          logError(['_onWebSocketMessage <<<<<<', session.info, EasyConstant.serverCloseBySignatureError.codeDesc, packet]);
          session.close(EasyConstant.serverCloseBySignatureError.code, EasyConstant.serverCloseBySignatureError.desc);
          return;
        }
        //集群P2P包
        if (packet.route == EasyConstant.routeInnerP2P) {
          logDebug(['_onWebSocketMessage <<<<<<', session.info, packet]);
          pushSession(child.ucid!, route: child.route, data: child.data);
          return;
        }
        //集群GRP包
        if (packet.route == EasyConstant.routeInnerGRP) {
          logDebug(['_onWebSocketMessage <<<<<<', session.info, packet]);
          pushChannel(child.ucid!, route: child.route, data: child.data);
          return;
        }
        //集群ALL包
        if (packet.route == EasyConstant.routeInnerALL) {
          logDebug(['_onWebSocketMessage <<<<<<', session.info, packet]);
          broadcast(route: child.route, data: child.data, binded: child.ucid! == 'true');
          return;
        }
        //集群RMC包
        final remote = _websoketRemoteMap[child.route];
        if (remote == null) {
          logError(['_onWebSocketMessage <<<<<<', session.info, EasyConstant.serverCloseByRemoteNotRound.codeDesc, packet]);
          session.close(EasyConstant.serverCloseByRemoteNotRound.code, EasyConstant.serverCloseByRemoteNotRound.desc);
          return;
        } else {
          logDebug(['_onWebSocketMessage <<<<<<', session.info, packet]);
          remote(session, child).then((response) {
            if (response == null) {
              logInfo(['_onWebSocketRequest =>', session.info, 'REMOTE', watch.elapsed, child.route]);
            } else {
              pushResponse(session, packet, response: response);
              logInfo(['_onWebSocketRequest =>', session.info, 'REMOTE', response.code, watch.elapsed, child.route]);
            }
          });
          return;
        }
      } catch (error, stack) {
        logError(['_onWebSocketMessage <<<<<<', session.info, EasyConstant.serverCloseByParseError.codeDesc, packet, error, '\n', stack]);
        session.close(EasyConstant.serverCloseByParseError.code, EasyConstant.serverCloseByParseError.desc);
        return;
      }
    }
    //自定义路由
    final route = _websocketRouteMap[packet.route];
    if (route == null) {
      logError(['_onWebSocketMessage <<<<<<', session.info, EasyConstant.serverCloseByRouteNotFound.codeDesc, packet]);
      session.close(EasyConstant.serverCloseByRouteNotFound.code, EasyConstant.serverCloseByRouteNotFound.desc);
      return;
    } else {
      logDebug(['_onWebSocketMessage <<<<<<', session.info, packet]);
      route(session, packet).then((response) {
        if (response == null) {
          logInfo(['_onWebSocketRequest =>', session.info, 'ROUTE', watch.elapsed, packet.route]);
        } else {
          pushResponse(session, packet, response: response);
          logInfo(['_onWebSocketRequest =>', session.info, 'ROUTE', response.code, watch.elapsed, packet.route]);
        }
      });
      return;
    }
  }

  Middleware _httpRequestLogger() {
    return (innerHandler) {
      return (request) {
        final watch = Stopwatch()..start();
        String requestUid = (request.headers['easy-security-identity'] ?? '').trim();
        requestUid = requestUid.isEmpty ? 'uid' : requestUid;
        return Future.sync(() => innerHandler(request)).then((response) {
          logInfo(['_onHttpRequest =>', '[${getRequestIp(request)} $requestUid]', request.method, response.statusCode, watch.elapsed, request.requestedUri.path, request.requestedUri.query]);
          return response;
        }, onError: (Object error, StackTrace stack) {
          if (error is HijackException) throw error; //这一行不能去掉，否则启动时报错
          logError(['_onHttpRequest =>', '[${getRequestIp(request)}] $requestUid', request.method, watch.elapsed, request.requestedUri.path, request.requestedUri.query, error, '\n', stack]);
          throw error;
        });
      };
    };
  }
}

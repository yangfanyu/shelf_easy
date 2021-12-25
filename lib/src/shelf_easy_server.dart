import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_easy/src/shelf_easy_client.dart';
import 'package:shelf_easy/src/shelf_easy_object.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef HeartListener = void Function(int totalSocket, int totalSession);
typedef CloseListener = void Function(EasyServerSession session, int? code, String? reason);
typedef Methodhandler = void Function(EasyServerSession session, EasyPacket packet);
typedef ChannelMessageCustomer = Map<String, dynamic> Function(String? uid, Map<String, dynamic>? data);
typedef ClusterClientDispatcher = int Function(String cluster, EasyPacket packet);

///
///服务器
///
class EasyServer extends EasyLogger {
  ///配置信息
  final EasyServerConfig _config;

  ///集群连接器集合
  final Map<String, List<EasyClient>> _clusterMap;

  ///路由监听器集合
  final Map<String, Methodhandler> _routeMap;

  ///远程监听器集合
  final Map<String, Methodhandler> _remoteMap;

  ///全部session集合，包括未绑定uid的session。（每个websocket连接对应一个session）
  final Map<int, EasyServerSession> _socketMap;

  ///已绑定uid的session集合
  final Map<String, EasyServerSession> _sessionMap;

  ///自定义消息推送组（如：聊天室、游戏房间等）
  final Map<String, Map<int, EasyServerSession>> _channelMap;

  ///心跳循环的监听器
  HeartListener? _heartListener;

  ///会话关闭的监听器
  CloseListener? _closeListener;

  ///心跳计时器
  Timer? _ticker;

  ///http服务器
  HttpServer? _server;

  EasyServer({required EasyServerConfig config, void Function(String msg, EasyLogLevel logLevel) logger = EasyLogger.defaultLogger})
      : assert(config.heart >= 30 * 1000),
        assert(config.timeout >= config.heart * 2),
        _config = config,
        _clusterMap = {},
        _routeMap = {},
        _remoteMap = {},
        _socketMap = {},
        _sessionMap = {},
        _channelMap = {},
        super(config.logLevel, config.logTag ?? '${config.host}:${config.port}', logger);

  ///初始化集群
  void initCluster() {
    _config.links.forEach((cluster, urlList) {
      final clientList = <EasyClient>[];
      for (var url in urlList) {
        clientList.add(EasyClient(
          config: EasyClientConfig(
            url: url,
            pwd: _config.pwd,
            binary: _config.binary,
            heartick: (_config.heart / 1000).floor(),
            logLevel: _config.logLevel,
          ),
          logger: EasyLogger.defaultLogger,
        ));
      }
      if (clientList.isNotEmpty) {
        _clusterMap[cluster] = clientList;
      }
    });
  }

  ///设置监听器
  void setListener(HeartListener heartListener, CloseListener closeListener) {
    _heartListener = heartListener;
    _closeListener = closeListener;
  }

  ///设置路由监听器
  void setRoute(String route, Methodhandler listener) => _routeMap[route] = listener;

  ///设置远程监听器
  void setRemote(String route, Methodhandler listener) => _remoteMap[route] = listener;

  ///根据uid从本节点获取session
  EasyServerSession? getSession(String uid) => _sessionMap[uid];

  ///绑定uid到session
  void bindUid(EasyServerSession session, String uid, {required String? token, bool closeold = false}) {
    //旧session处理
    final sessionold = _sessionMap[uid];
    if (sessionold != null) {
      unbindUid(sessionold); //解绑uid对应的旧session（此步骤务必在close之前执行，否则close事件中，会将uid对应的新session移除掉）
      if (closeold) sessionold.close(EasyConstant.newbindError.code, EasyConstant.newbindError.desc); //关闭旧的session
    }
    //新session处理
    unbindUid(session); //新session解绑旧的uid
    session.bindUid(uid, token: token); //新session绑定新的的uid
    _sessionMap[uid] = session; //新session绑定到_sessionMap
    logDebug('bindUid: ${session.info}');
  }

  ///解绑session的uid
  void unbindUid(EasyServerSession session) {
    if (!session.isBinded()) return;
    logDebug('unbindUid: ${session.info}');
    _sessionMap.remove(session.uid); //从_sessionMap中移除
    session.unbindUid();
  }

  ///加入本节点的某个消息推送组
  void joinChannel(EasyServerSession session, String cid) {
    final channel = _channelMap[cid] ?? {};
    channel[session.id] = session;
    _channelMap[cid] = channel;
    session.joinChannel(cid);
    logDebug('joinChannel: ${session.info} $cid');
  }

  ///退出本节点的某个消息推送组
  void quitChannel(EasyServerSession session, String cid) {
    final channel = _channelMap[cid];
    if (channel == null) return;
    channel.remove(session.id);
    if (channel.isEmpty) _channelMap.remove(cid);
    session.quitChannel(cid);
    logDebug('quitChannel: ${session.info} $cid');
  }

  ///删除本节点的某个消息推送组
  void deleteChannel(String cid) {
    final channel = _channelMap[cid];
    if (channel == null) return;
    channel.forEach((key, session) {
      session.quitChannel(cid);
    });
    _channelMap.remove(cid);
    logDebug('deleteChannel: $cid');
  }

  ///响应本节点的某个session的请求
  void response(EasyServerSession session, EasyPacket request, {int code = 200, String desc = 'ok', Map<String, dynamic>? data, bool heartick = false}) {
    if (heartick) {
      final packet = EasyPacket.response(route: EasyConstant.routeHeartick, id: request.id, code: request.code, desc: request.desc, data: request.data);
      session.send(EasySecurity.encrypt(packet, session.token ?? _config.pwd, _config.binary));
      logTrace('heartick: ${session.info} $packet');
    } else {
      final packet = EasyPacket.response(route: EasyConstant.routeResponse, id: request.id, code: code, desc: desc, data: data);
      session.send(EasySecurity.encrypt(packet, session.token ?? _config.pwd, _config.binary));
      logDebug('response: ${session.info} $packet');
    }
  }

  ///推送消息到本节点的某个session
  void pushSession(String uid, {required String route, int code = 200, String desc = 'ok', Map<String, dynamic>? data}) {
    final session = _sessionMap[uid];
    if (session == null) return;
    final packet = EasyPacket.pushdata(route: route, code: code, desc: desc, data: data);
    session.send(EasySecurity.encrypt(packet, session.token ?? _config.pwd, _config.binary));
    logDebug('pushSession: ${session.info} $packet');
  }

  ///推送消息到本节点的某批session
  void pushSessionBatch(List<String> uids, {required String route, int code = 200, String desc = 'ok', Map<String, dynamic>? data}) {
    final packet = EasyPacket.pushdata(route: route, code: code, desc: desc, data: data);
    for (var uid in uids) {
      final session = _sessionMap[uid];
      if (session != null) {
        session.send(EasySecurity.encrypt(packet, session.token ?? _config.pwd, _config.binary));
      }
    }
    logDebug('pushSessionBatch: $uids $packet');
  }

  ///推送消息到本节点的某个消息推送组
  void pushChannel(String cid, {required String route, int code = 200, String desc = 'ok', Map<String, dynamic>? data}) {
    final channel = _channelMap[cid];
    if (channel == null) return;
    final packet = EasyPacket.pushdata(route: route, code: code, desc: desc, data: data);
    channel.forEach((key, session) {
      session.send(EasySecurity.encrypt(packet, session.token ?? _config.pwd, _config.binary));
    });
    logDebug('pushChannel: $cid $packet');
  }

  ///推送消息到本节点的某个消息推送组，每个成员的数据都进过差异处理
  void pushChannelCustom(String cid, {required String route, int code = 200, String desc = 'ok', Map<String, dynamic>? data, required ChannelMessageCustomer customer}) {
    final channel = _channelMap[cid];
    if (channel == null) return;
    channel.forEach((key, session) {
      final packet = EasyPacket.pushdata(route: route, code: code, desc: desc, data: customer(session.uid, data));
      session.send(EasySecurity.encrypt(packet, session.token ?? _config.pwd, _config.binary));
      logDebug('pushChannelCustom: $cid $packet');
    });
  }

  ///推送消息到本节点的session，[binded]为true时只推送给已经绑定过uid的session，[binded]为false时推送到所有的session
  void broadcast({required String route, int code = 200, String desc = 'ok', Map<String, dynamic>? data, bool binded = true}) {
    final packet = EasyPacket.pushdata(route: route, code: code, desc: desc, data: data);
    if (binded) {
      _sessionMap.forEach((key, session) {
        session.send(EasySecurity.encrypt(packet, session.token ?? _config.pwd, _config.binary));
      });
    } else {
      _socketMap.forEach((key, session) {
        session.send(EasySecurity.encrypt(packet, session.token ?? _config.pwd, _config.binary));
      });
    }
    logDebug('broadcast: $binded $packet ');
  }

  ///推送消息到集群的某个session，[dispatcher]为null时，对该集群的全部节点进行遍历发送
  void pushClusterSession(String cluster, {required String route, int code = 200, String desc = 'ok', Map<String, dynamic>? data, required String ucid, ClusterClientDispatcher? dispatcher}) {
    final clientList = _clusterMap[cluster];
    if (clientList == null) return;
    final packet = EasyPacket.signature(_config.secret, route: route, code: code, desc: desc, data: data, ucid: ucid);
    if (dispatcher != null) {
      final client = clientList[dispatcher(cluster, packet)];
      client.request(EasyConstant.routeInnerP2P, data: packet.toJson());
      logDebug('pushClusterSession: $cluster ${client.url} $packet ');
    } else {
      for (var client in clientList) {
        client.request(EasyConstant.routeInnerP2P, data: packet.toJson());
        logDebug('pushClusterSession: $cluster ${client.url} $packet ');
      }
    }
  }

  ///推送消息到集群的某个消息推送组，[dispatcher]为null时，对该集群的全部节点进行遍历发送
  void pushClusterChannel(String cluster, {required String route, int code = 200, String desc = 'ok', Map<String, dynamic>? data, required String ucid, ClusterClientDispatcher? dispatcher}) {
    final clientList = _clusterMap[cluster];
    if (clientList == null) return;
    final packet = EasyPacket.signature(_config.secret, route: route, code: code, desc: desc, data: data, ucid: ucid);
    if (dispatcher != null) {
      final client = clientList[dispatcher(cluster, packet)];
      client.request(EasyConstant.routeInnerGRP, data: packet.toJson());
      logDebug('pushClusterChannel: $cluster ${client.url} $packet ');
    } else {
      for (var client in clientList) {
        client.request(EasyConstant.routeInnerGRP, data: packet.toJson());
        logDebug('pushClusterChannel: $cluster ${client.url} $packet ');
      }
    }
  }

  ///推送消息到集群的session，对该集群的全部节点进行遍历发送，[binded]为true时只推送给已经绑定过uid的session，[binded]为false时推送到所有的session
  void clusterBroadcast(String cluster, {required String route, int code = 200, String desc = 'ok', Map<String, dynamic>? data, bool binded = true}) {
    final clientList = _clusterMap[cluster];
    if (clientList == null) return;
    final packet = EasyPacket.signature(_config.secret, route: route, code: code, desc: desc, data: data, ucid: binded.toString());
    for (var client in clientList) {
      client.request(EasyConstant.routeInnerALL, data: packet.toJson());
      logDebug('pushClusterChannel: $cluster ${client.url} $packet ');
    }
  }

  ///集群节点间远程路由异步调用，[dispatcher]为null时，从该集群的全部节点中随机选择一个节点
  void callRemote(String cluster, {required String route, int code = 200, String desc = 'ok', Map<String, dynamic>? data, ClusterClientDispatcher? dispatcher}) {
    final clientList = _clusterMap[cluster];
    if (clientList == null) return;
    final packet = EasyPacket.signature(_config.secret, route: route, code: code, desc: desc, data: data, ucid: null);
    final client = clientList[dispatcher == null ? Random().nextInt(clientList.length) : dispatcher(cluster, packet)];
    client.request(EasyConstant.routeInnerRMC, data: packet.toJson());
    logDebug('callRemote: $cluster ${client.url} $packet ');
  }

  ///集群节点间远程路由异步调用，并返回结果，[dispatcher]为null时，从该集群的全部节点中随机选择一个节点
  Future<EasyPacket> callRemoteForResult(String cluster, {required String route, int code = 200, String desc = 'ok', Map<String, dynamic>? data, ClusterClientDispatcher? dispatcher}) {
    final clientList = _clusterMap[cluster];
    if (clientList == null) return Future.value(EasyConstant.remoteError);
    Completer<EasyPacket> completer = Completer();
    final packet = EasyPacket.signature(_config.secret, route: route, code: code, desc: desc, data: data, ucid: null);
    final client = clientList[dispatcher == null ? Random().nextInt(clientList.length) : dispatcher(cluster, packet)];
    client.request(EasyConstant.routeInnerRMC, data: packet.toJson(), ondata: (resp) => completer.complete(resp), onerror: (resp) => completer.complete(resp));
    logDebug('callRemoteForResult: $cluster ${client.url} $packet ');
    return completer.future;
  }

  ///开启服务器
  void start({Router? httpRouter}) {
    if (httpRouter == null) {
      //websocket服务器
      final handler = const Pipeline().addMiddleware(logRequests(logger: logHandler)).addHandler((request) {
        return webSocketHandler((WebSocketChannel websocket) => _onWebSocketConnect(websocket, request))(request);
      });
      serve(handler, _config.host, _config.port).then((server) {
        logInfo('wss server is listening...');
        //保存http服务器实例
        _server = server;
        //连接关联的集群节点
        _clusterMap.forEach((cluster, clientList) {
          for (var client in clientList) {
            _connectForCluster(cluster, client);
          }
        });
        //开启心跳循环
        _ticker = Timer.periodic(Duration(milliseconds: _config.heart), (timer) => _onServerHeart());
      });
    } else {
      //web服务器
      final handler = const Pipeline().addMiddleware(logRequests(logger: logHandler)).addHandler((request) {
        return httpRouter(request);
      });
      serve(handler, _config.host, _config.port).then((server) {
        logInfo('web server is listening...');
        //保存http服务器实例
        _server = server;
      });
    }
  }

  ///关闭服务器
  void close(void Function() callback) {
    //销毁心跳循环
    _ticker?.cancel();
    _ticker = null;
    //断开集群连接
    _clusterMap.forEach((cluster, clientList) {
      for (var client in clientList) {
        client.destroy();
      }
    });
    //关闭服务器
    _server?.close(force: true).then((value) {
      logInfo('server was closed.');
      _server = null;
      callback();
    });
  }

  ///心跳循环
  void _onServerHeart() {
    int totalSocket = 0;
    int totalSession = 0;
    _socketMap.forEach((id, session) {
      if (session.isExpired(_config.timeout)) {
        session.close(EasyConstant.timeoutError.code, EasyConstant.timeoutError.desc); //清除超时的链接
      } else {
        totalSocket += 1;
        totalSession += session.isBinded() ? 1 : 0;
      }
    });
    logInfo('_onServerHeart: totalSocket-> $totalSocket totalSession-> $totalSession');
    //回调上层绑定的监听器
    if (_heartListener != null) _heartListener!(totalSocket, totalSession);
  }

  ///收到连接后注册监听
  void _onWebSocketConnect(WebSocketChannel websocket, Request request) {
    final session = EasyServerSession(socket: websocket, ip: _getRequestAddress(request));
    _socketMap[session.id] = session; //绑定到_socketMap
    websocket.stream.listen((data) {
      logTrace('_onWebSocketData: ${session.info} $data');
      _onWebSocketMessage(session, data);
    }, onError: (Object error, StackTrace? stackTrace) {
      logError('_onWebSocketError: ${session.info} $error $stackTrace');
      session.close(EasyConstant.socketError.code, EasyConstant.socketError.desc);
    }, onDone: () {
      logInfo('_onWebSocketDone: ${session.info} ${session.closeCode} ${session.closeReason}');
      //回调上层绑定的监听器
      if (_closeListener != null) _closeListener!(session, session.closeCode, session.closeReason);
      //统一进行内存清理操作
      session.eachChannel((cid) => {quitChannel(session, cid)}); //退出已加入的所有分组
      unbindUid(session); //可能已经绑定了uid，需要进行解绑操作
      _socketMap.remove(session.id); //从_socketMap中移除
    }, cancelOnError: false);
    logInfo('_onWebSocketOpen: ${session.info}');
  }

  void _onWebSocketMessage(EasyServerSession session, dynamic data) {
    final packet = EasySecurity.decrypt(data, session.token ?? _config.pwd);
    //解析数据包
    if (packet == null) {
      logError('_onWebSocketMessage: ${session.info} ${EasyConstant.parseError} $packet');
      session.close(EasyConstant.parseError.code, EasyConstant.parseError.desc);
      return;
    }
    //校验重复包
    if (session.isRepeat(packet.id, _config.reqIdCache)) {
      logError('_onWebSocketMessage: ${session.info} ${EasyConstant.repeatError} $packet');
      session.close(EasyConstant.repeatError.code, EasyConstant.repeatError.desc);
      return;
    }
    //收到心跳包
    if (packet.route == EasyConstant.routeHeartick) {
      logTrace('_onWebSocketMessage: ${session.info} $packet');
      session.heartick(); //更新本次心跳时间戳
      response(session, packet, heartick: true); //响应心跳包
      return;
    }
    //集群内部包
    if (packet.route == EasyConstant.routeInnerP2P || packet.route == EasyConstant.routeInnerGRP || packet.route == EasyConstant.routeInnerALL || packet.route == EasyConstant.routeInnerRMC) {
      try {
        //校验子数据包签名
        final child = EasyPacket.fromJson(packet.data!);
        if (child.isSignError(_config.secret)) {
          logError('_onWebSocketMessage: ${session.info} ${EasyConstant.signError} $packet');
          session.close(EasyConstant.signError.code, EasyConstant.signError.desc);
          return;
        }
        //集群P2P包
        if (packet.route == EasyConstant.routeInnerP2P) {
          logDebug('_onWebSocketMessage: ${session.info} $packet');
          pushSession(child.ucid!, route: child.route, code: child.code, desc: child.desc, data: child.data);
          return;
        }
        //集群GRP包
        if (packet.route == EasyConstant.routeInnerGRP) {
          logDebug('_onWebSocketMessage: ${session.info} $packet');
          pushChannel(child.ucid!, route: child.route, code: child.code, desc: child.desc, data: child.data);
          return;
        }
        //集群ALL包
        if (packet.route == EasyConstant.routeInnerALL) {
          logDebug('_onWebSocketMessage: ${session.info} $packet');
          broadcast(route: child.route, code: child.code, desc: child.desc, data: child.data, binded: child.ucid! == 'true');
          return;
        }
        //集群RMC包
        final remote = _remoteMap[child.route];
        if (remote == null) {
          logError('_onWebSocketMessage: ${session.info} ${EasyConstant.remoteError} $packet');
          session.close(EasyConstant.remoteError.code, EasyConstant.remoteError.desc);
          return;
        } else {
          logDebug('_onWebSocketMessage: ${session.info} $packet');
          remote(session, child);
          return;
        }
      } catch (e) {
        logError('_onWebSocketMessage: ${session.info} ${EasyConstant.parseError} $packet $e');
        session.close(EasyConstant.parseError.code, EasyConstant.parseError.desc);
        return;
      }
    }
    //自定义路由
    final route = _routeMap[packet.route];
    if (route == null) {
      logError('_onWebSocketMessage: ${session.info} ${EasyConstant.routeError} $packet');
      session.close(EasyConstant.routeError.code, EasyConstant.routeError.desc);
      return;
    } else {
      logDebug('_onWebSocketMessage: ${session.info} $packet');
      route(session, packet);
      return;
    }
  }

  String _getRequestAddress(Request request) {
    try {
      logTrace('${request.headers}');
      return request.headers[_config.ipHeader] ?? (request.context['shelf.io.connection_info'] as HttpConnectionInfo?)?.remoteAddress.address ?? 'unknow address';
    } catch (e) {
      logError('_getRequestAddress error: $e');
      return 'unknow address';
    }
  }

  void _connectForCluster(String cluster, EasyClient client) {
    client.connect(
      onopen: () {
        logInfo('client onopen-> $cluster ${client.url}');
      },
      onclose: (code, reason) {
        logWarn('client onclose-> $cluster ${client.url} $code $reason');
      },
      onerror: (error) {
        logError('client onerror-> $cluster ${client.url} $error');
      },
      onretry: (count) {
        logDebug('client onretry-> $cluster ${client.url} $count');
      },
      onheart: (second, delay) {
        logTrace('client onheart-> $cluster ${client.url} $second ${delay}ms');
      },
    );
  }
}

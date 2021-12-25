import 'dart:async';
import 'package:shelf_easy/src/shelf_easy_object.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

///
///客户端
///
class EasyClient extends EasyLogger {
  //配置信息
  final EasyClientConfig _config;

  ///监听器列表集合
  final Map<String, List<EasyClientListener>> _listenersMap;

  ///请求集合
  final Map<int, EasyClientRequester> _requesterMap;

  ///秒数自增量
  int _timerInc;

  ///请求id自增量
  int _reqIdInc;

  ///网络延迟（毫秒）
  int _netDelay;

  ///断线重连尝试次数
  int _retryCnt;

  ///是否暂停断线重连功能
  bool _paused;

  ///本实例是否已经废弃，即是否已经调用过[destroy]方法
  bool _expired;

  ///weboscket实例
  WebSocketChannel? _socket;

  ///秒钟计时器
  Timer? _timer;

  ///用户token，这个值不为null时，代替_pwd
  String? _token;

  void Function()? _onopen;
  void Function(int code, String reason)? _onclose;
  void Function(String error)? _onerror;
  void Function(int count)? _onretry;
  void Function(int second, int delay)? _onheart;

  EasyClient({required EasyClientConfig config, void Function(String msg, EasyLogLevel logLevel) logger = EasyLogger.defaultLogger})
      : assert(config.timeout >= 5 * 1000),
        assert(config.heartick >= 30),
        assert(config.conntick >= 3),
        _config = config,
        _listenersMap = {},
        _requesterMap = {},
        _timerInc = 0,
        _reqIdInc = 0,
        _netDelay = 0,
        _retryCnt = 0,
        _paused = false,
        _expired = false,
        _socket = null,
        _timer = null,
        _token = null,
        super(config.logLevel, config.logTag ?? config.url, logger);

  ///开始进行网络连接
  void connect({void Function()? onopen, void Function(int code, String reason)? onclose, void Function(String error)? onerror, void Function(int count)? onretry, void Function(int second, int delay)? onheart}) {
    if (_expired) return;
    if (isConnected()) return;
    _onopen = onopen;
    _onclose = onclose;
    _onerror = onerror;
    _onretry = onretry;
    _onheart = onheart;
    //安全开启连接
    _safeOpen();
    //开始心跳循环
    _timer = Timer.periodic(Duration(seconds: 1), (timer) => _onHeartick());
  }

  ///关闭连接销毁实例
  ///
  ///注意：调用此函数后，此实例不可继续做网络操作，不可重新连接网络。
  Future<void> destroy() {
    if (_expired) return Future.value();
    logInfo('destroy');
    //关闭计时器
    _timer?.cancel();
    _timer = null;
    //安全关闭连接
    _safeClose(EasyConstant.clientClose.code, EasyConstant.clientClose.desc);
    //最后设置废弃标志
    return Future.delayed(Duration(milliseconds: 100), () => _expired = true);
  }

  ///向远程服务器发起请求
  void request(String route, {Map<String, dynamic>? data, void Function(EasyPacket packet)? ondata, void Function(EasyPacket packet)? onerror}) {
    if (_expired) return;
    final reqId = _reqIdInc++;
    final requester = EasyClientRequester(ondata: ondata, onerror: onerror);
    if (ondata != null || onerror != null) _requesterMap[reqId] = requester;
    _sendPacket(EasyPacket.request(route: route, id: reqId, desc: requester.time.toString(), data: data));
  }

  ///添加指定[route]的监听器，可用作自由定义事件的管理器
  void addListener(String route, void Function(EasyPacket packet) ondata, {bool once = false}) {
    if (_expired) return;
    final listenerList = _listenersMap[route] ?? [];
    listenerList.add(EasyClientListener(ondata: ondata, once: once));
    _listenersMap[route] = listenerList;
  }

  ///删除指定[route]的监听器，[ondata]为null时删除[route]的全部监听器，否则只删除[ondata]函数的监听器
  void removeListener(String route, {void Function(EasyPacket packet)? ondata}) {
    if (_expired) return;
    final listenerList = _listenersMap[route];
    if (listenerList == null) return;
    if (ondata == null) {
      _listenersMap.remove(route); //删除该路由的全部监听器
      return;
    }
    final targetList = <EasyClientListener>[]; //要移除的监听器
    for (var element in listenerList) {
      if (element.ondata == ondata) targetList.add(element);
    }
    while (targetList.isNotEmpty) {
      listenerList.remove(targetList.removeLast());
    }
    if (listenerList.isEmpty) _listenersMap.remove(route);
  }

  ///触发[EasyPacket.route]对应的全部监听器
  void triggerEvent(EasyPacket packet) {
    if (_expired) return;
    final listenerList = _listenersMap[packet.route];
    if (listenerList == null) return;
    final onceList = <EasyClientListener>[]; //删除只触发一次的监听器
    for (var element in listenerList) {
      if (element.ondata != null) element.ondata!(packet);
      if (element.once) onceList.add(element);
    }
    for (var element in onceList) {
      removeListener(packet.route, ondata: element.ondata);
    }
  }

  ///暂停断线自动重连的功能
  void pauseReconnect() => _paused = true;

  ///恢复断线自动重连的功能
  void resumeReconnect() => _paused = false;

  ///绑定用户口令
  void bindToken(String token) => _token = token;

  ///解绑用户口令
  void unbindToken() => _token = null;

  ///是否已经建立网络连接
  bool isConnected() => _socket != null;

  ///读取url
  String get url => _config.url;

  void _sendPacket(EasyPacket packet) {
    if (_expired) return;
    if (!isConnected()) return;
    dynamic data = EasySecurity.encrypt(packet, _token ?? _config.pwd, _config.binary);
    if (data == null) {
      logError('_sendPacket encrypt error: $packet');
      if (_onerror != null) _onerror!('_sendPacket encrypt error: $packet');
      return;
    }
    if (packet.route == EasyConstant.routeHeartick) {
      logTrace('_sendPacket >>> $packet');
    } else {
      logDebug('_sendPacket >>> $packet');
    }
    _socket?.sink.add(data);
  }

  void _readPacket(dynamic data) {
    if (_expired) return;
    final packet = EasySecurity.decrypt(data, _token ?? _config.pwd);
    if (packet == null) {
      logError('_readPacket decrypt error: $data');
      if (_onerror != null) _onerror!('_readPacket decrypt error: $data');
      return;
    }
    switch (packet.route) {
      case EasyConstant.routeHeartick:
        logTrace('_readPacket <<< $packet');
        //服务端心跳响应
        _netDelay = DateTime.now().millisecondsSinceEpoch - int.parse(packet.desc); //更新网络延迟
        logTrace('net delay is ${_netDelay}ms');
        break;
      case EasyConstant.routeResponse:
        logDebug('_readPacket <<< $packet');
        //客户端请求响应
        final target = _requesterMap.remove(packet.id);
        if (target == null) return; //超时的响应，监听器已经被_timer删除
        _netDelay = DateTime.now().millisecondsSinceEpoch - target.time; //更新网络延迟
        logTrace('net delay is ${_netDelay}ms');
        if (packet.ok) {
          if (target.ondata != null) target.ondata!(packet);
        } else {
          if (target.onerror != null) target.onerror!(packet);
        }
        break;
      default:
        logDebug('_readPacket <<< $packet');
        //服务器推送数据
        triggerEvent(packet);
        break;
    }
  }

  void _safeOpen() {
    if (_expired) return;
    _safeClose(EasyConstant.clientRetry.code, EasyConstant.clientRetry.desc); //关闭旧连接
    logDebug('_safeOpen');
    _socket = WebSocketChannel.connect(Uri.parse(_config.url));
    _socket?.stream.listen((data) => _onWebSocketData(data), onError: _onWebSocketError, onDone: _onWebSocketDone, cancelOnError: false);
    _onWebSocketOpen();
  }

  void _safeClose(int code, String reason) {
    if (_expired) return;
    if (_socket == null) return;
    logDebug('_safeClose $code $reason');
    _socket?.sink.close(code, reason);
    _socket = null;
  }

  void _onWebSocketOpen() {
    if (_expired) return;
    logInfo('_onWebSocketOpen');
    _retryCnt = 0; //重置重连次数为0
    if (_onopen != null) _onopen!();
  }

  void _onWebSocketData(dynamic data) {
    if (_expired) return;
    logTrace('_onWebSocketData: $data');
    _readPacket(data);
  }

  void _onWebSocketDone() {
    if (_expired) return;
    logInfo('_onWebSocketDone: ${_socket?.closeCode} ${_socket?.closeReason}');
    _safeClose(EasyConstant.clientDone.code, EasyConstant.clientDone.desc); //关闭旧连接
    if (_onclose != null) _onclose!(_socket?.closeCode ?? EasyConstant.clientUnknow.code, _socket?.closeReason ?? EasyConstant.clientUnknow.desc);
  }

  void _onWebSocketError(Object error, StackTrace? stackTrace) {
    if (_expired) return;
    logError('_onWebSocketError: $error $stackTrace');
    _safeClose(EasyConstant.clientError.code, EasyConstant.clientError.desc); //关闭旧连接
    if (_onerror != null) _onerror!('$error $stackTrace');
  }

  void _onHeartick() {
    if (_expired) return;
    //秒数自增
    _timerInc++;
    //清除超时的请求
    final time = DateTime.now().millisecondsSinceEpoch;
    final timeoutList = <int>[];
    _requesterMap.forEach((id, target) {
      if (time - target.time > _config.timeout) {
        if (target.onerror != null) target.onerror!(EasyConstant.clientTimeout);
        timeoutList.add(id);
      }
    });
    for (var element in timeoutList) {
      _requesterMap.remove(element);
    }
    //心跳和断线重连
    if (isConnected()) {
      if (_timerInc % _config.heartick == 0) {
        request(EasyConstant.routeHeartick); //发送心跳包
      }
    } else {
      if (_timerInc % _config.conntick == 0 && !_paused) {
        _retryCnt++; //增加重连次数
        if (_onretry != null) _onretry!(_retryCnt);
        _safeOpen(); //安全开启连接
      }
    }
    //心跳周期回调
    if (_onheart != null) _onheart!(_timerInc, _netDelay);
  }
}

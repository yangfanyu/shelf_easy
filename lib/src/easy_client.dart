import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'easy_class.dart';
import 'wk/wk_base.dart';
import 'wk/wk_unsupport.dart' if (dart.library.io) 'wk/wk_native.dart' if (dart.library.html) 'wk/wk_html.dart' as worker;

///
///客户端
///
class EasyClient extends EasyLogger {
  static const _threadTaskEncrypt = '___threadTaskEncrypt___';
  static const _threadTaskDecrypt = '___threadTaskDecrypt___';

  ///配置信息
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

  ///并发隔离线程
  WkBase? _thread;

  ///weboscket实例
  WebSocketChannel? _socket;

  ///weboscket实例是否已经收到过初始化消息
  bool _socketInited;

  ///秒钟计时器
  Timer? _timer;

  ///用户id
  String? _uid;

  ///用户token，这个值不为null时，代替_pwd
  String? _token;

  void Function()? _onopen;
  void Function(int code, String reason)? _onclose;
  void Function(String error)? _onerror;
  void Function(int count)? _onretry;
  void Function(int second, int delay)? _onheart;

  EasyClient({required EasyClientConfig config})
      : _config = config,
        _listenersMap = {},
        _requesterMap = {},
        _timerInc = 0,
        _reqIdInc = 0,
        _netDelay = 0,
        _retryCnt = 0,
        _paused = false,
        _expired = false,
        _thread = null,
        _socket = null,
        _socketInited = false,
        _timer = null,
        _token = null,
        super(
          logger: config.logger,
          logLevel: config.logLevel,
          logTag: config.logTag ?? config.url,
          logFilePath: config.logFilePath,
          logFileBackup: config.logFileBackup,
          logFileMaxBytes: config.logFileMaxBytes,
        ) {
    if (_config.timeout < 5 * 1000) throw ('_config.timeout < 5 * 1000');
    if (_config.heartick < 30) throw ('_config.heartick < 30');
    if (_config.conntick < 3) throw ('_config.conntick < 3');
  }

  ///初始化并发线程，用于客户端高计算量任务，如json解析、加解密操作等
  Future<void> initThread(Future<dynamic> Function(String taskType, dynamic taskData) customHandler, {bool runErrorsZone = true, bool errorsAreFatal = false}) {
    _thread = worker.create(WkConfig(serviceConfig: {'customHandler': customHandler}, serviceHandler: _serviceHandler, messageHandler: _messageHandler));
    return _thread!.start(runErrorsZone: runErrorsZone, errorsAreFatal: errorsAreFatal);
  }

  ///运行一个并发计算任务，[taskType]为计算任务类型名，[taskData]计算任务所需数据
  Future<T?> runThreadTask<T>(String taskType, dynamic taskData) {
    if (threadEnable) {
      return _thread!.runTask(taskType: taskType, taskData: taskData);
    } else {
      return Future.value(null);
    }
  }

  ///开始进行网络连接，[now]为true时立即尝试连接，为false时将会推迟[EasyClientConfig.conntick]秒连接
  void connect({void Function()? onopen, void Function(int code, String reason)? onclose, void Function(String error)? onerror, void Function(int count)? onretry, void Function(int second, int delay)? onheart, bool now = true}) {
    if (_expired) return;
    if (isConnected) return;
    logDebug(['connect...']);
    _onopen = onopen;
    _onclose = onclose;
    _onerror = onerror;
    _onretry = onretry;
    _onheart = onheart;
    //立即建立连接
    if (now) _safeOpen();
    //开始心跳循环
    _timer = Timer.periodic(Duration(seconds: 1), (timer) => _onHeartick());
  }

  ///关闭连接销毁实例，调用此函数后，此实例不可进行websocket网络操作，不可重新连接网络。
  Future<void> destroy() async {
    if (_expired) return;
    logDebug(['destroy...']);
    //关闭计时器
    _timer?.cancel();
    _timer = null;
    //清除监听器
    _requesterMap.clear();
    _listenersMap.clear();
    //安全关闭连接
    _safeClose(EasyConstant.clientCloseByDestroy.code, EasyConstant.clientCloseByDestroy.desc);
    //销毁隔离线程
    await _thread?.close();
    //最后设置废弃标志
    return Future.delayed(Duration(milliseconds: 30), () {
      _expired = true;
      logInfo(['destroyed.']);
    });
  }

  ///发起AES加密通讯的http请求
  Future<EasyPacket> httpRequest(String route, {Map<String, dynamic>? data, List<List<int>>? fileBytes, MediaType? mediaType, Map<String, String>? headers}) async {
    final requestId = _reqIdInc++;
    final requestPacket = EasyPacket.request(route: route, id: requestId, desc: DateTime.now().millisecondsSinceEpoch.toString(), data: data);
    final requestData = threadEnable
        ? await _thread!.runTask(
            taskType: _threadTaskEncrypt,
            taskData: [requestPacket, _token ?? _config.pwd, _config.binary],
          )
        : EasySecurity.encrypt(requestPacket, _token ?? _config.pwd, _config.binary);
    if (requestData == null) {
      final responsePacket = requestPacket.requestEncryptError();
      logError(['httpRequest =>', responsePacket.codeDesc, requestPacket]);
      return responsePacket;
    }
    logDebug(['httpRequest >>>>>>', requestPacket]);
    logTrace(['httpRequest =>', requestData]);
    try {
      int fieldId = 0;
      final url = Uri.parse(route);
      final response = fileBytes == null || mediaType == null
          ? await http.post(url, body: requestData, headers: {'content-type': _config.binary ? 'application/octet-stream' : 'text/plain', 'easy-security-identity': _uid ?? ''}..addAll(headers ?? {}))
          : await http.Response.fromStream(await (http.MultipartRequest('POST', url)
                ..headers.addAll({'easy-security-identity': _uid ?? ''})
                ..files.add(_config.binary ? http.MultipartFile.fromBytes('data', requestData) : http.MultipartFile.fromString('data', requestData))
                ..files.addAll(fileBytes.map((bytes) => http.MultipartFile.fromBytes('file_${fieldId++}', bytes, contentType: mediaType))))
              .send());
      logTrace(['httpResponse <=', response.headers]);
      final responseBody = _config.binary ? response.bodyBytes : response.body;
      logTrace(['httpResponse <=', responseBody]);
      if (response.statusCode != 200) {
        final responsePacket = requestPacket.requestStatusCodeError(status: response.statusCode, reason: response.reasonPhrase);
        logError(['httpResponse <<<<<<', responsePacket]);
        return responsePacket;
      }
      final responseData = threadEnable
          ? await _thread!.runTask<EasyPacket>(
              taskType: _threadTaskDecrypt,
              taskData: [responseBody, _token ?? _config.pwd],
            )
          : EasySecurity.decrypt(responseBody, _token ?? _config.pwd);
      if (responseData == null) {
        final responsePacket = requestPacket.requestDecryptError();
        logError(['httpResponse <<<<<<', responsePacket]);
        return responsePacket;
      }
      if (responseData.ok) {
        logDebug(['httpResponse <<<<<<', responseData]);
      } else {
        logError(['httpResponse <<<<<<', responseData]);
      }
      return responseData;
    } catch (error, stack) {
      final responsePacket = requestPacket.requestExceptionError(error: error);
      logError(['httpResponse <<<<<<', responsePacket, error, '\n', stack]);
      return responsePacket;
    }
  }

  ///发起AES加密通讯的websocket请求，[waitCompleter]为true时等待服务器响应请求，为false时发送完毕后立即返回
  Future<EasyPacket> websocketRequest(String route, {Map<String, dynamic>? data, bool waitCompleter = true}) async {
    final requestId = _reqIdInc++;
    final requestPacket = EasyPacket.request(route: route, id: requestId, desc: DateTime.now().millisecondsSinceEpoch.toString(), data: data);
    if (_expired) {
      final responsePacket = requestPacket.requestExpiredError();
      logError(['websocketRequest =>', responsePacket.codeDesc, requestPacket]);
      return responsePacket;
    }
    if (!isConnected) {
      final responsePacket = requestPacket.requestNotConnected();
      logError(['websocketRequest =>', responsePacket.codeDesc, requestPacket]);
      return responsePacket;
    }
    final requestData = threadEnable
        ? await _thread!.runTask(
            taskType: _threadTaskEncrypt,
            taskData: [requestPacket, _token ?? _config.pwd, _config.binary],
          )
        : EasySecurity.encrypt(requestPacket, _token ?? _config.pwd, _config.binary);
    if (requestData == null) {
      final responsePacket = requestPacket.requestEncryptError();
      logError(['websocketRequest =>', responsePacket.codeDesc, requestPacket]);
      return responsePacket;
    }
    if (route == EasyConstant.routeHeartick) {
      logTrace(['websocketHeartick >>>>>>', requestPacket]);
      logTrace(['websocketHeartick =>', requestData]);
      _socket?.sink.add(requestData);
      final responsePacket = requestPacket.requestFinished();
      logTrace(['websocketHeartick <<<<<<', responsePacket]);
      return responsePacket;
    }
    logDebug(['websocketRequest >>>>>>', requestPacket]);
    logTrace(['websocketRequest =>', requestData]);
    if (waitCompleter) {
      final completer = Completer<EasyPacket>();
      _requesterMap[requestId] = EasyClientRequester(requestPacket, completer);
      _socket?.sink.add(requestData);
      return completer.future;
    } else {
      _socket?.sink.add(requestData);
      final responsePacket = requestPacket.requestFinished();
      logDebug(['websocketResponse <<<<<<', responsePacket]);
      return responsePacket;
    }
  }

  ///添加指定[route]的监听器，可用作自由定义事件的管理器
  void addListener(String route, void Function(EasyPacket packet) ondata, {bool once = false}) {
    if (_expired) return;
    final listenerList = _listenersMap[route] ?? [];
    listenerList.add(EasyClientListener(ondata: ondata, once: once));
    _listenersMap[route] = listenerList;
  }

  ///删除指定[route]的监听器，[ondata]为null时删除对应[route]的全部监听器，否则只删除对应[ondata]函数的监听器
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

  ///绑定用户信息。[token]是数据加解密密钥，为null时，使用[EasyClientConfig.pwd]进行加解密
  void bindUser(String uid, {required String? token}) {
    _uid = uid;
    _token = token;
    logDebug(['bindUser =>', _uid, _token]);
  }

  ///解绑用户信息
  void unbindUser() {
    _uid = null;
    _token = null;
    logDebug(['unbindUser =>', _uid, _token]);
  }

  ///读取websocket连接url
  String get url => _config.url;

  ///是否已经建立网络连接
  bool get isConnected => _socket != null && _socketInited;

  ///是否已经建立隔离线程
  bool get threadEnable => _thread != null;

  void _safeOpen() {
    if (_expired) return;
    _safeClose(EasyConstant.clientCloseByRetry.code, EasyConstant.clientCloseByRetry.desc); //关闭旧连接
    logTrace(['_safeOpen']);
    _socket = WebSocketChannel.connect(Uri.parse(_config.url));
    _socketInited = false;
    _socket?.stream.listen((data) => _onWebSocketData(data), onError: _onWebSocketError, onDone: _onWebSocketDone, cancelOnError: false);
  }

  void _safeClose(int code, String reason) {
    if (_expired) return;
    logTrace(['_safeClose =>', code, reason]);
    _socket?.sink.close(code, reason);
    _socket = null;
    _socketInited = false;
  }

  void _onWebSocketData(dynamic data) async {
    if (_expired) return;
    final packet = threadEnable
        ? await _thread!.runTask<EasyPacket>(
            taskType: _threadTaskDecrypt,
            taskData: [data, _token ?? _config.pwd],
          )
        : EasySecurity.decrypt(data, _token ?? _config.pwd);
    if (packet == null) {
      logError(['_onWebSocketData <=', 'decrypt error:', data]);
      return;
    }
    logTrace(['_onWebSocketData <=', data]);
    switch (packet.route) {
      case EasyConstant.routeInitiate:
        //连接到服务器后的第一个消息
        logDebug(['_onWebSocketOpen <<<<<<', packet]);
        logInfo(['connected.']);
        _retryCnt = 0; //重置重连次数为0
        _socketInited = true; //设置已经初始化标志
        if (_onopen != null) _onopen!();
        break;
      case EasyConstant.routeHeartick:
        //心跳包响应
        _netDelay = DateTime.now().millisecondsSinceEpoch - int.parse(packet.desc); //更新网络延迟
        logTrace(['websocketHeartick <<<<<<', '${_netDelay}ms', packet]);
        break;
      case EasyConstant.routeResponse:
        //请求响应
        final requester = _requesterMap.remove(packet.id);
        if (requester == null) return; //超时的响应，监听器已经被_timer删除
        _netDelay = DateTime.now().millisecondsSinceEpoch - requester.time; //更新网络延迟
        if (packet.ok) {
          logDebug(['websocketResponse <<<<<<', '${_netDelay}ms', packet]);
        } else {
          logError(['websocketResponse <<<<<<', '${_netDelay}ms', packet]);
        }
        requester.completer.complete(packet);
        break;
      default:
        logDebug(['_onWebSocketPush <<<<<<', packet]);
        //推送数据
        triggerEvent(packet);
        break;
    }
  }

  void _onWebSocketError(Object error, StackTrace stack) {
    if (_expired) return;
    logError(['_onWebSocketError =>', error, '\n', stack]);
    _safeClose(EasyConstant.clientCloseByError.code, EasyConstant.clientCloseByError.desc); //关闭旧连接
    if (_onerror != null) _onerror!(error.toString());
  }

  void _onWebSocketDone() {
    if (_expired) return;
    logDebug(['_onWebSocketDone =>', _socket?.closeCode, _socket?.closeReason]);
    _safeClose(EasyConstant.clientCloseByDone.code, EasyConstant.clientCloseByDone.desc); //关闭旧连接
    if (_onclose != null) _onclose!(_socket?.closeCode ?? EasyConstant.clientCloseByUnknow.code, _socket?.closeReason ?? EasyConstant.clientCloseByUnknow.desc);
  }

  void _onHeartick() {
    if (_expired) return;
    //秒数自增
    _timerInc++;
    //清除超时的请求
    final time = DateTime.now().millisecondsSinceEpoch;
    final timeoutList = <int>[];
    _requesterMap.forEach((requestId, requester) {
      if (time - requester.time > _config.timeout) {
        final responsePacket = requester.packet.requestTimeoutError();
        logError(['websocketResponse <<<<<<', responsePacket]);
        requester.completer.complete(responsePacket);
        timeoutList.add(requestId);
      }
    });
    for (var requestId in timeoutList) {
      _requesterMap.remove(requestId);
    }
    //心跳和断线重连
    if (isConnected) {
      if (_timerInc % _config.heartick == 0) {
        websocketRequest(EasyConstant.routeHeartick, waitCompleter: false); //发送心跳包
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

  ///发起任意的GET请求
  static Future<http.Response> get(Uri url, {Map<String, String>? headers}) => http.get(url, headers: headers);

  ///发起任意的POST请求
  static Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) => http.post(url, headers: headers, body: body, encoding: encoding);

  static Future<bool> _serviceHandler(WkSignal signal, Map<String, dynamic> config) async {
    return true;
  }

  static Future<dynamic> _messageHandler(Map<String, dynamic> config, String type, dynamic data) async {
    Future<dynamic> Function(String taskType, dynamic taskData) customHandler = config['customHandler'];
    switch (type) {
      case WkMessage.runZonedGuardedError:
        return null; //暂时先忽略掉
      case _threadTaskEncrypt:
        return EasySecurity.encrypt(data[0], data[1], data[2]);
      case _threadTaskDecrypt:
        return EasySecurity.decrypt(data[0], data[1]);
      default:
        return customHandler(type, data);
    }
  }
}

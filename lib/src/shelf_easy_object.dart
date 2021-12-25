import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

///
///日志级别
///
///注意保持定义顺序不变，因为框架使用了index值进行判断
///
enum EasyLogLevel {
  //trace
  trace,

  ///debug
  debug,

  ///info
  info,

  ///warn
  warn,

  ///error
  error,
}

///
///一些常量
///
///本框架保留状态码:
///
/// * 4001-4100 服务端保留状态码范围
/// * 4101-4200 客户端保留状态码范围
/// * 4201-4999 可自定义的状态码范围
///
///更多状态码资料参考： https://tools.ietf.org/html/rfc6455#section-7.4.2 和 https://github.com/websockets/ws/issues/715
class EasyConstant {
  ///心跳包路由
  static const routeHeartick = '__heartick__';

  ///响应包路由
  static const routeResponse = '__response__';

  ///集群点对点消息路由
  static const routeInnerP2P = '__innerP2P__';

  ///集群分组消息路由
  static const routeInnerGRP = '__innerGRP__';

  ///集群广播消息路由
  static const routeInnerALL = '__innerALL__';

  ///集群远程方法路由
  static const routeInnerRMC = '__innerRMC__';

  ///服务端解析数据失败
  static const parseError = EasyPacket._(code: 4001, desc: 'parseError');

  ///服务端校验重复id包未通过
  static const repeatError = EasyPacket._(code: 4002, desc: 'repeatError');

  ///服务端检验数据签名未通过
  static const signError = EasyPacket._(code: 4003, desc: 'signError');

  ///服务端没有对应的路由方法
  static const routeError = EasyPacket._(code: 4004, desc: 'routeError');

  ///服务端没有对应的远程方法
  static const remoteError = EasyPacket._(code: 4005, desc: 'remoteError');

  ///服务端会话的套接字发生错误
  static const socketError = EasyPacket._(code: 4006, desc: 'socketError');

  ///服务端会话长时间未收到心跳包
  static const timeoutError = EasyPacket._(code: 4007, desc: 'timeoutError');

  ///服务端有新会话绑定了同样的uid
  static const newbindError = EasyPacket._(code: 4008, desc: 'newbindError');

  ///客户端尝试重新连接
  static const clientRetry = EasyPacket._(code: 4101, desc: 'clientRetry');

  ///客户端触发done事件
  static const clientDone = EasyPacket._(code: 4102, desc: 'clientDone');

  ///客户端触发error事件
  static const clientError = EasyPacket._(code: 4103, desc: 'clientError');

  ///客户端主动关闭连接
  static const clientClose = EasyPacket._(code: 4104, desc: 'clientClose');

  ///客户端网络请求超时
  static const clientTimeout = EasyPacket._(code: 4105, desc: 'clientTimeout');

  ///客户端未知关闭原因
  static const clientUnknow = EasyPacket._(code: 4106, desc: 'clientUnknow');
}

///
///模型基类
///
abstract class EasyModel {
  const EasyModel();
  Map<String, dynamic> toJson();
}

///
///日志处理
///
abstract class EasyLogger {
  ///日志级别
  final EasyLogLevel _logLevel;

  ///日志处理函数
  final void Function(String msg, EasyLogLevel logLevel) _logger;

  ///统一的标签
  final String _tag;

  const EasyLogger(this._logLevel, this._tag, this._logger);

  void logTrace(String msg) {
    if (EasyLogLevel.trace.index >= _logLevel.index) {
      _logger('[TRACE] $_tag $msg', EasyLogLevel.trace);
    }
  }

  void logDebug(String msg) {
    if (EasyLogLevel.debug.index >= _logLevel.index) {
      _logger('[DEBUG] $_tag $msg', EasyLogLevel.debug);
    }
  }

  void logInfo(String msg) {
    if (EasyLogLevel.info.index >= _logLevel.index) {
      _logger('[INFO] $_tag $msg', EasyLogLevel.info);
    }
  }

  void logWarn(String msg) {
    if (EasyLogLevel.warn.index >= _logLevel.index) {
      _logger('[WARN] $_tag $msg', EasyLogLevel.warn);
    }
  }

  void logError(String msg) {
    if (EasyLogLevel.error.index >= _logLevel.index) {
      _logger('[ERROR] $_tag $msg', EasyLogLevel.error);
    }
  }

  void logHandler(String msg, bool isError) {
    if (isError) {
      if (EasyLogLevel.error.index >= _logLevel.index) {
        _logger('[ERROR] $_tag $msg', EasyLogLevel.error);
      }
    } else {
      if (EasyLogLevel.debug.index >= _logLevel.index) {
        _logger('[DEBUG] $_tag $msg', EasyLogLevel.debug);
      }
    }
  }

  static void defaultLogger(String msg, EasyLogLevel logLevel) {
    switch (logLevel) {
      case EasyLogLevel.trace:
        print('\x1B[34m$msg\x1B[0m');
        break;
      case EasyLogLevel.debug:
        print('\x1B[36m$msg\x1B[0m');
        break;
      case EasyLogLevel.info:
        print('\x1B[32m$msg\x1B[0m');
        break;
      case EasyLogLevel.warn:
        print('\x1B[33m$msg\x1B[0m');
        break;
      case EasyLogLevel.error:
        print('\x1B[31m$msg\x1B[0m');
        break;
    }
  }
}

///
///数据包类
///
class EasyPacket extends EasyModel {
  ///响应或请求的路由
  final String route;

  ///响应或请求的id
  final int id;

  ///响应或请求的状态码
  final int code;

  ///响应或请求的描述信息
  final String desc;

  ///响应或请求的数据内容
  final Map<String, dynamic>? data;

  ///集群内部包 uid 或 cid 或 广播范围(binded的bool值)
  final String? ucid;

  ///集群内部包随机字符串
  final String? word;

  ///集群内部包签名字符串
  final String? sign;

  ///状态是否正确
  bool get ok => code == 200;

  const EasyPacket._({this.route = '', this.id = 0, this.code = 200, this.desc = 'ok', this.data, this.ucid, this.word, this.sign});

  ///根据map创建实例
  factory EasyPacket.fromJson(Map<String, dynamic> map) {
    return EasyPacket._(
      route: map['route'],
      id: map['id'],
      code: map['code'],
      desc: map['desc'],
      data: map['data'],
      ucid: map['ucid'],
      word: map['word'],
      sign: map['sign'],
    );
  }

  ///创建一个请求数据的实例
  factory EasyPacket.request({required String route, required int id, required String desc, required Map<String, dynamic>? data}) {
    return EasyPacket._(route: route, id: id, desc: desc, data: data);
  }

  ///创建一个响应数据的实例
  factory EasyPacket.response({required String route, required int id, required int code, required String desc, required Map<String, dynamic>? data}) {
    return EasyPacket._(route: route, id: id, code: code, desc: desc, data: data);
  }

  ///创建一个推送数据的实例
  factory EasyPacket.pushdata({required String route, required int code, required String desc, required Map<String, dynamic>? data}) {
    return EasyPacket._(route: route, code: code, desc: desc, data: data);
  }

  ///创建一个内部数据的实例
  factory EasyPacket.signature(String secret, {required String route, required int code, required String desc, required Map<String, dynamic>? data, required String? ucid}) {
    final word = EasySecurity.uuid.v4();
    final sign = EasySecurity.getMd5('$secret$route$word$secret');
    return EasyPacket._(route: route, code: code, desc: desc, data: data, ucid: ucid, word: word, sign: sign);
  }

  ///验证签名是否错误
  bool isSignError(String secret) {
    return EasySecurity.getMd5('$secret$route$word$secret') != sign;
  }

  ///转换成Map格式
  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'route': route,
      'id': id,
      'code': code,
      'desc': desc,
    };
    if (data != null) map['data'] = data;
    if (ucid != null) map['ucid'] = ucid;
    if (word != null) map['word'] = word;
    if (sign != null) map['sign'] = sign;
    return map;
  }

  ///转换成字符串
  @override
  String toString() => jsonEncode(this);
}

///
///加密解密
///
class EasySecurity {
  ///uuid生成器
  static const uuid = Uuid();

  ///计算md5编码
  static String getMd5(String data) {
    return md5.convert(utf8.encode(data)).toString();
  }

  ///将数据包进行加密，采用随机生成iv和key的AES加密算法，CBC、Pkcs7
  ///
  /// * [data] 要加密的数据包
  /// * [pwd] 加密的密码
  /// * [binary] 返回结果是否为二进制数组
  ///
  ///[binary]为true时返回[Uint8List]，为false时返回[String]类型
  static dynamic encrypt(EasyPacket data, String? pwd, bool binary) {
    try {
      String plainText = jsonEncode(data);
      if (pwd != null) {
        final hmacSha256 = Hmac(sha256, utf8.encode(pwd)); // HMAC-SHA256
        final salt = Key.fromSecureRandom(16).bytes;
        final iv = Key.fromSecureRandom(16).bytes;
        final key = Uint8List.fromList(hmacSha256.convert(salt).bytes);
        final aesCrypto = Encrypter(AES(Key(key), mode: AESMode.cbc, padding: 'PKCS7'));
        final body = aesCrypto.encrypt(plainText, iv: IV(iv)).bytes;
        final encRes = Uint8List(salt.length + iv.length + body.length);
        copyUint8List(binary, encRes, salt, 0);
        copyUint8List(binary, encRes, iv, salt.length);
        copyUint8List(binary, encRes, body, salt.length + iv.length);
        return binary ? encRes : base64Encode(encRes);
      } else {
        return binary ? plainText.codeUnits : plainText;
      }
    } catch (e) {
      return null;
    }
  }

  ///将收到的数据进行解密，采用随机生成iv和key的AES解密算法，CBC、Pkcs7
  ///
  /// * [data] 要解密的数据
  /// * [pwd] 解密的密码
  ///
  static EasyPacket? decrypt(dynamic data, String? pwd) {
    try {
      if (pwd != null) {
        final hmacSha256 = Hmac(sha256, utf8.encode(pwd)); // HMAC-SHA256
        Uint8List bytes;
        if (data is String) {
          bytes = base64Decode(data);
        } else if (data is ByteBuffer) {
          final copy = data.asUint8List(); //Web is NativeByteBuffer
          bytes = Uint8List(copy.length);
          copyUint8List(true, bytes, copy, 0);
        } else if (data is Uint8List) {
          bytes = Uint8List(data.length); //Native is Uint8List
          copyUint8List(true, bytes, data, 0);
        } else {
          return null;
        }
        final salt = bytes.sublist(0, 16);
        final iv = bytes.sublist(16, 32);
        final key = Uint8List.fromList(hmacSha256.convert(salt).bytes);
        final body = bytes.sublist(32);
        final aesCrypto = Encrypter(AES(Key(key), mode: AESMode.cbc, padding: 'PKCS7'));
        final decRes = aesCrypto.decrypt(Encrypted(body), iv: IV(iv));
        return EasyPacket.fromJson(jsonDecode(decRes));
      } else {
        return EasyPacket.fromJson(jsonDecode(data is String ? data : String.fromCharCodes(data)));
      }
    } catch (e) {
      return null;
    }
  }

  ///拷贝字节数组
  ///
  /// * [swapInt32Endian] 是否交换字节序
  /// * [to] 保存的子节数组
  /// * [from] 来源的子节数组
  /// * [toOffset] 在[to]数组中的从这个位置开始保存
  ///
  static void copyUint8List(bool swapInt32Endian, Uint8List to, Uint8List from, int toOffset) {
    if (swapInt32Endian) {
      for (int i = 0; i < from.length; i += 4) {
        to[toOffset + i + 0] = from[i + 3];
        to[toOffset + i + 1] = from[i + 2];
        to[toOffset + i + 2] = from[i + 1];
        to[toOffset + i + 3] = from[i + 0];
      }
    } else {
      for (int i = 0; i < from.length; i++) {
        to[toOffset + i] = from[i];
      }
    }
  }
}

///
///客户端配置
///
class EasyClientConfig {
  ///日志级别
  final EasyLogLevel logLevel;

  ///日志标签
  final String? logTag;

  ///服务器地址
  final String url;

  ///数据加解密密码
  final String? pwd;

  ///是否用二进制传输
  final bool binary;

  ///请求超时时间（毫秒）
  final int timeout;

  ///发送心跳包的间隔（秒）
  final int heartick;

  ///断线重连的间隔（秒）
  final int conntick;

  const EasyClientConfig({
    this.logLevel = EasyLogLevel.trace,
    this.logTag,
    required this.url,
    this.pwd,
    this.binary = false,
    this.timeout = 10 * 1000,
    this.heartick = 60,
    this.conntick = 6,
  });
}

///
///客户端事件监听器
///
class EasyClientListener {
  ///消息处理函数
  final void Function(EasyPacket packet)? ondata;

  ///是否触发一次后就移除
  final bool once;

  const EasyClientListener({this.ondata, this.once = false});
}

///
///客户端请求处理器
///
class EasyClientRequester {
  ///请求成功的处理函数
  final void Function(EasyPacket packet)? ondata;

  ///请求失败的处理函数
  final void Function(EasyPacket packet)? onerror;

  ///请求的时间（毫秒时间戳）
  final int time;

  EasyClientRequester({this.ondata, this.onerror}) : time = DateTime.now().millisecondsSinceEpoch;
}

///
///服务端配置
///
class EasyServerConfig {
  ///日志级别
  final EasyLogLevel logLevel;

  ///日志标签
  final String? logTag;

  ///域名
  final String host;

  ///端口号
  final int port;

  ///数据加解密密码，为null时不启用数据加解密
  final String? pwd;

  ///内部推送数据包签名验签密钥
  final String secret;

  ///true使用二进制收发数据，false使用字符串收发数据
  final bool binary;

  ///心跳检测周期（毫秒）
  final int heart;

  ///两个心跳包之间的最大间隔时间（毫秒）
  final int timeout;

  ///校验重复包的包id缓存数量
  final int reqIdCache;

  ///获取ip地址的请求头
  final String ipHeader;

  ///需要连接的集群节点
  final Map<String, List<String>> links;

  const EasyServerConfig({
    this.logLevel = EasyLogLevel.trace,
    this.logTag,
    required this.host,
    required this.port,
    this.pwd,
    this.secret = '',
    this.binary = false,
    this.heart = 60 * 1000,
    this.timeout = 60 * 1000 * 3,
    this.reqIdCache = 32,
    this.ipHeader = 'x-forwarded-for',
    this.links = const {},
  });
}

///
///服务端会话
///
class EasyServerSession {
  ///id自增量
  static int _increment = 1;

  ///会话id
  final int _id;

  ///套接字
  final WebSocketChannel _socket;

  ///ip地址
  final String _ip;

  ///自定义缓存数据
  final Map<String, dynamic> _context;

  ///自定义消息推送组
  final Map<String, bool> _channel;

  ///最近请求的id列表
  final List<int> _reqIds;

  ///最近收到心跳包的时间
  int _lastHeart;

  ///用户id
  String? _uid;

  ///用户token
  String? _token;

  ///创建实例
  ///
  ///[socket] 客户端的websocket连接
  ///
  ///[ip] 客户端ip地址
  EasyServerSession({required WebSocketChannel socket, required String ip})
      : _id = _increment++,
        _socket = socket,
        _ip = ip,
        _context = {},
        _channel = {},
        _reqIds = [],
        _uid = null,
        _lastHeart = DateTime.now().millisecondsSinceEpoch;

  ///发送数据
  void send(dynamic data) {
    _socket.sink.add(data);
  }

  ///关闭连接
  void close(int code, String resaon) => _socket.sink.close(code, resaon);

  ///缓存键值对数据
  void setContext<T>(String key, T value) => _context[key] = value;

  ///读取键值对数据
  T getContext<T>(String key) => _context[key];

  ///删除键值对数据
  void delContext(String key) => _context.remove(key);

  ///加入指定推送组
  void joinChannel(String cid) => _channel[cid] = true;

  ///退出指定推送组
  void quitChannel(String cid) => _channel.remove(cid);

  ///遍历已加入的全部推送组
  void eachChannel(void Function(String cid) callback) => _channel.forEach((key, value) => callback(key));

  ///更新流量统计信息，同时返回是否收到重复包
  ///
  ///[reqId] 请求id
  ///
  ///[cacheSize] 缓存reqId数量上限
  bool isRepeat(int reqId, int cacheSize) {
    if (_reqIds.lastIndexOf(reqId) >= 0) {
      return true; //收到重复包
    }
    if (_reqIds.length >= cacheSize) {
      _reqIds.removeRange(0, (cacheSize / 2).floor()); //清掉队列前的一半缓存
    }
    _reqIds.add(reqId);
    return false;
  }

  ///更新最近收到心跳包的时间
  void heartick() => _lastHeart = DateTime.now().millisecondsSinceEpoch;

  ///是否已经超时未收到心跳包
  ///
  ///[timeout] 超时时间（毫秒）
  bool isExpired(int timeout) => DateTime.now().millisecondsSinceEpoch > _lastHeart + timeout;

  ///绑定用户id
  void bindUid(String uid, {required String? token}) {
    _uid = uid;
    _token = token;
  }

  ///解绑用户id
  void unbindUid() {
    _uid = null;
    _token = null;
  }

  ///是否绑定了uid
  bool isBinded() => _uid != null;

  ///自增id
  int get id => _id;

  ///ip地址
  String get ip => _ip;

  ///用户id
  String? get uid => _uid;

  ///用户token
  String? get token => _token;

  ///信息
  String get info => '$_ip $_id $_uid';

  ///连接关闭的状态码
  int? get closeCode => _socket.closeCode;

  ///连接关闭的状态信息
  String? get closeReason => _socket.closeReason;
}

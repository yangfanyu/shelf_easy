import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

///
///一些常量
///
///本框架Websocket保留状态码:
///
/// * 4001-4100 服务端保留状态码范围
/// * 4101-4200 客户端保留状态码范围
/// * 4201-4999 可自定义的状态码范围
///
///更多状态码资料参考： https://tools.ietf.org/html/rfc6455#section-7.4.2 和 https://github.com/websockets/ws/issues/715
class EasyConstant {
  /* **************** websocket保留路由 **************** */
  ///初始化路由
  static const routeInitiate = '__initiate__';

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

  ///由客户端完成请求的响应
  static const routeFinished = '__finished__';

  /* **************** websocket被关闭的原因 **************** */

  ///服务端解析数据失败
  static const serverCloseByParseError = EasyPacket._(code: 4001, desc: 'serverCloseByParseError');

  ///服务端校验重复id包未通过
  static const serverCloseByRepeatError = EasyPacket._(code: 4002, desc: 'serverCloseByRepeatError');

  ///服务端检验数据签名未通过
  static const serverCloseBySignatureError = EasyPacket._(code: 4003, desc: 'serverCloseBySignatureError');

  ///服务端没有对应的路由方法
  static const serverCloseByRouteNotFound = EasyPacket._(code: 4004, desc: 'serverCloseByRouteNotFound');

  ///服务端没有对应的远程方法
  static const serverCloseByRemoteNotRound = EasyPacket._(code: 4005, desc: 'serverCloseByRemoteNotRound');

  ///服务端会话的套接字发生错误
  static const serverCloseBySocketError = EasyPacket._(code: 4006, desc: 'serverCloseBySocketError');

  ///服务端会话长时间未收到心跳包
  static const serverCloseByTimeoutError = EasyPacket._(code: 4007, desc: 'serverCloseByTimeoutError');

  ///服务端有新会话绑定了同样的uid
  static const serverCloseByNewbindError = EasyPacket._(code: 4008, desc: 'serverCloseByNewbindError');

  ///服务端调用kickout函数关闭会话
  static const serverCloseByKickoutError = EasyPacket._(code: 4009, desc: 'serverCloseByKickoutError');

  ///客户端尝试重新连接
  static const clientCloseByRetry = EasyPacket._(code: 4101, desc: 'clientCloseByRetry');

  ///客户端触发error事件
  static const clientCloseByError = EasyPacket._(code: 4103, desc: 'clientCloseByError');

  ///客户端触发done事件
  static const clientCloseByDone = EasyPacket._(code: 4102, desc: 'clientCloseByDone');

  ///客户端主动关闭连接
  static const clientCloseByDestroy = EasyPacket._(code: 4104, desc: 'clientCloseByDestroy');

  ///客户端未知关闭原因
  static const clientCloseByUnknow = EasyPacket._(code: 4106, desc: 'clientCloseByUnknow');
}

///
///日志级别
///
///注意保持定义顺序不变，因为[EasyLogger]使用了index值进行判断
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
/// 日志处理方法
///
typedef EasyLogHandler = void Function(EasyLogger instance, String msg, EasyLogLevel logLevel);

///
///日志处理
///
class EasyLogger {
  ///日志处理器
  final EasyLogHandler _logger;

  ///日志级别
  final EasyLogLevel _logLevel;

  ///日志标签
  final String _logTag;

  ///日志输出文件路径
  final String? _logFilePath;

  ///日志文件保存数量
  final int _logFileBackup;

  ///日志文件每份大小（字节）
  final int _logFileMaxBytes;

  String get logTag => _logTag;

  EasyLogger({
    EasyLogHandler? logger,
    EasyLogLevel? logLevel,
    String? logTag,
    String? logFilePath,
    int? logFileBackup,
    int? logFileMaxBytes,
  })  : _logger = logger ?? EasyLogger.printLogger,
        _logLevel = logLevel ?? EasyLogLevel.trace,
        _logTag = logTag ?? 'EasyLogger',
        _logFilePath = logFilePath,
        _logFileBackup = logFileBackup ?? 8,
        _logFileMaxBytes = logFileMaxBytes ?? 8 * 1024 * 1024;

  void logTrace(List<dynamic> args) {
    if (EasyLogLevel.trace.index >= _logLevel.index) {
      _logger(this, '[TRACE] ${DateTime.now().toIso8601String()} $_logTag ${args.join(' ')}', EasyLogLevel.trace);
    }
  }

  void logDebug(List<dynamic> args) {
    if (EasyLogLevel.debug.index >= _logLevel.index) {
      _logger(this, '[DEBUG] ${DateTime.now().toIso8601String()} $_logTag ${args.join(' ')}', EasyLogLevel.debug);
    }
  }

  void logInfo(List<dynamic> args) {
    if (EasyLogLevel.info.index >= _logLevel.index) {
      _logger(this, '[INFO] ${DateTime.now().toIso8601String()} $_logTag ${args.join(' ')}', EasyLogLevel.info);
    }
  }

  void logWarn(List<dynamic> args) {
    if (EasyLogLevel.warn.index >= _logLevel.index) {
      _logger(this, '[WARN] ${DateTime.now().toIso8601String()} $_logTag ${args.join(' ')}', EasyLogLevel.warn);
    }
  }

  void logError(List<dynamic> args) {
    if (EasyLogLevel.error.index >= _logLevel.index) {
      _logger(this, '[ERROR] ${DateTime.now().toIso8601String()} $_logTag ${args.join(' ')}', EasyLogLevel.error);
    }
  }

  ///当前输出文件缓存
  static final Map<String, File> _filesMap = {};

  ///使用[print]输出到控制台
  static void printLogger(EasyLogger instance, String msg, EasyLogLevel logLevel) {
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

  ///使用[stdout]输出到控制台
  static void stdoutLogger(EasyLogger instance, String msg, EasyLogLevel logLevel) {
    switch (logLevel) {
      case EasyLogLevel.trace:
        stdout.writeln('\x1B[34m$msg\x1B[0m');
        break;
      case EasyLogLevel.debug:
        stdout.writeln('\x1B[36m$msg\x1B[0m');
        break;
      case EasyLogLevel.info:
        stdout.writeln('\x1B[32m$msg\x1B[0m');
        break;
      case EasyLogLevel.warn:
        stdout.writeln('\x1B[33m$msg\x1B[0m');
        break;
      case EasyLogLevel.error:
        stdout.writeln('\x1B[31m$msg\x1B[0m');
        break;
    }
  }

  ///写入到日志文件，注意：为避免并发异步写入混乱，目前采用的全部是同步操作
  static void writeLogger(EasyLogger instance, String msg, EasyLogLevel logLevel) {
    if (instance._logFilePath == null) return;
    try {
      //检测文件是否存在，不存在则创建新的
      File? file = _filesMap[instance._logFilePath];
      if (file == null) {
        file = File('${instance._logFilePath}.log');
        _filesMap[instance._logFilePath!] = file;
        if (!file.existsSync()) file.createSync(recursive: true); //同步创建
      }
      //同步写入可避免顺序混乱
      file.writeAsStringSync('$msg\n', mode: FileMode.append, flush: true);
      //检查当前文件大大小，进行备份
      if (file.lengthSync() > instance._logFileMaxBytes) {
        //获取目录下的历史备份文件
        final fileList = <File>[];
        final entityList = file.parent.listSync();
        for (var entity in entityList) {
          if (entity.path.startsWith(file.path)) {
            fileList.add(File(entity.path));
          }
        }
        //根据名称升序排列
        fileList.sort((a, b) => a.path.compareTo(b.path));
        //移除多余的文件
        while (fileList.length > instance._logFileBackup) {
          fileList.removeLast().deleteSync();
        }
        //逆序重命名
        for (var i = fileList.length - 1; i >= 0; i--) {
          fileList[i].renameSync('${instance._logFilePath}.log.${i + 1}');
        }
        //从当前缓存文件中移除掉
        _filesMap.remove(instance._logFilePath);
      }
    } catch (error) {
      //从当前缓存文件中移除掉
      _filesMap.remove(instance._logFilePath);
    }
  }

  ///同时输出到控制台和写入到文件
  static void printAndWriteLogger(EasyLogger instance, String msg, EasyLogLevel logLevel) {
    printLogger(instance, msg, logLevel);
    writeLogger(instance, msg, logLevel);
  }

  ///同时输出到控制台和写入到文件
  static void stdoutAndWriteLogger(EasyLogger instance, String msg, EasyLogLevel logLevel) {
    stdoutLogger(instance, msg, logLevel);
    writeLogger(instance, msg, logLevel);
  }
}

///
///数据包类
///
class EasyPacket<T> {
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

  ///自定义扩展结果字段，不参与任何转换工作，纯粹由使用者自定义值
  final T? extra;

  ///状态是否正确
  bool get ok => code == 200;

  String get codeDesc => '[$code:$desc]';

  const EasyPacket._({this.route = '', this.id = 0, this.code = 200, this.desc = 'OK', this.data, this.ucid, this.word, this.sign, this.extra});

  /* **************** 服务端推送使用 **************** */

  ///服务端创建推送响应包
  factory EasyPacket.pushresp({required String route, required int id, required int code, required String desc, required Map<String, dynamic>? data}) => EasyPacket._(route: route, id: id, code: code, desc: desc, data: data);

  ///服务端创建推送数据包
  factory EasyPacket.pushdata({required String route, required Map<String, dynamic>? data}) => EasyPacket._(route: route, data: data);

  ///服务端创建推送签名包
  factory EasyPacket.pushsign(String secret, {required String route, required Map<String, dynamic>? data, required String? ucid}) {
    final word = EasySecurity.uuid.v4();
    final sign = EasySecurity.getMd5('$secret$route$word$secret');
    return EasyPacket._(route: route, data: data, ucid: ucid, word: word, sign: sign);
  }

  /* **************** 客户端请求使用 **************** */

  ///客户端创建请求数据包
  factory EasyPacket.request({required String route, required int id, required String desc, required Map<String, dynamic>? data}) => EasyPacket._(route: route, id: id, desc: desc, data: data);

  ///客户端数据发送完毕
  EasyPacket requestFinished() => EasyPacket._(route: EasyConstant.routeFinished, id: id, code: 200, desc: 'Client Side Finished');

  ///客户端收到的状态码错误
  EasyPacket requestStatusCodeError({required int status, String? reason}) => EasyPacket._(route: EasyConstant.routeFinished, id: id, code: status, desc: 'Client Side StatusCode Error: ${reason ?? status}');

  ///客户端未建立连接
  EasyPacket requestNotConnected() => EasyPacket._(route: EasyConstant.routeFinished, id: id, code: 601, desc: 'Client Side Not Connected');

  ///客户端编码数据失败
  EasyPacket requestEncryptError() => EasyPacket._(route: EasyConstant.routeFinished, id: id, code: 602, desc: 'Client Side Encrypt Error');

  ///客户端解码数据失败
  EasyPacket requestDecryptError() => EasyPacket._(route: EasyConstant.routeFinished, id: id, code: 603, desc: 'Client Side Decrypt Error');

  ///客户端未知错误
  EasyPacket requestExceptionError({required Object error}) => EasyPacket._(route: EasyConstant.routeFinished, id: id, code: 604, desc: 'Client side Exception Error: $error');

  ///客户端请求超时
  EasyPacket requestTimeoutError() => EasyPacket._(route: EasyConstant.routeFinished, id: id, code: 605, desc: 'Client Side Timeout Error');

  ///客户端已经销毁
  EasyPacket requestExpiredError() => EasyPacket._(route: EasyConstant.routeFinished, id: id, code: 606, desc: 'Client Side Expired Error');

  /* **************** 服务端响应使用 **************** */

  ///服务端响应
  EasyPacket response({required int code, String? desc, Map<String, dynamic>? data}) => EasyPacket._(route: EasyConstant.routeResponse, id: id, code: code, desc: desc ?? '$code', data: data);

  ///服务端处理成功
  EasyPacket responseOk({String? desc, Map<String, dynamic>? data}) => EasyPacket._(route: EasyConstant.routeResponse, id: id, code: 200, desc: desc ?? 'Server Side OK', data: data);

  ///服务端权限认证未通过
  EasyPacket responseUnauthorized({String? desc}) => EasyPacket._(route: EasyConstant.routeResponse, id: id, code: 401, desc: desc ?? 'Server Side Unauthorized');

  ///服务端禁止客户端访问
  EasyPacket responseMethodNotAllowed({String? desc}) => EasyPacket._(route: EasyConstant.routeResponse, id: id, code: 405, desc: desc ?? 'Server Side Method Not Allowed');

  ///服务端内部错误，无法完成客户端请求
  EasyPacket responseInternalServerError({String? desc}) => EasyPacket._(route: EasyConstant.routeResponse, id: id, code: 500, desc: desc ?? 'Server Side Internal Server Error');

  /* **************** 其他方法 **************** */

  ///根据Map创建新实例
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

  ///转换为Map格式数据
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

  ///克隆一个实例并赋值extra字段
  EasyPacket<E> cloneExtra<E>(E? extra) => EasyPacket<E>._(route: route, id: id, code: code, desc: desc, data: data, ucid: ucid, word: word, sign: sign, extra: extra);

  ///验证签名是否错误
  bool isSignError(String secret) => EasySecurity.getMd5('$secret$route$word$secret') != sign;

  ///jsonEncode(this)抛出的异常被吃掉了，所以需要写成jsonEncode(toJson())
  @override
  String toString() => '$runtimeType(${jsonEncode(toJson())})';
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
        _copyUint8List(binary, encRes, salt, 0);
        _copyUint8List(binary, encRes, iv, salt.length);
        _copyUint8List(binary, encRes, body, salt.length + iv.length);
        return binary ? encRes : base64Encode(encRes);
      } else {
        return binary ? plainText.codeUnits : plainText;
      }
    } catch (error) {
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
          _copyUint8List(true, bytes, copy, 0);
        } else if (data is Uint8List) {
          bytes = Uint8List(data.length); //Native is Uint8List
          _copyUint8List(true, bytes, data, 0);
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
    } catch (error) {
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
  static void _copyUint8List(bool swapInt32Endian, Uint8List to, Uint8List from, int toOffset) {
    // if (swapInt32Endian) {
    //   for (int i = 0; i < from.length; i += 4) {
    //     to[toOffset + i + 0] = from[i + 3];
    //     to[toOffset + i + 1] = from[i + 2];
    //     to[toOffset + i + 2] = from[i + 1];
    //     to[toOffset + i + 3] = from[i + 0];
    //   }
    // } else {
    for (int i = 0; i < from.length; i++) {
      to[toOffset + i] = from[i];
    }
    // }
  }
}

///
///客户端配置
///
class EasyClientConfig {
  ///日志处理方法
  final EasyLogHandler? logger;

  ///日志级别
  final EasyLogLevel? logLevel;

  ///日志标签
  final String? logTag;

  ///日志输出文件路径
  final String? logFilePath;

  ///日志文件保存数量
  final int? logFileBackup;

  ///日志文件每份大小（字节）
  final int? logFileMaxBytes;

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

  EasyClientConfig({
    this.logger,
    this.logLevel,
    this.logTag,
    this.logFilePath,
    this.logFileBackup,
    this.logFileMaxBytes,
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

  EasyClientListener({this.ondata, this.once = false});
}

///
///客户端请求处理器
///
class EasyClientRequester {
  //请求数据包
  final EasyPacket packet;

  ///异步完成器
  final Completer<EasyPacket> completer;

  ///请求的时间（毫秒时间戳）
  final int time;

  EasyClientRequester(this.packet, this.completer) : time = DateTime.now().millisecondsSinceEpoch;
}

///
///服务端配置
///
class EasyServerConfig {
  ///日志处理方法
  final EasyLogHandler? logger;

  ///日志级别
  final EasyLogLevel? logLevel;

  ///日志标签
  final String? logTag;

  ///日志输出文件路径
  final String? logFilePath;

  ///日志文件保存数量
  final int? logFileBackup;

  ///日志文件每份大小（字节）
  final int? logFileMaxBytes;

  ///监听域名
  final String host;

  ///监听端口号
  final int port;

  ///集群启动的实例数量，建议只对web服务设置设置该值>1，因为websocket服务每个session是有状态的
  final int instances;

  ///数据加解密密码，为null时不启用数据加解密
  final String? pwd;

  ///内部通讯数据包签名验签密钥
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

  //响应http请求的额外请求头信息
  final Map<String, String>? httpHeaders;

  ///ssl模式key文件路径
  final String? sslKeyFile;

  ///ssl模式cer文件路径
  final String? sslCerFile;

  ///需要远程连接的集群分组
  final List<String>? links;

  ///需要远程连接的集群分组配置信息
  final Map<String, List<EasyServerConfig>> clusterConfigs;

  ///数据库配置信息
  final EasyUniDbConfig? uniDbConfig;

  ///是否启用ssl模式
  bool get sslsEnable => sslKeyFile != null && sslCerFile != null;

  ///http请求地址
  String get httpUrl => sslsEnable ? 'https://$host:$port' : 'http://$host:$port';

  ///websocket连接地址
  String get websocketUrl => sslsEnable ? 'wss://$host:$port' : 'ws://$host:$port';

  EasyServerConfig({
    this.logger,
    this.logLevel,
    this.logTag,
    this.logFilePath,
    this.logFileBackup,
    this.logFileMaxBytes,
    required this.host,
    required this.port,
    this.instances = 1,
    this.pwd,
    this.secret = 'secret',
    this.binary = false,
    this.heart = 60 * 1000,
    this.timeout = 60 * 1000 * 3,
    this.reqIdCache = 32,
    this.ipHeader = 'x-forwarded-for',
    this.httpHeaders,
    this.sslKeyFile,
    this.sslCerFile,
    this.links,
    this.uniDbConfig,
  }) : clusterConfigs = {};

  ///初始化需要远程连接的集群分组配置信息
  void initClusterConfigs(Map<String, List<EasyServerConfig>> clusterServerConfigs) {
    links?.forEach((cluster) {
      clusterConfigs[cluster] = clusterServerConfigs[cluster] ?? [];
    });
  }
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

  ///绑定用户信息
  void bindUser(String uid, {required String? token}) {
    _uid = uid;
    _token = token;
  }

  ///解绑用户信息
  void unbindUser() {
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
  String get info => '[$_ip $_id ${_uid ?? 'uid'}]';

  ///连接关闭的状态码
  int? get closeCode => _socket.closeCode;

  ///连接关闭的状态信息
  String? get closeReason => _socket.closeReason;
}

///
///数据库驱动类型
///
enum EasyUniDbDriver {
  ///可用于Native端与Web端
  hive,

  ///用于Native端
  mongo,

  ///用于Native端
  postgre,
}

///
///数据库配置信息
///
class EasyUniDbConfig {
  ///日志处理方法
  final EasyLogHandler? logger;

  ///日志级别
  final EasyLogLevel? logLevel;

  ///日志标签
  final String? logTag;

  ///日志输出文件路径
  final String? logFilePath;

  ///日志文件保存数量
  final int? logFileBackup;

  ///日志文件每份大小（字节）
  final int? logFileMaxBytes;

  ///驱动类型
  final EasyUniDbDriver driver;

  ///数据库域名
  final String host;

  ///数据库端口
  final int port;

  ///数据库用户名
  final String? user;

  ///数据库密码
  final String? password;

  ///数据库名称
  final String db;

  ///连接池大小
  final int poolSize;

  ///其他连接参数
  final Map<String, String> params;

  EasyUniDbConfig({
    this.logger,
    this.logLevel,
    this.logTag,
    this.logFilePath,
    this.logFileBackup,
    this.logFileMaxBytes,
    required this.driver,
    required this.host,
    required this.port,
    this.user,
    this.password,
    required this.db,
    this.poolSize = 8,
    required this.params,
  });
}

///
///代码生成器配置
///
class EasyCoderConfig {
  static const defaultType = '__defaultType__';

  ///日志处理方法
  final EasyLogHandler? logger;

  ///日志级别
  final EasyLogLevel? logLevel;

  ///日志标签
  final String? logTag;

  ///日志输出文件路径
  final String? logFilePath;

  ///日志文件保存数量
  final int? logFileBackup;

  ///日志文件每份大小（字节）
  final int? logFileMaxBytes;

  ///导出文件路径
  final String absFolder;

  ///代码缩进单位
  final String indent;

  ///基本数据类型fromJson方法-值转换
  final Map<String, String> baseFromJsonVals;

  ///嵌套数据类型fromJson方法-键转换（经过测试发现：jsonEncode操作Map时只支持以字符串为key，mongo数据库保存Map时只支持以字符串为key）
  final Map<String, String> nestFromJsonKeys;

  ///嵌套数据类型fromJson方法-值转换
  final Map<String, String> nestFromJsonVals;

  EasyCoderConfig({
    this.logger,
    this.logLevel,
    this.logTag,
    this.logFilePath,
    this.logFileBackup,
    this.logFileMaxBytes,
    required this.absFolder,
    this.indent = '  ',
    Map<String, String> customBaseFromJsonVals = const {},
    Map<String, String> customNestFromJsonKeys = const {},
    Map<String, String> customNestFromJsonVals = const {},
  })  : baseFromJsonVals = {
          'int': 'DbQueryField.tryParseInt(#)',
          'double': 'DbQueryField.tryParseDouble(#)',
          'num': 'DbQueryField.tryParseNum(#)',
          'bool': 'DbQueryField.tryParseBool(#)',
          'String': 'DbQueryField.tryParseString(#)',
          'ObjectId': 'DbQueryField.tryParseObjectId(#)',
          defaultType: '# is Map ? @.fromJson(#) : #',
          ...customBaseFromJsonVals,
        },
        nestFromJsonKeys = {
          'int': 'DbQueryField.parseInt(#)',
          'double': 'DbQueryField.parseDouble(#)',
          'num': 'DbQueryField.parseNum(#)',
          'bool': 'DbQueryField.parseBool(#)',
          'String': 'DbQueryField.parseString(#)',
          'ObjectId': 'DbQueryField.parseObjectId(#)',
          defaultType: '@.fromString(#)',
          ...customNestFromJsonKeys,
        },
        nestFromJsonVals = {
          'int': 'DbQueryField.parseInt(#)',
          'double': 'DbQueryField.parseDouble(#)',
          'num': 'DbQueryField.parseNum(#)',
          'bool': 'DbQueryField.parseBool(#)',
          'String': 'DbQueryField.parseString(#)',
          'ObjectId': 'DbQueryField.parseObjectId(#)',
          defaultType: '@.fromJson(#)',
          ...customNestFromJsonVals,
        };

  static String compileTemplateCode(String templateCode, String valueCode, String typeCode) {
    return templateCode.replaceAll('#', valueCode).replaceAll('@', typeCode);
  }
}

///
///代码生成器模型信息
///
class EasyCoderModelInfo {
  ///模型类的import部分
  final List<String> importList;

  ///模型类的注释信息
  final List<String> classDesc;

  ///模型类的名称
  final String className;

  ///模型常量字段
  final List<EasyCoderFieldInfo> constFields;

  ///模型变量字段
  final List<EasyCoderFieldInfo> classFields;

  ///模型扩展字段，这一部分字段不参与序列化和查询
  final List<EasyCoderFieldInfo> extraFields;

  ///是否生成constFields字段的Map映射，为true时每个常量字段类型必须为int
  final bool constMap;

  ///是否生成写入辅助类
  final bool dirty;

  ///是否生成查询辅助类
  final bool query;

  EasyCoderModelInfo({
    required this.importList,
    required this.classDesc,
    required this.className,
    required this.constFields,
    required this.classFields,
    required this.extraFields,
    this.constMap = false,
    this.dirty = true,
    this.query = true,
  });
}

///
///代码生成器字段信息
///
class EasyCoderFieldInfo {
  ///字段类型
  final String type;

  ///字段名称
  final String name;

  ///字段注释信息
  final List<String> desc;

  ///是否为保密字段
  final bool secrecy;

  ///是否可以为null
  final bool nullAble;

  ///字段默认值
  final String? defVal;

  ///常量字段映射的中文值
  final String? zhText;

  ///常量字段映射的英文值
  final String? enText;

  EasyCoderFieldInfo({
    required this.type,
    required this.name,
    required this.desc,
    this.secrecy = false,
    this.nullAble = false,
    this.defVal,
    this.zhText,
    this.enText,
  });
}

import 'dart:async';

///
///线程操作接口
///
abstract class WkBase {
  ///启动线程
  Future<void> start() => throw UnimplementedError();

  ///关闭线程
  Future<void> close() => throw UnimplementedError();

  ///运行线程任务
  Future<T?> runTask<T>({WkSignal signal = WkSignal.message, String taskType = '', dynamic taskData}) => throw UnimplementedError();
}

///
///线程配置
///
class WkConfig {
  ///调用任务函数runTask后，未得到返回结果的超时时间（毫秒）
  final int timeout;

  ///服务配置信息
  final Map<String, dynamic> serviceConfig;

  ///内部服务处理器（顶级函数 或 静态函数）
  final Future<dynamic> Function(WkSignal signal, Map<String, dynamic> config) serviceHandler;

  ///外部消息处理器（顶级函数 或 静态函数）
  final Future<dynamic> Function(String taskType, dynamic taskData) messageHandler;

  ///数据通讯端口
  dynamic sendPort;

  WkConfig({
    this.timeout = 10 * 1000,
    required this.serviceConfig,
    required this.serviceHandler,
    required this.messageHandler,
    this.sendPort,
  });
}

///
///线程任务
///
class WkTask<T> {
  ///请求的时间
  final int time;

  ///异步完成器
  final Completer<T> completer;

  WkTask(this.completer) : time = DateTime.now().millisecondsSinceEpoch;
}

///
///线程信号
///
enum WkSignal {
  ///开启
  start,

  ///关闭
  close,

  ///消息
  message,
}

///
///线程通讯消息
///
class WkMessage {
  ///消息信号类型
  final WkSignal signal;

  ///消息唯一标志
  final int id;

  ///自定义类型
  final String type;

  ///自定义数据
  final dynamic data;

  WkMessage(
    this.signal,
    this.id,
    this.type,
    this.data,
  );
}

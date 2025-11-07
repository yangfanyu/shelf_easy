import 'dart:async';
import 'dart:isolate';

import 'wk_base.dart';

class WkNative implements WkBase {
  final WkConfig _config;
  final Map<int, WkTask> _taskMap = {};
  int _taskIdInc = 0;
  ReceivePort? _receivePort;
  Isolate? _isolate;
  SendPort? _sendPort;
  Timer? _timer; //秒钟计时器

  WkNative(this._config);

  @override
  Future<void> start({bool runErrorsZone = true, bool errorsAreFatal = false}) {
    if (_receivePort != null) return Future.value();
    final completer = Completer();
    _receivePort = ReceivePort();
    _config.sendPort = _receivePort?.sendPort;
    _receivePort?.listen((message) async {
      if (message is SendPort) {
        _sendPort = message;
        await runTask(signal: WkSignal.start); //发送服务开启信号
        completer.complete();
      } else if (message is WkMessage) {
        final task = _taskMap.remove(message.id);
        task?.completer.complete(message.data);
      }
    }, cancelOnError: false);
    Isolate.spawn(runErrorsZone ? _entryPointZone : _entryPoint, _config, errorsAreFatal: errorsAreFatal).then((value) {
      _isolate = value;
      _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) => _onHeartick());
    });
    return completer.future;
  }

  @override
  Future<void> close() async {
    await runTask(signal: WkSignal.close); //发送服务关闭信号
    _timer?.cancel();
    _receivePort?.close();
    _isolate?.kill();
  }

  @override
  Future<T?> runTask<T>({WkSignal signal = WkSignal.message, String taskType = '', dynamic taskData}) {
    if (_sendPort == null) return Future.value(null);
    final taskId = _taskIdInc++;
    final completer = Completer<T>();
    final tasker = WkTask(completer);
    _taskMap[taskId] = tasker;
    _sendPort?.send(WkMessage(signal, taskId, taskType, taskData));
    return tasker.completer.future;
  }

  ///清除超时的任务
  void _onHeartick() {
    final time = DateTime.now().millisecondsSinceEpoch;
    final list = <int>[];
    _taskMap.forEach((id, task) {
      if (time - task.time > _config.timeout) list.add(id);
    });
    for (var id in list) {
      final task = _taskMap.remove(id);
      task?.completer.complete(null);
    }
  }

  ///子线程入口函数
  static void _entryPointZone(WkConfig config) {
    runZonedGuarded(
      () {
        _entryPoint(config);
      },
      (error, stack) {
        config.messageHandler(config.serviceConfig, WkMessage.runZonedGuardedError, [error, stack]);
      },
    );
  }

  static void _entryPoint(WkConfig config) {
    final ReceivePort receivePort = ReceivePort();
    final SendPort sendPort = config.sendPort;
    receivePort.listen((message) async {
      if (message is WkMessage) {
        switch (message.signal) {
          case WkSignal.start:
          case WkSignal.close:
            try {
              final result = await config.serviceHandler(message.signal, config.serviceConfig);
              sendPort.send(WkMessage(message.signal, message.id, message.type, result));
            } catch (error) {
              sendPort.send(WkMessage(message.signal, message.id, message.type, false));
            }
            break;
          case WkSignal.message:
            try {
              final result = await config.messageHandler(config.serviceConfig, message.type, message.data);
              sendPort.send(WkMessage(message.signal, message.id, message.type, result));
            } catch (error) {
              sendPort.send(WkMessage(message.signal, message.id, message.type, null));
            }
            break;
        }
      }
    }, cancelOnError: false);
    sendPort.send(receivePort.sendPort);
  }
}

WkBase create(WkConfig config) => WkNative(config);

import 'dart:async';
import 'dart:html';

import 'wk_base.dart';

class WkHtml implements WkBase {
  final WkConfig _config;
  final Map<int, WkTask> _taskMap = {};
  int _taskIdInc = 0;
  Worker? _worker;
  StreamSubscription<MessageEvent>? _workerSubscription;
  Timer? _timer; //秒钟计时器

  WkHtml(this._config);

  @override
  Future<void> start() {
    if (_worker != null) return Future.value();
    final completer = Completer();
    if (Worker.supported) {
      _worker = Worker('wk_html_worker.js');
      _workerSubscription = _worker?.onMessage.listen((event) async {
        final message = event.data;
        if (message is String && message == 'inited') {
          await runTask(signal: WkSignal.start); //发送服务开启信号
          completer.complete();
        } else if (message is WkMessage) {
          final task = _taskMap.remove(message.id);
          task?.completer.complete(message.data);
        }
      });
      _worker?.postMessage(_config);
      _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) => _onHeartick());
    }
    return completer.future;
  }

  @override
  Future<void> close() async {
    await runTask(signal: WkSignal.close); //发送服务关闭信号
    _timer?.cancel();
    _workerSubscription?.cancel();
    _worker?.terminate();
  }

  @override
  Future<T?> runTask<T>({WkSignal signal = WkSignal.message, String taskType = '', dynamic taskData}) {
    if (_worker == null) return Future.value(null);
    final taskId = _taskIdInc++;
    final completer = Completer<T>();
    final tasker = WkTask(completer);
    _taskMap[taskId] = tasker;
    _worker?.postMessage(WkMessage(signal, taskId, taskType, taskData));
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
}

WkBase create(WkConfig config) => WkHtml(config);

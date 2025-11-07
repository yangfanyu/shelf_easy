import 'dart:async';
import 'dart:io';

import 'package:shelf_easy/shelf_easy.dart';
import 'package:shelf_easy/src/wk/wk_unsupport.dart' if (dart.library.io) 'package:shelf_easy/src/wk/wk_native.dart' if (dart.library.html) 'package:shelf_easy/src/wk/wk_html.dart' as worker;

void main() async {
  final logger = EasyLogger(logTag: '[MASTER]');

  runZonedGuarded(
    () {
      Timer.periodic(Duration(seconds: 2), (timer) {
        throw ('main error');
      });
      for (int i = 0; i < 2; i++) {
        startWorkers(i);
      }
    },
    (error, stack) {
      logger.logError([error, '\n', stack]);
    },
  );
  // Timer.periodic(Duration(seconds: 5), (timer) {
  //   throw ('outer error');
  // });
  //sigint
  ProcessSignal.sigint.watch().listen((signal) {
    logger.logDebug(['ProcessSignal.sigint']);
    exit(0);
  });
}

void startWorkers(int index) {
  //经过测试， 这种方式根本无法捕获
  // final logger = EasyLogger(logTag: '[CHILD-$index]');
  // runZonedGuarded(() {
  //   final wk = worker.create(WkConfig(
  //     serviceConfig: {
  //       'index': index,
  //     },
  //     serviceHandler: _serviceHandler,
  //     messageHandler: _messageHandler,
  //   ));
  //   wk.start();
  // }, (error, stack) {
  //   logger.logError([error, '\n', stack]);
  // });

  final wk = worker.create(
    WkConfig(
      serviceConfig: {
        'index': index,
      },
      serviceHandler: _serviceHandler,
      messageHandler: _messageHandler,
    ),
  );
  wk.start(runErrorsZone: false, errorsAreFatal: true);
}

Future<bool> _serviceHandler(WkSignal signal, Map<String, dynamic> config) async {
  if (signal == WkSignal.start) {
    Timer.periodic(Duration(seconds: 2), (timer) {
      print('---------------------${config.toString()}');
    });
    Timer.periodic(Duration(seconds: 2), (timer) {
      throw (config.toString());
    });
  }
  return true;
}

Future<dynamic> _messageHandler(Map<String, dynamic> config, String type, dynamic data) async {
  final index = config['index'];
  EasyLogger? logger = config['logger'];
  if (logger == null) {
    logger = EasyLogger(logTag: '[CHILD-$index]');
    config['logger'] = logger;
  }
  if (type == WkMessage.runZonedGuardedError) {
    final dataList = data as List;
    final error = dataList[0];
    final stack = dataList[1];
    logger.logFatal([error, '\n', stack]);
  } else {}
  return null;
}

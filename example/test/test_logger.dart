import 'dart:io';

import 'package:shelf_easy/shelf_easy.dart';


void main() {
  final logger = EasyLogger(
    logger: EasyLogger.printAndWriteLogger, //这里设置为：同时输出到控制台和文件（默认情况下输出到控制台）
    logLevel: EasyLogLevel.trace,
    logTag: 'HelloLogger',
    logFilePath: '${Directory.current.path}/logs/test_logger', //日志文件输出路径
  );
  logger.logTrace(['hello', 'world', DateTime.now().toUtc()]);
  logger.logDebug(['hello', 'world', DateTime.now().toUtc()]);
  logger.logInfo(['hello', 'world', DateTime.now().toUtc()]);
  logger.logWarn(['hello', 'world', DateTime.now().toUtc()]);
  logger.logError(['hello', 'world', DateTime.now().toUtc()]);
  logger.logFatal(['hello', 'world', DateTime.now().toUtc()]);
}

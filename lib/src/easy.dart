import 'dart:io';

import 'easy_class.dart';
import 'easy_server.dart';
import 'easy_unidb.dart';
import 'wk/wk_base.dart';
import 'wk/wk_unsupport.dart' if (dart.library.io) 'wk/wk_native.dart' if (dart.library.html) 'wk/wk_html.dart' as worker;

///
///服务器入口函数
///
typedef EasyServerEntryPoint = void Function(String environment, String cluster, EasyServer server, EasyUniDb? uniDb);

///
///集群启动类
///
class Easy {
  static final List<WkBase> _workerList = [];

  ///启动服务器集群
  ///
  /// * [machineBind] 是否只启动与机器名称对应的进程
  /// * [machineFile] 机器名称文件的绝对路径
  /// * [environment] 当前启动的环境
  /// * [envClusterServerConfig] 环境集群配置信息
  /// * [envClusterServerEntryPoint] 环境集群入口函数
  /// * [envDefaultServerConfig] 环境默认配置信息
  /// * [envDefaultServerEntryPoint] 环境默认入口函数
  /// * [defaultLogFolder] 默认日志文件输出文件夹
  /// * [runErrorsZone] 在runZonedGuarded函数中运行子线程逻辑
  /// * [errorsAreFatal] 为true时若在子线程中产生未捕获的异常，将终止子线程的运行
  ///
  static Future<void> startClusterServers({
    bool machineBind = false,
    String machineFile = '/etc/hostname',
    required String environment,
    required Map<String, Map<String, List<EasyClusterNodeConfig>>> envClusterServerConfig,
    Map<String, Map<String, EasyServerEntryPoint>>? envClusterServerEntryPoint,
    Map<String, EasyClusterNodeConfig>? envDefaultServerConfig,
    Map<String, EasyServerEntryPoint>? envDefaultServerEntryPoint,
    String? defaultLogFolder,
    bool runErrorsZone = true,
    bool errorsAreFatal = false,
  }) async {
    final clusterServerConfig = envClusterServerConfig[environment];
    final clusterServerEntryPoint = envClusterServerEntryPoint?[environment];
    final defaultServerConfig = envDefaultServerConfig?[environment];
    final defaultServerEntryPoint = envDefaultServerEntryPoint?[environment];
    final finalServerConfig = <String, List<EasyServerConfig>>{}; //解析后的服务器集群配置信息
    final finalLogFileFolder = defaultLogFolder ?? '${Directory.current.path}/logs'; //日志文件输出文件夹
    clusterServerConfig?.forEach((cluster, serverConfigList) {
      finalServerConfig[cluster] = [];
      for (var serverConfig in serverConfigList) {
        final isolateInstances = serverConfig.isolateInstances ?? defaultServerConfig?.isolateInstances ?? 1;
        for (var i = 0; i < isolateInstances; i++) {
          finalServerConfig[cluster]?.add(
            EasyServerConfig.fromClusterNodeConfig(
              serverConfig: serverConfig,
              globalConfig: defaultServerConfig,
              defaultLogTag: '$environment-$cluster-${serverConfig.host}:${serverConfig.port}${isolateInstances > 1 ? '-$i' : ''}',
              defaultLogFilePath: '$finalLogFileFolder/$environment-$cluster-${serverConfig.port}${isolateInstances > 1 ? '-$i' : ''}',
            ),
          );
        }
      }
    });
    finalServerConfig.forEach((cluster, serverConfigList) {
      for (var serverConfig in serverConfigList) {
        serverConfig.initClusterLinksConfigs(finalServerConfig); //初始化需要远程连接的集群分组配置信息
        if (machineBind && serverConfig.host != File(machineFile).readAsStringSync().trim()) {
          continue; //不匹配主机名
        }
        final serverEntryPoint = clusterServerEntryPoint?[cluster] ?? defaultServerEntryPoint;
        _workerList.add(
          worker.create(
            WkConfig(
              serviceConfig: {
                'environment': environment,
                'cluster': cluster,
                'serverConfig': serverConfig,
                'serverEntryPoint': serverEntryPoint,
              },
              serviceHandler: _serviceHandler,
              messageHandler: _messageHandler,
            ),
          ),
        );
      }
    });
    for (var wk in _workerList) {
      await wk.start(runErrorsZone: runErrorsZone, errorsAreFatal: errorsAreFatal);
    }
  }

  ///关闭服务器集群
  static Future<void> closeClusterServers() async {
    for (var wk in _workerList) {
      await wk.close();
    }
  }

  static Future<bool> _serviceHandler(WkSignal signal, Map<String, dynamic> config) async {
    switch (signal) {
      case WkSignal.start:
        final String environment = config['environment'];
        final String cluster = config['cluster'];
        final EasyServerConfig serverConfig = config['serverConfig'];
        final EasyServerEntryPoint serverEntryPoint = config['serverEntryPoint'];
        if (serverConfig.uniDbConfig == null) {
          final serverInstance = EasyServer(config: serverConfig);
          config['serverInstance'] = serverInstance;
          serverEntryPoint(environment, cluster, serverInstance, null);
          await serverInstance.start();
        } else {
          final serverInstance = EasyServer(config: serverConfig);
          final databaseInstance = EasyUniDb(config: serverConfig.uniDbConfig!);
          config['serverInstance'] = serverInstance;
          config['databaseInstance'] = databaseInstance;
          serverEntryPoint(environment, cluster, serverInstance, databaseInstance);
          await databaseInstance.connect();
          await serverInstance.start();
        }
        break;
      case WkSignal.close:
        final EasyServer? serverInstance = config['serverInstance'];
        final EasyUniDb? databaseInstance = config['databaseInstance'];
        await serverInstance?.close();
        await databaseInstance?.destroy();
        break;
      default:
        break;
    }
    return true;
  }

  static Future<dynamic> _messageHandler(Map<String, dynamic> config, String type, dynamic data) async {
    if (type == WkMessage.runZonedGuardedError) {
      final EasyServer? serverInstance = config['serverInstance'];
      final List dataList = data;
      serverInstance?.logFatal(['runZonedGuardedError =>', dataList[0], '\n', dataList[1]]);
    }
    return null;
  }
}

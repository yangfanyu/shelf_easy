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
  /// * [envClusterServerConfig] 环境集群服务器置信息
  /// * [envClusterDatabaseConfig] 环境数集群据库配置信息
  /// * [envClusterServerEntryPoint] 环境集群入口函数
  /// * [envDefaultDatabaseConfig] 环境默认据库配置信息
  /// * [envDefaultServerEntryPoint] 环境默认入口函数
  ///
  /// 下面的选项如果不为null将会覆盖到每个节点
  ///
  /// * [logger] 日志记录器
  /// * [logLevel] 日志输出级别
  /// * [logFolder] 日志文件输出文件夹
  /// * [logFileBackup] 日志文件保存数量
  /// * [logFileMaxBytes] 日志文件每份大小（字节）
  /// * [pwd] 外部服务器数据加密密码
  /// * [secret] 内部服务器集群之间数据通讯签名密钥
  /// * [binary] websocket服务器是否使用二进制传输数据
  /// * [sslKeyFile] privateKey文件路径
  /// * [sslCerFile] certificate文件路径
  ///
  static startClusterServers({
    bool machineBind = false,
    String machineFile = '/etc/hostname',
    required String environment,
    required Map<String, Map<String, List<EasyServerConfig>>> envClusterServerConfig,
    Map<String, Map<String, EasyUniDbConfig>>? envClusterDatabaseConfig,
    Map<String, Map<String, EasyServerEntryPoint>>? envClusterServerEntryPoint,
    Map<String, EasyUniDbConfig>? envDefaultDatabaseConfig,
    Map<String, EasyServerEntryPoint>? envDefaultServerEntryPoint,
    EasyLogHandler logger = EasyLogger.printLogger,
    EasyLogLevel logLevel = EasyLogLevel.info,
    String? logFolder,
    int? logFileBackup,
    int? logFileMaxBytes,
    String? pwd,
    String? secret,
    bool? binary,
    String? sslKeyFile,
    String? sslCerFile,
  }) async {
    final clusterServerConfig = envClusterServerConfig[environment];
    final clusterDatabaseConfig = envClusterDatabaseConfig?[environment];
    final clusterServerEntryPoint = envClusterServerEntryPoint?[environment];
    final defaultDatabaseConfig = envDefaultDatabaseConfig?[environment];
    final defaultServerEntryPoint = envDefaultServerEntryPoint?[environment];
    final finalServerConfig = <String, List<EasyServerConfig>>{}; //解析后的服务器集群配置信息
    final finalLogFileFolder = logFolder ?? '${Directory.current.path}/logs'; //日志文件输出文件夹
    clusterServerConfig?.forEach((cluster, serverConfigList) {
      finalServerConfig[cluster] = [];
      for (var serverConfig in serverConfigList) {
        final databaseConfig = serverConfig.uniDbConfig ?? clusterDatabaseConfig?[cluster] ?? defaultDatabaseConfig;
        for (var i = 0; i < serverConfig.instances; i++) {
          final logTag = '$environment-$cluster-${serverConfig.host}:${serverConfig.port}${serverConfig.instances > 1 ? '-$i' : ''}';
          final logFilePath = '$finalLogFileFolder/$environment-$cluster-${serverConfig.port}${serverConfig.instances > 1 ? '-$i' : ''}';
          finalServerConfig[cluster]?.add(EasyServerConfig(
            logger: logger,
            logLevel: logLevel,
            logTag: logTag,
            logFilePath: logFilePath,
            logFileBackup: logFileBackup ?? serverConfig.logFileBackup,
            logFileMaxBytes: logFileMaxBytes ?? serverConfig.logFileMaxBytes,
            host: serverConfig.host,
            port: serverConfig.port,
            instances: serverConfig.instances,
            pwd: pwd ?? serverConfig.pwd,
            secret: secret ?? serverConfig.secret,
            binary: binary ?? serverConfig.binary,
            heart: serverConfig.heart,
            timeout: serverConfig.timeout,
            reqIdCache: serverConfig.reqIdCache,
            ipHeader: serverConfig.ipHeader,
            corsHeaders: serverConfig.corsHeaders,
            sslKeyFile: sslKeyFile ?? serverConfig.sslKeyFile,
            sslCerFile: sslCerFile ?? serverConfig.sslCerFile,
            links: serverConfig.links,
            uniDbConfig: databaseConfig == null
                ? null
                : EasyUniDbConfig(
                    logger: logger,
                    logLevel: logLevel,
                    logTag: '$logTag [${databaseConfig.driver.name}://${databaseConfig.host}:${databaseConfig.port}]',
                    logFilePath: logFilePath,
                    logFileBackup: logFileBackup ?? databaseConfig.logFileBackup,
                    logFileMaxBytes: logFileMaxBytes ?? databaseConfig.logFileMaxBytes,
                    driver: databaseConfig.driver,
                    host: databaseConfig.host,
                    port: databaseConfig.port,
                    user: databaseConfig.user,
                    password: databaseConfig.password,
                    db: databaseConfig.db,
                    poolSize: databaseConfig.poolSize,
                    params: databaseConfig.params,
                  ),
          ));
        }
      }
    });
    finalServerConfig.forEach((cluster, serverConfigList) {
      for (var serverConfig in serverConfigList) {
        serverConfig.initClusterConfigs(finalServerConfig); //初始化需要远程连接的集群分组配置信息
        if (machineBind && serverConfig.host != File(machineFile).readAsStringSync().trim()) {
          continue; //不匹配主机名
        }
        final serverEntryPoint = clusterServerEntryPoint?[cluster] ?? defaultServerEntryPoint;
        _workerList.add(worker.create(WkConfig(
          serviceConfig: {
            'environment': environment,
            'cluster': cluster,
            'serverConfig': serverConfig,
            'serverEntryPoint': serverEntryPoint,
          },
          serviceHandler: _serviceHandler,
          messageHandler: _messageHandler,
        )));
      }
    });
    for (var wk in _workerList) {
      await wk.start();
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
    return null;
  }
}

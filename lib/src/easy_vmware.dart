import 'dart:convert';

import 'easy_class.dart';
import 'vm/vm_keys.dart';
import 'vm/vm_object.dart';
import 'vm/vm_parser.dart';
import 'vm/vm_runner.dart';

///
///Dart子集虚拟机
///
class EasyVmWare extends EasyLogger {
  ///配置信息
  final EasyVmWareConfig _config;

  ///运行器实例
  final VmRunner _runner;

  ///调试JSON编码器
  final JsonEncoder _encoder;

  ///程序应用库代码集合
  final Map<String, String> _sourceCodes;

  EasyVmWare({required EasyVmWareConfig config})
      : _config = config,
        _runner = VmRunner(),
        _encoder = JsonEncoder.withIndent('  '),
        _sourceCodes = {},
        super(
          logger: config.logger,
          logLevel: config.logLevel,
          logTag: config.logTag ?? 'EasyVmWare',
          logFilePath: config.logFilePath,
          logFileBackup: config.logFileBackup,
          logFileMaxBytes: config.logFileMaxBytes,
        ) {
    reassemble(sourceCodes: config.sourceCodes);
  }

  ///重新装载
  void reassemble({required Map<String, String> sourceCodes}) {
    logDebug(['reassemble => ', sourceCodes.keys]);
    _sourceCodes.clear();
    _sourceCodes.addAll(sourceCodes);
    final sourceTrees = <String, Map<VmKeys, dynamic>>{};
    _sourceCodes.forEach((key, value) {
      final routeList = <String>[];
      final valueTree = VmParser.parseSource(value, routeList: routeList, routeLogger: _config.debugRoute ? (route) => logDebug([key, '=>', route]) : null);
      if (_config.debugRoute) logDebug([key, '=>', _encoder.convert(routeList), '\n']);
      sourceTrees[key] = valueTree;
    });
    _runner.reassemble(sourceTrees: sourceTrees);
  }

  ///释放内存
  void shutdown() {
    logDebug(['reassemble => ', _sourceCodes.keys]);
    _runner.shutdown();
  }

  ///调用主函数
  T main<T>() {
    return _runner.callFunction(_config.mainMethod, positionalArguments: _config.mainListArgs, namedArguments: _config.mainNameArgs);
  }

  ///调用任意任意函数
  T call<T>({required String methodName, List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments}) {
    return _runner.callFunction(methodName, positionalArguments: positionalArguments, namedArguments: namedArguments);
  }

  ///打印应用库语法树集合
  void debugSourceTrees({String? key}) {
    logDebug([_encoder.convert(_runner.toJsonSourceTrees(key: key))]);
  }

  ///打印运行时作用域堆栈
  void debugObjectStack({int? index, bool simple = true}) {
    logDebug([_encoder.convert(_runner.toJsonObjectStack(index: index, simple: simple))]);
  }

  ///打印虚拟对象的详细信息
  void debugVmObjectInfo({required String key}) {
    logDebug([_encoder.convert(_runner.getVmObject(key))]);
  }

  ///虚拟机全局日志
  static EasyLogger _vmwareLogger = EasyLogger(logTag: 'EasyVmWare');

  ///加载全局作用域
  ///
  /// * [customClassList] 自定义导入的类型
  /// * [customProxyList] 自定义导入的全局方法或实例
  /// * [nativeValueConverter] 读取原生数据值转换器，如：在flutter中经常需要<Widget>[]类型的参数，但虚拟机中实际上是个<dynamic>[]类型
  /// * [quickTypeSpeculationMethod] 加速类型推测的函数
  /// * [logObjectStackInAndOut] 打印对象栈的变化
  /// * [logSlowTypeSpeculation] 打印慢的类型推断
  ///
  static void loadGlobalLibrary({
    EasyLogger? globalLogger,
    List<VmClass> customClassList = const [],
    List<VmProxy> customProxyList = const [],
    dynamic Function(dynamic value)? nativeValueConverter,
    String? Function(dynamic instance)? quickTypeSpeculationMethod,
    bool logObjectStackInAndOut = false,
    bool logSlowTypeSpeculation = true,
  }) {
    _vmwareLogger = globalLogger ?? _vmwareLogger;
    VmObject.nativeValueConverter = nativeValueConverter;
    VmClass.quickTypeSpeculationMethod = quickTypeSpeculationMethod;
    if (logSlowTypeSpeculation) {
      VmClass.slowTypeSpeculationReport = (instance, vmclass, cycles, total) {
        _vmwareLogger.logFatal(['slowTypeSpeculationReport ======>', instance.runtimeType, '------>', vmclass.identifier, '------>', 'cycles:', cycles, '/', total]);
      };
    }
    if (logObjectStackInAndOut) {
      VmRunner.objectStackInAndOutReport = (isIn, isOk, length, members) {
        (isOk ? _vmwareLogger.logDebug : _vmwareLogger.logError)(['objectStackInAndOutReport ======>', isIn ? 'in' : 'out', '------>', isOk ? 'ok' : 'error', '------>', length, '--->', members]);
      };
    }
    VmRunner.loadGlobalLibrary(customClassList: customClassList, customProxyList: customProxyList);
  }

  ///简洁的执行[sourceCode]源代码中的[methodName]函数
  static T eval<T>({required String sourceCode, required String methodName, List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments}) {
    final runner = VmRunner(sourceTrees: {'default': VmParser.parseSource(sourceCode)});
    final result = runner.callFunction(methodName, positionalArguments: positionalArguments, namedArguments: namedArguments);
    runner.shutdown();
    return result;
  }
}

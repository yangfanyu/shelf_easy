import 'easy_class.dart';
import 'vm/vm_keys.dart';
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

  ///调用主函数
  T main<T>({List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments}) {
    return _runner.callFunction(_config.mainMethod, positionalArguments: positionalArguments, namedArguments: namedArguments);
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

  ///提示某类型推测慢的日志器
  static final _slowTypeSpeculationLogger = EasyLogger(logTag: 'EasyVmWare');

  ///加载全局作用域，[customClassList]为自定义导入的类型，[customProxyList]为自定义导入的全局方法或实例，[quickTypeSpeculationMethod]为加速类型推测的函数
  static void loadGlobalLibrary({List<VmClass> customClassList = const [], List<VmProxy> customProxyList = const [], String? Function(dynamic instance)? quickTypeSpeculationMethod}) {
    VmRunner.loadGlobalLibrary(customClassList: customClassList, customProxyList: customProxyList);
    VmClass.quickTypeSpeculationMethod = quickTypeSpeculationMethod;
    VmClass.slowTypeSpeculationReport = (instance, vmclass, cycles, total) {
      _slowTypeSpeculationLogger.logFatal(['slowTypeSpeculationReport ======>', instance.runtimeType, '------>', vmclass.identifier, '------>', 'cycles:', cycles, '/', total]);
    };
  }

  ///简洁的执行[sourceCode]源代码中的[methodName]函数
  static T eval<T>({required String sourceCode, required String methodName}) {
    return VmRunner(sourceTrees: {'default': VmParser.parseSource(sourceCode)}).callFunction(methodName);
  }
}

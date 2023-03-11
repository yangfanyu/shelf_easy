import 'easy_class.dart';
import 'vm/vm_parser.dart';
import 'vm/vm_runner.dart';

///
///Dart子集虚拟机
///
class EasyVmWare extends EasyLogger {
  ///配置信息
  final EasyVmWareConfig _config;

  ///模块运行器集合
  final Map<String, VmRunner> _runners;

  ///JSON调试编码器
  final JsonEncoder _encoder;

  EasyVmWare({required EasyVmWareConfig config})
      : _config = config,
        _runners = {},
        _encoder = JsonEncoder.withIndent('  '),
        super(
          logger: config.logger,
          logLevel: config.logLevel,
          logTag: config.logTag ?? 'EasyVmWare',
          logFilePath: config.logFilePath,
          logFileBackup: config.logFileBackup,
          logFileMaxBytes: config.logFileMaxBytes,
        ) {
    _config.allModules.forEach((key, value) {
      if (_config.debugRoute) {
        final routeList = <String>[];
        final moduleTree = VmParser.parseSource(value, routeList: routeList, routeLogger: (route) => logDebug([key, '=>', route]));
        logDebug([key, '=>', _encoder.convert(routeList)]);
        _runners[key] = VmRunner(moduleTree: moduleTree);
      } else {
        final moduleTree = VmParser.parseSource(value);
        _runners[key] = VmRunner(moduleTree: moduleTree);
      }
    });
  }

  ///调用主模块的主函数
  T main<T>({List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments}) {
    return _runners[_config.mainModule]?.callFunction(_config.mainMethod, positionalArguments: positionalArguments, namedArguments: namedArguments) as T;
  }

  ///调用任意模块的任意函数
  T call<T>({required String moduleName, required String methodName, List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments}) {
    return _runners[moduleName]?.callFunction(methodName, positionalArguments: positionalArguments, namedArguments: namedArguments) as T;
  }

  ///打印虚拟机信息，[moduleName]不为null时打印指定模块的信息
  void debugVmWareInfo({String? moduleName}) {
    if (moduleName == null) {
      logDebug([_encoder.convert(_runners)]);
    } else {
      logDebug([_encoder.convert(_runners[moduleName])]);
    }
  }

  ///打印模块语法树，[moduleName]不为null时打印指定模块的信息
  void debugModuleTree({String? moduleName}) {
    if (moduleName == null) {
      logDebug([_encoder.convert(_runners.map((key, value) => MapEntry(key, value.toModuleJson())))]);
    } else {
      logDebug([_encoder.convert(_runners[moduleName]?.toModuleJson())]);
    }
  }

  ///打印作用域堆栈，[moduleName]不为null时打印指定模块的信息
  void debugObjectStack({String? moduleName}) {
    if (moduleName == null) {
      logDebug([_encoder.convert(_runners.map((key, value) => MapEntry(key, value.toObjectJson())))]);
    } else {
      logDebug([_encoder.convert(_runners[moduleName]?.toObjectJson())]);
    }
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

  ///简洁的执行[moduleCode]源代码中的[methodName]函数
  static T eval<T>({required String moduleCode, required String methodName}) {
    return VmRunner(moduleTree: VmParser.parseSource(moduleCode)).callFunction(methodName);
  }
}

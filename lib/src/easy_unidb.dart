import 'db/db_base.dart';
import 'db/db_hive.dart' as hive;
import 'db/db_unsupport.dart' if (dart.library.io) 'db/db_mongo.dart' as mongo;
import 'db/db_unsupport.dart' if (dart.library.io) 'db/db_postgre.dart' as postgre;
import 'easy_class.dart';

///
///数据库统一操作
///
class EasyUniDb extends EasyLogger implements DbBase {
  ///配置信息
  final EasyUniDbConfig _config;

  ///数据库操作实例
  final DbBase _handle;

  EasyUniDb({required EasyUniDbConfig config})
      : _config = config,
        _handle = _createDatabaseHandle(config),
        super(
          logger: config.logger,
          logLevel: config.logLevel,
          logTag: config.logTag ?? '${config.driver.name}://${config.host}:${config.port}',
          logFilePath: config.logFilePath,
          logFileBackup: config.logFileBackup,
          logFileMaxBytes: config.logFileMaxBytes,
        ) {
    if (_config.user == null && _config.password != null) throw ('_config.user == null && _config.password != null');
    if (_config.user != null && _config.password == null) throw ('_config.user != null && _config.password == null');
  }

  ///连接到数据库
  @override
  Future<void> connect() async {
    try {
      logDebug(['connect...']);
      await _handle.connect();
      logInfo(['connected.']);
    } catch (error, stack) {
      logError(['connect =>', error, '\n', stack]);
    }
  }

  ///销毁数据库连接
  @override
  Future<void> destroy() async {
    try {
      logDebug(['destroy...']);
      await _handle.destroy();
      logInfo(['destroyed.']);
    } catch (error, stack) {
      logError(['destroy =>', error, '\n', stack]);
    }
  }

  ///插入单条记录
  /// * [DbResult.success] 插入成功的数量 >0 时为true
  /// * [DbResult.rescode] 插入成功的数量 或 异常标识[-1]
  @override
  Future<DbResult<void>> insertOne<T extends DbBaseModel>(String table, T model, {DbInsertOptions? insertOptions}) async {
    try {
      final result = await _handle.insertOne(table, model, insertOptions: insertOptions);
      (result.success ? logDebug : logWarn)(['insertOne =>', table, model, insertOptions, result]);
      return result;
    } catch (error, stack) {
      logError(['insertOne =>', table, model, insertOptions, error, '\n', stack]);
      return DbResult(success: false, rescode: -1, message: error.toString());
    }
  }

  ///插入多条记录
  /// * [DbResult.success] 插入成功的数量 >0 时为true
  /// * [DbResult.rescode] 插入成功的数量 或 异常标识[-1]
  @override
  Future<DbResult<void>> insertMany<T extends DbBaseModel>(String table, List<T> models, {DbInsertOptions? insertOptions}) async {
    try {
      final result = await _handle.insertMany(table, models, insertOptions: insertOptions);
      (result.success ? logDebug : logWarn)(['insertMany =>', table, models, insertOptions, result]);
      return result;
    } catch (error, stack) {
      logError(['insertMany =>', table, models, insertOptions, error, '\n', stack]);
      return DbResult(success: false, rescode: -1, message: error.toString());
    }
  }

  ///删除单条记录
  /// * [DbResult.success] 删除成功的数量 >0 时为true
  /// * [DbResult.rescode] 删除成功的数量 或 异常标识[-1]
  @override
  Future<DbResult<void>> deleteOne(String table, DbFilter filter, {DbDeleteOptions? deleteOptions}) async {
    try {
      final result = await _handle.deleteOne(table, filter, deleteOptions: deleteOptions);
      (result.success ? logDebug : logWarn)(['deleteOne =>', table, filter, deleteOptions, result]);
      return result;
    } catch (error, stack) {
      logError(['deleteOne =>', table, filter, deleteOptions, error, '\n', stack]);
      return DbResult(success: false, rescode: -1, message: error.toString());
    }
  }

  ///删除多条记录
  /// * [DbResult.success] 删除成功的数量 >0 时为true
  /// * [DbResult.rescode] 删除成功的数量 或 异常标识[-1]
  @override
  Future<DbResult<void>> deleteMany(String table, DbFilter filter, {DbDeleteOptions? deleteOptions}) async {
    try {
      final result = await _handle.deleteMany(table, filter, deleteOptions: deleteOptions);
      (result.success ? logDebug : logWarn)(['deleteMany =>', table, filter, deleteOptions, result]);
      return result;
    } catch (error, stack) {
      logError(['deleteMany =>', table, filter, deleteOptions, error, '\n', stack]);
      return DbResult(success: false, rescode: -1, message: error.toString());
    }
  }

  ///更新单条记录
  /// * [DbResult.success] 更新成功的数量 >0 时为true
  /// * [DbResult.rescode] 更新成功的数量 或 异常标识[-1]
  @override
  Future<DbResult<void>> updateOne(String table, DbFilter filter, DbUpdate update, {DbUpdateOptions? updateOptions}) async {
    try {
      final result = await _handle.updateOne(table, filter, update, updateOptions: updateOptions);
      (result.success ? logDebug : logWarn)(['updateOne =>', table, filter, update, updateOptions, result]);
      return result;
    } catch (error, stack) {
      logError(['updateOne =>', table, filter, update, updateOptions, error, '\n', stack]);
      return DbResult(success: false, rescode: -1, message: error.toString());
    }
  }

  ///更新多条记录
  /// * [DbResult.success] 更新成功的数量 >0 时为true
  /// * [DbResult.rescode] 更新成功的数量 或 异常标识[-1]
  @override
  Future<DbResult<void>> updateMany(String table, DbFilter filter, DbUpdate update, {DbUpdateOptions? updateOptions}) async {
    try {
      final result = await _handle.updateMany(table, filter, update, updateOptions: updateOptions);
      (result.success ? logDebug : logWarn)(['updateMany =>', table, filter, update, updateOptions, result]);
      return result;
    } catch (error, stack) {
      logError(['updateMany =>', table, filter, update, updateOptions, error, '\n', stack]);
      return DbResult(success: false, rescode: -1, message: error.toString());
    }
  }

  ///查找单条记录
  /// * [DbResult.success] 当 DbResult.result!=null 时为true
  /// * [DbResult.rescode] 返回结果的数量 或 异常标识[-1]
  /// * [DbResult.result] 类型[T]的实例 或 null
  @override
  Future<DbResult<T>> findOne<T extends DbBaseModel>(String table, DbFilter filter, {DbFindOptions? findOptions, required T Function(Map<String, dynamic> map) converter}) async {
    try {
      final result = await _handle.findOne(table, filter, findOptions: findOptions, converter: converter);
      (result.success ? logDebug : logWarn)(['findOne =>', table, filter, findOptions, result]);
      return result;
    } catch (error, stack) {
      logError(['findOne =>', table, filter, findOptions, error, '\n', stack]);
      return DbResult(success: false, rescode: -1, message: error.toString());
    }
  }

  ///查找多条记录
  /// * [DbResult.success] 当 DbResult.resultList!=null 时为true
  /// * [DbResult.rescode] 返回结果的数量 或 异常标识[-1]
  /// * [DbResult.resultList] 类型[T]的实例数组 或 null
  @override
  Future<DbResult<T>> findMany<T extends DbBaseModel>(String table, DbFilter filter, {DbFindOptions? findOptions, required T Function(Map<String, dynamic> map) converter}) async {
    try {
      final result = await _handle.findMany(table, filter, findOptions: findOptions, converter: converter);
      (result.success ? logDebug : logWarn)(['findMany =>', table, filter, findOptions, result]);
      return result;
    } catch (error, stack) {
      logError(['findMany =>', table, filter, findOptions, error, '\n', stack]);
      return DbResult(success: false, rescode: -1, message: error.toString());
    }
  }

  ///查找并删除单条记录
  /// * [DbResult.success] 当 DbResult.result!=null 时为true
  /// * [DbResult.rescode] 返回结果的数量 或 异常标识[-1]
  /// * [DbResult.result] 类型[T]的实例 或 null
  @override
  Future<DbResult<T>> findAndDelete<T extends DbBaseModel>(String table, DbFilter filter, {DbFindDeleteOptions? findDeleteOptions, required T Function(Map<String, dynamic> map) converter}) async {
    try {
      final result = await _handle.findAndDelete(table, filter, findDeleteOptions: findDeleteOptions, converter: converter);
      (result.success ? logDebug : logWarn)(['findAndDelete =>', table, filter, findDeleteOptions, result]);
      return result;
    } catch (error, stack) {
      logError(['findAndDelete =>', table, filter, findDeleteOptions, error, '\n', stack]);
      return DbResult(success: false, rescode: -1, message: error.toString());
    }
  }

  ///查找并更新单条记录
  /// * [DbResult.success] 当 DbResult.result!=null 时为true
  /// * [DbResult.rescode] 返回结果的数量 或 异常标识[-1]
  /// * [DbResult.result] 类型[T]的实例 或 null
  /// * 注意：如果[DbFindUpdateOptions.$upsert]为true 但是 [DbFindUpdateOptions.$returnNew]非true, 则在成功upserted之后并不会返回新插入的对象数据，此时：[DbResult.success]为true，[DbResult.rescode]为0，[DbResult.result]为null
  @override
  Future<DbResult<T>> findAndUpdate<T extends DbBaseModel>(String table, DbFilter filter, DbUpdate update, {DbFindUpdateOptions? findUpdateOptions, required T Function(Map<String, dynamic> map) converter}) async {
    if (findUpdateOptions?.$upsert == true && findUpdateOptions?.$returnNew != true) {
      logWarn(['findAndUpdate =>', table, 'DbFindUpdateOptions.\$upsert is true but DbFindUpdateOptions.\$returnNew is not true, may cause return null result.']);
    }
    try {
      final result = await _handle.findAndUpdate(table, filter, update, findUpdateOptions: findUpdateOptions, converter: converter);
      (result.success ? logDebug : logWarn)(['findAndUpdate =>', table, filter, update, findUpdateOptions, result]);
      return result;
    } catch (error, stack) {
      logError(['findAndUpdate =>', table, filter, update, findUpdateOptions, error, '\n', stack]);
      return DbResult(success: false, rescode: -1, message: error.toString());
    }
  }

  ///聚合管道操作
  /// * [DbResult.success] 当 DbResult.resultList!=null 时为true
  /// * [DbResult.rescode] 返回结果的数量 或 异常标识[-1]
  /// * [DbResult.resultList] 类型[T]的实例数组 或 null
  @override
  Future<DbResult<T>> aggregate<T extends DbBaseModel>(String table, List<DbPipeline> pipeline, {DbAggregateOptions? aggregateOptions, required T Function(Map<String, dynamic> map) converter}) async {
    try {
      final result = await _handle.aggregate(table, pipeline, aggregateOptions: aggregateOptions, converter: converter);
      (result.success ? logDebug : logWarn)(['aggregate =>', table, pipeline, aggregateOptions, result]);
      return result;
    } catch (error, stack) {
      logError(['aggregate =>', table, pipeline, aggregateOptions, error, '\n', stack]);
      return DbResult(success: false, rescode: -1, message: error.toString());
    }
  }

  ///统计记录数量
  /// * [DbResult.success] 统计结果的数值 >=0 时为true
  /// * [DbResult.rescode] 统计结果的数值 或 异常标识[-1]
  @override
  Future<DbResult<int>> count(String table, DbFilter filter, {DbCountOptions? countOptions}) async {
    try {
      final result = await _handle.count(table, filter, countOptions: countOptions);
      (result.success ? logDebug : logWarn)(['count =>', table, filter, countOptions, result]);
      return result;
    } catch (error, stack) {
      logError(['count =>', table, filter, countOptions, error, '\n', stack]);
      return DbResult(success: false, rescode: -1, message: error.toString());
    }
  }

  ///事务批量操作
  /// * [operate] 批量操作回调函数。在回调中未抛出异常则提交事务，抛出异常则回滚事务，务必将回调参数session赋值给回调中的每个api的xxxxOptions.session
  /// * 注意：底层的mongo数据库驱动未实现对事务的支持，所以当驱动类型为[EasyUniDbDriver.mongo]时，本接口只是一个普通的批量回调操作
  @override
  Future<DbResult<void>> withTransaction(Future<String> Function(DbSession session) operate, {DbTransactionOptions? transactionOptions, void Function({String? msg, String? warn, String? err})? onmessage}) async {
    try {
      final result = await _handle.withTransaction(operate, transactionOptions: transactionOptions, onmessage: onmessage ?? ({msg, warn, err}) => _defaultTransactionMessageListener(this, msg: msg, warn: warn, err: err));
      (result.success ? logDebug : logWarn)(['withTransaction =>', transactionOptions, result]);
      return result;
    } catch (error, stack) {
      logError(['withTransaction =>', transactionOptions, error, '\n', stack]);
      return DbResult(success: false, rescode: -1, message: error.toString());
    }
  }

  ///withTransaction方法默认的消息处理器
  static void _defaultTransactionMessageListener(EasyLogger logger, {String? msg, String? warn, String? err}) {
    if (msg != null) logger.logInfo(['withTransaction =>', msg]);
    if (warn != null) logger.logWarn(['withTransaction =>', warn]);
    if (err != null) logger.logError(['withTransaction =>', err]);
  }

  ///根据[EasyUniDbConfig.driver]来初始化不同的数据库操作实例
  static DbBase _createDatabaseHandle(EasyUniDbConfig config) {
    final dbcfg = DbConfig(host: config.host, port: config.port, user: config.user, password: config.password, db: config.db, poolSize: config.poolSize, params: config.params);
    switch (config.driver) {
      case EasyUniDbDriver.hive:
        return hive.create(dbcfg);
      case EasyUniDbDriver.mongo:
        return mongo.create(dbcfg);
      case EasyUniDbDriver.postgre:
        return postgre.create(dbcfg);
    }
  }
}

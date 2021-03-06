import 'package:mongo_dart/mongo_dart.dart';

import 'db_base.dart';

class DbMongo implements DbBase {
  final DbConfig _config;
  late final Db _db;
  DbMongo(this._config);

  @override
  Future<void> connect() async {
    final params = _config.params.isEmpty ? '' : '?${Uri(queryParameters: _config.params).query}';
    if (_config.user == null || _config.password == null) {
      _db = Db('mongodb://${_config.host}:${_config.port}/${_config.db}$params');
    } else {
      _db = Db('mongodb+srv://${_config.user}:${_config.password}@${_config.host}:${_config.port}/${_config.db}$params');
    }
    await _db.open();
  }

  @override
  Future<void> destroy() async {
    await _db.close();
  }

  @override
  Future<DbResult<void>> insertOne<T extends DbBaseModel>(String table, T model, {DbInsertOptions? insertOptions}) async {
    final result = await _db.collection(table).insertOne(model.toJson());
    return DbResult(
      success: true,
      insertedCount: result.nInserted,
      modifiedCount: result.nModified,
      matchedCount: result.nMatched,
      upsertedCount: result.nUpserted,
      deletedCount: result.nRemoved,
    );
  }

  @override
  Future<DbResult<void>> insertMany<T extends DbBaseModel>(String table, List<T> models, {DbInsertOptions? insertOptions}) async {
    final result = await _db.collection(table).insertMany(models.map((e) => e.toJson()).toList());
    return DbResult(
      success: true,
      insertedCount: result.nInserted,
      modifiedCount: result.nModified,
      matchedCount: result.nMatched,
      upsertedCount: result.nUpserted,
      deletedCount: result.nRemoved,
    );
  }

  @override
  Future<DbResult<void>> deleteOne(String table, DbFilter filter, {DbDeleteOptions? deleteOptions}) async {
    final result = await _db.collection(table).deleteOne(filter.toJson());
    return DbResult(
      success: true,
      insertedCount: result.nInserted,
      modifiedCount: result.nModified,
      matchedCount: result.nMatched,
      upsertedCount: result.nUpserted,
      deletedCount: result.nRemoved,
    );
  }

  @override
  Future<DbResult<void>> deleteMany(String table, DbFilter filter, {DbDeleteOptions? deleteOptions}) async {
    final result = await _db.collection(table).deleteMany(filter.toJson());
    return DbResult(
      success: true,
      insertedCount: result.nInserted,
      modifiedCount: result.nModified,
      matchedCount: result.nMatched,
      upsertedCount: result.nUpserted,
      deletedCount: result.nRemoved,
    );
  }

  @override
  Future<DbResult<void>> updateOne(String table, DbFilter filter, DbUpdate update, {DbUpdateOptions? updateOptions}) async {
    final result = await _db.collection(table).updateOne(
          filter.toJson(),
          update.toJson(),
          upsert: updateOptions?.$upsert,
        );
    return DbResult(
      success: true,
      insertedCount: result.nInserted,
      modifiedCount: result.nModified,
      matchedCount: result.nMatched,
      upsertedCount: result.nUpserted,
      deletedCount: result.nRemoved,
    );
  }

  @override
  Future<DbResult<void>> updateMany(String table, DbFilter filter, DbUpdate update, {DbUpdateOptions? updateOptions}) async {
    final result = await _db.collection(table).updateMany(
          filter.toJson(),
          update.toJson(),
          upsert: updateOptions?.$upsert,
        );
    return DbResult(
      success: true,
      insertedCount: result.nInserted,
      modifiedCount: result.nModified,
      matchedCount: result.nMatched,
      upsertedCount: result.nUpserted,
      deletedCount: result.nRemoved,
    );
  }

  @override
  Future<DbResult<T>> findOne<T extends DbBaseModel>(String table, DbFilter filter, {DbFindOptions? findOptions, required T Function(Map<String, dynamic> map) converter}) async {
    final result = await _db.collection(table).modernFindOne(
          filter: filter.toJson(),
          skip: findOptions?.$skip,
          sort: findOptions?.$sortToJson(),
          projection: findOptions?.$projectionToJson(),
        );
    if (result == null) {
      return DbResult(
        success: false,
        message: 'Result is null',
      );
    } else {
      return DbResult(
        success: true,
        result: converter(result),
        resultData: result,
      );
    }
  }

  @override
  Future<DbResult<T>> findMany<T extends DbBaseModel>(String table, DbFilter filter, {DbFindOptions? findOptions, required T Function(Map<String, dynamic> map) converter}) async {
    final result = await _db
        .collection(table)
        .modernFind(
          filter: filter.toJson(),
          skip: findOptions?.$skip,
          limit: findOptions?.$limit,
          sort: findOptions?.$sortToJson(),
          projection: findOptions?.$projectionToJson(),
        )
        .toList();
    return DbResult(
      success: true,
      resultList: result.map((e) => converter(e)).toList(),
      resultData: result,
    );
  }

  @override
  Future<DbResult<T>> findAndDelete<T extends DbBaseModel>(String table, DbFilter filter, {DbFindDeleteOptions? findDeleteOptions, required T Function(Map<String, dynamic> map) converter}) async {
    final result = await _db.collection(table).modernFindAndModify(
          query: filter.toJson(),
          remove: true,
          fields: findDeleteOptions?.$projectionToJson(),
        );
    if (result.value == null) {
      return DbResult(
        success: false,
        message: result.errmsg ?? 'Result.value is null',
      );
    } else {
      return DbResult(
        success: true,
        result: converter(result.value!),
        resultData: result.value,
      );
    }
  }

  @override
  Future<DbResult<T>> findAndUpdate<T extends DbBaseModel>(String table, DbFilter filter, DbUpdate update, {DbFindUpdateOptions? findUpdateOptions, required T Function(Map<String, dynamic> map) converter}) async {
    final result = await _db.collection(table).modernFindAndModify(
          query: filter.toJson(),
          update: update.toJson(),
          remove: false,
          upsert: findUpdateOptions?.$upsert,
          fields: findUpdateOptions?.$projectionToJson(),
          returnNew: findUpdateOptions?.$returnNew,
        );
    if (result.value == null) {
      if (result.lastErrorObject?.upserted != null) {
        return DbResult(
          success: true,
          message: result.errmsg ?? 'Upserted a new document with ${result.lastErrorObject?.upserted}',
        );
      } else {
        return DbResult(
          success: false,
          message: result.errmsg ?? 'Result.value is null',
        );
      }
    } else {
      return DbResult(
        success: true,
        result: converter(result.value!),
        resultData: result.value,
      );
    }
  }

  @override
  Future<DbResult<T>> aggregate<T extends DbBaseModel>(String table, List<DbPipeline> pipeline, {DbAggregateOptions? aggregateOptions, required T Function(Map<String, dynamic> map) converter}) async {
    final result = await _db.collection(table).modernAggregate(pipeline.map((e) => e.compile()).toList()).toList();
    return DbResult(
      success: true,
      resultList: result.map((e) => converter(e)).toList(),
      resultData: result,
    );
  }

  @override
  Future<DbResult<int>> count(String table, DbFilter filter, {DbCountOptions? countOptions}) async {
    final result = await _db.collection(table).count(filter.toJson());
    return DbResult(
      success: true,
      result: result,
      resultData: result,
    );
  }

  @override
  Future<DbResult<void>> withTransaction(Future<String> Function(DbSession session) operate, {DbTransactionOptions? transactionOptions, void Function({String? msg, String? warn, String? err})? onmessage}) async {
    if (onmessage != null) onmessage(warn: 'The underlying driver mongo_dart does not support transactions. This function is just a preliminary interface.');
    final session = DbSession();
    if (onmessage != null) onmessage(msg: 'startSession');
    try {
      if (onmessage != null) onmessage(msg: 'startTransaction');
      final message = await operate(session);
      if (onmessage != null) onmessage(msg: 'commitTransaction');
      return DbResult(success: true, message: message);
    } catch (error, stack) {
      if (onmessage != null) onmessage(err: 'abortTransaction by error: $error\n$stack');
      return DbResult(success: false, message: error.toString());
    } finally {
      if (onmessage != null) onmessage(msg: 'endSession');
    }
  }
}

DbBase create(DbConfig config) => DbMongo(config);

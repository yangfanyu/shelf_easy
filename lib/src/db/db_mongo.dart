import 'dart:math';

import 'package:mongo_dart/mongo_dart.dart';

import 'db_base.dart';

class DbMongo implements DbBase {
  final DbConfig _config;

  Db? _safedb;

  DbMongo(this._config);

  bool get _isConnected => _safedb != null && _safedb!.isConnected;

  Db get _db => _safedb!;

  @override
  Future<void> connect() async {
    if (_isConnected) {
      return;
    } else {
      await _safedb?.close();
      _safedb = null;
    }
    final params = _config.params.isEmpty ? '' : '?${Uri(queryParameters: _config.params).query}';
    if (_config.user == null || _config.password == null) {
      _safedb = Db('mongodb://${_config.host}:${_config.port}/${_config.db}$params');
    } else {
      _safedb = Db('mongodb://${_config.user}:${_config.password}@${_config.host}:${_config.port}/${_config.db}$params');
    }
    await _safedb?.open();
  }

  @override
  Future<void> destroy() async {
    await _safedb?.close();
    _safedb = null;
  }

  @override
  Future<DbResult<void>> insertOne<T extends DbBaseModel>(String table, T model, {DbInsertOptions? insertOptions}) async {
    await connect();
    if (!_isConnected) throw ('Mongo database is not connected, please try again.');
    final result = await _db.collection(table).insertOne(model.toJson());
    return DbResult(
      success: result.nInserted > 0,
      rescode: result.nInserted,
      insertedCount: result.nInserted,
      modifiedCount: result.nModified,
      matchedCount: result.nMatched,
      upsertedCount: result.nUpserted,
      deletedCount: result.nRemoved,
    );
  }

  @override
  Future<DbResult<void>> insertMany<T extends DbBaseModel>(String table, List<T> models, {DbInsertOptions? insertOptions}) async {
    await connect();
    if (!_isConnected) throw ('Mongo database is not connected, please try again.');
    final result = await _db.collection(table).insertMany(models.map((e) => e.toJson()).toList());
    return DbResult(
      success: result.nInserted > 0,
      rescode: result.nInserted,
      insertedCount: result.nInserted,
      modifiedCount: result.nModified,
      matchedCount: result.nMatched,
      upsertedCount: result.nUpserted,
      deletedCount: result.nRemoved,
    );
  }

  @override
  Future<DbResult<void>> deleteOne(String table, DbFilter filter, {DbDeleteOptions? deleteOptions}) async {
    await connect();
    if (!_isConnected) throw ('Mongo database is not connected, please try again.');
    final result = await _db.collection(table).deleteOne(filter.toJson());
    return DbResult(
      success: result.nRemoved > 0,
      rescode: result.nRemoved,
      insertedCount: result.nInserted,
      modifiedCount: result.nModified,
      matchedCount: result.nMatched,
      upsertedCount: result.nUpserted,
      deletedCount: result.nRemoved,
    );
  }

  @override
  Future<DbResult<void>> deleteMany(String table, DbFilter filter, {DbDeleteOptions? deleteOptions}) async {
    await connect();
    if (!_isConnected) throw ('Mongo database is not connected, please try again.');
    final result = await _db.collection(table).deleteMany(filter.toJson());
    return DbResult(
      success: result.nRemoved > 0,
      rescode: result.nRemoved,
      insertedCount: result.nInserted,
      modifiedCount: result.nModified,
      matchedCount: result.nMatched,
      upsertedCount: result.nUpserted,
      deletedCount: result.nRemoved,
    );
  }

  @override
  Future<DbResult<void>> updateOne(String table, DbFilter filter, DbUpdate update, {DbUpdateOptions? updateOptions}) async {
    await connect();
    if (!_isConnected) throw ('Mongo database is not connected, please try again.');
    final result = await _db.collection(table).updateOne(
          filter.toJson(),
          update.toJson(),
          upsert: updateOptions?.$upsert,
        );
    return DbResult(
      success: result.nModified > 0 || result.nMatched > 0 || result.nUpserted > 0,
      rescode: max(max(result.nModified, result.nMatched), result.nUpserted),
      insertedCount: result.nInserted,
      modifiedCount: result.nModified,
      matchedCount: result.nMatched,
      upsertedCount: result.nUpserted,
      deletedCount: result.nRemoved,
    );
  }

  @override
  Future<DbResult<void>> updateMany(String table, DbFilter filter, DbUpdate update, {DbUpdateOptions? updateOptions}) async {
    await connect();
    if (!_isConnected) throw ('Mongo database is not connected, please try again.');
    final result = await _db.collection(table).updateMany(
          filter.toJson(),
          update.toJson(),
          upsert: updateOptions?.$upsert,
        );
    return DbResult(
      success: result.nModified > 0 || result.nMatched > 0 || result.nUpserted > 0,
      rescode: max(max(result.nModified, result.nMatched), result.nUpserted),
      insertedCount: result.nInserted,
      modifiedCount: result.nModified,
      matchedCount: result.nMatched,
      upsertedCount: result.nUpserted,
      deletedCount: result.nRemoved,
    );
  }

  @override
  Future<DbResult<T>> findOne<T extends DbBaseModel>(String table, DbFilter filter, {DbFindOptions? findOptions, required T Function(Map<String, dynamic> map) converter}) async {
    await connect();
    if (!_isConnected) throw ('Mongo database is not connected, please try again.');
    final result = await _db.collection(table).modernFindOne(
          filter: filter.toJson(),
          skip: findOptions?.$skip,
          sort: findOptions?.$sortToJson(),
          projection: findOptions?.$projectionToJson(),
        );
    if (result == null) {
      return DbResult(
        success: false,
        rescode: 0,
        message: 'Result is null',
      );
    } else {
      return DbResult(
        success: true,
        rescode: 1,
        result: converter(result),
        resultData: result,
      );
    }
  }

  @override
  Future<DbResult<T>> findMany<T extends DbBaseModel>(String table, DbFilter filter, {DbFindOptions? findOptions, required T Function(Map<String, dynamic> map) converter}) async {
    await connect();
    if (!_isConnected) throw ('Mongo database is not connected, please try again.');
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
      rescode: result.length,
      resultList: result.map((e) => converter(e)).toList(),
      resultData: result,
    );
  }

  @override
  Future<DbResult<T>> findAndDelete<T extends DbBaseModel>(String table, DbFilter filter, {DbFindDeleteOptions? findDeleteOptions, required T Function(Map<String, dynamic> map) converter}) async {
    await connect();
    if (!_isConnected) throw ('Mongo database is not connected, please try again.');
    final result = await _db.collection(table).modernFindAndModify(
          query: filter.toJson(),
          remove: true,
          fields: findDeleteOptions?.$projectionToJson(),
        );
    if (result.value == null) {
      return DbResult(
        success: false,
        rescode: 0,
        message: result.errmsg ?? 'Result.value is null',
      );
    } else {
      return DbResult(
        success: true,
        rescode: 1,
        result: converter(result.value!),
        resultData: result.value,
      );
    }
  }

  @override
  Future<DbResult<T>> findAndUpdate<T extends DbBaseModel>(String table, DbFilter filter, DbUpdate update, {DbFindUpdateOptions? findUpdateOptions, required T Function(Map<String, dynamic> map) converter}) async {
    await connect();
    if (!_isConnected) throw ('Mongo database is not connected, please try again.');
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
          rescode: 0,
          message: result.errmsg ?? 'Upserted a new document with ${result.lastErrorObject?.upserted}',
        );
      } else {
        return DbResult(
          success: false,
          rescode: 0,
          message: result.errmsg ?? 'Result.value is null',
        );
      }
    } else {
      return DbResult(
        success: true,
        rescode: 1,
        result: converter(result.value!),
        resultData: result.value,
      );
    }
  }

  @override
  Future<DbResult<T>> aggregate<T extends DbBaseModel>(String table, List<DbPipeline> pipeline, {DbAggregateOptions? aggregateOptions, required T Function(Map<String, dynamic> map) converter}) async {
    await connect();
    if (!_isConnected) throw ('Mongo database is not connected, please try again.');
    final result = await _db.collection(table).modernAggregate(pipeline.map((e) => e.compile()).toList()).toList();
    return DbResult(
      success: true,
      rescode: result.length,
      resultList: result.map((e) => converter(e)).toList(),
      resultData: result,
    );
  }

  @override
  Future<DbResult<int>> count(String table, DbFilter filter, {DbCountOptions? countOptions}) async {
    await connect();
    if (!_isConnected) throw ('Mongo database is not connected, please try again.');
    final result = await _db.collection(table).count(filter.toJson());
    return DbResult(
      success: true,
      rescode: result,
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
      return DbResult(success: true, rescode: 0, message: message);
    } catch (error, stack) {
      if (onmessage != null) onmessage(err: 'abortTransaction by error: $error\n$stack');
      return DbResult(success: false, rescode: -1, message: error.toString());
    } finally {
      if (onmessage != null) onmessage(msg: 'endSession');
    }
  }
}

DbBase create(DbConfig config) => DbMongo(config);

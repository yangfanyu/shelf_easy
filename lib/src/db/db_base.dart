import 'dart:convert';

import 'package:bson/bson.dart';

export 'dart:convert' show JsonEncoder, jsonDecode, jsonEncode;

export 'package:bson/bson.dart' show ObjectId;

///
///数据库操作接口
///
abstract class DbBase {
  Future<void> connect() => throw UnimplementedError();

  Future<void> destroy() => throw UnimplementedError();

  Future<DbResult<void>> insertOne<T extends DbBaseModel>(String table, T model, {DbInsertOptions? insertOptions}) => throw UnimplementedError();

  Future<DbResult<void>> insertMany<T extends DbBaseModel>(String table, List<T> models, {DbInsertOptions? insertOptions}) => throw UnimplementedError();

  Future<DbResult<void>> deleteOne(String table, DbFilter filter, {DbDeleteOptions? deleteOptions}) => throw UnimplementedError();

  Future<DbResult<void>> deleteMany(String table, DbFilter filter, {DbDeleteOptions? deleteOptions}) => throw UnimplementedError();

  Future<DbResult<void>> updateOne(String table, DbFilter filter, DbUpdate update, {DbUpdateOptions? updateOptions}) => throw UnimplementedError();

  Future<DbResult<void>> updateMany(String table, DbFilter filter, DbUpdate update, {DbUpdateOptions? updateOptions}) => throw UnimplementedError();

  Future<DbResult<T>> findOne<T extends DbBaseModel>(String table, DbFilter filter, {DbFindOptions? findOptions, required T Function(Map<String, dynamic> map) converter}) => throw UnimplementedError();

  Future<DbResult<T>> findMany<T extends DbBaseModel>(String table, DbFilter filter, {DbFindOptions? findOptions, required T Function(Map<String, dynamic> map) converter}) => throw UnimplementedError();

  Future<DbResult<T>> findAndDelete<T extends DbBaseModel>(String table, DbFilter filter, {DbFindDeleteOptions? findDeleteOptions, required T Function(Map<String, dynamic> map) converter}) => throw UnimplementedError();

  Future<DbResult<T>> findAndUpdate<T extends DbBaseModel>(String table, DbFilter filter, DbUpdate update, {DbFindUpdateOptions? findUpdateOptions, required T Function(Map<String, dynamic> map) converter}) => throw UnimplementedError();

  Future<DbResult<T>> aggregate<T extends DbBaseModel>(String table, List<DbPipeline> pipeline, {DbAggregateOptions? aggregateOptions, required T Function(Map<String, dynamic> map) converter}) => throw UnimplementedError();

  Future<DbResult<int>> count(String table, DbFilter filter, {DbCountOptions? countOptions}) => throw UnimplementedError();

  Future<DbResult<void>> withTransaction(Future<String> Function(DbSession session) operate, {DbTransactionOptions? transactionOptions, void Function({String? msg, String? warn, String? err})? onmessage}) => throw UnimplementedError();
}

///
///数据库配置
///
class DbConfig {
  ///数据库主机域名或IP地址
  final String host;

  ///数据库主机端口号
  final int port;

  ///用户名
  final String? user;

  ///密码
  final String? password;

  ///数据库名
  final String db;

  ///连接池大小
  final int poolSize;

  ///其他参数
  final Map<String, String> params;

  DbConfig({
    required this.host,
    required this.port,
    this.user,
    this.password,
    required this.db,
    required this.poolSize,
    required this.params,
  });
}

///
///数据库会话，用于事务操作
///
class DbSession {}

///
///基本数据表模型
///
abstract class DbBaseModel {
  ///转换为基本数据类型的Map。转换结果可以直接使用[jsonEncode]进行序列化，可以直接保存到mongo数据库
  Map<String, dynamic> toJson() => throw UnimplementedError();

  ///通过基本数据类型的Map来更新字段。来源[map]可以直接使用[jsonEncode]进行序列化，可以直接保存到mongo数据库
  void updateByJson(Map<String, dynamic> map) => throw UnimplementedError();

  ///转换为用字符串key读取字段值的Map
  Map<String, dynamic> toKValues() => throw UnimplementedError();

  ///通过用字符串key读取字段值的Map来更新字段
  void updateByKValues(Map<String, dynamic> map) => throw UnimplementedError();

  ///jsonEncode(this)抛出的异常被吃掉了，所以需要写成jsonEncode(toJson())
  @override
  String toString() => '$runtimeType(${jsonEncode(toJson())})';
}

///
///JSON数据封装类
///
class DbJsonWraper extends DbBaseModel {
  ///可以直接使用[jsonEncode]进行序列化，可以直接保存到mongo数据库的Map数据
  final Map<String, dynamic> data;

  DbJsonWraper({Map<String, dynamic>? data}) : data = data ?? {};

  factory DbJsonWraper.fromString(String data) => DbJsonWraper.fromJson(jsonDecode(data.substring(data.indexOf('(') + 1, data.lastIndexOf(')'))));

  factory DbJsonWraper.fromJson(Map<String, dynamic> map) => DbJsonWraper(data: map);

  @override
  Map<String, dynamic> toJson() => data;

  @override
  void updateByJson(Map<String, dynamic> map) => data.addAll(map);

  @override
  Map<String, dynamic> toKValues() => data;

  @override
  void updateByKValues(Map<String, dynamic> map) => data.addAll(map);

  @override
  String toString() => 'DbJsonWraper(${jsonEncode(toJson())})';
}

///
///操作结果
///
class DbResult<T> extends DbBaseModel {
  ///操作是否成功
  final bool success;

  ///操作成功或失败的描述情况
  final String message;

  ///插入的数量
  final int insertedCount;

  ///修改的数量
  final int modifiedCount;

  ///匹配的数量
  final int matchedCount;

  ///更新或插入的数量
  final int upsertedCount;

  ///删除的数量
  final int deletedCount;

  ///转换后的操作结果
  final T? result;

  ///转换后的操作结果列表
  final List<T>? resultList;

  ///转换前操作结果的原始数据
  final Object? resultData;

  DbResult({
    required this.success,
    this.message = '',
    this.insertedCount = 0,
    this.modifiedCount = 0,
    this.matchedCount = 0,
    this.upsertedCount = 0,
    this.deletedCount = 0,
    this.result,
    this.resultList,
    this.resultData,
  });

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'success': success,
      'message': message,
      'insertedCount': insertedCount,
      'modifiedCount': modifiedCount,
      'matchedCount': matchedCount,
      'upsertedCount': upsertedCount,
      'deletedCount': deletedCount,
    };
    if (result != null) map['result'] = DbQueryField.toBaseType(result);
    if (resultList != null) map['resultList'] = DbQueryField.toBaseType(resultList);
    if (resultData != null) map['resultData'] = DbQueryField.toBaseType(resultData);
    return map;
  }
}

///
///过滤语句处理
///
class DbFilter extends DbBaseModel {
  ///比较操作
  final Set<DbQueryField>? $cmds;

  ///或 条件查询
  List<Set<DbQueryField>>? $or;

  ///与 条件查询
  List<Set<DbQueryField>>? $and;

  ///查询与任一表达式都不匹配的文档
  List<Set<DbQueryField>>? $nor;

  DbFilter(this.$cmds, {this.$or, this.$and, this.$nor});

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    $cmds?.forEach((element) {
      map[element._name] = element._cmds.isNotEmpty ? element._cmds : DBUnsupportNullValue('\$cmds', element._name);
    });
    if ($or != null) {
      map['\$or'] = $or!.map((e) => {for (var element in e) element._name: element._cmds.isNotEmpty ? element._cmds : DBUnsupportNullValue('\$or', element._name)}).toList();
    }
    if ($and != null) {
      map['\$and'] = $and!.map((e) => {for (var element in e) element._name: element._cmds.isNotEmpty ? element._cmds : DBUnsupportNullValue('\$and', element._name)}).toList();
    }
    if ($nor != null) {
      map['\$nor'] = $nor!.map((e) => {for (var element in e) element._name: element._cmds.isNotEmpty ? element._cmds : DBUnsupportNullValue('\$nor', element._name)}).toList();
    }
    return map;
  }
}

///
///更新语句处理
///
class DbUpdate extends DbBaseModel {
  ///直接设置字段值
  final Set<DbQueryField>? $set;

  ///将字段 加/减 某值 并更新
  final Set<DbQueryField>? $inc;

  ///将字段 乘以 某值 并更新
  final Set<DbQueryField>? $mul;

  ///将 某值 加入数组中，若相同的值在数组中已经存在了，不再加入
  final Set<DbQueryField>? $addToSet;

  ///将 某值 加入数组中，若相同的值在数组中已经存在了，依然插入
  final Set<DbQueryField>? $push;

  ///通过指定一个查询条件来删除所有符合条件的数组字段元素
  final Set<DbQueryField>? $pull;

  ///删除数组中的第一个或最后一个元素，-1表示第一个，1表示最后一个
  final Set<DbQueryField>? $pop;

  DbUpdate({this.$set, this.$inc, this.$mul, this.$addToSet, this.$push, this.$pull, this.$pop});

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if ($set != null) {
      map['\$set'] = {for (var element in $set!) element._name: element._value$set ?? DBUnsupportNullValue('\$set', element._name)};
    }
    if ($inc != null) {
      map['\$inc'] = {for (var element in $inc!) element._name: element._value$inc ?? DBUnsupportNullValue('\$inc', element._name)};
    }
    if ($mul != null) {
      map['\$mul'] = {for (var element in $mul!) element._name: element._value$mul ?? DBUnsupportNullValue('\$mul', element._name)};
    }
    if ($addToSet != null) {
      map['\$addToSet'] = {for (var element in $addToSet!) element._name: element._value$addToSet ?? DBUnsupportNullValue('\$addToSet', element._name)};
    }
    if ($push != null) {
      map['\$push'] = {for (var element in $push!) element._name: element._value$push ?? DBUnsupportNullValue('\$push', element._name)};
    }
    if ($pull != null) {
      map['\$pull'] = {for (var element in $pull!) element._name: element._value$pull ?? DBUnsupportNullValue('\$pull', element._name)};
    }
    if ($pop != null) {
      map['\$pop'] = {for (var element in $pop!) element._name: element._value$pop ?? DBUnsupportNullValue('\$pop', element._name)};
    }
    return map;
  }
}

///
///聚合语句处理
///
class DbPipeline extends DbBaseModel {
  ///过滤操作
  final DbFilter? $match;

  ///分组操作
  final Set<DbQueryField>? $group;

  ///计数字段
  final String? $count;

  ///跳过数量
  final int? $skip;

  ///返回数量
  final int? $limit;

  ///排序参数
  final Set<DbQueryField>? $sort;

  DbPipeline({this.$match, this.$group, this.$count, this.$skip, this.$limit, this.$sort});

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if ($match != null) {
      map['\$match'] = $match?.toJson();
    }
    if ($group != null) {
      final groupIds = <String, dynamic>{};
      final groupFields = <String, Map<String, dynamic>>{};
      for (var element in $group!) {
        if (element._group$id != null) groupIds[element._group$id!] = '\$${element._name}';
        if (element._group$sum != null) groupFields[element._group$sum!] = {'\$sum': '\$${element._name}'};
        if (element._group$avg != null) groupFields[element._group$avg!] = {'\$avg': '\$${element._name}'};
        if (element._group$min != null) groupFields[element._group$min!] = {'\$min': '\$${element._name}'};
        if (element._group$max != null) groupFields[element._group$max!] = {'\$max': '\$${element._name}'};
      }
      if ($count != null) groupFields[$count!] = {'\$sum': 1};
      if (groupIds.length == 1) {
        map['\$group'] = {'_id': groupIds.values.first, ...groupFields};
      } else {
        map['\$group'] = {'_id': groupIds, ...groupFields};
      }
    }
    if ($skip != null) {
      map['\$skip'] = $skip;
    }
    if ($limit != null) {
      map['\$limit'] = $limit;
    }
    if ($sort != null) {
      map['\$sort'] = {for (var element in $sort!) element._name: element._value$sort ?? DBUnsupportNullValue('\$sort', element._name)};
    }
    return map;
  }

  Map<String, Object> compile() {
    final map = toJson();
    return map.map((key, value) => MapEntry(key, _convertToObject(value)));
  }

  Object _convertToObject(dynamic v) {
    if (v is Map) {
      return v.map((key, value) => MapEntry(key, _convertToObject(value)));
    } else if (v is List) {
      return v.map((value) => _convertToObject(value)).toList();
    } else {
      return v;
    }
  }
}

///
///插入操作选项
///
class DbInsertOptions extends DbBaseModel {
  //事务会话
  final DbSession? session;

  DbInsertOptions({this.session});

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}

///
///删除操作选项
///
class DbDeleteOptions extends DbBaseModel {
  //事务会话
  final DbSession? session;

  DbDeleteOptions({this.session});

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}

///
///更新操作选项
///
class DbUpdateOptions extends DbBaseModel {
  //事务会话
  final DbSession? session;

  ///没有则插入，有则更新
  final bool? $upsert;

  DbUpdateOptions({this.session, this.$upsert});

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if ($upsert != null) {
      map['\$upsert'] = $upsert;
    }
    return map;
  }
}

///
///查询操作选项
///
class DbFindOptions extends DbBaseModel {
  //事务会话
  final DbSession? session;

  ///跳过数量
  final int? $skip;

  ///返回数量
  final int? $limit;

  ///排序参数
  final Set<DbQueryField>? $sort;

  ///投影参数
  final Set<DbQueryField>? $projection;

  DbFindOptions({this.session, this.$skip, this.$limit, this.$sort, this.$projection});

  ///$sort转换为Map格式数据
  Map<String, Object>? $sortToJson() {
    if ($sort != null) {
      return {for (var element in $sort!) element._name: element._value$sort ?? DBUnsupportNullValue('\$sort', element._name)};
    }
    return null;
  }

  ///$projection转换为Map格式数据
  Map<String, Object>? $projectionToJson() {
    if ($projection != null) {
      return {for (var element in $projection!) element._name: element._value$projection ?? DBUnsupportNullValue('\$projection', element._name)};
    }
    return null;
  }

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if ($skip != null) {
      map['\$skip'] = $skip;
    }
    if ($limit != null) {
      map['\$limit'] = $limit;
    }
    if ($sort != null) {
      map['\$sort'] = {for (var element in $sort!) element._name: element._value$sort ?? DBUnsupportNullValue('\$sort', element._name)};
    }
    if ($projection != null) {
      map['\$projection'] = {for (var element in $projection!) element._name: element._value$projection ?? DBUnsupportNullValue('\$projection', element._name)};
    }
    return map;
  }
}

///
///删除且查询操作选项
///
class DbFindDeleteOptions extends DbBaseModel {
  //事务会话
  final DbSession? session;

  ///投影参数
  final Set<DbQueryField>? $projection;

  DbFindDeleteOptions({this.session, this.$projection});

  ///$projection转换为Map格式数据
  Map<String, Object>? $projectionToJson() {
    if ($projection != null) {
      return {for (var element in $projection!) element._name: element._value$projection ?? DBUnsupportNullValue('\$projection', element._name)};
    }
    return null;
  }

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if ($projection != null) {
      map['\$projection'] = {for (var element in $projection!) element._name: element._value$projection ?? DBUnsupportNullValue('\$projection', element._name)};
    }
    return map;
  }
}

///
///更新且查询操作选项
///
class DbFindUpdateOptions extends DbBaseModel {
  //事务会话
  final DbSession? session;

  ///没有则插入，有则更新
  final bool? $upsert;

  ///返回值是否更新后的记录
  final bool? $returnNew;

  ///投影参数
  final Set<DbQueryField>? $projection;

  DbFindUpdateOptions({this.session, this.$upsert, this.$returnNew, this.$projection});

  ///$projection转换为Map格式数据
  Map<String, Object>? $projectionToJson() {
    if ($projection != null) {
      return {for (var element in $projection!) element._name: element._value$projection ?? DBUnsupportNullValue('\$projection', element._name)};
    }
    return null;
  }

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if ($upsert != null) {
      map['\$upsert'] = $upsert;
    }
    if ($returnNew != null) {
      map['\$returnNew'] = $returnNew;
    }
    if ($projection != null) {
      map['\$projection'] = {for (var element in $projection!) element._name: element._value$projection ?? DBUnsupportNullValue('\$projection', element._name)};
    }
    return map;
  }
}

//
///聚合操作附加选项
///
class DbAggregateOptions extends DbBaseModel {
  //事务会话
  final DbSession? session;

  DbAggregateOptions({this.session});

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}

///
///统计数量附加选项
///
class DbCountOptions extends DbBaseModel {
  //事务会话
  final DbSession? session;

  DbCountOptions({this.session});

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}

///
///事务的会话选项
///
class DbTransactionOptions extends DbBaseModel {
  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}

///
///
///数据操作字段类
///
/// * [FD_TYPE] 字段的数据类型
/// * [NUM_TYPE] 数值操作的数据类型
/// * [ITEM_TYPE] 数组操作的子项数据类型
///
class DbQueryField<FD_TYPE, NUM_TYPE, ITEM_TYPE> {
  ///字段名称
  final String _name;

  ///指令集合
  final Map<String, dynamic> _cmds;

  Object? _value$set;

  Object? _value$inc;

  Object? _value$mul;

  Object? _value$addToSet;

  Object? _value$push;

  Object? _value$pull;

  int? _value$pop;

  int? _value$sort;

  int? _value$projection;

  String? _group$id;

  String? _group$sum;

  String? _group$avg;

  String? _group$min;

  String? _group$max;

  String get name => _name;

  DbQueryField(this._name) : _cmds = {};

  /* **************** 指令操作 ********** */
  ///等于
  void $eq(FD_TYPE value) => _cmds['\$eq'] = toBaseType(value);

  ///不等于
  void $ne(FD_TYPE value) => _cmds['\$ne'] = toBaseType(value);

  ///大于
  void $gt(FD_TYPE value) => _cmds['\$gt'] = toBaseType(value);

  ///大于等于
  void $gte(FD_TYPE value) => _cmds['\$gte'] = toBaseType(value);

  ///小于
  void $lt(FD_TYPE value) => _cmds['\$lt'] = toBaseType(value);

  ///小于等于
  void $lte(FD_TYPE value) => _cmds['\$lte'] = toBaseType(value);

  ///匹配数组中任一值
  void $in(List<FD_TYPE> values) => _cmds['\$in'] = toBaseType(values);

  ///不匹配数组中的值
  void $nin(List<FD_TYPE> values) => _cmds['\$nin'] = toBaseType(values);

  ///查询存在该字段的记录
  void $exists(bool exists) => _cmds['\$exists'] = toBaseType(exists);

  ///正则匹配，mongo官方文档：https://www.mongodb.com/docs/v4.4/reference/operator/query/regex/
  void $match(String pattern, {String? options}) {
    _cmds['\$regex'] = pattern;
    if (options != null) _cmds['\$options'] = options;
  }

  /* **************** 赋值操作 ********** */

  ///设置 $set 操作的值
  void $set(FD_TYPE value) => _value$set = toBaseType(value);

  ///设置 $inc 操作的值
  void $inc(NUM_TYPE value) => _value$inc = toBaseType(value);

  ///设置 $mul 操作的值
  void $mul(NUM_TYPE value) => _value$mul = toBaseType(value);

  ///设置 $addToSet 操作的值
  void $addToSet(ITEM_TYPE value) => _value$addToSet = toBaseType(value);

  ///设置 $push 操作的值
  void $push(ITEM_TYPE value) => _value$push = toBaseType(value);

  ///设置 $pull 操作的值
  void $pull(ITEM_TYPE value) => _value$pull = toBaseType(value);

  ///设置 $pop 操作的值，1表示最后一个，-1表示第一个
  void $pop(int value) => _value$pop = toBaseType(value);

  ///设置 $sort 操作的值，1为升序排列，-1是降序排列
  void $sort(int value) => _value$sort = toBaseType(value);

  ///设置 $projection 操作的值，1为包含该字段，0为排除该字段
  void $projection(int value) => _value$projection = toBaseType(value);

  ///从该数组字段中移除最后一个成员
  void popLast() => $pop(1);

  ///从该数组字段中移除第一个成员
  void popFirst() => $pop(-1);

  ///根据该字段升序排列
  void sortAsc() => $sort(1);

  ///根据该字段降序排列
  void sortDesc() => $sort(-1);

  ///返回结果包含该字段
  void include() => $projection(1);

  ///返回结排除该字段
  void exclude() => $projection(0);

  /* **************** 聚合操作 ********** */

  ///将该字段作为分组id
  void $id({String? asField}) => _group$id = asField ?? _name;

  ///计算该字段的总和值
  void $sum({String? asField}) => _group$sum = asField ?? _name;

  ///计算该字段的平均值
  void $avg({String? asField}) => _group$avg = asField ?? _name;

  ///获取该字段的最小值。
  void $min({String? asField}) => _group$min = asField ?? _name;

  ///获取该字段的最大值。
  void $max({String? asField}) => _group$max = asField ?? _name;

  /* **************** 工具函数 ********** */

  ///将复杂类型转换为dart内置的基础类型。转换结果可以直接使用[jsonEncode]进行序列化，可以直接保存到mongo数据库
  ///
  ///经过测试发现：jsonEncode操作Map时只支持以字符串为key，mongo数据库保存Map时只支持以字符串为key
  static dynamic toBaseType(dynamic v) {
    if (v is Map) {
      return v.map((key, value) => MapEntry(key is String ? key : (key is ObjectId ? key.toHexString() : key.toString()), toBaseType(value)));
    } else if (v is List) {
      return v.map((value) => toBaseType(value)).toList();
    } else if (v is DbBaseModel) {
      return v.toJson();
    } else if (v is ObjectId) {
      return v;
    } else {
      return v;
    }
  }

  ///解析int，失败返回0
  static int parseInt(dynamic v) => tryParseInt(v) ?? 0;

  ///解析double，失败返回0
  static double parseDouble(dynamic v) => tryParseDouble(v) ?? 0;

  ///解析num，失败返回0
  static num parseNum(dynamic v) => tryParseNum(v) ?? 0;

  ///解析bool，失败返回false
  static bool parseBool(dynamic v) => tryParseBool(v) ?? false;

  ///解析String，失败返回''
  static String parseString(dynamic v) => tryParseString(v) ?? '';

  ///解析ObjectId，失败返回ObjectId('000000000000000000000000')
  static ObjectId parseObjectId(dynamic v) => tryParseObjectId(v) ?? ObjectId.fromHexString('000000000000000000000000');

  ///解析int，失败返回null
  static int? tryParseInt(dynamic v) {
    if (v is int) {
      return v;
    } else if (v is double) {
      return v.toInt();
    } else if (v is num) {
      return v.toInt();
    } else if (v is String) {
      return int.tryParse(v);
    }
    return null;
  }

  ///解析double，失败返回null
  static double? tryParseDouble(dynamic v) {
    if (v is int) {
      return v.toDouble();
    } else if (v is double) {
      return v;
    } else if (v is num) {
      return v.toDouble();
    } else if (v is String) {
      return double.tryParse(v);
    }
    return null;
  }

  ///解析num，失败返回null
  static num? tryParseNum(dynamic v) {
    if (v is int) {
      return v;
    } else if (v is double) {
      return v;
    } else if (v is num) {
      return v;
    } else if (v is String) {
      return num.tryParse(v);
    }
    return null;
  }

  ///解析bool，失败返回null
  static bool? tryParseBool(dynamic v) {
    if (v is bool) {
      return v;
    } else if (v is String) {
      return v == 'true';
    }
    return null;
  }

  ///解析String，失败返回null
  static String? tryParseString(dynamic v) {
    if (v is String) {
      return v;
    } else if (v != null) {
      return v.toString();
    }
    return null;
  }

  ///解析ObjectId，失败返回null
  static ObjectId? tryParseObjectId(dynamic v) {
    if (v is ObjectId) {
      return v;
    } else if (v is String) {
      try {
        return ObjectId.fromHexString(v);
      } catch (error) {
        return null;
      }
    }
    return null;
  }

  ///创建一个新的ObjectId
  static ObjectId createObjectId() {
    return ObjectId();
  }

  ///将HexString转换为ObjectId
  static ObjectId hexstr2ObjectId(String hexstr) {
    try {
      return ObjectId.fromHexString(hexstr);
    } catch (error) {
      return ObjectId.fromHexString('000000000000000000000000');
    }
  }
}

///
///字段操作值不能为空
///
class DBUnsupportNullValue {
  DBUnsupportNullValue(String operate, String fieldName) {
    throw UnsupportedError('DBUnsupportNullValue: Operate $operate of \'$fieldName\' unsupport null value.');
  }
}

///
///字段不支持数字操作
///
class DBUnsupportNumberOperate {
  DBUnsupportNumberOperate() {
    throw UnsupportedError('DBUnsupportNumberOperate: This field unsupport number operate.');
  }
}

///
///字段不支持数组操作
///
class DBUnsupportArrayOperate {
  DBUnsupportArrayOperate() {
    throw UnsupportedError('DBUnsupportArrayOperate: This field unsupport array operate.');
  }
}

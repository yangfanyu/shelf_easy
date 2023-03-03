import 'dart:io';

import 'package:shelf_easy/shelf_easy.dart';

import '../model/all.dart';

void main() {
  final unidb = EasyUniDb(
    config: EasyUniDbConfig(
      driver: EasyUniDbDriver.mongo,
      host: 'localhost',
      port: 27017,
      db: 'shelf_easy_example',
      params: {},
    ),
  );
  unidb.connect().then((value) async {
    await unidb.insertOne(UserQuery.$tableName, User(no: 'aaa'));

    await unidb.insertMany(UserQuery.$tableName, [User(no: 'bbb'), User(no: 'ccc'), User(no: 'ddd'), User(no: 'eee'), User(no: 'fff')]);

    await unidb.deleteOne(
      UserQuery.$tableName,
      DbFilter({
        UserQuery.no..$eq('fff'),
      }),
    );

    await unidb.deleteMany(
      UserQuery.$tableName,
      DbFilter(
        null,
        $or: [
          {UserQuery.no..$eq('ddd')},
          {UserQuery.no..$eq('eee')}
        ],
      ),
    );

    final userBBB = (await unidb.findOne(UserQuery.$tableName, DbFilter({UserQuery.no..$eq('bbb')}), converter: User.fromJson)).result;
    unidb.logWarn(['userBBB =>', userBBB]);

    final userList = (await unidb.findMany(UserQuery.$tableName, DbFilter({}), converter: User.fromJson)).resultList;
    unidb.logWarn(['userList =>', userList]);

    final deleteAllCount = (await unidb.deleteMany(UserQuery.$tableName, DbFilter({}))).rescode;
    unidb.logWarn(['deleteAllCount =>', deleteAllCount]);

    final afterDelAllTotal = (await unidb.count(UserQuery.$tableName, DbFilter({}))).rescode;
    unidb.logWarn(['afterDelAllTotal =>', afterDelAllTotal]);
    //关闭连接
    await unidb.destroy().then((value) => exit(0));
  });
  //sigint
  ProcessSignal.sigint.watch().listen((signal) {
    unidb.destroy().then((value) => exit(0));
  });
}

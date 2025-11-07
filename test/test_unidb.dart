import 'dart:convert';
import 'dart:io';

import 'package:shelf_easy/shelf_deps.dart';
import 'package:shelf_easy/shelf_easy.dart';

import 'model/address.dart';
import 'model/user.dart';

void main() {
  // testJsonTool();
  testHelpClass();
  // testDataBase();
  // testAggregate();
}

void testJsonTool() {
  final encoder = JsonEncoder.withIndent('  ');
  final user = User(
    age: 88,
    ageObjectIdAddressMap: {
      1: {ObjectId(): Address()},
    },
  );
  final userString = user.toString();
  print(userString);
  print(User.fromString(userString));
  print(encoder.convert(User.fromString(userString)));
}

void testHelpClass() {
  final encoder = JsonEncoder.withIndent('  ');
  print('\n DbFilter');
  print(
    encoder.convert(
      DbFilter(
        {
          UserQuery.name..$eq('compare'),
          UserQuery.pwd..$match('pattern', options: 'i'),
          UserQuery.age
            ..$gte(10)
            ..$lte(20),
          UserQuery.address..$eq(Address()),
          UserQuery.accessList..$itemMatch($gte: 1, $lte: 0),
        },
        $or: [
          {
            UserQuery.name..$eq('or'),
            UserQuery.age..$lte(20),
          },
          {
            UserQuery.name..$eq('or'),
            UserQuery.age..$lte(20),
          },
        ],
        $and: [
          {
            UserQuery.name..$eq('and'),
            UserQuery.age..$lte(20),
          },
          {
            UserQuery.name..$eq('and'),
            UserQuery.age..$lte(20),
          },
        ],
        $nor: [
          {
            UserQuery.name..$eq('nor'),
            UserQuery.age..$lte(20),
          },
          {
            UserQuery.name..$eq('nor'),
            UserQuery.age..$lte(20),
          },
        ],
      ).toJson(),
    ),
  );
  print('\n DbUpdate');
  print(
    encoder.convert(
      DbUpdate(
        $set: {
          UserQuery.name..$set('set'),
          UserQuery.accessList..$set([1, 2, 3]),
        },
        $inc: {
          UserQuery.age..$inc(1),
        },
        $mul: {
          UserQuery.rmb..$mul(10),
        },
        $addToSet: {
          UserQuery.accessList..$addToSet(1),
        },
        $push: {
          UserQuery.accessList..$push(1),
          UserQuery.addressList..$push(Address()),
        },
        $pull: {
          UserQuery.accessList..$pull(1),
          UserQuery.addressList..$pull(Address()),
        },
        $pop: {
          UserQuery.accessList..popLast(),
          UserQuery.addressList..popLast(),
        },
      ).toJson(),
    ),
  );
  print('\n DbUpdateOptions');
  print(
    encoder.convert(
      DbUpdateOptions(
        $upsert: true,
      ).toJson(),
    ),
  );
  print('\n DbFindOptions');
  print(
    encoder.convert(
      DbFindOptions(
        $skip: 1,
        $limit: 1,
        $sort: {
          UserQuery.name..sortDesc(),
          UserQuery.age..sortDesc(),
        },
        $projection: {
          UserQuery.name..include(),
          UserQuery.age..exclude(),
        },
      ).toJson(),
    ),
  );
  print('\n DbFindOptions sortToJson');
  print(
    encoder.convert(
      DbFindOptions(
        $skip: 1,
        $limit: 1,
        $sort: {
          UserQuery.name..sortDesc(),
          UserQuery.age..sortDesc(),
        },
        $projection: {
          UserQuery.name..include(),
          UserQuery.age..exclude(),
        },
      ).$sortToJson(),
    ),
  );
  print('\n DbFindOptions projectionToJson');
  print(
    encoder.convert(
      DbFindOptions(
        $skip: 1,
        $limit: 1,
        $sort: {
          UserQuery.name..sortDesc(),
          UserQuery.age..sortDesc(),
        },
        $projection: {
          UserQuery.name..include(),
          UserQuery.age..exclude(),
        },
      ).$projectionToJson(),
    ),
  );
  print('\n DbFindDeleteOptions');
  print(
    encoder.convert(
      DbFindDeleteOptions(
        $projection: {
          UserQuery.name..include(),
          UserQuery.age..exclude(),
        },
      ).toJson(),
    ),
  );
  print('\n DbFindUpdateOptions');
  print(
    encoder.convert(
      DbFindUpdateOptions(
        $upsert: false,
        $returnNew: true,
        $projection: {
          UserQuery.name..include(),
          UserQuery.age..exclude(),
        },
      ).toJson(),
    ),
  );

  print('\n List<DbPipeline>');
  print(
    encoder.convert(
      [
        DbPipeline(
          $match: DbFilter(
            {
              UserQuery.age..$gte(15),
            },
            $or: [
              {
                UserQuery.age..$eq(11),
              },
              {
                UserQuery.age..$eq(22),
              },
              {
                UserQuery.age..$eq(33),
              },
            ],
          ),
        ),
        DbPipeline(
          $project: {
            UserQuery.id..$project(),
            UserQuery.age..include(),
            UserQuery.name..exclude(),
            UserQuery.rmb..$project(asField: 'rmbxxx'),
            DbQueryField('aaa.bbb')..$project(asField: 'ccc_ddd'),
          },
        ),
        DbPipeline(
          $unwind: UserQuery.age.name,
        ),
        DbPipeline(
          $unwind: {'path': '\$sizes'},
        ),
        DbPipeline(
          $group: {
            UserQuery.age..$id(),
            UserQuery.name..$id(asField: 'nick'),
            UserQuery.rmb..$sum(),
            DbQueryField('usercnt')..$row(),
          },
        ),
        DbPipeline(
          $sort: {
            UserQuery.id..sortAsc(),
          },
        ),
        DbPipeline(
          $skip: 1,
        ),
        DbPipeline(
          $limit: 2,
        ),
      ],
    ),
  );
}

void testDataBase() {
  final database = EasyUniDb(
    config: EasyUniDbConfig(
      driver: EasyUniDbDriver.mongo,
      host: InternetAddress.anyIPv4.host,
      port: 27017,
      db: 'shelf',
      params: {},
    ),
  );
  database.connect().then((value) async {
    //deleteOne without filter
    await database.deleteOne(UserQuery.$tableName, DbFilter({}));
    //deleteMany with exists
    await database.deleteMany(
      UserQuery.$tableName,
      DbFilter({
        UserQuery.rmb..$exists(false),
      }),
    );
    //deleteMany without filter
    await database.deleteMany(UserQuery.$tableName, DbFilter({}));
    //insertOne
    final user = User(name: '用户1', accessList: [-1, 101, 102, 103, 104]);
    await database.insertOne(
      UserQuery.$tableName,
      user,
    );
    //insertMany
    await database.insertMany(UserQuery.$tableName, [
      User(
        name: '用户2',
        friendList: [user.id],
        ageObjectIdAddressMap: {
          1: {ObjectId(): Address()},
        },
        accessList: [201, 202, 203, 204],
      ),
      User(name: '用户3', friendList: [user.id], accessList: [-1, 301, 302, 303, 304]),
      User(name: '用户4', friendList: [user.id], accessList: [-1, 401, 402, 403, 404]),
    ]);
    //updateOne
    await database.updateOne(
      UserQuery.$tableName,
      DbFilter({
        UserQuery.id..$eq(user.id),
      }),
      DbUpdate(
        $set: {
          UserQuery.age..$set(88),
        },
        $addToSet: {
          UserQuery.accessList..$addToSet(1),
          UserQuery.friendList..$addToSet(user.id),
        },
      ),
    );
    //updateOne with same value
    await database.updateOne(
      UserQuery.$tableName,
      DbFilter({
        UserQuery.id..$eq(user.id),
      }),
      DbUpdate(
        $set: {
          UserQuery.age..$set(88),
        },
        $addToSet: {
          UserQuery.accessList..$addToSet(1),
          UserQuery.friendList..$addToSet(user.id),
        },
      ),
    );
    //updateOne with upsert
    await database.updateOne(
      UserQuery.$tableName,
      DbFilter({
        UserQuery.id..$eq(ObjectId()),
      }),
      DbUpdate(
        $set: {
          UserQuery.name..$set('用户5_updateOne_upsert'),
          UserQuery.age..$set(888),
        },
        $addToSet: {
          UserQuery.accessList..$addToSet(1),
          UserQuery.friendList..$addToSet(user.id),
        },
      ),
      updateOptions: DbUpdateOptions(
        $upsert: true,
      ),
    );
    //updateMany without filter
    await database.updateMany(
      UserQuery.$tableName,
      DbFilter({}),
      DbUpdate(
        $addToSet: {
          UserQuery.accessList..$addToSet(2),
        },
      ),
      updateOptions: DbUpdateOptions(
        $upsert: true,
      ),
    );
    //findOne with filter match
    await database.findOne(
      UserQuery.$tableName,
      DbFilter({
        UserQuery.name..$match('3', options: 'i'),
      }),
      findOptions: DbFindOptions(
        $projection: {
          UserQuery.name..include(),
          UserQuery.accessList..include(),
        },
      ),
      converter: User.fromJson,
    );
    //findOne with filter elemMatch
    await database.findOne(
      UserQuery.$tableName,
      DbFilter({
        UserQuery.accessList..$itemMatch($eq: 202),
      }),
      converter: User.fromJson,
      findOptions: DbFindOptions(
        $projection: {
          UserQuery.name..include(),
          UserQuery.accessList..include(),
        },
      ),
    );
    //findOne without filter
    await database.findOne(
      UserQuery.$tableName,
      DbFilter({}),
      converter: User.fromJson,
    );
    //findOne without filter and with skip,projection
    final complexUser = await database.findOne(
      UserQuery.$tableName,
      DbFilter({}),
      converter: User.fromJson,
      findOptions: DbFindOptions(
        $skip: 1,
        $projection: {
          // UserQuery.name..exclude(),
          UserQuery.address..exclude(),
          UserQuery.addressList..exclude(),
          UserQuery.friendList..exclude(),
        },
      ),
    );
    print(complexUser.result?.ageObjectIdAddressMap);
    //findOne without filter and with skip sort projection
    await database.findMany(
      UserQuery.$tableName,
      DbFilter({}),
      converter: User.fromJson,
      findOptions: DbFindOptions(
        $skip: 1,
        $limit: 2,
        $sort: {UserQuery.name..sortAsc()},
        $projection: {
          // UserQuery.id..exclude(),
          UserQuery.name..include(),
          // UserQuery.address..exclude(),
          // UserQuery.accessList..exclude(),
          // UserQuery.addressList..exclude(),
          // UserQuery.friendList..exclude(),
        },
      ),
    );
    //findMany without filter
    await database.findMany(
      UserQuery.$tableName,
      DbFilter({}),
      converter: User.fromJson,
      findOptions: DbFindOptions(
        $sort: {UserQuery.name..sortDesc()},
        $projection: {
          // UserQuery.id..exclude(),
          UserQuery.name..include(),
          // UserQuery.address..exclude(),
          // UserQuery.accessList..exclude(),
          // UserQuery.addressList..exclude(),
          // UserQuery.friendList..exclude(),
        },
      ),
    );
    //findMany with filter elemMatch
    await database.findMany(
      UserQuery.$tableName,
      DbFilter({
        UserQuery.accessList..$itemMatch($gte: 200, $lte: 400),
      }),
      converter: User.fromJson,
      findOptions: DbFindOptions(
        $projection: {
          UserQuery.name..include(),
          UserQuery.accessList..include(),
        },
      ),
    );
    //findMany with filter elemMatch
    await database.findMany(
      UserQuery.$tableName,
      DbFilter({
        UserQuery.accessList..$itemMatch($ne: -1),
      }),
      converter: User.fromJson,
      findOptions: DbFindOptions(
        $projection: {
          UserQuery.name..include(),
          UserQuery.accessList..include(),
        },
      ),
    );
    //findMany with filter elemMatch [every$ne]
    await database.findMany(
      UserQuery.$tableName,
      DbFilter({
        UserQuery.accessList..$itemMatch(every$ne: -1),
      }),
      converter: User.fromJson,
      findOptions: DbFindOptions(
        $projection: {
          UserQuery.name..include(),
          UserQuery.accessList..include(),
        },
      ),
    );
    //count
    await database.count(
      UserQuery.$tableName,
      DbFilter(
        {
          UserQuery.rmb..$exists(true),
          UserQuery.pwd..$exists(true),
        },
      ),
    );
    //findAndUpdate with upsert 已经存在的记录
    await database.findAndUpdate(
      UserQuery.$tableName,
      DbFilter({
        UserQuery.id..$eq(user.id),
      }),
      DbUpdate(
        $set: {
          UserQuery.name..$set('222222222222222222222222'),
        },
        $inc: {
          UserQuery.rmb..$inc(666),
        },
      ),
      converter: User.fromJson,
      findUpdateOptions: DbFindUpdateOptions(
        $upsert: true,
        $returnNew: true,
        $projection: {
          UserQuery.name..include(),
        },
      ),
    );
    //findAndUpdate with upsert 不存在的记录
    final objId = ObjectId.fromHexString('000000000000000000000000');
    await database.findAndUpdate(
      UserQuery.$tableName,
      DbFilter(
        {
          UserQuery.id..$eq(objId),
          // UserQuery.age..$inc(999), //throw DBUnsupportNullValue: Operate $cmds of 'age' unsupport null value.
          UserQuery.rmb..$eq(888000000),
        },
        // $or: [
        //   {
        //     UserQuery.age..$inc(999), //throw DBUnsupportNullValue: Operate $or of 'age' unsupport null value.
        //   }
        // ],
      ),
      DbUpdate(
        $set: {
          UserQuery.name..$set('000000000000000000000000'),
        },
        $inc: {
          UserQuery.rmb..$inc(888),
        },
      ),
      converter: User.fromJson,
      findUpdateOptions: DbFindUpdateOptions(
        $upsert: true,
        // $returnNew: true,
      ),
    );
    //count without filter
    await database.count(UserQuery.$tableName, DbFilter({}));
    //findAndDelete
    await database.findAndDelete(
      UserQuery.$tableName,
      DbFilter(
        {
          UserQuery.id..$eq(user.id),
        },
      ),
      converter: User.fromJson,
      findDeleteOptions: DbFindDeleteOptions(
        $projection: {
          // UserQuery.name..include(),
          UserQuery.address..exclude(),
          UserQuery.accessList..exclude(),
          UserQuery.friendList..exclude(),
          UserQuery.addressList..exclude(),
        },
      ),
    );
    //count witth filter
    await database.count(
      UserQuery.$tableName,
      DbFilter(
        {
          UserQuery.address..$exists(false),
        },
      ),
    );
    //count without filter
    final res = await database.count(UserQuery.$tableName, DbFilter({}));
    print(res.result);
    //withTransaction
    await database.withTransaction((session) async {
      final user = User(name: 'Transaction user');
      await database.insertOne(
        UserQuery.$tableName,
        user,
        insertOptions: DbInsertOptions(session: session),
      );
      if (DateTime.now().millisecond % 2 == 0) throw ('Test abort Error');
      final address = Address(country: 'Transaction address');
      await database.updateOne(
        UserQuery.$tableName,
        DbFilter({
          UserQuery.id..$eq(user.id),
        }),
        DbUpdate(
          $set: {
            UserQuery.address..$set(address),
          },
        ),
        updateOptions: DbUpdateOptions(session: session),
      );
      return 'Finished message';
    });
    print(User().toJson.hashCode);
    print(User().toJson.hashCode);
    print(User().toJson.hashCode);
    print(DbQueryField.createObjectId());
    print(DbQueryField.hexstr2ObjectId(''));
    //关闭连接
    await database.destroy().then((value) => exit(0));
  });
  //sigint
  ProcessSignal.sigint.watch().listen((signal) {
    database.destroy().then((value) => exit(0));
  });
}

void testAggregate() {
  final database = EasyUniDb(
    config: EasyUniDbConfig(
      driver: EasyUniDbDriver.mongo,
      host: InternetAddress.anyIPv4.host,
      port: 27017,
      db: 'shelf',
      params: {},
    ),
  );
  database.connect().then((value) async {
    //deleteMany without filter
    await database.deleteMany(UserQuery.$tableName, DbFilter({}));
    //insertMany
    await database.insertMany(UserQuery.$tableName, [
      User(name: '用户11', age: 11, rmb: 10),
      User(name: '用户11', age: 11, rmb: 20),
      User(name: '用户22', age: 22, rmb: 30),
      User(name: '用户22', age: 22, rmb: 40),
      User(name: '用户33', age: 33, rmb: 50),
      User(name: '用户33', age: 33, rmb: 60),
      User(name: '用户44', age: 44, rmb: 70),
      User(name: '用户44', age: 44, rmb: 80),
    ]);
    //aggregate1
    await database.aggregate<DbJsonWraper>(
      UserQuery.$tableName,
      [
        DbPipeline(
          $match: DbFilter({
            UserQuery.age..$gte(15),
          }),
        ),
        DbPipeline(
          $group: {
            UserQuery.age..$id(),
            UserQuery.rmb..$sum(),
            UserQuery.age..$sum(asField: 'sumAge'),
            UserQuery.rmb..$min(asField: 'minRmb'),
            UserQuery.rmb..$max(asField: 'maxRmb'),
            UserQuery.rmb..$avg(asField: 'avgRmb'),
            DbQueryField('usercnt')..$row(),
          },
        ),
        DbPipeline(
          $sort: {
            UserQuery.id..sortAsc(),
          },
        ),
      ],
      converter: DbJsonWraper.fromJson,
    );
    //aggregate2
    await database.aggregate<DbJsonWraper>(
      UserQuery.$tableName,
      [
        DbPipeline(
          $match: DbFilter(
            {
              // UserQuery.age..$gte(15),
            },
            $or: [
              {
                UserQuery.age..$eq(11),
              },
              {
                UserQuery.age..$eq(22),
              },
              {
                UserQuery.age..$eq(33),
              },
            ],
          ),
        ),
        DbPipeline(
          $group: {
            UserQuery.age..$id(),
            UserQuery.name..$id(asField: 'nick'),
            UserQuery.rmb..$sum(),
            DbQueryField('usercnt')..$row(),
          },
        ),
        DbPipeline(
          $sort: {
            UserQuery.id..sortAsc(),
          },
        ),
        DbPipeline(
          $skip: 1,
        ),
        DbPipeline(
          $limit: 2,
        ),
      ],
      converter: DbJsonWraper.fromJson,
    );
    //关闭连接
    await database.destroy().then((value) => exit(0));
  });
  //sigint
  ProcessSignal.sigint.watch().listen((signal) {
    database.destroy().then((value) => exit(0));
  });
}

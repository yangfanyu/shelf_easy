// ignore_for_file: avoid_function_literals_in_foreach_calls
// ignore_for_file: deprecated_member_use
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: unnecessary_constructor_name

import 'package:shelf_easy/shelf_easy.dart';
import '../model/all.dart';

///
///测试的数据模型桥接库
///
class ModelLibrary {
  ///class Constant
  static final classConstant = VmClass<Constant>(
    identifier: 'Constant',
    superclassNames: ['Object', 'DbBaseModel'],
    externalProxyMap: {
      'new': VmProxy(identifier: 'new', externalStaticPropertyReader: () => Constant.new),
      'fromJson': VmProxy(identifier: 'fromJson', externalStaticPropertyReader: () => Constant.fromJson),
      'fromString': VmProxy(identifier: 'fromString', externalStaticPropertyReader: () => Constant.fromString),
      'constMap': VmProxy(identifier: 'constMap', externalStaticPropertyReader: () => Constant.constMap),
      'sexFemale': VmProxy(identifier: 'sexFemale', externalStaticPropertyReader: () => Constant.sexFemale),
      'sexMale': VmProxy(identifier: 'sexMale', externalStaticPropertyReader: () => Constant.sexMale),
      'sexUnknow': VmProxy(identifier: 'sexUnknow', externalStaticPropertyReader: () => Constant.sexUnknow),
      'buildTarget': VmProxy(identifier: 'buildTarget', externalInstancePropertyReader: (Constant instance) => instance.buildTarget),
      'hashCode': VmProxy(identifier: 'hashCode', externalInstancePropertyReader: (Constant instance) => instance.hashCode),
      'noSuchMethod': VmProxy(identifier: 'noSuchMethod', externalInstancePropertyReader: (Constant instance) => instance.noSuchMethod),
      'runtimeType': VmProxy(identifier: 'runtimeType', externalInstancePropertyReader: (Constant instance) => instance.runtimeType),
      'toJson': VmProxy(identifier: 'toJson', externalInstancePropertyReader: (Constant instance) => instance.toJson),
      'toKValues': VmProxy(identifier: 'toKValues', externalInstancePropertyReader: (Constant instance) => instance.toKValues),
      'toString': VmProxy(identifier: 'toString', externalInstancePropertyReader: (Constant instance) => instance.toString),
      'updateByJson': VmProxy(identifier: 'updateByJson', externalInstancePropertyReader: (Constant instance) => instance.updateByJson),
      'updateByKValues': VmProxy(identifier: 'updateByKValues', externalInstancePropertyReader: (Constant instance) => instance.updateByKValues),
    },
  );

  ///class DbBaseModel
  static final classDbBaseModel = VmClass<DbBaseModel>(
    identifier: 'DbBaseModel',
    superclassNames: ['Object'],
    externalProxyMap: {
      'buildTarget': VmProxy(identifier: 'buildTarget', externalInstancePropertyReader: (DbBaseModel instance) => instance.buildTarget),
      'hashCode': VmProxy(identifier: 'hashCode', externalInstancePropertyReader: (DbBaseModel instance) => instance.hashCode),
      'noSuchMethod': VmProxy(identifier: 'noSuchMethod', externalInstancePropertyReader: (DbBaseModel instance) => instance.noSuchMethod),
      'runtimeType': VmProxy(identifier: 'runtimeType', externalInstancePropertyReader: (DbBaseModel instance) => instance.runtimeType),
      'toJson': VmProxy(identifier: 'toJson', externalInstancePropertyReader: (DbBaseModel instance) => instance.toJson),
      'toKValues': VmProxy(identifier: 'toKValues', externalInstancePropertyReader: (DbBaseModel instance) => instance.toKValues),
      'toString': VmProxy(identifier: 'toString', externalInstancePropertyReader: (DbBaseModel instance) => instance.toString),
      'updateByJson': VmProxy(identifier: 'updateByJson', externalInstancePropertyReader: (DbBaseModel instance) => instance.updateByJson),
      'updateByKValues': VmProxy(identifier: 'updateByKValues', externalInstancePropertyReader: (DbBaseModel instance) => instance.updateByKValues),
    },
  );

  ///class Location
  static final classLocation = VmClass<Location>(
    identifier: 'Location',
    superclassNames: ['Object', 'DbBaseModel'],
    externalProxyMap: {
      'new': VmProxy(identifier: 'new', externalStaticPropertyReader: () => Location.new),
      'fromJson': VmProxy(identifier: 'fromJson', externalStaticPropertyReader: () => Location.fromJson),
      'fromString': VmProxy(identifier: 'fromString', externalStaticPropertyReader: () => Location.fromString),
      'altitude': VmProxy(identifier: 'altitude', externalInstancePropertyReader: (Location instance) => instance.altitude, externalInstancePropertyWriter: (Location instance, value) => instance.altitude = value),
      'buildTarget': VmProxy(identifier: 'buildTarget', externalInstancePropertyReader: (Location instance) => instance.buildTarget),
      'city': VmProxy(identifier: 'city', externalInstancePropertyReader: (Location instance) => instance.city, externalInstancePropertyWriter: (Location instance, value) => instance.city = value),
      'country': VmProxy(identifier: 'country', externalInstancePropertyReader: (Location instance) => instance.country, externalInstancePropertyWriter: (Location instance, value) => instance.country = value),
      'district': VmProxy(identifier: 'district', externalInstancePropertyReader: (Location instance) => instance.district, externalInstancePropertyWriter: (Location instance, value) => instance.district = value),
      'hashCode': VmProxy(identifier: 'hashCode', externalInstancePropertyReader: (Location instance) => instance.hashCode),
      'id': VmProxy(identifier: 'id', externalInstancePropertyReader: (Location instance) => instance.id),
      'latitude': VmProxy(identifier: 'latitude', externalInstancePropertyReader: (Location instance) => instance.latitude, externalInstancePropertyWriter: (Location instance, value) => instance.latitude = value),
      'longitude': VmProxy(identifier: 'longitude', externalInstancePropertyReader: (Location instance) => instance.longitude, externalInstancePropertyWriter: (Location instance, value) => instance.longitude = value),
      'noSuchMethod': VmProxy(identifier: 'noSuchMethod', externalInstancePropertyReader: (Location instance) => instance.noSuchMethod),
      'province': VmProxy(identifier: 'province', externalInstancePropertyReader: (Location instance) => instance.province, externalInstancePropertyWriter: (Location instance, value) => instance.province = value),
      'runtimeType': VmProxy(identifier: 'runtimeType', externalInstancePropertyReader: (Location instance) => instance.runtimeType),
      'time': VmProxy(identifier: 'time', externalInstancePropertyReader: (Location instance) => instance.time),
      'toJson': VmProxy(identifier: 'toJson', externalInstancePropertyReader: (Location instance) => instance.toJson),
      'toKValues': VmProxy(identifier: 'toKValues', externalInstancePropertyReader: (Location instance) => instance.toKValues),
      'toString': VmProxy(identifier: 'toString', externalInstancePropertyReader: (Location instance) => instance.toString),
      'updateByJson': VmProxy(identifier: 'updateByJson', externalInstancePropertyReader: (Location instance) => instance.updateByJson),
      'updateByKValues': VmProxy(identifier: 'updateByKValues', externalInstancePropertyReader: (Location instance) => instance.updateByKValues),
    },
  );

  ///class LocationDirty
  static final classLocationDirty = VmClass<LocationDirty>(
    identifier: 'LocationDirty',
    superclassNames: ['Object'],
    externalProxyMap: {
      'new': VmProxy(identifier: 'new', externalStaticPropertyReader: () => LocationDirty.new),
      'altitude': VmProxy(identifier: 'altitude', externalInstancePropertyWriter: (LocationDirty instance, value) => instance.altitude = value),
      'city': VmProxy(identifier: 'city', externalInstancePropertyWriter: (LocationDirty instance, value) => instance.city = value),
      'country': VmProxy(identifier: 'country', externalInstancePropertyWriter: (LocationDirty instance, value) => instance.country = value),
      'data': VmProxy(identifier: 'data', externalInstancePropertyReader: (LocationDirty instance) => instance.data),
      'district': VmProxy(identifier: 'district', externalInstancePropertyWriter: (LocationDirty instance, value) => instance.district = value),
      'hashCode': VmProxy(identifier: 'hashCode', externalInstancePropertyReader: (LocationDirty instance) => instance.hashCode),
      'id': VmProxy(identifier: 'id', externalInstancePropertyWriter: (LocationDirty instance, value) => instance.id = value),
      'latitude': VmProxy(identifier: 'latitude', externalInstancePropertyWriter: (LocationDirty instance, value) => instance.latitude = value),
      'longitude': VmProxy(identifier: 'longitude', externalInstancePropertyWriter: (LocationDirty instance, value) => instance.longitude = value),
      'noSuchMethod': VmProxy(identifier: 'noSuchMethod', externalInstancePropertyReader: (LocationDirty instance) => instance.noSuchMethod),
      'province': VmProxy(identifier: 'province', externalInstancePropertyWriter: (LocationDirty instance, value) => instance.province = value),
      'runtimeType': VmProxy(identifier: 'runtimeType', externalInstancePropertyReader: (LocationDirty instance) => instance.runtimeType),
      'time': VmProxy(identifier: 'time', externalInstancePropertyWriter: (LocationDirty instance, value) => instance.time = value),
      'toString': VmProxy(identifier: 'toString', externalInstancePropertyReader: (LocationDirty instance) => instance.toString),
    },
  );

  ///class LocationQuery
  static final classLocationQuery = VmClass<LocationQuery>(
    identifier: 'LocationQuery',
    superclassNames: ['Object'],
    externalProxyMap: {
      'new': VmProxy(identifier: 'new', externalStaticPropertyReader: () => LocationQuery.new),
      '\$tableName': VmProxy(identifier: '\$tableName', externalStaticPropertyReader: () => LocationQuery.$tableName),
      'altitude': VmProxy(identifier: 'altitude', externalStaticPropertyReader: () => LocationQuery.altitude),
      'city': VmProxy(identifier: 'city', externalStaticPropertyReader: () => LocationQuery.city),
      'country': VmProxy(identifier: 'country', externalStaticPropertyReader: () => LocationQuery.country),
      'district': VmProxy(identifier: 'district', externalStaticPropertyReader: () => LocationQuery.district),
      'id': VmProxy(identifier: 'id', externalStaticPropertyReader: () => LocationQuery.id),
      'latitude': VmProxy(identifier: 'latitude', externalStaticPropertyReader: () => LocationQuery.latitude),
      'longitude': VmProxy(identifier: 'longitude', externalStaticPropertyReader: () => LocationQuery.longitude),
      'province': VmProxy(identifier: 'province', externalStaticPropertyReader: () => LocationQuery.province),
      'time': VmProxy(identifier: 'time', externalStaticPropertyReader: () => LocationQuery.time),
      'hashCode': VmProxy(identifier: 'hashCode', externalInstancePropertyReader: (LocationQuery instance) => instance.hashCode),
      'noSuchMethod': VmProxy(identifier: 'noSuchMethod', externalInstancePropertyReader: (LocationQuery instance) => instance.noSuchMethod),
      'runtimeType': VmProxy(identifier: 'runtimeType', externalInstancePropertyReader: (LocationQuery instance) => instance.runtimeType),
      'toString': VmProxy(identifier: 'toString', externalInstancePropertyReader: (LocationQuery instance) => instance.toString),
    },
  );

  ///class User
  static final classUser = VmClass<User>(
    identifier: 'User',
    superclassNames: ['Object', 'DbBaseModel'],
    externalProxyMap: {
      'new': VmProxy(identifier: 'new', externalStaticPropertyReader: () => User.new),
      'fromJson': VmProxy(identifier: 'fromJson', externalStaticPropertyReader: () => User.fromJson),
      'fromString': VmProxy(identifier: 'fromString', externalStaticPropertyReader: () => User.fromString),
      'age': VmProxy(identifier: 'age', externalInstancePropertyReader: (User instance) => instance.age, externalInstancePropertyWriter: (User instance, value) => instance.age = value),
      'buildTarget': VmProxy(identifier: 'buildTarget', externalInstancePropertyReader: (User instance) => instance.buildTarget),
      'hashCode': VmProxy(identifier: 'hashCode', externalInstancePropertyReader: (User instance) => instance.hashCode),
      'id': VmProxy(identifier: 'id', externalInstancePropertyReader: (User instance) => instance.id),
      'location': VmProxy(identifier: 'location', externalInstancePropertyReader: (User instance) => instance.location, externalInstancePropertyWriter: (User instance, value) => instance.location = value),
      'locationList': VmProxy(identifier: 'locationList', externalInstancePropertyReader: (User instance) => instance.locationList, externalInstancePropertyWriter: (User instance, value) => instance.locationList = value),
      'locationMap': VmProxy(identifier: 'locationMap', externalInstancePropertyReader: (User instance) => instance.locationMap, externalInstancePropertyWriter: (User instance, value) => instance.locationMap = value),
      'no': VmProxy(identifier: 'no', externalInstancePropertyReader: (User instance) => instance.no, externalInstancePropertyWriter: (User instance, value) => instance.no = value),
      'noSuchMethod': VmProxy(identifier: 'noSuchMethod', externalInstancePropertyReader: (User instance) => instance.noSuchMethod),
      'pwd': VmProxy(identifier: 'pwd', externalInstancePropertyReader: (User instance) => instance.pwd, externalInstancePropertyWriter: (User instance, value) => instance.pwd = value),
      'runtimeType': VmProxy(identifier: 'runtimeType', externalInstancePropertyReader: (User instance) => instance.runtimeType),
      'sex': VmProxy(identifier: 'sex', externalInstancePropertyReader: (User instance) => instance.sex, externalInstancePropertyWriter: (User instance, value) => instance.sex = value),
      'time': VmProxy(identifier: 'time', externalInstancePropertyReader: (User instance) => instance.time),
      'toJson': VmProxy(identifier: 'toJson', externalInstancePropertyReader: (User instance) => instance.toJson),
      'toKValues': VmProxy(identifier: 'toKValues', externalInstancePropertyReader: (User instance) => instance.toKValues),
      'toString': VmProxy(identifier: 'toString', externalInstancePropertyReader: (User instance) => instance.toString),
      'updateByJson': VmProxy(identifier: 'updateByJson', externalInstancePropertyReader: (User instance) => instance.updateByJson),
      'updateByKValues': VmProxy(identifier: 'updateByKValues', externalInstancePropertyReader: (User instance) => instance.updateByKValues),
    },
  );

  ///class UserDirty
  static final classUserDirty = VmClass<UserDirty>(
    identifier: 'UserDirty',
    superclassNames: ['Object'],
    externalProxyMap: {
      'new': VmProxy(identifier: 'new', externalStaticPropertyReader: () => UserDirty.new),
      'age': VmProxy(identifier: 'age', externalInstancePropertyWriter: (UserDirty instance, value) => instance.age = value),
      'data': VmProxy(identifier: 'data', externalInstancePropertyReader: (UserDirty instance) => instance.data),
      'hashCode': VmProxy(identifier: 'hashCode', externalInstancePropertyReader: (UserDirty instance) => instance.hashCode),
      'id': VmProxy(identifier: 'id', externalInstancePropertyWriter: (UserDirty instance, value) => instance.id = value),
      'location': VmProxy(identifier: 'location', externalInstancePropertyWriter: (UserDirty instance, value) => instance.location = value),
      'locationList': VmProxy(identifier: 'locationList', externalInstancePropertyWriter: (UserDirty instance, value) => instance.locationList = value),
      'locationMap': VmProxy(identifier: 'locationMap', externalInstancePropertyWriter: (UserDirty instance, value) => instance.locationMap = value),
      'no': VmProxy(identifier: 'no', externalInstancePropertyWriter: (UserDirty instance, value) => instance.no = value),
      'noSuchMethod': VmProxy(identifier: 'noSuchMethod', externalInstancePropertyReader: (UserDirty instance) => instance.noSuchMethod),
      'pwd': VmProxy(identifier: 'pwd', externalInstancePropertyWriter: (UserDirty instance, value) => instance.pwd = value),
      'runtimeType': VmProxy(identifier: 'runtimeType', externalInstancePropertyReader: (UserDirty instance) => instance.runtimeType),
      'sex': VmProxy(identifier: 'sex', externalInstancePropertyWriter: (UserDirty instance, value) => instance.sex = value),
      'time': VmProxy(identifier: 'time', externalInstancePropertyWriter: (UserDirty instance, value) => instance.time = value),
      'toString': VmProxy(identifier: 'toString', externalInstancePropertyReader: (UserDirty instance) => instance.toString),
    },
  );

  ///class UserQuery
  static final classUserQuery = VmClass<UserQuery>(
    identifier: 'UserQuery',
    superclassNames: ['Object'],
    externalProxyMap: {
      'new': VmProxy(identifier: 'new', externalStaticPropertyReader: () => UserQuery.new),
      '\$secrecyFieldsExclude': VmProxy(identifier: '\$secrecyFieldsExclude', externalStaticPropertyReader: () => UserQuery.$secrecyFieldsExclude),
      '\$tableName': VmProxy(identifier: '\$tableName', externalStaticPropertyReader: () => UserQuery.$tableName),
      'age': VmProxy(identifier: 'age', externalStaticPropertyReader: () => UserQuery.age),
      'id': VmProxy(identifier: 'id', externalStaticPropertyReader: () => UserQuery.id),
      'location': VmProxy(identifier: 'location', externalStaticPropertyReader: () => UserQuery.location),
      'locationList': VmProxy(identifier: 'locationList', externalStaticPropertyReader: () => UserQuery.locationList),
      'locationMap': VmProxy(identifier: 'locationMap', externalStaticPropertyReader: () => UserQuery.locationMap),
      'no': VmProxy(identifier: 'no', externalStaticPropertyReader: () => UserQuery.no),
      'pwd': VmProxy(identifier: 'pwd', externalStaticPropertyReader: () => UserQuery.pwd),
      'sex': VmProxy(identifier: 'sex', externalStaticPropertyReader: () => UserQuery.sex),
      'time': VmProxy(identifier: 'time', externalStaticPropertyReader: () => UserQuery.time),
      'hashCode': VmProxy(identifier: 'hashCode', externalInstancePropertyReader: (UserQuery instance) => instance.hashCode),
      'noSuchMethod': VmProxy(identifier: 'noSuchMethod', externalInstancePropertyReader: (UserQuery instance) => instance.noSuchMethod),
      'runtimeType': VmProxy(identifier: 'runtimeType', externalInstancePropertyReader: (UserQuery instance) => instance.runtimeType),
      'toString': VmProxy(identifier: 'toString', externalInstancePropertyReader: (UserQuery instance) => instance.toString),
    },
  );

  ///all class list
  static final libraryClassList = <VmClass>[
    classConstant,
    classDbBaseModel,
    classLocation,
    classLocationDirty,
    classLocationQuery,
    classUser,
    classUserDirty,
    classUserQuery,
  ];

  ///all proxy list
  static final libraryProxyList = <VmProxy<void>>[];
}

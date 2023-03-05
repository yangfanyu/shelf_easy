import 'package:shelf_easy/shelf_easy.dart';
import '../model/all.dart';

///
///Custom桥接库
///
class ModelLibrary {
  ///类型[Constant]
  static final classConstant = VmClass<Constant>(
    identifier: 'Constant',
    externalProxyMap: {
      'Constant': VmProxy(identifier: 'Constant', externalStaticPropertyReader: () => Constant.new),
      'new': VmProxy(identifier: 'new', externalStaticPropertyReader: () => Constant.new),
      'fromJson': VmProxy(identifier: 'fromJson', externalStaticPropertyReader: () => Constant.fromJson),
      'fromString': VmProxy(identifier: 'fromString', externalStaticPropertyReader: () => Constant.fromString),
      'constMap': VmProxy(identifier: 'constMap', externalStaticPropertyReader: () => Constant.constMap),
      'sexFemale': VmProxy(identifier: 'sexFemale', externalStaticPropertyReader: () => Constant.sexFemale),
      'sexMale': VmProxy(identifier: 'sexMale', externalStaticPropertyReader: () => Constant.sexMale),
      'sexUnknow': VmProxy(identifier: 'sexUnknow', externalStaticPropertyReader: () => Constant.sexUnknow),
      'buildTarget': VmProxy(identifier: 'buildTarget', externalInstancePropertyReader: (instance) => instance.buildTarget),
      'hashCode': VmProxy(identifier: 'hashCode', externalInstancePropertyReader: (instance) => instance.hashCode),
      'noSuchMethod': VmProxy(identifier: 'noSuchMethod', externalInstancePropertyReader: (instance) => instance.noSuchMethod),
      'runtimeType': VmProxy(identifier: 'runtimeType', externalInstancePropertyReader: (instance) => instance.runtimeType),
      'toJson': VmProxy(identifier: 'toJson', externalInstancePropertyReader: (instance) => instance.toJson),
      'toKValues': VmProxy(identifier: 'toKValues', externalInstancePropertyReader: (instance) => instance.toKValues),
      'toString': VmProxy(identifier: 'toString', externalInstancePropertyReader: (instance) => instance.toString),
      'updateByJson': VmProxy(identifier: 'updateByJson', externalInstancePropertyReader: (instance) => instance.updateByJson),
      'updateByKValues': VmProxy(identifier: 'updateByKValues', externalInstancePropertyReader: (instance) => instance.updateByKValues),
    },
  );

  ///类型[Location]
  static final classLocation = VmClass<Location>(
    identifier: 'Location',
    externalProxyMap: {
      'Location': VmProxy(identifier: 'Location', externalStaticPropertyReader: () => Location.new),
      'new': VmProxy(identifier: 'new', externalStaticPropertyReader: () => Location.new),
      'fromJson': VmProxy(identifier: 'fromJson', externalStaticPropertyReader: () => Location.fromJson),
      'fromString': VmProxy(identifier: 'fromString', externalStaticPropertyReader: () => Location.fromString),
      'altitude': VmProxy(identifier: 'altitude', externalInstancePropertyReader: (instance) => instance.altitude, externalInstancePropertyWriter: (instance, value) => instance.altitude = value),
      'buildTarget': VmProxy(identifier: 'buildTarget', externalInstancePropertyReader: (instance) => instance.buildTarget),
      'city': VmProxy(identifier: 'city', externalInstancePropertyReader: (instance) => instance.city, externalInstancePropertyWriter: (instance, value) => instance.city = value),
      'country': VmProxy(identifier: 'country', externalInstancePropertyReader: (instance) => instance.country, externalInstancePropertyWriter: (instance, value) => instance.country = value),
      'district': VmProxy(identifier: 'district', externalInstancePropertyReader: (instance) => instance.district, externalInstancePropertyWriter: (instance, value) => instance.district = value),
      'hashCode': VmProxy(identifier: 'hashCode', externalInstancePropertyReader: (instance) => instance.hashCode),
      'id': VmProxy(identifier: 'id', externalInstancePropertyReader: (instance) => instance.id),
      'latitude': VmProxy(identifier: 'latitude', externalInstancePropertyReader: (instance) => instance.latitude, externalInstancePropertyWriter: (instance, value) => instance.latitude = value),
      'longitude': VmProxy(identifier: 'longitude', externalInstancePropertyReader: (instance) => instance.longitude, externalInstancePropertyWriter: (instance, value) => instance.longitude = value),
      'noSuchMethod': VmProxy(identifier: 'noSuchMethod', externalInstancePropertyReader: (instance) => instance.noSuchMethod),
      'province': VmProxy(identifier: 'province', externalInstancePropertyReader: (instance) => instance.province, externalInstancePropertyWriter: (instance, value) => instance.province = value),
      'runtimeType': VmProxy(identifier: 'runtimeType', externalInstancePropertyReader: (instance) => instance.runtimeType),
      'time': VmProxy(identifier: 'time', externalInstancePropertyReader: (instance) => instance.time),
      'toJson': VmProxy(identifier: 'toJson', externalInstancePropertyReader: (instance) => instance.toJson),
      'toKValues': VmProxy(identifier: 'toKValues', externalInstancePropertyReader: (instance) => instance.toKValues),
      'toString': VmProxy(identifier: 'toString', externalInstancePropertyReader: (instance) => instance.toString),
      'updateByJson': VmProxy(identifier: 'updateByJson', externalInstancePropertyReader: (instance) => instance.updateByJson),
      'updateByKValues': VmProxy(identifier: 'updateByKValues', externalInstancePropertyReader: (instance) => instance.updateByKValues),
    },
  );

  ///类型[User]
  static final classUser = VmClass<User>(
    identifier: 'User',
    externalProxyMap: {
      'User': VmProxy(identifier: 'User', externalStaticPropertyReader: () => User.new),
      'new': VmProxy(identifier: 'new', externalStaticPropertyReader: () => User.new),
      'fromJson': VmProxy(identifier: 'fromJson', externalStaticPropertyReader: () => User.fromJson),
      'fromString': VmProxy(identifier: 'fromString', externalStaticPropertyReader: () => User.fromString),
      'age': VmProxy(identifier: 'age', externalInstancePropertyReader: (instance) => instance.age, externalInstancePropertyWriter: (instance, value) => instance.age = value),
      'buildTarget': VmProxy(identifier: 'buildTarget', externalInstancePropertyReader: (instance) => instance.buildTarget),
      'hashCode': VmProxy(identifier: 'hashCode', externalInstancePropertyReader: (instance) => instance.hashCode),
      'id': VmProxy(identifier: 'id', externalInstancePropertyReader: (instance) => instance.id),
      'location': VmProxy(identifier: 'location', externalInstancePropertyReader: (instance) => instance.location, externalInstancePropertyWriter: (instance, value) => instance.location = value),
      'locationList': VmProxy(identifier: 'locationList', externalInstancePropertyReader: (instance) => instance.locationList, externalInstancePropertyWriter: (instance, value) => instance.locationList = value),
      'locationMap': VmProxy(identifier: 'locationMap', externalInstancePropertyReader: (instance) => instance.locationMap, externalInstancePropertyWriter: (instance, value) => instance.locationMap = value),
      'no': VmProxy(identifier: 'no', externalInstancePropertyReader: (instance) => instance.no, externalInstancePropertyWriter: (instance, value) => instance.no = value),
      'noSuchMethod': VmProxy(identifier: 'noSuchMethod', externalInstancePropertyReader: (instance) => instance.noSuchMethod),
      'pwd': VmProxy(identifier: 'pwd', externalInstancePropertyReader: (instance) => instance.pwd, externalInstancePropertyWriter: (instance, value) => instance.pwd = value),
      'runtimeType': VmProxy(identifier: 'runtimeType', externalInstancePropertyReader: (instance) => instance.runtimeType),
      'sex': VmProxy(identifier: 'sex', externalInstancePropertyReader: (instance) => instance.sex, externalInstancePropertyWriter: (instance, value) => instance.sex = value),
      'time': VmProxy(identifier: 'time', externalInstancePropertyReader: (instance) => instance.time),
      'toJson': VmProxy(identifier: 'toJson', externalInstancePropertyReader: (instance) => instance.toJson),
      'toKValues': VmProxy(identifier: 'toKValues', externalInstancePropertyReader: (instance) => instance.toKValues),
      'toString': VmProxy(identifier: 'toString', externalInstancePropertyReader: (instance) => instance.toString),
      'updateByJson': VmProxy(identifier: 'updateByJson', externalInstancePropertyReader: (instance) => instance.updateByJson),
      'updateByKValues': VmProxy(identifier: 'updateByKValues', externalInstancePropertyReader: (instance) => instance.updateByKValues),
    },
  );

  ///包装类型列表
  static final libraryClassList = <VmClass>[
    classConstant,
    classLocation,
    classUser,
  ];

  ///代理函数列表
  static final libraryProxyList = <VmProxy<void>>[];
}

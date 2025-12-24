import 'dart:convert';

import 'package:shelf_easy/shelf_easy.dart';
import 'package:shelf_easy/shelf_deps.dart' show ObjectId;

///
///位置
///
class Location extends DbBaseModel {
  ///唯一标志
  ObjectId _id;

  ///国家
  String country;

  ///省
  String province;

  ///市
  String city;

  ///区
  String district;

  ///纬度
  double latitude;

  ///经度
  double longitude;

  ///海拔
  double altitude;

  ///创建时间
  int _time;

  static const Map<String, Map<String, String?>> fieldMap = {
    'zh': {
      '_id': null,
      'country': null,
      'province': null,
      'city': null,
      'district': null,
      'latitude': null,
      'longitude': null,
      'altitude': null,
      '_time': null,
    },
    'en': {
      '_id': null,
      'country': null,
      'province': null,
      'city': null,
      'district': null,
      'latitude': null,
      'longitude': null,
      'altitude': null,
      '_time': null,
    },
  };

  ///唯一标志
  ObjectId get id => _id;

  ///创建时间
  int get time => _time;

  Location({
    ObjectId? id,
    String? country,
    String? province,
    String? city,
    String? district,
    double? latitude,
    double? longitude,
    double? altitude,
    int? time,
  }) : _id = id ?? ObjectId(),
       country = country ?? '',
       province = province ?? '',
       city = city ?? '',
       district = district ?? '',
       latitude = latitude ?? 16.666666,
       longitude = longitude ?? 116.666666,
       altitude = altitude ?? 1,
       _time = time ?? DateTime.now().millisecondsSinceEpoch;

  factory Location.fromString(String data) {
    return Location.fromJson(jsonDecode(data.substring(data.indexOf('(') + 1, data.lastIndexOf(')'))));
  }

  factory Location.fromJson(Map<String, dynamic> map) {
    return Location(
      id: DbQueryField.tryParseObjectId(map['_id']),
      country: DbQueryField.tryParseString(map['country']),
      province: DbQueryField.tryParseString(map['province']),
      city: DbQueryField.tryParseString(map['city']),
      district: DbQueryField.tryParseString(map['district']),
      latitude: DbQueryField.tryParseDouble(map['latitude']),
      longitude: DbQueryField.tryParseDouble(map['longitude']),
      altitude: DbQueryField.tryParseDouble(map['altitude']),
      time: DbQueryField.tryParseInt(map['_time']),
    );
  }

  @override
  String toString() {
    return 'Location(${jsonEncode(toJson())})';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '_id': DbQueryField.toBaseType(_id),
      'country': DbQueryField.toBaseType(country),
      'province': DbQueryField.toBaseType(province),
      'city': DbQueryField.toBaseType(city),
      'district': DbQueryField.toBaseType(district),
      'latitude': DbQueryField.toBaseType(latitude),
      'longitude': DbQueryField.toBaseType(longitude),
      'altitude': DbQueryField.toBaseType(altitude),
      '_time': DbQueryField.toBaseType(_time),
    };
  }

  @override
  Map<String, dynamic> toKValues() {
    return {
      '_id': _id,
      'country': country,
      'province': province,
      'city': city,
      'district': district,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      '_time': _time,
    };
  }

  @override
  void updateByJson(Map<String, dynamic> map, {Location? parser}) {
    parser = parser ?? Location.fromJson(map);
    if (map.containsKey('_id')) _id = parser._id;
    if (map.containsKey('country')) country = parser.country;
    if (map.containsKey('province')) province = parser.province;
    if (map.containsKey('city')) city = parser.city;
    if (map.containsKey('district')) district = parser.district;
    if (map.containsKey('latitude')) latitude = parser.latitude;
    if (map.containsKey('longitude')) longitude = parser.longitude;
    if (map.containsKey('altitude')) altitude = parser.altitude;
    if (map.containsKey('_time')) _time = parser._time;
  }

  @override
  void updateByKValues(Map<String, dynamic> map) {
    if (map.containsKey('_id')) _id = map['_id'];
    if (map.containsKey('country')) country = map['country'];
    if (map.containsKey('province')) province = map['province'];
    if (map.containsKey('city')) city = map['city'];
    if (map.containsKey('district')) district = map['district'];
    if (map.containsKey('latitude')) latitude = map['latitude'];
    if (map.containsKey('longitude')) longitude = map['longitude'];
    if (map.containsKey('altitude')) altitude = map['altitude'];
    if (map.containsKey('_time')) _time = map['_time'];
  }
}

class LocationField {
  ///唯一标志
  static const String id = '_id';

  ///国家
  static const String country = 'country';

  ///省
  static const String province = 'province';

  ///市
  static const String city = 'city';

  ///区
  static const String district = 'district';

  ///纬度
  static const String latitude = 'latitude';

  ///经度
  static const String longitude = 'longitude';

  ///海拔
  static const String altitude = 'altitude';

  ///创建时间
  static const String time = '_time';
}

class LocationDirty {
  final Map<String, dynamic> data = {};

  ///唯一标志
  set id(ObjectId value) => data['_id'] = DbQueryField.toBaseType(value);

  ///国家
  set country(String value) => data['country'] = DbQueryField.toBaseType(value);

  ///省
  set province(String value) => data['province'] = DbQueryField.toBaseType(value);

  ///市
  set city(String value) => data['city'] = DbQueryField.toBaseType(value);

  ///区
  set district(String value) => data['district'] = DbQueryField.toBaseType(value);

  ///纬度
  set latitude(double value) => data['latitude'] = DbQueryField.toBaseType(value);

  ///经度
  set longitude(double value) => data['longitude'] = DbQueryField.toBaseType(value);

  ///海拔
  set altitude(double value) => data['altitude'] = DbQueryField.toBaseType(value);

  ///创建时间
  set time(int value) => data['_time'] = DbQueryField.toBaseType(value);
}

class LocationQuery {
  static const $tableName = 'location';

  ///唯一标志
  static DbQueryField<ObjectId, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get id => DbQueryField('_id');

  ///国家
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get country => DbQueryField('country');

  ///省
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get province => DbQueryField('province');

  ///市
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get city => DbQueryField('city');

  ///区
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get district => DbQueryField('district');

  ///纬度
  static DbQueryField<double, double, DBUnsupportArrayOperate> get latitude => DbQueryField('latitude');

  ///经度
  static DbQueryField<double, double, DBUnsupportArrayOperate> get longitude => DbQueryField('longitude');

  ///海拔
  static DbQueryField<double, double, DBUnsupportArrayOperate> get altitude => DbQueryField('altitude');

  ///创建时间
  static DbQueryField<int, int, DBUnsupportArrayOperate> get time => DbQueryField('_time');
}

extension LocationStringExtension on String {
  String get trsLocationField => Location.fieldMap[EasyLocale.languageCode]?[this] ?? this;

  String trsLocationFieldByCode(String code) => Location.fieldMap[code]?[this] ?? this;
}

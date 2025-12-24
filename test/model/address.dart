import 'dart:convert';

import 'package:shelf_easy/shelf_easy.dart';

import 'location.dart';

///
///用户地址类
///
class Address extends DbBaseModel {
  ///国家
  String country;

  ///省份
  String province;

  ///市
  String city;

  ///县（区）
  String area;

  ///县（区）
  Location location;

  static const Map<String, Map<String, String?>> fieldMap = {
    'zh': {
      'country': null,
      'province': null,
      'city': null,
      'area': null,
      'location': null,
    },
    'en': {
      'country': null,
      'province': null,
      'city': null,
      'area': null,
      'location': null,
    },
  };

  Address({
    String? country,
    String? province,
    String? city,
    String? area,
    Location? location,
  }) : country = country ?? '',
       province = province ?? '',
       city = city ?? '',
       area = area ?? '',
       location = location ?? Location();

  factory Address.fromString(String data) {
    return Address.fromJson(jsonDecode(data.substring(data.indexOf('(') + 1, data.lastIndexOf(')'))));
  }

  factory Address.fromJson(Map<String, dynamic> map) {
    return Address(
      country: DbQueryField.tryParseString(map['country']),
      province: DbQueryField.tryParseString(map['province']),
      city: DbQueryField.tryParseString(map['city']),
      area: DbQueryField.tryParseString(map['area']),
      location: map['location'] is Map ? Location.fromJson(map['location']) : map['location'],
    );
  }

  @override
  String toString() {
    return 'Address(${jsonEncode(toJson())})';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'country': DbQueryField.toBaseType(country),
      'province': DbQueryField.toBaseType(province),
      'city': DbQueryField.toBaseType(city),
      'area': DbQueryField.toBaseType(area),
      'location': DbQueryField.toBaseType(location),
    };
  }

  @override
  Map<String, dynamic> toKValues() {
    return {
      'country': country,
      'province': province,
      'city': city,
      'area': area,
      'location': location,
    };
  }

  @override
  void updateByJson(Map<String, dynamic> map, {Address? parser}) {
    parser = parser ?? Address.fromJson(map);
    if (map.containsKey('country')) country = parser.country;
    if (map.containsKey('province')) province = parser.province;
    if (map.containsKey('city')) city = parser.city;
    if (map.containsKey('area')) area = parser.area;
    if (map.containsKey('location')) location = parser.location;
  }

  @override
  void updateByKValues(Map<String, dynamic> map) {
    if (map.containsKey('country')) country = map['country'];
    if (map.containsKey('province')) province = map['province'];
    if (map.containsKey('city')) city = map['city'];
    if (map.containsKey('area')) area = map['area'];
    if (map.containsKey('location')) location = map['location'];
  }
}

class AddressField {
  ///国家
  static const String country = 'country';

  ///省份
  static const String province = 'province';

  ///市
  static const String city = 'city';

  ///县（区）
  static const String area = 'area';

  ///县（区）
  static const String location = 'location';
}

class AddressDirty {
  final Map<String, dynamic> data = {};

  ///国家
  set country(String value) => data['country'] = DbQueryField.toBaseType(value);

  ///省份
  set province(String value) => data['province'] = DbQueryField.toBaseType(value);

  ///市
  set city(String value) => data['city'] = DbQueryField.toBaseType(value);

  ///县（区）
  set area(String value) => data['area'] = DbQueryField.toBaseType(value);

  ///县（区）
  set location(Location value) => data['location'] = DbQueryField.toBaseType(value);
}

class AddressQuery {
  static const $tableName = 'address';

  ///国家
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get country => DbQueryField('country');

  ///省份
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get province => DbQueryField('province');

  ///市
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get city => DbQueryField('city');

  ///县（区）
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get area => DbQueryField('area');

  ///县（区）
  static DbQueryField<Location, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get location => DbQueryField('location');
}

extension AddressStringExtension on String {
  String get trsAddressField => Address.fieldMap[EasyLocale.languageCode]?[this] ?? this;

  String trsAddressFieldByCode(String code) => Address.fieldMap[code]?[this] ?? this;
}

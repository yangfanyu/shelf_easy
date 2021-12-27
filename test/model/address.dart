import 'package:shelf_easy/src/db/db_base.dart';
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

  Address({
    String? country,
    String? province,
    String? city,
    String? area,
    Location? location,
  })  : country = country ?? '',
        province = province ?? '',
        city = city ?? '',
        area = area ?? '',
        location = location ?? Location();

  factory Address.fromJson(Map<String, dynamic> map) {
    return Address(
      country: map['country'],
      province: map['province'],
      city: map['city'],
      area: map['area'],
      location: map['location'] is Map ? Location.fromJson(map['location']) : map['location'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'country': DbQueryField.convertToBaseType(country),
      'province': DbQueryField.convertToBaseType(province),
      'city': DbQueryField.convertToBaseType(city),
      'area': DbQueryField.convertToBaseType(area),
      'location': DbQueryField.convertToBaseType(location),
    };
  }

  void update(Map<String, dynamic> map) {
    final parser = Address.fromJson(map);
    if (map['country'] != null) country = parser.country;
    if (map['province'] != null) province = parser.province;
    if (map['city'] != null) city = parser.city;
    if (map['area'] != null) area = parser.area;
    if (map['location'] != null) location = parser.location;
  }
}

class AddressDirty {
  final Map<String, dynamic> data = {};
  set country(String value) => data['country'] = DbQueryField.convertToBaseType(value);
  set province(String value) => data['province'] = DbQueryField.convertToBaseType(value);
  set city(String value) => data['city'] = DbQueryField.convertToBaseType(value);
  set area(String value) => data['area'] = DbQueryField.convertToBaseType(value);
  set location(Location value) => data['location'] = DbQueryField.convertToBaseType(value);
}

class AddressQuery {
  static const $tableName = 'address';
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get country => DbQueryField('country');
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get province => DbQueryField('province');
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get city => DbQueryField('city');
  static DbQueryField<String, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get area => DbQueryField('area');
  static DbQueryField<Location, DBUnsupportNumberOperate, DBUnsupportArrayOperate> get location => DbQueryField('location');
}

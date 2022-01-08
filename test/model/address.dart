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

  void updateFields(Map<String, dynamic> map) {
    final parser = Address.fromJson(map);
    if (map.containsKey('country')) country = parser.country;
    if (map.containsKey('province')) province = parser.province;
    if (map.containsKey('city')) city = parser.city;
    if (map.containsKey('area')) area = parser.area;
    if (map.containsKey('location')) location = parser.location;
  }
}

class AddressDirty {
  final Map<String, dynamic> data = {};

  ///国家
  set country(String value) => data['country'] = DbQueryField.convertToBaseType(value);

  ///省份
  set province(String value) => data['province'] = DbQueryField.convertToBaseType(value);

  ///市
  set city(String value) => data['city'] = DbQueryField.convertToBaseType(value);

  ///县（区）
  set area(String value) => data['area'] = DbQueryField.convertToBaseType(value);

  ///县（区）
  set location(Location value) => data['location'] = DbQueryField.convertToBaseType(value);
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

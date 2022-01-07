import 'package:shelf_easy/src/db/db_base.dart';

///
///用户位置类
///
class Location extends DbBaseModel {
  ///纬度
  double latitude;

  ///经度
  double longitude;

  ///精确度
  double accuracy;

  Location({
    double? latitude,
    double? longitude,
    double? accuracy,
  })  : latitude = latitude ?? 0,
        longitude = longitude ?? 0,
        accuracy = accuracy ?? 0;

  factory Location.fromJson(Map<String, dynamic> map) {
    return Location(
      latitude: map['latitude'],
      longitude: map['longitude'],
      accuracy: map['accuracy'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'latitude': DbQueryField.convertToBaseType(latitude),
      'longitude': DbQueryField.convertToBaseType(longitude),
      'accuracy': DbQueryField.convertToBaseType(accuracy),
    };
  }

  void updateFields(Map<String, dynamic> map) {
    final parser = Location.fromJson(map);
    if (map['latitude'] != null) latitude = parser.latitude;
    if (map['longitude'] != null) longitude = parser.longitude;
    if (map['accuracy'] != null) accuracy = parser.accuracy;
  }
}

class LocationDirty {
  final Map<String, dynamic> data = {};
  set latitude(double value) => data['latitude'] = DbQueryField.convertToBaseType(value);
  set longitude(double value) => data['longitude'] = DbQueryField.convertToBaseType(value);
  set accuracy(double value) => data['accuracy'] = DbQueryField.convertToBaseType(value);
}

class LocationQuery {
  static const $tableName = 'location';
  static DbQueryField<double, double, DBUnsupportArrayOperate> get latitude => DbQueryField('latitude');
  static DbQueryField<double, double, DBUnsupportArrayOperate> get longitude => DbQueryField('longitude');
  static DbQueryField<double, double, DBUnsupportArrayOperate> get accuracy => DbQueryField('accuracy');
}

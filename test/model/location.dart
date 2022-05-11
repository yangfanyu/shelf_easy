import 'package:shelf_easy/shelf_easy.dart';

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

  @override
  Map<String, dynamic> toKValues() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
    };
  }

  void updateFields(Map<String, dynamic> map, {Location? parser}) {
    parser = parser ?? Location.fromJson(map);
    if (map.containsKey('latitude')) latitude = parser.latitude;
    if (map.containsKey('longitude')) longitude = parser.longitude;
    if (map.containsKey('accuracy')) accuracy = parser.accuracy;
  }
}

class LocationDirty {
  final Map<String, dynamic> data = {};

  ///纬度
  set latitude(double value) => data['latitude'] = DbQueryField.convertToBaseType(value);

  ///经度
  set longitude(double value) => data['longitude'] = DbQueryField.convertToBaseType(value);

  ///精确度
  set accuracy(double value) => data['accuracy'] = DbQueryField.convertToBaseType(value);
}

class LocationQuery {
  static const $tableName = 'location';

  ///纬度
  static DbQueryField<double, double, DBUnsupportArrayOperate> get latitude => DbQueryField('latitude');

  ///经度
  static DbQueryField<double, double, DBUnsupportArrayOperate> get longitude => DbQueryField('longitude');

  ///精确度
  static DbQueryField<double, double, DBUnsupportArrayOperate> get accuracy => DbQueryField('accuracy');
}

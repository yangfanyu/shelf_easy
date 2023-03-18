import 'dart:convert';

import 'package:shelf_easy/shelf_easy.dart';

import 'location.dart';

///
///位置包装类
///
class WrapperLocation extends DbBaseModel {
  ///纬度
  double latitude;

  ///经度
  double longitude;

  ///精确度
  double accuracy;

  WrapperLocation({
    double? latitude,
    double? longitude,
    double? accuracy,
  })  : latitude = latitude ?? 0,
        longitude = longitude ?? 0,
        accuracy = accuracy ?? 0;

  factory WrapperLocation.fromString(String data) {
    return WrapperLocation.fromJson(jsonDecode(data.substring(data.indexOf('(') + 1, data.lastIndexOf(')'))));
  }

  factory WrapperLocation.fromJson(Map<String, dynamic> map) {
    map = map['args'];
    return WrapperLocation(
      latitude: DbQueryField.tryParseDouble(map['latitude']),
      longitude: DbQueryField.tryParseDouble(map['longitude']),
      accuracy: DbQueryField.tryParseDouble(map['accuracy']),
    );
  }

  @override
  String toString() {
    return 'WrapperLocation(${jsonEncode(toJson())})';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'WrapperLocation',
      'args': {
        'latitude': DbQueryField.toBaseType(latitude),
        'longitude': DbQueryField.toBaseType(longitude),
        'accuracy': DbQueryField.toBaseType(accuracy),
      },
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

  @override
  void updateByJson(Map<String, dynamic> map, {WrapperLocation? parser}) {
    parser = parser ?? WrapperLocation.fromJson(map);
    if (map.containsKey('latitude')) latitude = parser.latitude;
    if (map.containsKey('longitude')) longitude = parser.longitude;
    if (map.containsKey('accuracy')) accuracy = parser.accuracy;
  }

  @override
  void updateByKValues(Map<String, dynamic> map) {
    if (map.containsKey('latitude')) latitude = map['latitude'];
    if (map.containsKey('longitude')) longitude = map['longitude'];
    if (map.containsKey('accuracy')) accuracy = map['accuracy'];
  }

  @override
  Location buildTarget() {
    return Location(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
    );
  }
}

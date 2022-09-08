import 'package:shelf_easy/shelf_easy.dart';

import 'wrapper_location.dart';
import 'wrapper_empty.dart';

export 'wrapper_location.dart';
export 'wrapper_empty.dart';

///Parsing class generated
class WrapBuilder {
  ///Parsing mapdata generated
  static final _recordBuilder = <String, DbBaseModel Function(Map<String, dynamic> map)>{
    'WrapperLocation': (Map<String, dynamic> map) => WrapperLocation.fromJson(map),
    'WrapperEmpty': (Map<String, dynamic> map) => WrapperEmpty.fromJson(map),
  };

  ///Parsing mapdata generated
  static final _targetBuilder = <String, DbBaseModel Function(DbBaseModel record)>{
    'WrapperLocation': (DbBaseModel record) => record.buildTarget(),
    'WrapperEmpty': (DbBaseModel record) => record.buildTarget(),
  };

  ///Parsing method generated
  static DbBaseModel buildRecord(Map<String, dynamic> map) => _recordBuilder[map['type']]!(map);

  ///Parsing method generated
  static DbBaseModel buildTarget(DbBaseModel record) => _targetBuilder[record.runtimeType]!(record);
}

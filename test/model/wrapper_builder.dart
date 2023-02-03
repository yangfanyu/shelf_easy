import 'package:shelf_easy/shelf_easy.dart';

import 'wrapper_location.dart';
import 'wrapper_empty.dart';

export 'wrapper_location.dart';
export 'wrapper_empty.dart';

///
///Parsing class
///
class WrapBuilder {
  ///Parsing fields
  static final _recordBuilder = <String, DbBaseModel Function(Map<String, dynamic> map)>{
    'WrapperLocation': (Map<String, dynamic> map) => WrapperLocation.fromJson(map),
    'WrapperEmpty': (Map<String, dynamic> map) => WrapperEmpty.fromJson(map),
  };

  ///Parsing method
  static DbBaseModel buildRecord(Map<String, dynamic> map) => _recordBuilder[map['type']]!(map);
}

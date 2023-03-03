import 'package:shelf_easy/shelf_easy.dart';

import '../model/all.dart';

void main() {
  final logger = EasyLogger();
  final encoder = JsonEncoder.withIndent('  ');

  final user1 = User(
    no: 'aaa',
    pwd: '111',
    location: Location(
      country: 'xx国',
      province: 'xx省',
      city: 'xx市',
      district: 'xx区',
    ),
    locationList: [
      Location(district: 'List项1'),
      Location(district: 'List项2'),
    ],
  );
  final user1String = encoder.convert(user1);
  logger.logInfo(['user1 =>', user1String]);

  final user2 = User.fromJson(jsonDecode(user1String))
    ..locationList = null
    ..locationMap = {
      1: Location(district: 'Map项1'),
      2: Location(district: 'Map项2'),
    };
  final user2String = encoder.convert(user2);
  logger.logInfo(['user2 =>', user2String]);
}

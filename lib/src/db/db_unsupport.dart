import 'db_base.dart';

class DbUnsupport extends DbBase {}

DbBase create(DbConfig config) => throw UnsupportedError('No implementation of the DbBase api provided.');

import 'wk_base.dart';

class WkUnsupport extends WkBase {}

WkBase create(WkConfig config) {
  throw UnsupportedError('No implementation of the WkBase api provided.');
}

import 'package:js/js.dart';
import 'package:shelf_easy/src/wk/wk_base.dart';

@anonymous
@JS()
abstract class MessageEvent {
  external dynamic get data;
}

@JS('postMessage')
external void postMessage(obj);

@JS('onmessage')
external set onMessage(fun);

void main() {
  late WkConfig config;
  onMessage = allowInterop((MessageEvent event) async {
    final message = event.data;
    if (message is WkConfig) {
      config = message;
      postMessage('inited');
    } else if (message is WkMessage) {
      switch (message.signal) {
        case WkSignal.start:
        case WkSignal.close:
          try {
            final result = await config.serviceHandler(message.signal, config.serviceConfig);
            postMessage(WkMessage(message.signal, message.id, message.type, result));
          } catch (error) {
            postMessage(WkMessage(message.signal, message.id, message.type, false));
          }
          break;
        case WkSignal.message:
          try {
            final result = await config.messageHandler(config.serviceConfig, message.type, message.data);
            postMessage(WkMessage(message.signal, message.id, message.type, result));
          } catch (error) {
            postMessage(WkMessage(message.signal, message.id, message.type, null));
          }
          break;
      }
    }
  });
}

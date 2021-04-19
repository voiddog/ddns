import 'package:logger/logger.dart';
import 'package:event_bus/event_bus.dart';

final logger = Logger(
  filter: ProductionFilter(),
  printer: PrettyPrinter(
    printTime: false,
    methodCount: 0,
    errorMethodCount: 0,
  )
);

final eventBus = EventBus();

bool isIPV4(String? ip) {
  if (ip?.isNotEmpty != true) {
    return false;
  }
  try {
    final ips = ip!.split('.');
    assert(ips.length == 4);
    for (var node in ips) {
      final v = int.parse(node);
      if (v < 0 || v > 255) {
        return false;
      }
    }
  } catch (e) {
    return false;
  }
  return true;
}

import 'package:ddns/ddns.dart';
import 'package:test/test.dart';

void main() {
  test('test ip server', () async {
    final ipService = IPService();
    expect(ipService.ipv4, null);
    ipService.start({});
    await ipService.ipStream.first;
    expect(ipService.ipv4 != null, true);
    print('done');
  });
}

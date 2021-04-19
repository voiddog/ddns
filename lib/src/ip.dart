import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import '../ddns.dart';
import 'service.dart';
import 'utils.dart';

part 'ip.g.dart';

@JsonSerializable()
class IPServiceConfig {
  final int? ipUpdateDuration;

  IPServiceConfig({required this.ipUpdateDuration});

  factory IPServiceConfig.fromJson(Map<String, dynamic> json) =>
      _$IPServiceConfigFromJson(json);
}

class IPService extends Service {
  IPService();

  /// 当前的 ipv4
  String? get ipv4 => _ipv4;
  Stream<String> get ipStream => _ipv4StreamCtl.stream;

  @override
  void onStart(Map<String, dynamic> config) {
    assert(_client == null);
    assert(_timer == null);
    _client = http.Client();
    _request2UpdateIP();
    final _config = IPServiceConfig.fromJson(config);
    _timer = Timer.periodic(
        _config.ipUpdateDuration as Duration? ?? const Duration(minutes: 5), (_) {
      _request2UpdateIP();
    });
  }

  @override
  void onStop() {
    _client!.close();
    _client = null;
    _timer!.cancel();
    _timer = null;
  }

  @override
  String get configName => 'ip';

  Future<void> _request2UpdateIP() async {
    logger.v('request get ip.');
    logger.v('start get ip.');
    try {
      final response =
          await _client!.get(Uri.parse('https://ipv4.icanhazip.com/'));
      final ip = response.body.trim();
      // verify ipv4
      if (!isIPV4(ip)) {
        logger.e('$ip is not ipv4.');
        return;
      }
      logger.v('get ip success: $ip');
      _updateIP(ip);
    } catch (e, stack) {
      logger.e('get ip failed.', e, stack);
    }
  }

  void _updateIP(String ip) {
    if (ip != _ipv4) {
      logger.i('ip changed: $ip');
    }
    _ipv4 = ip;
    _ipv4StreamCtl.add(ip);
  }

  final StreamController<String> _ipv4StreamCtl =
      StreamController.broadcast(sync: true);
  String? _ipv4;
  http.Client? _client;
  Timer? _timer;
}

import 'dart:async';
import 'dart:convert';

import 'package:ddns/ddns.dart';
import 'package:ddns/src/mail.dart';
import 'package:ddns/src/utils.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

import 'service.dart';

part 'godaddy.g.dart';

@JsonSerializable()
class GodaddyConfig {
  final String domain;
  final String records;
  final String key;
  final String secret;
  @JsonKey(name: 'error_mails')
  final List<String> errorMails;

  GodaddyConfig({
    @required this.domain,
    @required this.records,
    @required this.key,
    @required this.secret,
    this.errorMails,
  })  : assert(domain != null),
        assert(records != null),
        assert(key != null),
        assert(secret != null);

  factory GodaddyConfig.fromJson(Map<String, dynamic> json) =>
      _$GodaddyConfigFromJson(json);
}

class GodaddyService extends Service {
  final Stream<String> ipv4Stream;

  final String initIpv4;

  GodaddyService({@required this.ipv4Stream, @required this.initIpv4})
      : assert(ipv4Stream != null);

  @override
  void onStart(Map<String, dynamic> config) {
    assert(_subscription == null);
    _config = config == null ? null : GodaddyConfig.fromJson(config);
    _subscription = ipv4Stream.listen(_onNewIp);
    if (initIpv4?.isNotEmpty == true) {
      _onNewIp(initIpv4);
    }
  }

  @override
  void onStop() {
    _subscription.cancel();
    _subscription = null;
  }

  @override
  String get configName => 'godaddy';

  String _lastIpv4;
  Future<void> _onNewIp(String ipv4) async {
    if (_config == null) {
      return;
    }
    if (!isIPV4(ipv4)) {
      return;
    }
    if (_lastIpv4 == ipv4) {
      return;
    }
    final domain = _config.domain;
    final records = _config.records;
    final response = await http.put(
      'https://api.godaddy.com/v1/domains/$domain/records/A/$records',
      body: jsonEncode([{
        'data': ipv4,
        'ttl': 3600,
        'name': records,
        'type': 'A',
      }]),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'sso-key ${_config.key}:${_config.secret}',
      },
    );
    if (response.statusCode != 200) {
      if (_config.errorMails?.isNotEmpty == true) {
        eventBus.fire(SendMailEvent(
          recipients: _config.errorMails,
          subject: 'Update Godaddy error',
          text: 'code :${response.statusCode}\n${response.body}',
        ));
      }
      logger.e('code: ${response.statusCode}, body: ${response.body}');
    } else {
      logger.i('success update godaddy ip: ${records}.${domain} -> $ipv4');
      _lastIpv4 = ipv4;
    }
  }

  GodaddyConfig _config;
  StreamSubscription _subscription;
}

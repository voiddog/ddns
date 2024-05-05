import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:core';

import 'package:json_annotation/json_annotation.dart';

import '../ddns.dart';
import 'mail.dart';
import 'service.dart';
import 'utils.dart';

part 'godaddy.g.dart';

@JsonSerializable()
class GodaddyConfig {
  final String domain;
  final String records;
  final String key;
  final String secret;
  final String? proxy;
  @JsonKey(name: 'error_mails')
  final List<String>? errorMails;

  GodaddyConfig({
    required this.domain,
    required this.records,
    required this.key,
    required this.secret,
    this.proxy,
    this.errorMails,
  });

  factory GodaddyConfig.fromJson(Map<String, dynamic> json) =>
      _$GodaddyConfigFromJson(json);
}

class GodaddyService extends Service {
  final Stream<String> ipv4Stream;

  final String? initIpv4;

  GodaddyService({required this.ipv4Stream, required this.initIpv4});

  @override
  void onStart(Map<String, dynamic> config) {
    assert(_subscription == null);
    _config = GodaddyConfig.fromJson(config);
    _subscription = ipv4Stream.listen(_onNewIp);
    _send_list = <int>[];
    if (initIpv4?.isNotEmpty == true) {
      _onNewIp(initIpv4);
    }
  }

  @override
  void onStop() {
    _subscription!.cancel();
    _subscription = null;
  }

  @override
  String get configName => 'godaddy';

  String? _lastIpv4;
  Future<void> _onNewIp(String? ipv4) async {
    if (_config == null) {
      return;
    }
    if (!isIPV4(ipv4)) {
      return;
    }
    if (_lastIpv4 == ipv4) {
      return;
    }
    final domain = _config!.domain;
    final records = _config!.records;
    final client = HttpClient();

    final url = Uri.parse(
        'https://api.godaddy.com/v1/domains/$domain/records/A/$records');
    final body = jsonEncode([
      {
        'data': ipv4,
        'ttl': 3600,
        'name': records,
        'type': 'A',
      }
    ]);

    try {
      if (_config!.proxy != null) {
        client.findProxy = (uri) {
          return 'PROXY ${_config!.proxy}';
        };
      }
      final request = await client.putUrl(url);
      request.headers.contentType = ContentType.json;
      request.headers.add(HttpHeaders.authorizationHeader,
          'sso-key ${_config!.key}:${_config!.secret}');
      request.headers.add(HttpHeaders.acceptHeader, 'application/json');

      request.write(body);

      final response = await request.close();

      if (response.statusCode != 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        if (_config!.errorMails?.isNotEmpty == true) {
          final sendText = 'code :${response.statusCode}\n${responseBody}';
          final sendHashCode = sendText.hashCode;
          if (_send_list?.contains(sendHashCode) == true) {
            _send_list?.add(sendHashCode);
            eventBus.fire(SendMailEvent(
              recipients: _config!.errorMails!,
              subject: 'Update Godaddy error',
              text: sendText,
            ));
          }
        }
        logger.e('code: ${response.statusCode}, body: ${responseBody}');
      } else {
        logger.i('success update godaddy ip: ${records}.${domain} -> $ipv4');
        _send_list?.clear();
        _lastIpv4 = ipv4;
      }
    } catch (e) {
      logger.e('request error: $e');
    }
    client.findProxy = null;
  }

  GodaddyConfig? _config;
  StreamSubscription? _subscription;
  List<int>? _send_list;
}

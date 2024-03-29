import 'dart:async';

import 'package:json_annotation/json_annotation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import 'service.dart';
import 'utils.dart';

part 'mail.g.dart';

@JsonSerializable()
class MailServiceConfig {
  final String username;

  final String password;

  @JsonKey(name: 'smtp_host')
  final String smtpHost;

  @JsonKey(name: 'smtp_port')
  final int? smtpPort;

  final bool? ssl;

  MailServiceConfig({
    required this.username,
    required this.password,
    required this.smtpHost,
    this.smtpPort = 587,
    this.ssl = false,
  });

  factory MailServiceConfig.fromJson(Map<String, dynamic> json) =>
      _$MailServiceConfigFromJson(json);
}

/// 发送邮件
class SendMailEvent {
  final List<String> recipients;
  final String subject;
  final String? text;

  SendMailEvent({required this.recipients, required this.subject, this.text});
}

class MailService extends Service {
  @override
  String get configName => 'mail';

  @override
  void onStart(Map<String, dynamic> json) {
    assert(_subscription == null);
    final config = MailServiceConfig.fromJson(json);
    final smtpServer = SmtpServer(
      config.smtpHost,
      port: config.smtpPort!,
      ssl: config.ssl!,
      username: config.username,
      password: config.password,
    );
    _subscription = eventBus.on<SendMailEvent>().listen((event) {
      final message = Message()
        ..from = Address(config.username, 'voiddog')
        ..recipients.addAll(event.recipients)
        ..subject = event.subject
        ..text = event.text;
      _sendMail(smtpServer, message);
    });
  }

  @override
  void onStop() {
    _subscription!.cancel();
    _subscription = null;
  }

  void _sendMail(SmtpServer server, Message message) async {
    try {
      await send(message, server);
      logger.i('Send mail success.');
    } on MailerException catch (e, stack) {
      final sb = StringBuffer();
      sb.writeln('Send mail failed.');
      for (var p in e.problems) {
        sb.writeln('  code: ${p.code}, ');
      }
      logger.e(sb.toString(), error: e, stackTrace: stack);
    } catch (e, stack) {
      logger.e('On mail send error:', error: e, stackTrace: stack);
    }
  }

  StreamSubscription? _subscription;
}

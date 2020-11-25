// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MailServiceConfig _$MailServiceConfigFromJson(Map<String, dynamic> json) {
  return MailServiceConfig(
    username: json['username'] as String,
    password: json['password'] as String,
    smtpHost: json['smtp_host'] as String,
    smtpPort: json['smtp_port'] as int,
    ssl: json['ssl'] as bool,
  );
}

Map<String, dynamic> _$MailServiceConfigToJson(MailServiceConfig instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
      'smtp_host': instance.smtpHost,
      'smtp_port': instance.smtpPort,
      'ssl': instance.ssl,
    };

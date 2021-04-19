// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'godaddy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GodaddyConfig _$GodaddyConfigFromJson(Map<String, dynamic> json) {
  return GodaddyConfig(
    domain: json['domain'] as String,
    records: json['records'] as String,
    key: json['key'] as String,
    secret: json['secret'] as String,
    errorMails:
        (json['error_mails'] as List?)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$GodaddyConfigToJson(GodaddyConfig instance) =>
    <String, dynamic>{
      'domain': instance.domain,
      'records': instance.records,
      'key': instance.key,
      'secret': instance.secret,
      'error_mails': instance.errorMails,
    };

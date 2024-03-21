// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'godaddy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GodaddyConfig _$GodaddyConfigFromJson(Map<String, dynamic> json) =>
    GodaddyConfig(
      domain: json['domain'] as String,
      records: json['records'] as String,
      key: json['key'] as String,
      secret: json['secret'] as String,
      proxy: json['proxy'] as String?,
      errorMails: (json['error_mails'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$GodaddyConfigToJson(GodaddyConfig instance) =>
    <String, dynamic>{
      'domain': instance.domain,
      'records': instance.records,
      'key': instance.key,
      'secret': instance.secret,
      'proxy': instance.proxy,
      'error_mails': instance.errorMails,
    };

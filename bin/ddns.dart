import 'dart:io';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:args/args.dart';
import 'package:ddns/ddns.dart' as ddns;

void main(List<String> arguments) {
  var parser = ArgParser();
  parser.addOption('config', abbr: 'c', help: '配置文件 path');
  parser.addFlag('verbose',
      abbr: 'v', help: '显示 verbose 级别日志', defaultsTo: false);

  final result = parser.parse(arguments);
  final configPath = result['config'];
  final verbose = result['verbose'];

  if (verbose) {
    Logger.level = Level.verbose;
  } else {
    Logger.level = Level.info;
  }

  if (configPath is! String || configPath?.isNotEmpty != true) {
    ddns.logger.e('缺少配置文件 path 参数.');
    exit(0);
  }

  if (!File(configPath).existsSync()) {
    ddns.logger.e('配置文件 $configPath 不存在.');
    exit(0);
  }
  Map<String, dynamic>? config = jsonDecode(File(configPath).readAsStringSync());
  final ipService = ddns.IPService();
  final serviceList = <ddns.Service>[
    ipService,
    ddns.GodaddyService(
      ipv4Stream: ipService.ipStream,
      initIpv4: ipService.ipv4,
    ),
    ddns.MailService(),
  ];
  serviceList.forEach((service) {
    final c = config![service.configName];
    if (c != null) {
      service.start(c);
    }
  });
}

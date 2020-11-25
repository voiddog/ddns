abstract class Service {

  bool get isStart => _isStart;
  bool _isStart = false;

  void start(Map<String, dynamic> config) {
    if (_isStart) {
      // already start
      return;
    }
    _isStart = true;
    onStart(config);
  }

  void stop() {
    if (!_isStart) {
      // not start yet
      return;
    }
    _isStart = false;
    onStop();
  }

  /// service 配置名称
  String get configName;

  void onStart(Map<String, dynamic> config);

  void onStop();
}
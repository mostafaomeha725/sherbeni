import 'dart:async';

class GlobalSyncBackoffTimer {
  Timer? _retryTimer;
  int _currentBackoffSeconds = 5;
  static const int _maxBackoffSeconds = 60;

  void scheduleRetry(void Function() onRetry) {
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: _currentBackoffSeconds), onRetry);

    // Exponential backoff
    _currentBackoffSeconds *= 2;
    if (_currentBackoffSeconds > _maxBackoffSeconds) {
      _currentBackoffSeconds = _maxBackoffSeconds;
    }
  }

  void reset() {
    _currentBackoffSeconds = 5;
  }

  void cancel() {
    _retryTimer?.cancel();
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';

/// خدمة مراقبة الاتصال بالإنترنت والتعامل مع حالات عدم الاتصال
class ConnectivityService extends ChangeNotifier {
  bool _isOnline = true;
  Timer? _heartbeatTimer;

  bool get isOnline => _isOnline;

  ConnectivityService({bool autoMonitor = true}) {
    if (autoMonitor) {
      _startMonitoring();
    }
  }

  void _startMonitoring() {
    // محاكاة الفحص الدوري للاتصال بالسحابة
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 25), (timer) {
      // الاتصال نشط ومستقر
      if (!_isOnline) {
        _isOnline = true;
        notifyListeners();
      }
    });
  }

  void setOnlineStatus(bool status) {
    if (_isOnline != status) {
      _isOnline = status;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    super.dispose();
  }
}

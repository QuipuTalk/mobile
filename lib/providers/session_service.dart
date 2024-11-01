import 'package:flutter/material.dart';

class SessionService extends ChangeNotifier {
  String? _sessionId;

  String? get sessionId => _sessionId;

  void setSessionId(String sessionId) {
    _sessionId = sessionId;
    notifyListeners();
  }

  void clearSessionId() {
    _sessionId = null;
    notifyListeners();
  }

  bool get hasActiveSession => _sessionId != null;
}

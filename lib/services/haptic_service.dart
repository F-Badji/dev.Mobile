import 'package:flutter_vibrate/flutter_vibrate.dart';

class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  bool _isEnabled = true;

  void enableHaptics() {
    _isEnabled = true;
  }

  void disableHaptics() {
    _isEnabled = false;
  }

  void triggerLight() {
    if (!_isEnabled) return;
    Vibrate.feedback(FeedbackType.light);
  }

  void triggerMedium() {
    if (!_isEnabled) return;
    Vibrate.feedback(FeedbackType.medium);
  }

  void triggerHeavy() {
    if (!_isEnabled) return;
    Vibrate.feedback(FeedbackType.heavy);
  }

  void triggerSelection() {
    if (!_isEnabled) return;
    Vibrate.feedback(FeedbackType.selection);
  }

  void triggerSuccess() {
    if (!_isEnabled) return;
    Vibrate.feedback(FeedbackType.success);
  }

  void triggerWarning() {
    if (!_isEnabled) return;
    Vibrate.feedback(FeedbackType.warning);
  }

  void triggerError() {
    if (!_isEnabled) return;
    Vibrate.feedback(FeedbackType.error);
  }

  void triggerVibrate() {
    if (!_isEnabled) return;
    Vibrate.vibrate();
  }

  // Legacy method names for backward compatibility
  void lightImpact() => triggerLight();
  void mediumImpact() => triggerMedium();
  void heavyImpact() => triggerHeavy();
  void selectionClick() => triggerSelection();
  void success() => triggerSuccess();
  void warning() => triggerWarning();
  void error() => triggerError();
  void vibrate() => triggerVibrate();

  bool get isEnabled => _isEnabled;
} 
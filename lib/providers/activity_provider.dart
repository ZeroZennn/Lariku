import 'package:flutter/material.dart';
import '../models/activity_model.dart';

class ActivityProvider with ChangeNotifier {
  RunActivity? _currentRun;

  RunActivity? get currentRun => _currentRun;

  void setRun(RunActivity run) {
    _currentRun = run;
    notifyListeners();
  }

  void clearRun() {
    _currentRun = null;
    notifyListeners();
  }
}

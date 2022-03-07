import 'package:flutter/cupertino.dart';

class TimeState with ChangeNotifier {
  int _time = 0;
  int get time => _time;
  set time(int newTime) {
    _time = newTime;
    notifyListeners();
  }
}

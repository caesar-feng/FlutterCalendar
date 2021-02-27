import 'package:flutter/material.dart';

enum CalendarControllerState { expanded, shrink, changeDate }

class CalendarController extends ChangeNotifier {
  CalendarControllerState _toggleState = CalendarControllerState.expanded;

  CalendarControllerState get controllerState => _toggleState;

  DateTime _date = DateTime.now();

  DateTime get date => _date;

  expanded() {
    _toggleState = CalendarControllerState.expanded;
    notifyListeners();
  }

  shrink() {
    _toggleState = CalendarControllerState.shrink;
    notifyListeners();
  }

  changeToDate(DateTime date) {
    _date = date;
    _toggleState = CalendarControllerState.changeDate;
    notifyListeners();
  }
}

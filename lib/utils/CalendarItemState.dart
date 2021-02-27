
import 'package:flutter_calendar/utils/CalendarBuilder.dart';

class CalendarItemState {
  //所在日期
  final DateTime dateTime;

  //是否是当前月份
  bool isCurrentMonth;

  //是否是今天
  final bool isToday;

  //所在集合中的角标
  int index = -1;

  CalendarItemState({
    this.dateTime,
    this.isCurrentMonth = true,
    this.isToday = false,
  }) : assert(dateTime != null);

  int get month => dateTime.month;

  int get day => dateTime.day;

  static CalendarItemState build(DateTime dateTime,
      {int day, bool isCurrentMonth = true}) {
    bool isToday = false;
    if (day != null) {
      final now = DateTime.now();
      dateTime = DateTime(dateTime.year, dateTime.month, day);
      isToday = now.year == dateTime.year &&
          now.month == dateTime.month &&
          now.day == dateTime.day;
    }
    if (isToday && CalendarBuilder.selectedDate == null) {
      CalendarBuilder.selectedDate = dateTime;
    }
    final bean = CalendarItemState(
      dateTime: dateTime,
      isToday: isToday,
      isCurrentMonth: isCurrentMonth,
    );
    return bean;
  }
}

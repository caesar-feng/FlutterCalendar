//日历gridItem比例
import 'package:flutter_calendar/utils/CalendarItemState.dart';
import 'package:flutter_calendar/CalendarPagerItem.dart';

const double ChildAspectRatio = 152 / 220;
const int HorizontalItemCount = 7;
const double GridSpacing = 1.5;
const double GridVerticalPadding = 3;
const double GridHorizontalPadding = 1.5 / 2;

//起始年份
const StartYear = 1900;
//结束年份
const EndYear = 2100;
const WeekPageDataCount = 9999;
const WeekPageInitialIndex = 5000;

class CalendarBuilder {
  CalendarBuilder._();

  static DateTime selectedDate;

  //1900-2100;日历页数
  static final int count = (EndYear - StartYear) * 12;

  static CalendarBuilder _instance;

  factory CalendarBuilder() => _getInstance();

  static CalendarBuilder get instance => _getInstance();

  static OnClick<CalendarPagerItemBean, CalendarItemState> onClick =
      (pageBean, gridBean) {
    int selectLine = gridBean.index ~/ HorizontalItemCount;
    pageBean.selectedLine = selectLine;
    if (pageBean.beans.length > 7) {
      _cache[pageBean.index] = pageBean;
    }
  };

  //缓存的日历数据
  static Map<int, CalendarPagerItemBean> _cache = {};

  static _getInstance() {
    if (_instance == null) {
      _instance = new CalendarBuilder._();
    }
    return _instance;
  }

  static CalendarPagerItemBean build(int index) {
    int year = StartYear + index ~/ 12;
    int month = index % 12 + 1;
    DateTime dateTime = DateTime(year, month);
    if (!_cache.containsKey(index)) {
      _cache[index] = _buildData(index, dateTime);
    }

    CalendarPagerItemBean bean = _cache[index];
    return bean;
  }

  static CalendarPagerItemBean buildWeekData(
      DateTime startDate, DateTime currentDate) {
    List<CalendarItemState> beans = [];
    CalendarItemState _bean;
    int index = dateTimeToIndex(startDate);
    for (int i = 0; i < HorizontalItemCount; i++) {
      CalendarItemState b = CalendarItemState.build(startDate,
          day: startDate.day,
          isCurrentMonth: startDate.month == currentDate.month);
      if (b.isToday) {
        _bean = b;
      }
      beans.add(b);
      startDate = startDate.add(Duration(days: 1));
    }

    List<CalendarItemState> week =
        beans.where((element) => !element.isCurrentMonth).toList();
    if (week.length == HorizontalItemCount) {
      beans.forEach((element) {
        element.isCurrentMonth = true;
      });
    }

    int todayIndex = beans.indexOf(_bean);

    return CalendarPagerItemBean(
        index: index,
        beans: beans,
        currentDate: startDate,
        todayIndex: todayIndex,
        selectedLine: todayIndex != -1 ? todayIndex ~/ HorizontalItemCount : 0,
        onClick: onClick);
  }

  static int dateTimeToIndex(DateTime dateTime) {
    int year = dateTime.year - StartYear;
    int month = dateTime.month;
    return year * 12 + month - 1;
  }

  static CalendarPagerItemBean _buildData(
    int index,
    DateTime dateTime,
  ) {
    List<CalendarItemState> beans = [];
    final days = DateTime(dateTime.year, dateTime.month + 1, 0).day;
    DateTime startWeekDay = DateTime(dateTime.year, dateTime.month, 1);
    DateTime endWeekDay = DateTime(dateTime.year, dateTime.month, days);
    CalendarItemState _bean;
    for (int i = 1; i <= days; i++) {
      CalendarItemState b = CalendarItemState.build(
        dateTime,
        day: i,
      );
      if (b.isToday) {
        _bean = b;
      }
      beans.add(b);
    }

    while (startWeekDay.weekday != 7) {
      startWeekDay = startWeekDay.subtract(Duration(days: 1));
      beans.insert(
          0, CalendarItemState.build(startWeekDay, isCurrentMonth: false));
    }
    while (endWeekDay.weekday != 6) {
      endWeekDay = endWeekDay.add(Duration(days: 1));
      beans.add(CalendarItemState.build(endWeekDay, isCurrentMonth: false));
    }

    int todayIndex = beans.indexOf(_bean);

    return CalendarPagerItemBean(
        index: index,
        beans: beans,
        currentDate: dateTime,
        todayIndex: todayIndex,
        selectedLine: todayIndex != -1 ? todayIndex ~/ HorizontalItemCount : 0,
        onClick: onClick);
  }
}

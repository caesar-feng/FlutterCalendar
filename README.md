# flutter_calendar

A Flutter Calendar

![image](https://github.com/caesar-feng/FlutterCalendar/blob/main/gif/1614422274018151.gif)
![image](https://github.com/caesar-feng/FlutterCalendar/blob/main/gif/1614422281281666.gif)

![image](https://github.com/caesar-feng/FlutterCalendar/blob/main/gif/1614422292911658.gif)
![image](https://github.com/caesar-feng/FlutterCalendar/blob/main/gif/1614422292911658%20(1).gif)

![image](https://github.com/caesar-feng/FlutterCalendar/blob/main/gif/1614422424029788.gif)

**Add this to your package's pubspec.yaml file:**

```
dependencies:
  imba_calendar: ^0.0.1
```

```dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Calendar(
        //the controller to control Calendar expand shrink jumpToTargetDate
        calendarController: calendarController,
        //it also be used to GridAxisSpacing
        backgroundColor: Colors.grey,
        //you can close the SliverPersistentHeader by false
        //also you could use a custom SliverPersistentHeader
        //by sliverPersistentHeader,if you use is you must tell Calendar
        //the custom SliverPersistentHeader`s height
        showSliverPersistentHeader: true,
        //if the scroll is not long enough isCalendarExpanded will be invalid
        isCalendarExpanded: true,
        onItemClick: (bean) => onItemClick(bean),
        itemBuilder:
            (BuildContext context, int index, CalendarItemState bean) =>
                Container(
          color: bean.dateTime == CalendarBuilder.selectedDate
              ? Colors.pinkAccent.shade100
              : Colors.white,
          alignment: Alignment.center,
          child: Text(
            "${bean.day}",
            style: TextStyle(color: Colors.black),
          ),
        ),
        //the day will be return -1 when user select day out of current Month
        // or the pager do not has select day
        // if you want a user select date then you should move to onItemClick
        sliverAppBarBuilder:
            (BuildContext context, int year, int month, int day) =>
                buildAppBar(year, month, day),
        //to add any widgets
        slivers: _buildSlivers(),
      ),
    );
  }
```

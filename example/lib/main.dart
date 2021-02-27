import 'package:flutter/material.dart';
import 'package:imba_calendar/Calendar.dart';
import 'package:imba_calendar/CalendarController.dart';
import 'package:imba_calendar/utils/CalendarBuilder.dart';
import 'package:imba_calendar/utils/CalendarItemState.dart';
import 'package:imba_calendar/utils/StickyTabBarDelegate.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  CalendarController calendarController;

  @override
  void initState() {
    calendarController = CalendarController();
    super.initState();
  }

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

  onItemClick(CalendarItemState bean) {
    // Pr.t("buildView ${bean.dateTime}");
  }

  Widget buildAppBar(int year, int month, int day) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      floating: true,
      elevation: 0,
      title: Row(
        children: [
          Text(
            "$year year",
            style: TextStyle(color: Colors.black),
          ),
          Text(
            "$month month",
            style: TextStyle(color: Colors.black),
          ),
          Text(
            "$day day",
            style: TextStyle(color: Colors.black),
          )
        ],
      ),
    );
  }

  List<Widget> _buildSlivers() {
    return [
      SliverPersistentHeader(
        pinned: true,
        delegate: SliverTabBarDelegate(
            child: TabBar(
          indicatorColor: Colors.transparent,
          labelColor: Colors.transparent,
          controller: TabController(length: 3, vsync: this),
          tabs: [
            FittedBox(
              child: FlatButton(
                color: Colors.grey.shade300,
                child: Text("Shrink Calendar"),
                onPressed: () => calendarController.shrink(),
              ),
            ),
            FittedBox(
              child: FlatButton(
                color: Colors.grey.shade300,
                child: Text("Expand Calendar"),
                onPressed: () => calendarController.expanded(),
              ),
            ),
            FittedBox(
              child: FlatButton(
                color: Colors.grey.shade300,
                child: Text("Back Today"),
                onPressed: () =>
                    calendarController.changeToDate(DateTime.now()),
              ),
            ),
          ],
        )),
      ),
      SliverList(
          delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) => Container(
                    height: 200,
                    color: Colors.transparent,
                    child: Text("$index"),
                  ),
              childCount: 10)),
    ];
  }
}

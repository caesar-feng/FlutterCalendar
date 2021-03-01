import 'package:flutter/material.dart';

import 'CalendarController.dart';
import 'utils/CalendarBuilder.dart';
import 'utils/CalendarItemState.dart';
import 'CalendarPagerItem.dart';
import 'utils/StickyTabBarDelegate.dart';

typedef SliverAppBarBuilder = SliverAppBar Function(
    BuildContext context, int year, int month, int day);

GlobalKey<_CalendarState> calendarKey = GlobalKey();

class Calendar extends StatefulWidget {
  final double childAspectRatio;
  final Widget child;
  final CalendarItemBuilder itemBuilder;
  final SliverAppBarBuilder sliverAppBarBuilder;
  final isCalendarExpanded;
  final Color backgroundColor;
  final ValueChanged<CalendarItemState> onItemClick;
  final List<Widget> slivers;
  final CalendarController calendarController;
  final SliverPersistentHeader sliverPersistentHeader;
  final bool showSliverPersistentHeader;
  final double sliverTabBarHeight;

  const Calendar({
    Key key,
    this.childAspectRatio = ChildAspectRatio,
    this.child,
    this.isCalendarExpanded = true,
    this.backgroundColor = Colors.white,
    @required this.itemBuilder,
    this.sliverAppBarBuilder,
    this.onItemClick,
    this.slivers = const [],
    this.calendarController,
    this.showSliverPersistentHeader = true,
    this.sliverPersistentHeader,
    this.sliverTabBarHeight,
  })
      :
  //if you want a custom sliverPersistentHeader you should tell me the widget height
        assert((sliverPersistentHeader != null && sliverTabBarHeight != null) ||
            (sliverPersistentHeader == null && sliverTabBarHeight == null)),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CalendarState();
  }
}

class _CalendarState extends State<Calendar> with TickerProviderStateMixin {
  double toolbarHeight;
  double screenSize;

  TabController tabController;
  ScrollController mainController = ScrollController();
  ScrollController gridController = ScrollController();
  PageController pageController;
  PageController weekPageController;
  CalendarController calendarController;

  int pageIndex = 0;

  //滑动时锁定的pageIndex
  int lockingPageIndex = 0;

  double expandedHeight;

  //根据滑动时锁定的lockingPageIndex获取的expandedHeight
  double lockingExpandedHeight;

  //防止横向滚动时 GridView缩小动画导致页面跳动
  bool isHorizontalScroll = false;

  //日历展开收起模式 默认展开
  bool isCalendarExpanded;

  double flexibleSpaceHeight = 0.0;

  //选中的行数
  int selectLine = 0;

  int get month => pageIndex % 12 + 1;

  int get year => StartYear + pageIndex ~/ 12;

  int _day;

  int get day => _day;

  //日历总行数
  int get lines => selectItemData.beans.length ~/ HorizontalItemCount;

  //收起时的时间
  DateTime shrinkDateTime;

  ValueChanged<CalendarItemState> _onItemClick;

  double sliverTabBarHeight = SliverTabBarHeight;

  CalendarPagerItemBean get selectItemData {
    return _buildItemData(pageIndex);
  }

  CalendarPagerItemBean _buildItemData(int index) {
    return CalendarBuilder.build(index);
  }

  @override
  void initState() {
    this.tabController =
        TabController(length: HorizontalItemCount, vsync: this);
    DateTime now = DateTime.now();
    pageIndex = CalendarBuilder.dateTimeToIndex(now);

    isCalendarExpanded = widget.isCalendarExpanded;

    _day = now.day;

    while (now.weekday != 7) {
      now = now.subtract(Duration(days: 1));
    }
    shrinkDateTime = DateTime(now.year, now.month, now.day);

    lockingPageIndex = pageIndex;

    pageController = PageController(initialPage: pageIndex);
    weekPageController = PageController(initialPage: WeekPageInitialIndex);
    pageController.addListener(() => _onPageScrolling());
    mainController.addListener(() => _onMainScrolling());

    _onItemClick = (v) {
      if (v.dateTime.month == month && v.dateTime.year == year) {
        _day = v.day;
      } else {
        _day = -1;
      }
      setState(() {});
      if (widget.onItemClick != null) {
        widget.onItemClick(v);
      }
    };

    calendarController = widget.calendarController;
    calendarController?.addListener(_onControl);

    if (widget.sliverPersistentHeader != null) {
      sliverTabBarHeight = widget.sliverTabBarHeight;
    }

    if (!widget.showSliverPersistentHeader) {
      sliverTabBarHeight = 0;
    }

    super.initState();
  }

  @override
  void dispose() {
    calendarController?.removeListener(_onControl);
    super.dispose();
  }

  void _onControl() {
    switch (calendarController.controllerState) {
      case CalendarControllerState.expanded:
        _expandedCalender();
        break;
      case CalendarControllerState.shrink:
        _shrinkCalender();
        break;
      case CalendarControllerState.changeDate:
        _changeDate(calendarController.date);
        break;
    }
  }

  @override
  void didUpdateWidget(Calendar oldWidget) {
    if (calendarController != oldWidget.calendarController) {
      if (oldWidget.calendarController != null) {
        oldWidget.calendarController.removeListener(_onControl);
        calendarController = oldWidget.calendarController;
        calendarController.addListener(_onControl);
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (screenSize == null) {
      screenSize = MediaQuery
          .of(context)
          .size
          .width;
      toolbarHeight = (screenSize -
          GridHorizontalPadding * 2 -
          GridSpacing * (HorizontalItemCount - 1)) /
          HorizontalItemCount /
          widget.childAspectRatio;
      expandedHeight = _getExpandHeight(lines);
      lockingExpandedHeight = expandedHeight;

      if (!isCalendarExpanded) {
        Future.delayed(Duration.zero, () {
          mainController.jumpTo(_getExpandHeight(lines - 1) +
              kToolbarHeight +
              sliverTabBarHeight);
        });
      }
    }

    return SafeArea(
      child: NotificationListener(
        onNotification: (Notification notification) {
          _checkScroll(notification);
          return false;
        },
        child: CustomScrollView(
          controller: mainController,
          slivers: [
            if (widget.sliverAppBarBuilder != null)
              widget.sliverAppBarBuilder(context, year, month, day),
            if (widget.showSliverPersistentHeader)
              widget.sliverPersistentHeader == null
                  ? _buildSliverPersistentHeader()
                  : widget.sliverPersistentHeader,
            _buildCalendar(),
          ]
            ..addAll(widget.slivers),
        ),
      ),
    );
  }

  _changeDate(DateTime dateTime) {
    CalendarBuilder.selectedDate =
        DateTime(dateTime.year, dateTime.month, dateTime.day);
    if (!isCalendarExpanded) {
      int num = 0;
      if (dateTime.isBefore(shrinkDateTime)) {
        //往前减一周
        num = -1;
      }
      Duration du = dateTime.difference(shrinkDateTime);
      num += du.inDays ~/ 7;
      weekPageController.jumpToPage(WeekPageInitialIndex + num);
    }

    // if (isCalendarExpanded) {
    pageIndex = CalendarBuilder.dateTimeToIndex(dateTime);
    pageController.jumpToPage(pageIndex);
    expandedHeight = _getExpandHeight(lines);
    try {
      final CalendarItemState state = selectItemData.beans.firstWhere((
          element) => element.dateTime == CalendarBuilder.selectedDate);
      selectItemData.selectedLine = selectItemData.beans.indexOf(state) ~/ 7;
    } catch (e) {}
    setState(() {});
    _updateDay(selectItemData);
  }

  _expandedCalender() {
    if (mainController != null &&
        mainController.hasClients &&
        mainController.offset != 0) {
      mainController.animateTo(0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOutQuad);
    }
  }

  _shrinkCalender() {
    double height =
        _getExpandHeight(lines - 1) + kToolbarHeight + sliverTabBarHeight;
    if (mainController != null &&
        mainController.hasClients &&
        height != mainController.offset) {
      mainController.animateTo(height,
          duration: Duration(milliseconds: 300), curve: Curves.easeOutQuad);
    }
  }

  Widget _buildFlexibleSpace() {
    return LayoutBuilder(
      builder: (c, b) {
        flexibleSpaceHeight = b.biggest.height;
        if (flexibleSpaceHeight <=
            toolbarHeight * lines + GridVerticalPadding * 2 &&
            gridController.hasClients &&
            !isHorizontalScroll) {
          gridController.jumpTo((toolbarHeight * lines +
              GridVerticalPadding * 2 -
              flexibleSpaceHeight) *
              selectLine /
              (lines - 1) +
              selectLine * GridSpacing);
        }

        return Stack(
          children: [
            PageView.builder(
              controller: pageController,
              onPageChanged: (i) => _onPageChange(i),
              itemBuilder: (c, i) {
                var bean = _buildItemData(i);
                selectLine = bean.selectedLine;
                return CalendarPagerItem(
                  onItemClick: _onItemClick,
                  backgroundColor: widget.backgroundColor,
                  itemBuilder: widget.itemBuilder,
                  childAspectRatio: widget.childAspectRatio,
                  bean: bean,
                  controller: gridController,
                );
              },
              itemCount: CalendarBuilder.count,
            ),
            if (!isCalendarExpanded)
              PageView.builder(
                controller: weekPageController,
                onPageChanged: (i) => _onWeekPageChange(i),
                itemBuilder: (c, i) {
                  var bean = CalendarBuilder.buildWeekData(
                      shrinkDateTime.add(Duration(
                          days: HorizontalItemCount *
                              (i - WeekPageInitialIndex))),
                      selectItemData.currentDate);
                  return CalendarPagerItem(
                    onItemClick: _onItemClick,
                    backgroundColor: widget.backgroundColor,
                    itemBuilder: widget.itemBuilder,
                    childAspectRatio: widget.childAspectRatio,
                    bean: bean,
                  );
                },
                itemCount: WeekPageDataCount,
              ),
          ],
        );
      },
    );
  }

  _updateDay(CalendarPagerItemBean bean) {
    try {
      List<CalendarItemState> list = bean.beans
          .where((element) =>
      element.isCurrentMonth &&
          element.dateTime == CalendarBuilder.selectedDate)
          .toList();
      if (list.length > 0) {
        _day = list[0].dateTime.day;
      } else {
        _day = -1;
      }
      setState(() {});
    } catch (e) {}
  }

  _onWeekPageChange(int i) {
    final bean = CalendarBuilder.buildWeekData(
        shrinkDateTime.add(
            Duration(days: HorizontalItemCount * (i - WeekPageInitialIndex))),
        selectItemData.currentDate);
    pageIndex = bean.index;
    pageController.jumpToPage(pageIndex);

    _updateDay(bean);

    try {
      final dateTime = bean.beans[0].dateTime;
      CalendarItemState list = selectItemData.beans
          .firstWhere((element) => element.dateTime == dateTime);
      selectItemData.selectedLine = list.index ~/ HorizontalItemCount;
    } catch (e) {}
    setState(() {});
  }

  _onPageChange(int i) {
    pageIndex = i;
    _updateDay(selectItemData);
    setState(() {});
  }

  Widget _buildCalendar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      pinned: true,
      toolbarHeight: toolbarHeight + GridVerticalPadding * 2,
      expandedHeight: expandedHeight,
      flexibleSpace: _buildFlexibleSpace(),
    );
  }

  _checkScroll(Notification notification) {
    if (notification is ScrollEndNotification) {
      if (mainController.position.maxScrollExtent ==
          notification.metrics.maxScrollExtent) {
        Future.delayed(Duration.zero, () => _onMainScrollEnd());
      } else if (notification.metrics.axis == Axis.horizontal) {
        isHorizontalScroll = false;
        lockingPageIndex = pageIndex;
        lockingExpandedHeight = _getExpandHeight(lines);
      }
    }
  }

  double _getExpandHeight(int lines) {
    return lines * toolbarHeight +
        GridVerticalPadding * 2 +
        (lines - 1) * GridSpacing;
  }

  _onMainScrollEnd() {
    if (flexibleSpaceHeight == toolbarHeight + GridVerticalPadding * 2) {
      int index = selectItemData.selectedLine * HorizontalItemCount;
      shrinkDateTime = selectItemData.beans[index].dateTime;
      weekPageController = PageController(initialPage: WeekPageInitialIndex);
      isCalendarExpanded = false;
      setState(() {});
    } else {
      isCalendarExpanded = true;
    }
    if (flexibleSpaceHeight > toolbarHeight + GridVerticalPadding * 2 &&
        flexibleSpaceHeight < toolbarHeight * lines / 2 + GridVerticalPadding) {
      _shrinkCalender();
    } else if (flexibleSpaceHeight > toolbarHeight * lines / 2 &&
        flexibleSpaceHeight < toolbarHeight * lines) {
      _expandedCalender();
    }
    _updateDay(selectItemData);
  }

  _onMainScrolling() {
    if (!isCalendarExpanded &&
        mainController.offset >
            _getExpandHeight(lines - 1) / 2 +
                kToolbarHeight +
                sliverTabBarHeight) {
      isCalendarExpanded = true;
      expandedHeight = _getExpandHeight(lines);
      setState(() {});
    }
  }

  _onPageScrolling() {
    if (!isCalendarExpanded) {
      return;
    }

    isHorizontalScroll = true;
    final move = pageController.offset;
    final pageOffset = lockingPageIndex * screenSize;
    int offset;
    //左滑
    if (move > pageOffset) {
      offset = lockingPageIndex + 1;
    } else
      //右滑
    if (move < pageOffset) {
      offset = lockingPageIndex - 1;
    } else {
      offset = pageIndex;
    }

    int newLines = _buildItemData(offset).beans.length ~/ HorizontalItemCount;

    double newHeight = _getExpandHeight(newLines);

    if (newHeight != expandedHeight) {
      final addPart = (newHeight - lockingExpandedHeight) *
          ((move - pageOffset).abs()) /
          screenSize;
      expandedHeight = lockingExpandedHeight + addPart;
      setState(() {});
    }
  }

  Widget _buildSliverPersistentHeader() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverTabBarDelegate(
          child: TabBar(
            indicatorColor: Colors.transparent,
            labelColor: Colors.transparent,
            controller: tabController,
            tabs: [
              _buildTitleDate("周日"),
              _buildTitleDate("周一"),
              _buildTitleDate("周二"),
              _buildTitleDate("周三"),
              _buildTitleDate("周四"),
              _buildTitleDate("周五"),
              _buildTitleDate("周六"),
            ],
          )),
    );
  }

  Widget _buildTitleDate(String date) {
    return FittedBox(
      child: Text(
        date,
        maxLines: 1,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}

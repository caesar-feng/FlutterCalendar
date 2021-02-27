import 'package:flutter/material.dart';

const double ToolBarHeight = 48;

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar child;
  final double height;

  StickyTabBarDelegate({@required this.child, this.height = ToolBarHeight});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: height,
      child: this.child,
      color: Colors.white,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

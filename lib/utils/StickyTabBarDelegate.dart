import 'package:flutter/material.dart';

const double SliverTabBarHeight = 48;

class SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar child;
  final double height;

  SliverTabBarDelegate(
      {@required this.child, this.height = SliverTabBarHeight});

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

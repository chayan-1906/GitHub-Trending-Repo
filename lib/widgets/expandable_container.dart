import 'package:flutter/material.dart';

class ExpandableContainer extends StatelessWidget {
  final bool expanded;
  final double collapsedHeight;
  final double expandedHeight;
  final Widget collapsedChild;
  final Widget expandedChild;

  const ExpandableContainer({
    Key key,
    @required this.collapsedChild,
    @required this.expandedChild,
    this.collapsedHeight = 80.0,
    this.expandedHeight = 150.0,
    this.expanded = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
      width: width,
      height: expanded ? expandedHeight : collapsedHeight,
      child: Container(
        child: expanded ? expandedChild : collapsedChild,
        // decoration: BoxDecoration(border: Border.all(width: 1.0, color: Theme.of(context).primaryColor),),
      ),
    );
  }
}

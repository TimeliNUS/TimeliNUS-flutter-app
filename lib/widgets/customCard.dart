import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry margin;
  final double radius;
  final double elevation;
  const CustomCard(
      {@required this.child,
      this.margin = const EdgeInsets.all(0),
      this.elevation = 0,
      this.radius = 15});
  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: elevation,
        margin: margin,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radius))),
        child: Padding(padding: EdgeInsets.all(25), child: child));
  }
}

import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry margin;
  final BorderRadiusGeometry radius;
  final double elevation;
  final double padding;
  const CustomCard(
      {@required this.child,
      this.margin = const EdgeInsets.all(0),
      this.elevation = 0,
      this.radius = const BorderRadius.all(Radius.circular(15)),
      this.padding = 25});
  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: elevation,
        margin: margin,
        shape: RoundedRectangleBorder(borderRadius: radius),
        child: Padding(padding: EdgeInsets.all(this.padding), child: child));
  }
}

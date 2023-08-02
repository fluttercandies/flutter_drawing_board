import 'package:flutter/material.dart';

class FDefaultIconStyle extends InheritedTheme {
  const FDefaultIconStyle({
    this.primaryColor,
    this.secondaryColor,
    this.color,
    this.size,
    required this.child,
  }) : super(child: child);

  final Color? primaryColor;

  final Color? secondaryColor;

  final Color? color;

  final double? size;

  final Widget child;

  static FDefaultIconStyle? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FDefaultIconStyle>();
  }

  @override
  bool updateShouldNotify(FDefaultIconStyle oldWidget) {
    return true;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return FDefaultIconStyle(
      color: color,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      size: size,
      child: child,
    );
  }
}

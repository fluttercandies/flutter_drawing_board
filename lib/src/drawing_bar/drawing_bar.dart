import 'package:flutter/material.dart';

import '../drawing_controller.dart';

sealed class DrawingBarStyle {
  const DrawingBarStyle();
}

class HorizontalToolsBarStyle extends DrawingBarStyle {
  const HorizontalToolsBarStyle({
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.spacing = 0.0,
  });

  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;
  final double spacing;
}

class VerticalToolsBarStyle extends DrawingBarStyle {
  const VerticalToolsBarStyle({
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.spacing = 0.0,
  });

  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;
  final double spacing;
}

class WrapToolsBarStyle extends DrawingBarStyle {
  const WrapToolsBarStyle({
    this.direction = Axis.horizontal,
    this.alignment = WrapAlignment.start,
    this.spacing = 0.0,
    this.runAlignment = WrapAlignment.start,
    this.runSpacing = 0.0,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.clipBehavior = Clip.none,
  });

  final Axis direction;
  final WrapAlignment alignment;
  final double spacing;
  final WrapAlignment runAlignment;
  final double runSpacing;
  final WrapCrossAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final Clip clipBehavior;
}

class DrawingBar extends StatelessWidget {
  const DrawingBar({
    super.key,
    required this.controller,
    this.style = const HorizontalToolsBarStyle(),
    required this.tools,
  });

  final DrawingController controller;
  final DrawingBarStyle style;
  final List<Widget> tools;

  @override
  Widget build(BuildContext context) {
    return DrawingControllerProvider(
      controller: controller,
      child: switch (style) {
        final HorizontalToolsBarStyle style => Row(
            mainAxisAlignment: style.mainAxisAlignment,
            mainAxisSize: style.mainAxisSize,
            crossAxisAlignment: style.crossAxisAlignment,
            textDirection: style.textDirection,
            verticalDirection: style.verticalDirection,
            textBaseline: style.textBaseline,
            spacing: style.spacing,
            children: tools,
          ),
        final VerticalToolsBarStyle style => Column(
            mainAxisAlignment: style.mainAxisAlignment,
            mainAxisSize: style.mainAxisSize,
            crossAxisAlignment: style.crossAxisAlignment,
            textDirection: style.textDirection,
            verticalDirection: style.verticalDirection,
            textBaseline: style.textBaseline,
            spacing: style.spacing,
            children: tools,
          ),
        final WrapToolsBarStyle style => Wrap(
            direction: style.direction,
            alignment: style.alignment,
            spacing: style.spacing,
            runAlignment: style.runAlignment,
            runSpacing: style.runSpacing,
            crossAxisAlignment: style.crossAxisAlignment,
            textDirection: style.textDirection,
            verticalDirection: style.verticalDirection,
            clipBehavior: style.clipBehavior,
            children: tools,
          ),
      },
    );
  }
}

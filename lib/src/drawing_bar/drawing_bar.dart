import 'package:flutter/material.dart';

import '../drawing_controller.dart';

/// 绘图工具栏样式基类
///
/// Drawing toolbar style base class
sealed class DrawingBarStyle {
  const DrawingBarStyle();
}

/// 水平工具栏样式
///
/// Horizontal toolbar style
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

/// 垂直工具栏样式
///
/// Vertical toolbar style
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

/// 自动换行工具栏样式
///
/// Wrap toolbar style (auto-wrapping)
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

/// 绘图工具栏组件
///
/// 提供灵活的工具栏布局，支持水平、垂直和自动换行三种样式
/// 自动将DrawingController通过Provider传递给子工具组件
///
/// Drawing Toolbar Widget
///
/// Provides flexible toolbar layout, supports horizontal, vertical and auto-wrap styles
/// Automatically passes DrawingController to child tool widgets via Provider
class DrawingBar extends StatelessWidget {
  const DrawingBar({
    super.key,
    required this.controller,
    this.style = const HorizontalToolsBarStyle(),
    required this.tools,
  });

  /// 绘图控制器
  ///
  /// Drawing controller
  final DrawingController controller;

  /// 工具栏样式
  ///
  /// Toolbar style
  final DrawingBarStyle style;

  /// 工具列表
  ///
  /// List of tools
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

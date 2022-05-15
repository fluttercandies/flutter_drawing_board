import 'package:flutter/material.dart';

import 'drawing_controller.dart';
import 'helper/ex_value_builder.dart';

/// 操作栏构建器
typedef ActionBuilder = Widget Function(DrawConfig config);

/// 操作栏
class ActionBar extends StatelessWidget {
  const ActionBar({
    Key? key,
    required this.controller,
    required this.builder,
  }) : super(key: key);

  /// 控制器
  final DrawingController controller;

  /// 构建器
  final ActionBuilder builder;

  @override
  Widget build(BuildContext context) {
    return ExValueBuilder<DrawConfig>(
      valueListenable: controller.drawConfig,
      builder: (_, DrawConfig dc, __) => builder(dc),
    );
  }
}

/// 工具栏构建器
typedef ToolsBuilder = Widget Function(
    Type currType, DrawingController controller);

/// 工具栏
class ToolsBar extends StatelessWidget {
  const ToolsBar({
    Key? key,
    required this.controller,
    this.shouldRebuild,
    required this.builder,
  }) : super(key: key);

  /// 控制器
  final DrawingController controller;

  /// 是否进行rebuild
  final bool Function(DrawConfig, DrawConfig)? shouldRebuild;

  /// 构建器
  final ToolsBuilder builder;

  @override
  Widget build(BuildContext context) {
    return ExValueBuilder<DrawConfig>(
      valueListenable: controller.drawConfig,
      shouldRebuild: shouldRebuild,
      builder: (BuildContext context, DrawConfig dc, _) =>
          builder(dc.contentType, controller),
    );
  }
}

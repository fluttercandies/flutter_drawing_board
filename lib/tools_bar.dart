import 'package:flutter/material.dart';

import 'drawing_controller.dart';
import 'helper/ex_value_builder.dart';
import 'paint_contents/paint_content.dart';

///工具栏构建器
typedef ToolsBuilder = Widget Function(BuildContext context, PaintType paintType);

///工具栏
class ToolsBar extends StatelessWidget {
  const ToolsBar({Key? key, @required this.controller, required this.builder}) : super(key: key);

  ///控制器
  final DrawingController? controller;

  ///构建器
  final ToolsBuilder builder;

  @override
  Widget build(BuildContext context) {
    return ExValueBuilder<DrawConfig>(
      valueListenable: controller!.drawConfig,
      shouldRebuild: (DrawConfig? p, DrawConfig? n) => p!.paintType != n!.paintType,
      builder: (BuildContext? context, DrawConfig? dc, _) => builder(context!, dc!.paintType!),
    );
  }
}

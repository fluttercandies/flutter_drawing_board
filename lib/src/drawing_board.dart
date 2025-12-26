import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'drawing_controller.dart';

import 'helper/ex_value_builder.dart';
import 'helper/get_size.dart';
import 'painter.dart';

/// 画板
class DrawingBoard extends StatelessWidget {
  const DrawingBoard({
    super.key,
    required this.background,
    required this.controller,
    this.onPointerDown,
    this.onPointerMove,
    this.onPointerUp,
    this.clipBehavior = Clip.antiAlias,
    this.boardClipBehavior = Clip.hardEdge,
    this.panAxis = PanAxis.free,
    this.boardBoundaryMargin,
    this.boardConstrained = false,
    this.maxScale = 20,
    this.minScale = 0.2,
    this.boardPanEnabled = true,
    this.boardScaleEnabled = true,
    this.boardScaleFactor = 200.0,
    this.onInteractionEnd,
    this.onInteractionStart,
    this.onInteractionUpdate,
    this.transformationController,
    this.alignment = Alignment.topCenter,
    this.enablePalmRejection = false,
  });

  /// 画板背景控件
  final Widget background;

  /// 画板控制器
  final DrawingController controller;

  /// 开始拖动
  final void Function(PointerDownEvent pde)? onPointerDown;

  /// 正在拖动
  final void Function(PointerMoveEvent pme)? onPointerMove;

  /// 结束拖动
  final void Function(PointerUpEvent pue)? onPointerUp;

  /// 边缘裁剪方式
  final Clip clipBehavior;

  /// 缩放板属性
  final Clip boardClipBehavior;
  final PanAxis panAxis;
  final EdgeInsets? boardBoundaryMargin;
  final bool boardConstrained;
  final double maxScale;
  final double minScale;
  final void Function(ScaleEndDetails)? onInteractionEnd;
  final void Function(ScaleStartDetails)? onInteractionStart;
  final void Function(ScaleUpdateDetails)? onInteractionUpdate;
  final bool boardPanEnabled;
  final bool boardScaleEnabled;
  final double boardScaleFactor;
  final TransformationController? transformationController;
  final AlignmentGeometry alignment;

  /// 启用手掌拒绝功能，防止手掌误触
  /// 当设置为 true 时，会检测触摸面积和触摸时间间隔，拒绝可能的手掌触摸
  final bool enablePalmRejection;

  DrawingController get _controller => controller;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent pde) => _controller.addFingerCount(pde.localPosition),
      onPointerUp: (PointerUpEvent pue) => _controller.reduceFingerCount(pue.localPosition),
      onPointerCancel: (PointerCancelEvent pce) => _controller.reduceFingerCount(pce.localPosition),
      child: InteractiveViewer(
        maxScale: maxScale,
        minScale: minScale,
        boundaryMargin: boardBoundaryMargin ?? EdgeInsets.all(MediaQuery.of(context).size.width),
        clipBehavior: boardClipBehavior,
        panAxis: panAxis,
        constrained: boardConstrained,
        onInteractionStart: onInteractionStart,
        onInteractionUpdate: onInteractionUpdate,
        onInteractionEnd: onInteractionEnd,
        scaleFactor: boardScaleFactor,
        panEnabled: boardPanEnabled,
        scaleEnabled: boardScaleEnabled,
        transformationController: transformationController,
        child: Align(alignment: alignment, child: _buildBoard),
      ),
    );
  }

  /// 构建画板
  Widget get _buildBoard {
    return ExValueBuilder<DrawConfig>(
      valueListenable: _controller.drawConfig,
      shouldRebuild: (DrawConfig p, DrawConfig n) => p.angle != n.angle || p.size != n.size,
      builder: (_, DrawConfig dc, Widget? child) {
        Widget c = child!;

        if (dc.size != null) {
          final bool isHorizontal = dc.angle.toDouble() % 2 == 0;
          final double max = dc.size!.longestSide;

          if (!isHorizontal) {
            c = SizedBox(width: max, height: max, child: c);
          }
        }

        return Transform.rotate(angle: dc.angle * pi / 2, child: c);
      },
      child: Center(
        child: RepaintBoundary(
          key: _controller.painterKey,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[_buildImage, _buildPainter],
          ),
        ),
      ),
    );
  }

  /// 构建背景
  Widget get _buildImage => GetSize(
        onChange: (Size? size) => _controller.setBoardSize(size),
        child: background,
      );

  /// 构建绘制层
  Widget get _buildPainter {
    return ExValueBuilder<DrawConfig>(
      valueListenable: _controller.drawConfig,
      shouldRebuild: (DrawConfig p, DrawConfig n) => p.size != n.size,
      builder: (_, DrawConfig dc, Widget? child) {
        return SizedBox(
          width: dc.size?.width,
          height: dc.size?.height,
          child: child,
        );
      },
      child: Painter(
        drawingController: _controller,
        onPointerDown: onPointerDown,
        onPointerMove: onPointerMove,
        onPointerUp: onPointerUp,
        enablePalmRejection: enablePalmRejection,
      ),
    );
  }

  /// 构建默认操作栏
  static Widget buildDefaultActions(DrawingController controller) {
    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        child: ExValueBuilder<DrawConfig>(
            valueListenable: controller.drawConfig,
            builder: (_, DrawConfig dc, ___) {
              return Row(
                children: <Widget>[
                  SizedBox(
                    height: 24,
                    width: 160,
                    child: Slider(
                      value: dc.strokeWidth,
                      max: 50,
                      min: 1,
                      onChanged: (double v) => controller.setStyle(strokeWidth: v),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      CupertinoIcons.arrow_turn_up_left,
                      color: controller.canUndo() ? null : Colors.grey,
                    ),
                    onPressed: () => controller.undo(),
                  ),
                  IconButton(
                    icon: Icon(
                      CupertinoIcons.arrow_turn_up_right,
                      color: controller.canRedo() ? null : Colors.grey,
                    ),
                    onPressed: () => controller.redo(),
                  ),
                  IconButton(
                      icon: const Icon(CupertinoIcons.rotate_right),
                      onPressed: () => controller.turn()),
                  IconButton(
                    icon: const Icon(CupertinoIcons.trash),
                    onPressed: () => controller.clear(),
                  ),
                ],
              );
            }),
      ),
    );
  }
}

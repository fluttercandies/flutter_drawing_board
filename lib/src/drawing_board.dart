import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'drawing_controller.dart';

import 'helper/ex_value_builder.dart';
import 'helper/get_size.dart';
import 'painter.dart';

/// 画板组件
///
/// 提供交互式绘图功能的核心Widget，支持多种绘制内容（线条、形状等）
/// 内置缩放、旋转、平移等交互功能，并可配置手掌拒绝等高级特性
///
/// Drawing Board Widget
///
/// A core widget that provides interactive drawing functionality, supporting various
/// drawing content (lines, shapes, etc.). Built-in zoom, rotation, pan interactions,
/// and configurable advanced features like palm rejection.
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
  ///
  /// Background widget of the drawing board
  final Widget background;

  /// 画板控制器
  ///
  /// Drawing board controller
  final DrawingController controller;

  /// 手指按下回调
  ///
  /// Callback when pointer is pressed down
  final void Function(PointerDownEvent pde)? onPointerDown;

  /// 手指移动回调
  ///
  /// Callback when pointer is moving
  final void Function(PointerMoveEvent pme)? onPointerMove;

  /// 手指抬起回调
  ///
  /// Callback when pointer is released
  final void Function(PointerUpEvent pue)? onPointerUp;

  /// 边缘裁剪方式
  ///
  /// Clip behavior for the drawing board
  final Clip clipBehavior;

  /// 画板容器的裁剪方式
  ///
  /// Clip behavior for the board container
  final Clip boardClipBehavior;

  /// 画板平移轴向限制
  ///
  /// Pan axis constraint for the board
  final PanAxis panAxis;

  /// 画板边界边距
  ///
  /// Boundary margin for the board
  final EdgeInsets? boardBoundaryMargin;

  /// 是否限制画板尺寸
  ///
  /// Whether to constrain the board size
  final bool boardConstrained;

  /// 最大缩放比例
  ///
  /// Maximum scale ratio
  final double maxScale;

  /// 最小缩放比例
  ///
  /// Minimum scale ratio
  final double minScale;

  /// 缩放交互结束回调
  ///
  /// Callback when scale interaction ends
  final void Function(ScaleEndDetails)? onInteractionEnd;

  /// 缩放交互开始回调
  ///
  /// Callback when scale interaction starts
  final void Function(ScaleStartDetails)? onInteractionStart;

  /// 缩放交互更新回调
  ///
  /// Callback when scale interaction updates
  final void Function(ScaleUpdateDetails)? onInteractionUpdate;

  /// 是否启用画板平移
  ///
  /// Whether board panning is enabled
  final bool boardPanEnabled;

  /// 是否启用画板缩放
  ///
  /// Whether board scaling is enabled
  final bool boardScaleEnabled;

  /// 画板缩放因子
  ///
  /// Scale factor for the board
  final double boardScaleFactor;

  /// 变换控制器
  ///
  /// Transformation controller
  final TransformationController? transformationController;

  /// 画板对齐方式
  ///
  /// Alignment of the drawing board
  final AlignmentGeometry alignment;

  /// 启用手掌拒绝功能，防止手掌误触
  /// 当设置为 true 时，会检测触摸面积和触摸时间间隔，拒绝可能的手掌触摸
  ///
  /// Enable palm rejection to prevent accidental palm touches
  /// When set to true, detects touch area and time intervals to reject potential palm touches
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

  /// 构建画板主体，包含旋转和尺寸处理
  ///
  /// Build the main board with rotation and size handling
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

  /// 构建背景层，并监听尺寸变化
  ///
  /// Build the background layer and listen for size changes
  Widget get _buildImage => GetSize(
        onChange: (Size? size) => _controller.setBoardSize(size),
        child: background,
      );

  /// 构建绘制层，包含实际的绘图canvas
  ///
  /// Build the painting layer with the actual drawing canvas
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

  /// 构建默认操作栏，包含笔刷粗细调节、撤销、重做、旋转、清空等功能
  ///
  /// Build default action bar with brush width adjustment, undo, redo, rotate, and clear functions
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

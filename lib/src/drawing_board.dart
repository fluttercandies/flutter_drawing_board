import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'color_pic_btn.dart';
import 'drawing_controller.dart';

import 'helper/ex_value_builder.dart';
import 'helper/safe_state.dart';
import 'paint_contents/circle.dart';
import 'paint_contents/eraser.dart';
import 'paint_contents/rectangle.dart';
import 'paint_contents/simple_line.dart';
import 'paint_contents/smooth_line.dart';
import 'paint_contents/straight_line.dart';
import 'painter.dart';

/// 默认工具栏构建器
typedef DefaultToolsBuilder = List<DefToolItem> Function(
  Type currType,
  DrawingController controller,
);

/// 画板
class DrawingBoard extends StatefulWidget {
  const DrawingBoard({
    Key? key,
    required this.background,
    this.controller,
    this.showDefaultActions = false,
    this.showDefaultTools = false,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.clipBehavior = Clip.antiAlias,
    this.defaultToolsBuilder,
    this.boardClipBehavior = Clip.hardEdge,
    this.boardAlignPanAxis = false,
    this.boardBoundaryMargin,
    this.boardConstrained = true,
    this.maxScale = 20,
    this.minScale = 0.2,
    this.boardPanEnabled = true,
    this.boardScaleEnabled = true,
    this.boardScaleFactor = 200.0,
    this.onInteractionEnd,
    this.onInteractionStart,
    this.onInteractionUpdate,
    this.transformationController,
  }) : super(key: key);

  @override
  _DrawingBoardState createState() => _DrawingBoardState();

  /// 画板背景控件
  final Widget background;

  /// 画板控制器
  final DrawingController? controller;

  /// 显示默认样式的操作栏
  final bool showDefaultActions;

  /// 显示默认样式的工具栏
  final bool showDefaultTools;

  /// 开始拖动
  final Function(DragStartDetails dsd)? onPanStart;

  /// 正在拖动
  final Function(DragUpdateDetails dud)? onPanUpdate;

  /// 结束拖动
  final Function(DragEndDetails ded)? onPanEnd;

  /// 边缘裁剪方式
  final Clip clipBehavior;

  final DefaultToolsBuilder? defaultToolsBuilder;

  /// 缩放板属性
  final Clip boardClipBehavior;
  final bool boardAlignPanAxis;
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

  /// 默认工具项列表
  static List<DefToolItem> defaultTools(
      Type currType, DrawingController controller) {
    return <DefToolItem>[
      DefToolItem(
          isActive: currType == SimpleLine,
          icon: CupertinoIcons.pencil,
          onTap: () => controller.setPaintContent = SimpleLine()),
      DefToolItem(
          isActive: currType == SmoothLine,
          icon: Icons.brush,
          onTap: () => controller.setPaintContent = SmoothLine()),
      DefToolItem(
          isActive: currType == StraightLine,
          icon: Icons.show_chart,
          onTap: () => controller.setPaintContent = StraightLine()),
      DefToolItem(
          isActive: currType == Rectangle,
          icon: CupertinoIcons.stop,
          onTap: () => controller.setPaintContent = Rectangle()),
      DefToolItem(
          isActive: currType == Circle,
          icon: CupertinoIcons.circle,
          onTap: () => controller.setPaintContent = Circle()),
      DefToolItem(
          isActive: currType == Eraser,
          icon: CupertinoIcons.bandage,
          onTap: () =>
              controller.setPaintContent = Eraser(color: Colors.white)),
    ];
  }
}

class _DrawingBoardState extends State<DrawingBoard>
    with SafeState<DrawingBoard> {
  ///画板控制器
  late DrawingController _drawingController;

  @override
  void initState() {
    super.initState();
    _drawingController = widget.controller ?? DrawingController();
  }

  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = ExValueBuilder<DrawConfig>(
      valueListenable: _drawingController.drawConfig,
      shouldRebuild: (DrawConfig p, DrawConfig n) => p.angle != n.angle,
      child: Center(child: AspectRatio(aspectRatio: 1, child: _buildBoard)),
      builder: (_, DrawConfig dc, Widget? child) {
        return InteractiveViewer(
          maxScale: widget.maxScale,
          minScale: widget.minScale,
          boundaryMargin: widget.boardBoundaryMargin ??
              EdgeInsets.all(MediaQuery.of(context).size.width),
          clipBehavior: widget.boardClipBehavior,
          alignPanAxis: widget.boardAlignPanAxis,
          constrained: widget.boardConstrained,
          onInteractionStart: widget.onInteractionStart,
          onInteractionUpdate: widget.onInteractionUpdate,
          onInteractionEnd: widget.onInteractionEnd,
          scaleFactor: widget.boardScaleFactor,
          panEnabled: widget.boardPanEnabled,
          scaleEnabled: widget.boardScaleEnabled,
          transformationController: widget.transformationController,
          child: child!,
        );
      },
    );

    if (widget.showDefaultActions || widget.showDefaultTools) {
      content = Column(
        children: <Widget>[
          Expanded(child: content),
          if (widget.showDefaultActions) _buildDefaultActions,
          if (widget.showDefaultTools) _buildDefaultTools,
        ],
      );
    }

    return content;
  }

  /// 构建画板
  Widget get _buildBoard {
    return Center(
      child: RepaintBoundary(
        key: _drawingController.painterKey,
        child: ExValueBuilder<DrawConfig>(
          valueListenable: _drawingController.drawConfig,
          shouldRebuild: (DrawConfig p, DrawConfig n) => p.angle != n.angle,
          child: Stack(children: <Widget>[_buildImage, _buildPainter]),
          builder: (_, DrawConfig dc, Widget? child) {
            return RotatedBox(quarterTurns: dc.angle, child: child);
          },
        ),
      ),
    );
  }

  /// 构建背景
  Widget get _buildImage => widget.background;

  /// 构建绘制层
  Widget get _buildPainter {
    return Positioned(
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
      child: Painter(
        drawingController: _drawingController,
        onPanStart: widget.onPanStart,
        onPanUpdate: widget.onPanUpdate,
        onPanEnd: widget.onPanEnd,
      ),
    );
  }

  /// 构建默认操作栏
  Widget get _buildDefaultActions {
    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        child: Row(
          children: <Widget>[
            SizedBox(
              height: 24,
              width: 160,
              child: ExValueBuilder<DrawConfig>(
                valueListenable: _drawingController.drawConfig,
                shouldRebuild: (DrawConfig p, DrawConfig n) =>
                    p.strokeWidth != n.strokeWidth,
                builder: (_, DrawConfig dc, ___) {
                  return Slider(
                    value: dc.strokeWidth,
                    max: 50,
                    min: 1,
                    onChanged: (double v) =>
                        _drawingController.setStyle(strokeWidth: v),
                  );
                },
              ),
            ),
            ColorPicBtn(controller: _drawingController),
            IconButton(
                icon: const Icon(CupertinoIcons.arrow_turn_up_left),
                onPressed: () => _drawingController.undo()),
            IconButton(
                icon: const Icon(CupertinoIcons.arrow_turn_up_right),
                onPressed: () => _drawingController.redo()),
            IconButton(
                icon: const Icon(CupertinoIcons.rotate_right),
                onPressed: () => _drawingController.turn()),
            IconButton(
                icon: const Icon(CupertinoIcons.trash),
                onPressed: () => _drawingController.clear()),
          ],
        ),
      ),
    );
  }

  /// 构建默认工具栏
  Widget get _buildDefaultTools {
    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        child: ExValueBuilder<DrawConfig>(
          valueListenable: _drawingController.drawConfig,
          shouldRebuild: (DrawConfig p, DrawConfig n) =>
              p.contentType != n.contentType,
          builder: (_, DrawConfig dc, ___) {
            final Type currType = dc.contentType;

            return Row(
              children: (widget.defaultToolsBuilder
                          ?.call(currType, _drawingController) ??
                      DrawingBoard.defaultTools(currType, _drawingController))
                  .map((DefToolItem item) => _DefToolItemWidget(item: item))
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}

/// 默认工具项配置文件
class DefToolItem {
  DefToolItem({
    required this.icon,
    required this.isActive,
    this.onTap,
    this.color,
    this.activeColor = Colors.blue,
    this.iconSize,
  });

  final Function()? onTap;
  final bool isActive;

  final IconData icon;
  final double? iconSize;
  final Color? color;
  final Color activeColor;
}

/// 默认工具项 Widget
class _DefToolItemWidget extends StatelessWidget {
  const _DefToolItemWidget({
    Key? key,
    required this.item,
  }) : super(key: key);

  final DefToolItem item;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: item.onTap,
      icon: Icon(
        item.icon,
        color: item.isActive ? item.activeColor : item.color,
        size: item.iconSize,
      ),
    );
  }
}

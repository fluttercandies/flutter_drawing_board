import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'drawing_controller.dart';

import 'helper/ex_value_builder.dart';
import 'helper/get_size.dart';
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

/// 默认操作栏构建器
typedef DefaultActionsBuilder = List<DefActionItem> Function(
  Type currType,
  DrawingController controller,
);

/// 画板
class DrawingBoard extends StatefulWidget {
  const DrawingBoard({
    super.key,
    required this.background,
    this.controller,
    this.showDefaultActions = false,
    this.showDefaultTools = false,
    this.onPointerDown,
    this.onPointerMove,
    this.onPointerUp,
    this.clipBehavior = Clip.antiAlias,
    this.defaultToolsBuilder,
    this.defaultActionsBuilder,
    this.toolsBackgroundColor = Colors.white,
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
  });

  /// 画板背景控件
  final Widget background;

  /// 画板控制器
  final DrawingController? controller;

  /// 显示默认样式的操作栏
  final bool showDefaultActions;

  /// 显示默认样式的工具栏
  final bool showDefaultTools;

  /// 开始拖动
  final Function(PointerDownEvent pde)? onPointerDown;

  /// 正在拖动
  final Function(PointerMoveEvent pme)? onPointerMove;

  /// 结束拖动
  final Function(PointerUpEvent pue)? onPointerUp;

  /// 边缘裁剪方式
  final Clip clipBehavior;

  /// 默认工具栏构建器
  final DefaultToolsBuilder? defaultToolsBuilder;

  /// 默认操作栏构建器
  final DefaultActionsBuilder? defaultActionsBuilder;

  /// 工具栏背景色
  final Color toolsBackgroundColor;

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

  /// 默认工具项列表
  static List<DefToolItem> defaultTools(
      Type currType, DrawingController controller) {
    return <DefToolItem>[
      DefToolItem(
          isActive: currType == SimpleLine,
          icon: Icons.edit,
          onTap: () => controller.setPaintContent(SimpleLine())),
      DefToolItem(
          isActive: currType == SmoothLine,
          icon: Icons.brush,
          onTap: () => controller.setPaintContent(SmoothLine())),
      DefToolItem(
          isActive: currType == StraightLine,
          icon: Icons.show_chart,
          onTap: () => controller.setPaintContent(StraightLine())),
      DefToolItem(
          isActive: currType == Rectangle,
          icon: CupertinoIcons.stop,
          onTap: () => controller.setPaintContent(Rectangle())),
      DefToolItem(
          isActive: currType == Circle,
          icon: CupertinoIcons.circle,
          onTap: () => controller.setPaintContent(Circle())),
      DefToolItem(
          isActive: currType == Eraser,
          icon: CupertinoIcons.bandage,
          onTap: () => controller.setPaintContent(Eraser())),
    ];
  }

  /// 默认操作项列表
  static List<DefActionItem> defaultActions(
    Type currType,
    DrawingController controller,
  ) {
    return <DefActionItem>[
      DefActionItem(
        icon: CupertinoIcons.arrow_turn_up_left,
        isEnabled: controller.canUndo(),
        onTap: () => controller.undo(),
      ),
      DefActionItem(
        icon: CupertinoIcons.arrow_turn_up_right,
        isEnabled: controller.canRedo(),
        onTap: () => controller.redo(),
      ),
      DefActionItem(
        icon: CupertinoIcons.rotate_right,
        onTap: () => controller.turn(),
      ),
      DefActionItem(
        icon: CupertinoIcons.trash,
        onTap: () => controller.clear(),
      ),
    ];
  }

  static Widget buildDefaultActions(DrawingController controller,
      {Color? toolsBackgroundColor,
      DefaultActionsBuilder? defaultActionsBuilder}) {
    return _DrawingBoardState.buildDefaultActions(controller,
        backgroundColor: toolsBackgroundColor,
        defaultActionsBuilder: defaultActionsBuilder);
  }

  static Widget buildDefaultTools(DrawingController controller,
      {DefaultToolsBuilder? defaultToolsBuilder,
      Axis axis = Axis.horizontal,
      Color? toolsBackgroundColor}) {
    return _DrawingBoardState.buildDefaultTools(controller,
        defaultToolsBuilder: defaultToolsBuilder,
        axis: axis,
        backgroundColor: toolsBackgroundColor);
  }

  @override
  State<DrawingBoard> createState() => _DrawingBoardState();
}

class _DrawingBoardState extends State<DrawingBoard> {
  late final DrawingController _controller =
      widget.controller ?? DrawingController();

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = InteractiveViewer(
      maxScale: widget.maxScale,
      minScale: widget.minScale,
      boundaryMargin: widget.boardBoundaryMargin ??
          EdgeInsets.all(MediaQuery.of(context).size.width),
      clipBehavior: widget.boardClipBehavior,
      panAxis: widget.panAxis,
      constrained: widget.boardConstrained,
      onInteractionStart: widget.onInteractionStart,
      onInteractionUpdate: widget.onInteractionUpdate,
      onInteractionEnd: widget.onInteractionEnd,
      scaleFactor: widget.boardScaleFactor,
      panEnabled: widget.boardPanEnabled,
      scaleEnabled: widget.boardScaleEnabled,
      transformationController: widget.transformationController,
      child: Align(alignment: widget.alignment, child: _buildBoard),
    );

    if (widget.showDefaultActions || widget.showDefaultTools) {
      content = Column(
        children: <Widget>[
          Expanded(child: content),
          if (widget.showDefaultActions)
            buildDefaultActions(_controller,
                backgroundColor: widget.toolsBackgroundColor,
                defaultActionsBuilder: widget.defaultActionsBuilder),
          if (widget.showDefaultTools)
            buildDefaultTools(_controller,
                defaultToolsBuilder: widget.defaultToolsBuilder,
                backgroundColor: widget.toolsBackgroundColor),
        ],
      );
    }

    return Listener(
      onPointerDown: (PointerDownEvent pde) =>
          _controller.addFingerCount(pde.localPosition),
      onPointerUp: (PointerUpEvent pue) =>
          _controller.reduceFingerCount(pue.localPosition),
      onPointerCancel: (PointerCancelEvent pce) =>
          _controller.reduceFingerCount(pce.localPosition),
      child: content,
    );
  }

  /// 构建画板
  Widget get _buildBoard {
    return ExValueBuilder<DrawConfig>(
      valueListenable: _controller.drawConfig,
      shouldRebuild: (DrawConfig p, DrawConfig n) =>
          p.angle != n.angle || p.size != n.size,
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
        child: widget.background,
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
        onPointerDown: widget.onPointerDown,
        onPointerMove: widget.onPointerMove,
        onPointerUp: widget.onPointerUp,
      ),
    );
  }

  /// 构建默认操作栏
  static Widget buildDefaultActions(DrawingController controller,
      {Color? backgroundColor, DefaultActionsBuilder? defaultActionsBuilder}) {
    return Material(
      color: backgroundColor ?? Colors.transparent,
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
                      onChanged: (double v) =>
                          controller.setStyle(strokeWidth: v),
                    ),
                  ),
                  ...(defaultActionsBuilder?.call(dc.contentType, controller) ??
                          DrawingBoard.defaultActions(
                              dc.contentType, controller))
                      .map((DefActionItem item) =>
                          _DefActionItemWidget(item: item)),
                ],
              );
            }),
      ),
    );
  }

  /// 构建默认工具栏
  static Widget buildDefaultTools(
    DrawingController controller, {
    DefaultToolsBuilder? defaultToolsBuilder,
    Axis axis = Axis.horizontal,
    Color? backgroundColor,
  }) {
    return Material(
      color: backgroundColor ?? Colors.transparent,
      child: SingleChildScrollView(
        scrollDirection: axis,
        padding: EdgeInsets.zero,
        child: ExValueBuilder<DrawConfig>(
          valueListenable: controller.drawConfig,
          shouldRebuild: (DrawConfig p, DrawConfig n) =>
              p.contentType != n.contentType,
          builder: (_, DrawConfig dc, ___) {
            final Type currType = dc.contentType;

            final List<Widget> children =
                (defaultToolsBuilder?.call(currType, controller) ??
                        DrawingBoard.defaultTools(currType, controller))
                    .map((DefToolItem item) => _DefToolItemWidget(item: item))
                    .toList();

            return axis == Axis.horizontal
                ? Row(children: children)
                : Column(children: children);
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
    this.badgeColor,
    this.badgeSize = 8.0,
  });

  final Function()? onTap;
  final bool isActive;

  final IconData icon;
  final double? iconSize;
  final Color? color;
  final Color activeColor;

  /// Optional badge color to show in top right corner
  final Color? badgeColor;

  /// Size of the badge circle
  final double badgeSize;
}

/// 默认工具项 Widget
class _DefToolItemWidget extends StatelessWidget {
  const _DefToolItemWidget({
    required this.item,
  });

  final DefToolItem item;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        IconButton(
          onPressed: item.onTap,
          icon: Icon(
            item.icon,
            color: item.isActive ? item.activeColor : item.color,
            size: item.iconSize,
          ),
        ),
        if (item.badgeColor != null)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: item.badgeSize,
              height: item.badgeSize,
              decoration: BoxDecoration(
                color: item.badgeColor,
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// 默认操作项配置文件
class DefActionItem {
  DefActionItem({
    required this.icon,
    required this.onTap,
    this.isEnabled = true,
    this.color,
    this.disabledColor = Colors.grey,
    this.iconSize,
  });

  final Function() onTap;
  final bool isEnabled;
  final IconData icon;
  final double? iconSize;
  final Color? color;
  final Color disabledColor;
}

/// 默认操作项 Widget
class _DefActionItemWidget extends StatelessWidget {
  const _DefActionItemWidget({
    required this.item,
  });

  final DefActionItem item;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: item.isEnabled ? item.onTap : null,
      icon: Icon(
        item.icon,
        color: item.isEnabled ? item.color : item.disabledColor,
        size: item.iconSize,
      ),
    );
  }
}

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/src/helper/color_pic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import 'color_pic_btn.dart';
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

typedef DefaultActionsBuilder = List<Widget> Function(DrawingController controller);

typedef BarBuilder = Widget Function(
  BuildContext context,
  List<Widget> children,
);

typedef BoardLayoutBuilder = Widget Function(
  BuildContext context,
  Widget board,
  Widget? actionBar,
  Widget? toolsBar,
);

/// 画板
class DrawingBoard extends StatefulWidget {
  const DrawingBoard({
    Key? key,
    required this.background,
    this.controller,
    this.showDefaultActions = false,
    this.showDefaultTools = false,
    this.onPointerDown,
    this.onPointerMove,
    this.onPointerUp,
    this.clipBehavior = Clip.antiAlias,
    this.defaultToolsBuilder,
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
    this.actionBarBuilder,
    this.toolsBarBuilder,
    this.boardLayoutBuilder,
    this.defaultActionsBuilder,
    this.alignment = Alignment.topCenter,
  }) : super(key: key);

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
  final DefaultActionsBuilder? defaultActionsBuilder;

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
  final BarBuilder? actionBarBuilder;
  final BarBuilder? toolsBarBuilder;
  final BoardLayoutBuilder? boardLayoutBuilder;

  /// 默认工具项列表
  static List<DefToolItem> defaultTools(
    Type currType,
    DrawingController controller, {
    final bool showPenTool = true,
    final bool showBrushTool = true,
    final bool showStraightLineTool = true,
    final bool showRectangleTool = true,
    final bool showCircleTool = true,
    final bool showEraserTool = true,
    final Color activeColor = Colors.blue,
    final Color? color,
    final double? iconSize,
  }) {
    return <DefToolItem>[
      if (showPenTool)
        DefToolItem(
          isActive: currType == SimpleLine,
          icon: CupertinoIcons.pencil,
          onTap: () => controller.setPaintContent = SimpleLine(),
          activeColor: activeColor,
          color: color,
          iconSize: iconSize,
        ),
      if (showBrushTool)
        DefToolItem(
          isActive: currType == SmoothLine,
          icon: Icons.brush,
          onTap: () => controller.setPaintContent = SmoothLine(),
          activeColor: activeColor,
          color: color,
          iconSize: iconSize,
        ),
      if (showStraightLineTool)
        DefToolItem(
          isActive: currType == StraightLine,
          icon: FontAwesomeIcons.slashForward,
          onTap: () => controller.setPaintContent = StraightLine(),
          activeColor: activeColor,
          color: color,
          iconSize: iconSize,
        ),
      if (showRectangleTool)
        DefToolItem(
          isActive: currType == Rectangle,
          icon: CupertinoIcons.stop,
          onTap: () => controller.setPaintContent = Rectangle(),
          activeColor: activeColor,
          color: color,
          iconSize: iconSize,
        ),
      if (showCircleTool)
        DefToolItem(
          isActive: currType == Circle,
          icon: CupertinoIcons.circle,
          onTap: () => controller.setPaintContent = Circle(),
          activeColor: activeColor,
          color: color,
          iconSize: iconSize,
        ),
      if (showEraserTool)
        DefToolItem(
          isActive: currType == Eraser,
          icon: FontAwesomeIcons.solidEraser,
          onTap: () => controller.setPaintContent = Eraser(color: Colors.white),
          activeColor: activeColor,
          color: color,
          iconSize: iconSize,
        ),
    ];
  }

  /// 构建默认操作栏
  static List<Widget> defaultActions(
    DrawingController controller, {
    final bool verticalSlider = false,
    final BoxDecoration? colorPicDecoration,
    final ColorPickerBuilder? colorPickerBuilder,
    final bool closeAfterColorPicked = false,
    final bool showUndoRedo = true,
    final bool showClear = true,
    final bool showStrokeWidth = true,
    final bool showColorPicker = true,
  }) {
    return <Widget>[
      if (showStrokeWidth)
        ExValueBuilder<DrawConfig>(
          valueListenable: controller.drawConfig,
          shouldRebuild: (DrawConfig p, DrawConfig n) => p.strokeWidth != n.strokeWidth,
          builder: (_, DrawConfig dc, ___) {
            const double maximum = 20.0;
            const double minimum = 1.0;
            if (verticalSlider) {
              return SfSlider.vertical(
                max: maximum,
                min: minimum,
                value: dc.strokeWidth,
                onChanged: (dynamic v) => controller.setStyle(strokeWidth: v as double?),
              );
            }
            return SfSlider(
              max: maximum,
              min: minimum,
              value: dc.strokeWidth,
              onChanged: (dynamic v) => controller.setStyle(strokeWidth: v as double?),
            );
          },
        ),
      if (showColorPicker)
        ColorPicBtn(
          controller: controller,
          decoration: colorPicDecoration,
          colorPickerBuilder: colorPickerBuilder,
          closeAfterPicked: closeAfterColorPicked,
        ),
      if (showUndoRedo)
        IconButton(
          icon: const Icon(
            CupertinoIcons.arrow_turn_up_left,
          ),
          onPressed: () => controller.undo(),
        ),
      if (showUndoRedo)
        IconButton(
          icon: const Icon(
            CupertinoIcons.arrow_turn_up_right,
          ),
          onPressed: () => controller.redo(),
        ),
      if (showClear)
        IconButton(
          icon: const Icon(
            CupertinoIcons.trash,
          ),
          onPressed: () => controller.clear(),
        ),
    ];
  }

  static Widget defaultActionBarBuilder(BuildContext context, List<Widget> children) {
    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        child: Row(
          children: children,
        ),
      ),
    );
  }

  static Widget defaultToolsBarBuilder(BuildContext context, List<Widget> children) {
    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        child: Row(
          children: children,
        ),
      ),
    );
  }

  static Widget defaultBoardLayout(
    BuildContext context, {
    required Widget board,
    Widget? actionBar,
    Widget? toolsBar,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(child: board),
        if (actionBar != null) actionBar,
        if (toolsBar != null) toolsBar,
      ],
    );
  }

  @override
  State<DrawingBoard> createState() => _DrawingBoardState();
}

class _DrawingBoardState extends State<DrawingBoard> {
  late final DrawingController _controller = widget.controller ?? DrawingController();

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = InteractiveViewer(
      maxScale: widget.maxScale,
      minScale: widget.minScale,
      boundaryMargin: widget.boardBoundaryMargin ?? EdgeInsets.all(MediaQuery.of(context).size.width),
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
      child: Align(
        alignment: widget.alignment,
        child: _buildBoard,
      ),
    );

    if (widget.showDefaultActions || widget.showDefaultTools) {}
    final Widget? actionBarWidget = widget.showDefaultActions ? _buildDefaultActions : null;
    final Widget? toolsBarWidget = widget.showDefaultTools ? _buildDefaultTools : null;
    content = widget.boardLayoutBuilder?.call(
          context,
          content,
          actionBarWidget,
          toolsBarWidget,
        ) ??
        DrawingBoard.defaultBoardLayout(
          context,
          board: content,
          actionBar: actionBarWidget,
          toolsBar: toolsBarWidget,
        );

    return Listener(
      onPointerDown: (PointerDownEvent pde) => _controller.addFingerCount(pde.localPosition),
      onPointerUp: (PointerUpEvent pue) => _controller.reduceFingerCount(pue.localPosition),
      child: content,
    );
  }

  /// 构建画板
  Widget get _buildBoard {
    return RepaintBoundary(
      key: _controller.painterKey,
      child: ExValueBuilder<DrawConfig>(
        valueListenable: _controller.drawConfig,
        shouldRebuild: (DrawConfig p, DrawConfig n) => p.angle != n.angle || p.size != n.size,
        builder: (_, DrawConfig dc, Widget? child) {
          Widget c = child!;

          if (dc.size != null) {
            final bool isHorizontal = dc.angle.toDouble() % 2 == 0;
            final double max = dc.size!.longestSide;

            if (!isHorizontal) {
              c = SizedBox(
                width: max,
                height: max,
                child: c,
              );
            }
          }

          return Transform.rotate(
            angle: dc.angle * pi / 2,
            child: c,
          );
        },
        child: Center(
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
  Widget get _buildDefaultActions {
    final List<Widget> children = (widget.defaultActionsBuilder ?? DrawingBoard.defaultActions).call(_controller);
    return widget.actionBarBuilder?.call(
          context,
          children,
        ) ??
        DrawingBoard.defaultActionBarBuilder(
          context,
          children,
        );
  }

  /// 构建默认工具栏
  Widget get _buildDefaultTools {
    return ExValueBuilder<DrawConfig>(
      valueListenable: _controller.drawConfig,
      shouldRebuild: (DrawConfig p, DrawConfig n) => p.contentType != n.contentType,
      builder: (_, DrawConfig dc, ___) {
        final Type currType = dc.contentType;
        final List<_DefToolItemWidget> children = (widget.defaultToolsBuilder?.call(currType, _controller) ??
                DrawingBoard.defaultTools(currType, _controller))
            .map((DefToolItem item) => _DefToolItemWidget(item: item))
            .toList();

        return widget.toolsBarBuilder?.call(context, children) ??
            DrawingBoard.defaultToolsBarBuilder(context, children);
      },
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

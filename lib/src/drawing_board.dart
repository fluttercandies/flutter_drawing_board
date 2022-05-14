import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'drawing_controller.dart';

import 'helper/color_pic.dart';
import 'helper/ex_value_builder.dart';
import 'helper/safe_state.dart';
import 'helper/safe_value_notifier.dart';
import 'paint_contents/eraser.dart';
import 'paint_contents/paint_content.dart';
import 'paint_contents/rectangle.dart';
import 'paint_contents/simple_line.dart';
import 'paint_contents/smooth_line.dart';
import 'paint_contents/straight_line.dart';
import 'painter.dart';

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
}

class _DrawingBoardState extends State<DrawingBoard>
    with SafeState<DrawingBoard> {
  ///线条粗细进度
  late SafeValueNotifier<double> _indicator;

  ///画板控制器
  late DrawingController _drawingController;

  @override
  void initState() {
    super.initState();
    _indicator = SafeValueNotifier<double>(1);
    _drawingController = widget.controller ?? DrawingController();
  }

  @override
  void dispose() {
    _indicator.dispose();
    if (widget.controller == null) {
      _drawingController.dispose();
    }
    super.dispose();
  }

  /// 选择颜色
  Future<void> _pickColor() async {
    final Color? newColor = await showModalBottomSheet<Color?>(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (_) => ColorPic(nowColor: _drawingController.getColor),
    );
    if (newColor == null) {
      return;
    }

    if (newColor != _drawingController.getColor) {
      _drawingController.setStyle(color: newColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = ExValueBuilder<DrawConfig>(
      valueListenable: _drawingController.drawConfig,
      shouldRebuild: (DrawConfig p, DrawConfig n) => p.angle != n.angle,
      child: Center(child: AspectRatio(aspectRatio: 1, child: _buildBoard)),
      builder: (_, DrawConfig dc, Widget? child) {
        return InteractiveViewer(
          maxScale: 20,
          minScale: 0.2,
          boundaryMargin: EdgeInsets.all(MediaQuery.of(context).size.width),
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
            SizedBox(
              width: 24,
              height: 24,
              child: ExValueBuilder<DrawConfig>(
                valueListenable: _drawingController.drawConfig,
                shouldRebuild: (DrawConfig p, DrawConfig n) =>
                    p.color != n.color,
                builder: (_, DrawConfig dc, ___) {
                  return TextButton(
                    onPressed: _pickColor,
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                    ),
                    child: Container(color: dc.color),
                  );
                },
              ),
            ),
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
              children: <Widget>[
                _buildToolItem<SimpleLine>(currType, CupertinoIcons.pencil,
                    () => _drawingController.setPaintContent = SimpleLine()),
                _buildToolItem<SmoothLine>(currType, CupertinoIcons.infinite,
                    () => _drawingController.setPaintContent = SmoothLine()),
                _buildToolItem<StraightLine>(currType, Icons.show_chart,
                    () => _drawingController.setPaintContent = StraightLine()),
                _buildToolItem<Rectangle>(currType, CupertinoIcons.stop,
                    () => _drawingController.setPaintContent = Rectangle()),
                _buildToolItem<Eraser>(
                    currType,
                    CupertinoIcons.bandage,
                    () => _drawingController.setPaintContent =
                        Eraser(color: Colors.white)),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 构建工具项
  Widget _buildToolItem<T extends PaintContent>(
      Type currType, IconData icon, Function() onTap) {
    return IconButton(
      icon: Icon(
        icon,
        color: T == currType ? Colors.blue : null,
      ),
      onPressed: onTap,
    );
  }
}

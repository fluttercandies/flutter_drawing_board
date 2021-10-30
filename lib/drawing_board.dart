import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'drawing_controller.dart';

import 'helper/color_pic.dart';
import 'helper/edit_text.dart';
import 'helper/ex_value_builder.dart';
import 'helper/get_size.dart';
import 'paint_contents/paint_content.dart';
import 'painter.dart';

///画板
class DrawingBoard extends StatefulWidget {
  const DrawingBoard({
    Key? key,
    required this.background,
    this.controller,
    this.showDefaultActions = false,
    this.showDefaultTools = false,
    this.drawingCallback,
  }) : super(key: key);

  @override
  _DrawingBoardState createState() => _DrawingBoardState();

  ///画板背景控件
  final Widget background;

  ///画板控制器
  final DrawingController? controller;

  ///显示默认样式的操作栏
  final bool showDefaultActions;

  ///显示默认样式的工具栏
  final bool showDefaultTools;

  ///绘制状态回调
  final Function(bool isDrawing)? drawingCallback;
}

class _DrawingBoardState extends State<DrawingBoard> {
  ///绘制区域大小
  final ValueNotifier<Size?> _size = ValueNotifier<Size?>(null);

  ///线条粗细进度
  final ValueNotifier<double> _indicator = ValueNotifier<double>(1);

  ///画板控制器
  late DrawingController? _drawingController;

  @override
  void initState() {
    super.initState();
    _drawingController = widget.controller ?? DrawingController();
  }

  @override
  void dispose() {
    _size.dispose();
    _indicator.dispose();
    if (widget.controller == null) {
      _drawingController!.dispose();
    }
    super.dispose();
  }

  ///选择颜色
  Future<void> _pickColor() async {
    final Color? newColor = await showModalBottomSheet<Color?>(
        context: context, builder: (_) => ColorPic(nowColor: _drawingController!.getColor));
    if (newColor != _drawingController!.getColor) {
      _drawingController!.setColor = newColor!;
    }
  }

  ///编辑文字
  Future<void> _editText() async {
    _drawingController!.setType = PaintType.text;
    final String? text = await showModalBottomSheet<String>(
        context: context, builder: (_) => EditText(defaultText: _drawingController!.getText));
    if (text != _drawingController!.getText) {
      _drawingController!.setText = text;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = ExValueBuilder<DrawConfig>(
      valueListenable: _drawingController!.drawConfig,
      shouldRebuild: (DrawConfig? p, DrawConfig? n) => p!.angle != n!.angle,
      child: Center(child: AspectRatio(aspectRatio: 1, child: _buildBoard)),
      builder: (_, DrawConfig? dc, Widget? child) {
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

  ///构建画板
  Widget get _buildBoard {
    return Center(
      child: RepaintBoundary(
        key: _drawingController!.painterKey,
        child: ExValueBuilder<DrawConfig>(
          valueListenable: _drawingController!.drawConfig,
          shouldRebuild: (DrawConfig? p, DrawConfig? n) => p!.angle != n!.angle,
          child: Stack(children: <Widget>[_buildImage, _buildPainter]),
          builder: (_, DrawConfig? dc, Widget? child) {
            return RotatedBox(
              quarterTurns: dc!.angle!,
              child: child,
            );
          },
        ),
      ),
    );
  }

  ///构建背景
  Widget get _buildImage {
    return GetSize(
      onChange: (Size? size) {
        if (_size.value == const Size(0.0, 0.0) || _size.value == null) {
          _size.value = size;
        }
      },
      child: ValueListenableBuilder<Size?>(
        valueListenable: _size,
        child: widget.background,
        builder: (_, Size? s, Widget? child) {
          final double? width = s?.width == 0 ? null : s?.width;
          final double? height = s?.height == 0 ? null : s?.height;
          return SizedBox(width: width, height: height, child: child);
        },
      ),
    );
  }

  ///构建绘制层
  Widget get _buildPainter {
    return ValueListenableBuilder<Size?>(
      valueListenable: _size,
      child: Painter(
        drawingController: _drawingController!,
        drawingCallback: widget.drawingCallback,
      ),
      builder: (_, Size? s, Widget? child) =>
          s == null || s == Size.zero ? Container() : SizedBox(child: child, width: s.width, height: s.height),
    );
  }

  ///构建默认操作栏
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
              child: ExValueBuilder<double>(
                valueListenable: _indicator,
                builder: (_, double? ind, ___) {
                  return Slider(
                    value: ind!,
                    max: 50,
                    min: 1,
                    onChanged: (double v) => _indicator.value = v,
                    onChangeEnd: (double v) => _drawingController!.setThickness = v,
                  );
                },
              ),
            ),
            SizedBox(
              width: 24,
              height: 24,
              child: ExValueBuilder<DrawConfig?>(
                valueListenable: _drawingController!.drawConfig,
                shouldRebuild: (DrawConfig? p, DrawConfig? n) => p!.color != n!.color,
                builder: (_, DrawConfig? dc, ___) {
                  return TextButton(
                    onPressed: _pickColor,
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                    ),
                    child: Container(color: dc!.color),
                  );
                },
              ),
            ),
            IconButton(
                icon: const Icon(CupertinoIcons.arrow_turn_up_left), onPressed: () => _drawingController!.undo()),
            IconButton(
                icon: const Icon(CupertinoIcons.arrow_turn_up_right), onPressed: () => _drawingController!.redo()),
            IconButton(icon: const Icon(CupertinoIcons.rotate_right), onPressed: () => _drawingController!.turn()),
            IconButton(icon: const Icon(CupertinoIcons.trash), onPressed: () => _drawingController!.clear()),
          ],
        ),
      ),
    );
  }

  ///构建默认工具栏
  Widget get _buildDefaultTools {
    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        child: Row(
          children: <Widget>[
            _buildToolItem(
                PaintType.simpleLine, CupertinoIcons.pencil, () => _drawingController!.setType = PaintType.simpleLine),
            _buildToolItem(
                PaintType.straightLine, Icons.show_chart, () => _drawingController!.setType = PaintType.straightLine),
            _buildToolItem(
                PaintType.rectangle, CupertinoIcons.stop, () => _drawingController!.setType = PaintType.rectangle),
            _buildToolItem(PaintType.text, CupertinoIcons.text_cursor, _editText),
            _buildToolItem(
                PaintType.eraser, CupertinoIcons.bandage, () => _drawingController!.setType = PaintType.eraser),
          ],
        ),
      ),
    );
  }

  ///构建工具项
  Widget _buildToolItem(PaintType type, IconData icon, Function() onTap) {
    return ExValueBuilder<DrawConfig>(
      valueListenable: _drawingController!.drawConfig,
      shouldRebuild: (DrawConfig? p, DrawConfig? n) => p!.paintType == type || n!.paintType == type,
      builder: (_, DrawConfig? dc, __) {
        return IconButton(
          icon: Icon(
            icon,
            color: dc?.paintType == type ? Colors.blue : null,
          ),
          onPressed: onTap,
        );
      },
    );
  }
}

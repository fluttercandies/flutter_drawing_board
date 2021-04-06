import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'drawing_controller.dart';
import 'paint_contents/custom_text.dart';
import 'paint_contents/eraser.dart';
import 'paint_contents/paint_content.dart';
import 'paint_contents/rectangle.dart';
import 'paint_contents/simple_line.dart';
import 'paint_contents/smooth_line.dart';
import 'paint_contents/straight_line.dart';

///绘图板
class Painter extends StatefulWidget {
  const Painter({
    Key key,
    @required this.drawingController,
  }) : super(key: key);

  @override
  _PainterState createState() => _PainterState();

  ///绘制控制器
  final DrawingController drawingController;
}

class _PainterState extends State<Painter> {
  ///触摸点数量
  ///记录以消除多指触摸引起的问题
  final ValueNotifier<int> _fingerCount = ValueNotifier<int>(0);

  @override
  void dispose() {
    _fingerCount.dispose();
    super.dispose();
  }

  ///手指落下
  void _onPanStart(DragStartDetails dsd) {
    if (_fingerCount.value > 1) {
      return;
    }
    widget.drawingController.startDraw(dsd.localPosition);
  }

  ///手指移动
  void _onPanUpdate(DragUpdateDetails dud) {
    if (_fingerCount.value > 1) {
      return;
    }

    widget.drawingController.drawing(dud.localPosition);
  }

  ///手指抬起
  void _onPanEnd(DragEndDetails ded) {
    if (_fingerCount.value > 1) {
      return;
    }
    widget.drawingController.endDraw();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent pde) => _fingerCount.value++,
      onPointerUp: (PointerUpEvent pue) => _fingerCount.value--,
      child: ValueListenableBuilder<int>(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Stack(
            children: <Widget>[
              SizedBox.expand(child: CustomPaint(painter: _DeepPainter(drawingController: widget.drawingController))),
              SizedBox.expand(child: CustomPaint(painter: _UpPainter(drawingController: widget.drawingController))),
            ],
          ),
        ),
        valueListenable: _fingerCount,
        builder: (_, int count, Widget child) {
          return GestureDetector(
            child: child,
            onPanStart: count <= 1 ? _onPanStart : null,
            onPanUpdate: count <= 1 ? _onPanUpdate : null,
            onPanEnd: count <= 1 ? _onPanEnd : null,
          );
        },
      ),
    );
  }
}

///表层画板
class _UpPainter extends CustomPainter {
  _UpPainter({this.drawingController}) : super(repaint: drawingController.drawConfig);

  final DrawingController drawingController;

  @override
  void paint(Canvas canvas, Size size) {
    if (drawingController.currentContent == null) {
      return;
    }

    switch (drawingController.getType) {
      case PaintType.simpleLine:
        _drawPath(canvas, drawingController.currentContent as SimpleLine);
        break;
      case PaintType.straightLine:
        _drawLine(canvas, drawingController.currentContent as StraightLine);
        break;
      case PaintType.rectangle:
        _drawRect(canvas, drawingController.currentContent as Rectangle);
        break;
      case PaintType.text:
        _drawText(canvas, size, drawingController.currentContent as CustomText, uper: true);
        break;
      case PaintType.smoothLine:
        _drawSmooth(canvas, drawingController.currentContent as SmoothLine);
        break;
      case PaintType.eraser:
        _eraser(canvas, size, drawingController.currentContent as Eraser);
        break;
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

///底层画板
class _DeepPainter extends CustomPainter {
  _DeepPainter({this.drawingController}) : super(repaint: drawingController.realPainter);
  final DrawingController drawingController;

  @override
  void paint(Canvas canvas, Size size) {
    final List<PaintContent> _contents = drawingController.getHistory;
    if (_contents.isEmpty) {
      return;
    }

    canvas.saveLayer(Offset.zero & size, Paint());

    for (int i = 0; i < drawingController.currentIndex; i++) {
      final PaintContent item = _contents[i];
      switch (item.type) {
        case PaintType.simpleLine:
          _drawPath(canvas, item as SimpleLine);
          break;
        case PaintType.straightLine:
          _drawLine(canvas, item as StraightLine);
          break;
        case PaintType.rectangle:
          _drawRect(canvas, item as Rectangle);
          break;
        case PaintType.text:
          _drawText(canvas, size, item as CustomText);
          break;
        case PaintType.smoothLine:
          _drawSmooth(canvas, item as SmoothLine);
          break;
        case PaintType.eraser:
          _eraser(canvas, size, item as Eraser);
          break;
        default:
          break;
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

///绘制自由线条
void _drawPath(Canvas canvas, SimpleLine line) => canvas.drawPath(line.path, line.paint);

///绘制直线
void _drawLine(Canvas canvas, StraightLine line) => canvas.drawLine(line.startPoint, line.endPoint, line.paint);

///绘制矩形
void _drawRect(Canvas canvas, Rectangle r) => canvas.drawRect(Rect.fromLTRB(r.startPoint.dx, r.startPoint.dy, r.endPoint.dx, r.endPoint.dy), r.paint);

///绘制文本
void _drawText(Canvas canvas, Size size, CustomText text, {bool uper = false}) {
  canvas.save();

  canvas.rotate(-math.pi * 0.5 * text.angle);

  if (text.angle == 1) {
    canvas.translate(-size.height, 0);
  }

  if (text.angle == 2) {
    canvas.translate(-size.width, -size.height);
  }

  if (text.angle == 3) {
    canvas.translate(0, -size.width);
  }

  if (uper) {
    canvas.drawRect(
      Rect.fromLTWH(
        text.realStart(size).dx,
        text.realStart(size).dy,
        text.realEnd(size).dx - text.realStart(size).dx,
        text.size,
      ),
      text.paint,
    );
  }

  text.textPainter.layout(maxWidth: text.maxWidth);
  text.textPainter.paint(canvas, text.realStart(size));

  canvas.restore();
}

///绘制平滑自由线条
void _drawSmooth(Canvas canvas, SmoothLine line) => canvas.drawPath(line.path, line.paint);

///绘制自由线条
void _eraser(Canvas canvas, Size size, Eraser line) => canvas.drawPath(line.path, line.paint);

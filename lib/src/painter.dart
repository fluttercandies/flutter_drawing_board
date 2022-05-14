import 'package:flutter/material.dart';

import 'drawing_controller.dart';
import 'helper/ex_value_builder.dart';
import 'helper/safe_value_notifier.dart';
import 'paint_contents/paint_content.dart';

/// 绘图板
class Painter extends StatefulWidget {
  const Painter({
    Key? key,
    required this.drawingController,
    this.clipBehavior = Clip.antiAlias,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
  }) : super(key: key);

  @override
  _PainterState createState() => _PainterState();

  /// 绘制控制器
  final DrawingController drawingController;

  /// 开始拖动
  final Function(DragStartDetails dsd)? onPanStart;

  /// 正在拖动
  final Function(DragUpdateDetails dud)? onPanUpdate;

  /// 结束拖动
  final Function(DragEndDetails ded)? onPanEnd;

  /// 边缘裁剪方式
  final Clip clipBehavior;
}

class _PainterState extends State<Painter> {
  /// 触摸点数量
  /// 记录以消除多指触摸引起的问题
  final SafeValueNotifier<int> _fingerCount = SafeValueNotifier<int>(0);

  @override
  void dispose() {
    _fingerCount.dispose();
    super.dispose();
  }

  /// 手指落下
  void _onPanStart(DragStartDetails dsd) {
    if (_fingerCount.value > 1) {
      return;
    }

    widget.drawingController.startDraw(dsd.localPosition);
    widget.onPanStart?.call(dsd);
  }

  /// 手指移动
  void _onPanUpdate(DragUpdateDetails dud) {
    if (_fingerCount.value > 1) {
      return;
    }

    widget.drawingController.drawing(dud.localPosition);
    widget.onPanUpdate?.call(dud);
  }

  /// 手指抬起
  void _onPanEnd(DragEndDetails ded) {
    if (_fingerCount.value > 1) {
      return;
    }

    widget.drawingController.endDraw();
    widget.onPanEnd?.call(ded);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent pde) => _fingerCount.value++,
      onPointerUp: (PointerUpEvent pue) => _fingerCount.value--,
      child: ExValueBuilder<int>(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          clipBehavior: widget.clipBehavior,
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              RepaintBoundary(child: CustomPaint(painter: _DeepPainter(controller: widget.drawingController))),
              CustomPaint(painter: _UpPainter(controller: widget.drawingController)),
            ],
          ),
        ),
        valueListenable: _fingerCount,
        builder: (_, int count, Widget? child) {
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

/// 表层画板
class _UpPainter extends CustomPainter {
  _UpPainter({required this.controller}) : super(repaint: controller.painter);

  final DrawingController controller;

  @override
  void paint(Canvas canvas, Size size) {
    if (controller.currentContent == null) return;

    controller.currentContent?.draw(canvas, size);
  }

  @override
  bool shouldRepaint(covariant _UpPainter oldDelegate) => true;
}

/// 底层画板
class _DeepPainter extends CustomPainter {
  _DeepPainter({required this.controller}) : super(repaint: controller.realPainter);
  final DrawingController controller;

  @override
  void paint(Canvas canvas, Size size) {
    final List<PaintContent> _contents = controller.getHistory;

    if (_contents.isEmpty) {
      return;
    }

    canvas.saveLayer(Offset.zero & size, Paint());

    for (int i = 0; i < controller.currentIndex; i++) {
      _contents[i].draw(canvas, size);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DeepPainter oldDelegate) => true;
}

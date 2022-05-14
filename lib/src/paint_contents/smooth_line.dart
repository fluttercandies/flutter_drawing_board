import 'dart:ui';
import 'package:flutter_drawing_board/src/helper/ex_paint.dart';
import 'paint_content.dart';

/// 笔触线条
class SmoothLine extends PaintContent {
  SmoothLine({
    /// 绘制影响因子，值越小线条越平滑，粗细变化越慢
    this.brushPrecision = 0.4,
  });

  final double brushPrecision;

  /// 绘制点列表
  late List<Offset> points;

  /// 点之间的绘制线条权重列表
  late List<double> strokeWidthList;

  @override
  void startDraw(Offset startPoint) {
    points = <Offset>[startPoint];
    strokeWidthList = <double>[paint.strokeWidth];
  }

  @override
  void drawing(Offset nowPoint) {
    final double distance = (nowPoint - points.last).distance;

    //原始画笔线条线宽
    final double s = paint.strokeWidth;

    double strokeWidth = s * (s * 2 / (s * distance));

    if (strokeWidth > s * 2) strokeWidth = s * 2;

    //上一个线宽
    final double preWidth = strokeWidthList.last;

    if (strokeWidth - preWidth > brushPrecision) {
      strokeWidth = preWidth + brushPrecision;
    } else if (preWidth - strokeWidth > brushPrecision) {
      strokeWidth = preWidth - brushPrecision;
    }

    //记录点位
    points.add(nowPoint);
    strokeWidthList.add(strokeWidth);
  }

  @override
  void draw(Canvas canvas, Size size, bool deeper) {
    for (int i = 1; i < points.length; i++) {
      canvas.drawPath(
        Path()
          ..moveTo(points[i - 1].dx, points[i - 1].dy)
          ..lineTo(points[i].dx, points[i].dy),
        paint.copyWith(strokeWidth: strokeWidthList[i]),
      );
    }
  }

  @override
  PaintContent copy() => SmoothLine(brushPrecision: brushPrecision);
}

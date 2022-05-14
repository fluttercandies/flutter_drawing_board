import 'dart:ui';

import 'paint_content.dart';

/// 笔触线条
class SmoothLine extends PaintContent {
  SmoothLine({
    /// 绘制影响因子，越小线条越平滑
    this.brushPrecision = 0.4,
    Paint? paint,
  }) : super(paint: paint);

  final double brushPrecision;

  /// 绘制点列表
  late List<Offset> points;

  /// 点之间的绘制线条权重列表
  late List<double> strokeWidthList;

  @override
  void startDraw(Offset startPoint) {
    points = <Offset>[startPoint];
    strokeWidthList = <double>[paint!.strokeWidth];
  }

  @override
  void drawing(Offset nowPoint) {
    final double distance = (nowPoint - points.last).distance;

    //原始大小
    final double s = paint!.strokeWidth;

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
  void draw(Canvas canvas, Size size) {
    for (int i = 1; i < points.length; i++) {
      canvas.drawPath(
        Path()
          ..moveTo(points[i - 1].dx, points[i - 1].dy)
          ..lineTo(points[i].dx, points[i].dy),
        paint!..strokeWidth = strokeWidthList[i],
      );
    }
  }

  @override
  PaintContent copy() => SmoothLine(paint: paint!, brushPrecision: brushPrecision);
}

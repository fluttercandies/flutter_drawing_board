import 'package:flutter/painting.dart';

import 'paint_content.dart';

/// 圆
class Circle extends PaintContent {
  Circle({
    this.isEllipse = false,
    this.startFromCenter = true,
  });

  /// 是否为椭圆
  final bool isEllipse;

  /// 从圆心开始绘制
  final bool startFromCenter;

  /// 圆心
  Offset center = Offset.zero;

  /// 半径
  double radius = 0;

  /// 起始点
  Offset startPoint = Offset.zero;

  /// 结束点
  Offset endPoint = Offset.zero;

  @override
  void startDraw(Offset startPoint) {
    this.startPoint = startPoint;
    center = startPoint;
  }

  @override
  void drawing(Offset nowPoint) {
    endPoint = nowPoint;
    center = Offset(
        (startPoint.dx + endPoint.dx) / 2, (startPoint.dy + endPoint.dy) / 2);
    radius = (endPoint - (startFromCenter ? startPoint : center)).distance;
  }

  @override
  void draw(Canvas canvas, Size size, bool deeper) {
    if (isEllipse)
      canvas.drawOval(Rect.fromPoints(startPoint, endPoint), paint);
    else
      canvas.drawCircle(startFromCenter ? startPoint : center, radius, paint);
  }

  @override
  Circle copy() => Circle(isEllipse: isEllipse);
}

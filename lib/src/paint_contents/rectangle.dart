import 'package:flutter/painting.dart';

import 'paint_content.dart';

/// 矩形
class Rectangle extends PaintContent {
  Rectangle();

  /// 起始点
  Offset startPoint = Offset.zero;

  /// 结束点
  Offset endPoint = Offset.zero;

  @override
  void startDraw(Offset startPoint) => this.startPoint = startPoint;

  @override
  void drawing(Offset nowPoint) => endPoint = nowPoint;

  @override
  void draw(Canvas canvas, Size size, bool deeper) =>
      canvas.drawRect(Rect.fromPoints(startPoint, endPoint), paint);

  @override
  Rectangle copy() => Rectangle();
}

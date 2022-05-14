import 'package:flutter/painting.dart';

import 'paint_content.dart';

/// 矩形
class Rectangle extends PaintContent {
  Rectangle({Paint? paint}) : super(paint: paint);

  /// 起始点
  late Offset startPoint;

  /// 结束点
  late Offset endPoint;

  @override
  void startDraw(Offset startPoint) => this.startPoint = startPoint;

  @override
  void drawing(Offset nowPoint) => endPoint = nowPoint;

  @override
  void draw(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTRB(startPoint.dx, startPoint.dy, endPoint.dx, endPoint.dy),
      paint!,
    );
  }

  @override
  Rectangle copy() => Rectangle(paint: paint);
}

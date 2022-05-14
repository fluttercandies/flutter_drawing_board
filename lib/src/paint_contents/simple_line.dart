import 'package:flutter/painting.dart';

import 'paint_content.dart';

/// 普通自由线条
class SimpleLine extends PaintContent {
  SimpleLine({Paint? paint}) : super(paint: paint);

  /// 绘制路径
  late Path path;

  @override
  void startDraw(Offset startPoint) {
    path = Path();
    path.moveTo(startPoint.dx, startPoint.dy);
  }

  @override
  void drawing(Offset nowPoint) => path.lineTo(nowPoint.dx, nowPoint.dy);

  @override
  void draw(Canvas canvas, Size size) => canvas.drawPath(path, paint!);

  @override
  SimpleLine copy() => SimpleLine(paint: paint);
}

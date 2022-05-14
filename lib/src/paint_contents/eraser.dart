import 'package:flutter/painting.dart';

import 'paint_content.dart';

/// 橡皮
class Eraser extends PaintContent {
  Eraser({Paint? paint, this.color = const Color(0xff000000)}) : super(paint: paint);

  /// 擦除路径
  late Path path;
  final Color color;

  @override
  void startDraw(Offset startPoint) {
    path = Path();
    path.moveTo(startPoint.dx, startPoint.dy);
  }

  @override
  void drawing(Offset nowPoint) => path.lineTo(nowPoint.dx, nowPoint.dy);

  @override
  void draw(Canvas canvas, Size size) => canvas.drawPath(path, paint!..color = color);

  @override
  Eraser copy() => Eraser(paint: paint);
}

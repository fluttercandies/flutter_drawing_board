import 'package:flutter/painting.dart';

import 'paint_content.dart';

/// 直线
class StraightLine extends PaintContent {
  StraightLine({Paint? paint}) : super(paint: paint);

  late Offset startPoint;
  late Offset endPoint;

  @override
  void startDraw(Offset startPoint) => this.startPoint = startPoint;

  @override
  void drawing(Offset nowPoint) => endPoint = nowPoint;

  @override
  void draw(Canvas canvas, Size size) => canvas.drawLine(startPoint, endPoint, paint!);

  @override
  PaintContent copy() => StraightLine(paint: paint);
}

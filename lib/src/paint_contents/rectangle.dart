import 'package:flutter/painting.dart';
import 'package:flutter_drawing_board/src/paint_extension/ex_offset.dart';
import 'package:flutter_drawing_board/src/paint_extension/ex_paint.dart';

import 'paint_content.dart';

/// 矩形
class Rectangle extends PaintContent {
  Rectangle();

  Rectangle.data({
    required this.startPoint,
    required this.endPoint,
    required Paint paint,
  }) : super.paint(paint);

  factory Rectangle.fromJson(Map<String, dynamic> data) {
    return Rectangle.data(
      startPoint: jsonToOffset(data['startPoint'] as Map<String, dynamic>),
      endPoint: jsonToOffset(data['endPoint'] as Map<String, dynamic>),
      paint: jsonToPaint(data['paint'] as Map<String, dynamic>),
    );
  }

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

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': 'Rectangle',
      'startPoint': startPoint.toJson(),
      'endPoint': endPoint.toJson(),
      'paint': paint.toJson(),
    };
  }
}

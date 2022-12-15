import 'package:flutter/painting.dart';
import 'package:flutter_drawing_board/src/paint_extension/ex_offset.dart';
import 'package:flutter_drawing_board/src/paint_extension/ex_paint.dart';

import 'paint_content.dart';

/// 直线
class StraightLine extends PaintContent {
  StraightLine();

  StraightLine.fromJson({
    required this.startPoint,
    required this.endPoint,
    required Paint paint,
  }) : super.paint(paint);

  late Offset startPoint;
  late Offset endPoint;

  @override
  void startDraw(Offset startPoint) => this.startPoint = startPoint;

  @override
  void drawing(Offset nowPoint) => endPoint = nowPoint;

  @override
  void draw(Canvas canvas, Size size, bool deeper) => canvas.drawLine(startPoint, endPoint, paint);

  @override
  StraightLine copy() => StraightLine();

  @override
  StraightLine fromJson(Map<String, dynamic> data) {
    return StraightLine.fromJson(
      startPoint: jsonToOffset(data['startPoint'] as Map<String, dynamic>),
      endPoint: jsonToOffset(data['endPoint'] as Map<String, dynamic>),
      paint: jsonToPaint(data['paint'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': 'StraightLine',
      'startPoint': startPoint.toJson(),
      'endPoint': endPoint.toJson(),
      'paint': paint.toJson(),
    };
  }
}

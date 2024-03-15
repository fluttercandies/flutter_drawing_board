import 'package:flutter/painting.dart';
import '../paint_extension/ex_offset.dart';
import '../paint_extension/ex_paint.dart';

import 'paint_content.dart';

/// 直线
class StraightLine extends PaintContent {
  StraightLine();

  StraightLine.data({
    required this.startPoint,
    required this.endPoint,
    required Paint paint,
  }) : super.paint(paint);

  factory StraightLine.fromJson(Map<String, dynamic> data) {
    return StraightLine.data(
      startPoint: jsonToOffset(data['startPoint'] as Map<String, dynamic>),
      endPoint: jsonToOffset(data['endPoint'] as Map<String, dynamic>),
      paint: jsonToPaint(data['paint'] as Map<String, dynamic>),
    );
  }

  late Offset startPoint;
  late Offset endPoint;

  @override
  void startDraw(Offset startPoint) => this.startPoint = startPoint;

  @override
  void drawing(Offset nowPoint) => endPoint = nowPoint;

  @override
  void draw(Canvas canvas, Size size, bool deeper) {
    //缩放和移动画布的时候，防止手指落下留下一个圆点。
    if(startPoint == endPoint){
      return;
    }
    canvas.drawLine(startPoint, endPoint, paint);
  }

  @override
  StraightLine copy() => StraightLine();

  @override
  Map<String, dynamic> toContentJson() {
    return <String, dynamic>{
      'startPoint': startPoint.toJson(),
      'endPoint': endPoint.toJson(),
      'paint': paint.toJson(),
    };
  }
}

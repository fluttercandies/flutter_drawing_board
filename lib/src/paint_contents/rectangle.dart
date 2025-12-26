import 'package:flutter/painting.dart';
import '../paint_extension/ex_offset.dart';
import '../paint_extension/ex_paint.dart';

import 'paint_content.dart';

/// 矩形绘制内容
///
/// 通过起点和终点定义对角线来绘制矩形
///
/// Rectangle Drawing Content
///
/// Draws a rectangle by defining diagonal through start and end points
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

  /// 起始点坐标（矩形对角线的一个端点）
  ///
  /// Start point coordinates (one endpoint of the rectangle diagonal)
  Offset? startPoint;

  /// 结束点坐标（矩形对角线的另一个端点）
  ///
  /// End point coordinates (the other endpoint of the rectangle diagonal)
  Offset? endPoint;

  @override
  String get contentType => 'Rectangle';

  @override
  void startDraw(Offset startPoint) => this.startPoint = startPoint;

  @override
  void drawing(Offset nowPoint) => endPoint = nowPoint;

  @override
  void draw(Canvas canvas, Size size, bool deeper) {
    if (startPoint == null || endPoint == null) {
      return;
    }

    canvas.drawRect(Rect.fromPoints(startPoint!, endPoint!), paint);
  }

  @override
  Rectangle copy() => Rectangle();

  @override
  Map<String, dynamic> toContentJson() {
    return <String, dynamic>{
      'startPoint': startPoint?.toJson(),
      'endPoint': endPoint?.toJson(),
      'paint': paint.toJson(),
    };
  }
}

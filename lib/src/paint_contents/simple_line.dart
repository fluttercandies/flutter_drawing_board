import 'package:flutter/painting.dart';
import 'package:flutter_drawing_board/src/draw_path/draw_path.dart';
import 'package:flutter_drawing_board/src/paint_extension/ex_paint.dart';

import 'paint_content.dart';

/// 普通自由线条
class SimpleLine extends PaintContent {
  SimpleLine();

  SimpleLine.data({
    required this.path,
    required Paint paint,
  }) : super.paint(paint);

  factory SimpleLine.fromJson(Map<String, dynamic> data) {
    return SimpleLine.data(
      path: DrawPath.fromJson(data['path'] as Map<String, dynamic>),
      paint: jsonToPaint(data['paint'] as Map<String, dynamic>),
    );
  }

  /// 绘制路径
  DrawPath path = DrawPath();

  @override
  void startDraw(Offset startPoint) =>
      path.moveTo(startPoint.dx, startPoint.dy);

  @override
  void drawing(Offset nowPoint) => path.lineTo(nowPoint.dx, nowPoint.dy);

  @override
  void draw(Canvas canvas, Size size, bool deeper) =>
      canvas.drawPath(path.path, paint);

  @override
  SimpleLine copy() => SimpleLine();

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': 'SimpleLine',
      'path': path.toJson(),
      'paint': paint.toJson(),
    };
  }
}

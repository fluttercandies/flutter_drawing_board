import 'package:flutter/material.dart';
import '../draw_path/draw_path.dart';
import '../paint_extension/ex_paint.dart';

import 'paint_content.dart';

/// 橡皮
class Eraser extends PaintContent {
  Eraser();

  Eraser.data({
    required this.drawPath,
    required Paint paint,
  }) : super.paint(paint);

  factory Eraser.fromJson(Map<String, dynamic> data) {
    return Eraser.data(
      drawPath: DrawPath.fromJson(data['path'] as Map<String, dynamic>),
      paint: jsonToPaint(data['paint'] as Map<String, dynamic>),
    );
  }

  /// 擦除路径
  DrawPath drawPath = DrawPath();

  @override
  String get contentType => 'Eraser';

  @override
  void startDraw(Offset startPoint) {
    drawPath.moveTo(startPoint.dx, startPoint.dy);
  }

  @override
  void drawing(Offset nowPoint) => drawPath.lineTo(nowPoint.dx, nowPoint.dy);

  @override
  void draw(Canvas canvas, Size size, bool deeper) {
    canvas.drawPath(drawPath.path, paint.copyWith(blendMode: BlendMode.clear));
  }

  @override
  Eraser copy() => Eraser();

  @override
  Map<String, dynamic> toContentJson() {
    return <String, dynamic>{
      'path': drawPath.toJson(),
      'paint': paint.toJson(),
    };
  }
}

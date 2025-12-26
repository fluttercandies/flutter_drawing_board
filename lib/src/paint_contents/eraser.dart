import 'package:flutter/material.dart';
import '../draw_path/draw_path.dart';
import '../paint_extension/ex_paint.dart';

import 'paint_content.dart';

/// 橡皮擦绘制内容
///
/// 使用BlendMode.clear混合模式实现擦除效果
/// 擦除路径会叠加在底层内容上，产生透明擦除效果
///
/// Eraser Drawing Content
///
/// Uses BlendMode.clear blend mode to achieve erasing effect
/// Eraser path is overlaid on the base content to produce transparent erasing effect
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
  ///
  /// Eraser path
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

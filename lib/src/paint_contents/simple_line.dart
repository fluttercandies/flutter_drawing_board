import 'package:flutter/painting.dart';

import 'paint_content.dart';

/// 普通自由线条
class SimpleLine extends PaintContent {
  SimpleLine();

  /// 绘制路径
  Path path = Path();

  @override
  void startDraw(Offset startPoint) =>
      path.moveTo(startPoint.dx, startPoint.dy);

  @override
  void drawing(Offset nowPoint) => path.lineTo(nowPoint.dx, nowPoint.dy);

  @override
  void draw(Canvas canvas, Size size, bool deeper) =>
      canvas.drawPath(path, paint);

  @override
  SimpleLine copy() => SimpleLine();
}

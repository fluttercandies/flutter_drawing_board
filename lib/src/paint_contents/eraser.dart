import 'package:flutter/painting.dart';
import 'package:flutter_drawing_board/src/helper/ex_paint.dart';

import 'paint_content.dart';

/// 橡皮
class Eraser extends PaintContent {
  Eraser({this.color = const Color(0xff000000)});

  /// 擦除路径
  Path path = Path();
  final Color color;

  @override
  void startDraw(Offset startPoint) {
    path.moveTo(startPoint.dx, startPoint.dy);
  }

  @override
  void drawing(Offset nowPoint) => path.lineTo(nowPoint.dx, nowPoint.dy);

  @override
  void draw(Canvas canvas, Size size, bool deeper) {
    if (deeper)
      canvas.drawPath(path, paint.copyWith(blendMode: BlendMode.clear));
    else
      canvas.drawPath(path, paint.copyWith(color: color));
  }

  @override
  Eraser copy() => Eraser(color: color);
}

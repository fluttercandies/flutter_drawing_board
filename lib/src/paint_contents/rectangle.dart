import 'package:flutter/painting.dart';

import 'paint_content.dart';

/// 矩形
class Rectangle extends PaintContent {
  Rectangle({
    required this.startPoint,
    required this.endPoint,
    required Paint paint,
  }) : super(type: PaintType.rectangle, paint: paint);

  /// 起始点
  Offset startPoint;

  /// 结束点
  Offset endPoint;
}

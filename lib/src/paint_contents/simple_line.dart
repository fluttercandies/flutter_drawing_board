import 'package:flutter/painting.dart';

import 'paint_content.dart';

/// 普通自由线条
class SimpleLine extends PaintContent {
  SimpleLine({
    required this.path,
    required Paint paint,
  }) : super(type: PaintType.simpleLine, paint: paint);

  /// 绘制路径
  Path path;
}

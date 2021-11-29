import 'package:flutter/painting.dart';

import 'paint_content.dart';

/// 橡皮
class Eraser extends PaintContent {
  Eraser({
    required this.path,
    required Paint paint,
  }) : super(type: PaintType.eraser, paint: paint);

  /// 擦除路径
  Path path;
}

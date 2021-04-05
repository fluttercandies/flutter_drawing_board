import 'package:flutter/painting.dart';

import 'paint_content.dart';

///普通自由线条
class SimpleLine extends PaintContent {
  SimpleLine({
    this.path,
    Paint paint,
  }) : super(type: PaintType.simpleLine, paint: paint);

  Path path;
}

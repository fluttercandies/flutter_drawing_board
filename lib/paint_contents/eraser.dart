import 'package:flutter/painting.dart';

import 'paint_content.dart';

///橡皮
class Eraser extends PaintContent {
  Eraser({
    this.path,
    Paint? paint,
  }) : super(type: PaintType.eraser, paint: paint);

  Path? path;
}

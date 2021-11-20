import 'package:flutter/painting.dart';

import 'paint_content.dart';

///矩形
class Rectangle extends PaintContent {
  Rectangle({
    this.startPoint,
    this.endPoint,
    Paint? paint,
  }) : super(type: PaintType.rectangle, paint: paint);

  Offset? startPoint;
  Offset? endPoint;
}

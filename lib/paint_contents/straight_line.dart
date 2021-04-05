import 'package:flutter/painting.dart';

import 'paint_content.dart';

///直线
class StraightLine extends PaintContent {
  StraightLine({
    this.startPoint,
    this.endPoint,
    Paint paint,
  }) : super(type: PaintType.straightLine, paint: paint);

  Offset startPoint;
  Offset endPoint;
}

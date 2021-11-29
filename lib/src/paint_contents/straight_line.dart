import 'package:flutter/painting.dart';

import 'paint_content.dart';

/// 直线
class StraightLine extends PaintContent {
  StraightLine({
    required this.startPoint,
    required this.endPoint,
    required Paint paint,
  }) : super(type: PaintType.straightLine, paint: paint);

  Offset startPoint;
  Offset endPoint;
}

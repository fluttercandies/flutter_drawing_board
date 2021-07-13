import 'dart:ui';

import 'paint_content.dart';

///平滑线条
class SmoothLine extends PaintContent {
  SmoothLine({this.points, this.path, this.start, Paint? paint})
      : super(type: PaintType.smoothLine, paint: paint);

  final List<Offset?>? points;

  final Path? path;

  Offset? start;
}

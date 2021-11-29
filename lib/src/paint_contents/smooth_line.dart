import 'dart:ui';

import 'paint_content.dart';

/// 笔触线条
class SmoothLine extends PaintContent {
  SmoothLine({
    required this.points,
    required this.strokeWidthList,
    required Paint paint,
  }) : super(type: PaintType.smoothLine, paint: paint);

  /// 绘制点列表
  final List<Offset> points;

  /// 点之间的绘制线条权重列表
  List<double> strokeWidthList;
}

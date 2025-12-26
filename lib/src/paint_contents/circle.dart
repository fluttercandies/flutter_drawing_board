import 'package:flutter/painting.dart';
import '../paint_extension/ex_offset.dart';
import '../paint_extension/ex_paint.dart';

import 'paint_content.dart';

/// 圆形/椭圆绘制内容
///
/// 支持两种绘制模式：
/// 1. 从圆心开始绘制：起点为圆心，终点决定半径
/// 2. 从对角开始绘制：起点和终点为对角，自动计算圆心和半径
///
/// Circle/Ellipse Drawing Content
///
/// Supports two drawing modes:
/// 1. Draw from center: start point is center, end point determines radius
/// 2. Draw from diagonal: start and end points are diagonal, automatically calculates center and radius
class Circle extends PaintContent {
  Circle({
    /// 是否绘制椭圆（false为圆形）
    ///
    /// Whether to draw ellipse (false for circle)
    this.isEllipse = false,

    /// 是否从圆心开始绘制
    ///
    /// Whether to start drawing from center
    this.startFromCenter = true,
  });

  Circle.data({
    this.isEllipse = false,
    this.startFromCenter = true,
    required this.center,
    required this.radius,
    required this.startPoint,
    required this.endPoint,
    required Paint paint,
  }) : super.paint(paint);

  factory Circle.fromJson(Map<String, dynamic> data) {
    return Circle.data(
      isEllipse: data['isEllipse'] as bool,
      startFromCenter: data['startFromCenter'] as bool,
      center: jsonToOffset(data['center'] as Map<String, dynamic>),
      radius: data['radius'] as double,
      startPoint: jsonToOffset(data['startPoint'] as Map<String, dynamic>),
      endPoint: jsonToOffset(data['endPoint'] as Map<String, dynamic>),
      paint: jsonToPaint(data['paint'] as Map<String, dynamic>),
    );
  }

  /// 是否为椭圆
  ///
  /// Whether it's an ellipse
  final bool isEllipse;

  /// 是否从圆心开始绘制
  ///
  /// Whether to start drawing from center
  final bool startFromCenter;

  /// 圆心坐标
  ///
  /// Center point coordinates
  Offset center = Offset.zero;

  /// 半径
  ///
  /// Radius
  double radius = 0;

  /// 起始点坐标
  ///
  /// Start point coordinates
  Offset startPoint = Offset.zero;

  /// 结束点坐标
  ///
  /// End point coordinates
  Offset endPoint = Offset.zero;

  @override
  String get contentType => 'Circle';

  @override
  void startDraw(Offset startPoint) {
    this.startPoint = startPoint;
    center = startPoint;
  }

  @override
  void drawing(Offset nowPoint) {
    endPoint = nowPoint;
    center = Offset((startPoint.dx + endPoint.dx) / 2, (startPoint.dy + endPoint.dy) / 2);
    radius = (endPoint - (startFromCenter ? startPoint : center)).distance;
  }

  @override
  void draw(Canvas canvas, Size size, bool deeper) {
    if (isEllipse) {
      canvas.drawOval(Rect.fromPoints(startPoint, endPoint), paint);
    } else {
      canvas.drawCircle(startFromCenter ? startPoint : center, radius, paint);
    }
  }

  @override
  Circle copy() => Circle(isEllipse: isEllipse);

  @override
  Map<String, dynamic> toContentJson() {
    return <String, dynamic>{
      'isEllipse': isEllipse,
      'startFromCenter': startFromCenter,
      'center': center.toJson(),
      'radius': radius,
      'startPoint': startPoint.toJson(),
      'endPoint': endPoint.toJson(),
      'paint': paint.toJson(),
    };
  }
}

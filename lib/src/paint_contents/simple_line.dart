import 'package:flutter/painting.dart';

import '../draw_path/draw_path.dart';
import '../paint_extension/ex_offset.dart';
import '../paint_extension/ex_paint.dart';
import 'paint_content.dart';

/// 自由线条绘制内容
///
/// 支持两种绘制模式：
/// 1. 传统路径模式：直接连接绘制点
/// 2. 贝塞尔曲线模式：使用二次贝塞尔曲线平滑连接，提供更流畅的线条效果
///
/// Simple Line Drawing Content
///
/// Supports two drawing modes:
/// 1. Traditional path mode: directly connects drawing points
/// 2. Bezier curve mode: uses quadratic bezier curves for smooth connection, providing smoother line effects
class SimpleLine extends PaintContent {
  SimpleLine({
    /// 最小点距离，用于过滤过近的点，减少数据量
    ///
    /// Minimum point distance for filtering points that are too close, reducing data volume
    this.minPointDistance = 2.0,

    /// 是否使用贝塞尔曲线平滑，默认 true
    /// 设置为 true 可以解决快速绘制时的折线感问题
    ///
    /// Whether to use bezier curve smoothing, default true
    /// Setting to true resolves the jagged line issue when drawing quickly
    this.useBezierCurve = true,
  });

  SimpleLine.data({
    this.minPointDistance = 2.0,
    this.useBezierCurve = false,
    this.points,
    DrawPath? path,
    required Paint paint,
  })  : path = path ?? DrawPath(),
        super.paint(paint);

  factory SimpleLine.fromJson(Map<String, dynamic> data) {
    // 兼容旧版本：如果有 points 就用新方式，否则用旧方式
    final bool hasPoints = data.containsKey('points');

    if (hasPoints) {
      return SimpleLine.data(
        minPointDistance: (data['minPointDistance'] ?? 2.0) as double,
        useBezierCurve: (data['useBezierCurve'] ?? false) as bool,
        points: (data['points'] as List<dynamic>)
            .map((dynamic e) => jsonToOffset(e as Map<String, dynamic>))
            .toList(),
        paint: jsonToPaint(data['paint'] as Map<String, dynamic>),
      );
    } else {
      // 旧版本兼容
      return SimpleLine.data(
        minPointDistance: (data['minPointDistance'] ?? 2.0) as double,
        path: DrawPath.fromJson(data['path'] as Map<String, dynamic>),
        paint: jsonToPaint(data['paint'] as Map<String, dynamic>),
      );
    }
  }

  /// 最小点距离
  ///
  /// Minimum point distance
  final double minPointDistance;

  /// 是否使用贝塞尔曲线
  ///
  /// Whether to use bezier curve
  final bool useBezierCurve;

  /// 绘制路径（为了向后兼容保留，用于传统路径模式）
  ///
  /// Drawing path (retained for backward compatibility, used in traditional path mode)
  DrawPath path = DrawPath();

  /// 绘制点列表（用于贝塞尔曲线模式）
  ///
  /// Drawing points list (used in bezier curve mode)
  List<Offset>? points;

  /// 上一个点的位置，用于点过滤优化
  ///
  /// Last point position for point filtering optimization
  Offset? _lastPoint;

  @override
  String get contentType => 'SimpleLine';

  @override
  void startDraw(Offset startPoint) {
    _lastPoint = startPoint;

    if (useBezierCurve) {
      // 使用点列表模式
      points = <Offset>[startPoint];
    } else {
      // 使用传统路径模式
      path.moveTo(startPoint.dx, startPoint.dy);
    }
  }

  @override
  void drawing(Offset nowPoint) {
    // 点过滤优化：跳过距离过近的点
    if (_lastPoint != null) {
      final double distance = (nowPoint - _lastPoint!).distance;

      // 如果距离小于最小点距离，跳过此点
      if (distance < minPointDistance) {
        return;
      }
    }

    if (useBezierCurve) {
      // 添加到点列表
      points?.add(nowPoint);
    } else {
      // 添加到路径
      path.lineTo(nowPoint.dx, nowPoint.dy);
    }

    _lastPoint = nowPoint;
  }

  @override
  void draw(Canvas canvas, Size size, bool deeper) {
    if (useBezierCurve && points != null && points!.isNotEmpty) {
      // 使用贝塞尔曲线绘制
      _drawWithBezierCurve(canvas);
    } else {
      // 使用传统路径绘制
      canvas.drawPath(path.path, paint);
    }
  }

  /// 使用贝塞尔曲线绘制平滑线条
  ///
  /// Draw smooth lines using bezier curves
  void _drawWithBezierCurve(Canvas canvas) {
    if (points == null || points!.isEmpty) {
      return;
    }

    if (points!.length == 1) {
      // 单点绘制为小圆点
      canvas.drawCircle(points![0], paint.strokeWidth / 8, paint);
      return;
    }

    final Path bezierPath = Path();
    bezierPath.moveTo(points![0].dx, points![0].dy);

    if (points!.length == 2) {
      // 两点直接连线
      bezierPath.lineTo(points![1].dx, points![1].dy);
    } else {
      // 使用二次贝塞尔曲线连接点
      for (int i = 1; i < points!.length - 1; i++) {
        final Offset p0 = points![i];
        final Offset p1 = points![i + 1];

        // 计算中点作为终点
        final Offset midPoint = Offset(
          (p0.dx + p1.dx) / 2,
          (p0.dy + p1.dy) / 2,
        );

        // 使用当前点作为控制点，中点作为终点
        bezierPath.quadraticBezierTo(p0.dx, p0.dy, midPoint.dx, midPoint.dy);
      }

      // 绘制最后一段 - 使用贝塞尔曲线避免折角
      final Offset lastPoint = points!.last;
      final Offset secondLastPoint = points![points!.length - 2];

      bezierPath.quadraticBezierTo(
        secondLastPoint.dx,
        secondLastPoint.dy,
        lastPoint.dx,
        lastPoint.dy,
      );
    }

    canvas.drawPath(bezierPath, paint);
  }

  @override
  SimpleLine copy() => SimpleLine(
        minPointDistance: minPointDistance,
        useBezierCurve: useBezierCurve,
      );

  @override
  Map<String, dynamic> toContentJson() {
    if (useBezierCurve && points != null) {
      // 新格式：保存点列表
      return <String, dynamic>{
        'minPointDistance': minPointDistance,
        'useBezierCurve': useBezierCurve,
        'points': points!.map((Offset e) => e.toJson()).toList(),
        'paint': paint.toJson(),
      };
    } else {
      // 旧格式：保存路径（向后兼容）
      return <String, dynamic>{
        'minPointDistance': minPointDistance,
        'useBezierCurve': useBezierCurve,
        'path': path.toJson(),
        'paint': paint.toJson(),
      };
    }
  }
}

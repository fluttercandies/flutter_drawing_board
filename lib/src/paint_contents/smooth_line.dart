import 'dart:ui';
import '../paint_extension/ex_offset.dart';
import '../paint_extension/ex_paint.dart';
import 'paint_content.dart';

/// 笔触线条
class SmoothLine extends PaintContent {
  SmoothLine({
    /// 绘制影响因子，值越小线条越平滑，粗细变化越慢
    this.brushPrecision = 0.4,

    /// 最小点距离，用于过滤过近的点，减少数据量
    /// 值越大，点越少，性能越好，但可能丢失细节
    this.minPointDistance = 2.0,

    /// 是否使用贝塞尔曲线平滑，默认 true
    this.useBezierCurve = true,

    /// 平滑级别，值越大越平滑，但计算成本越高
    /// 0: 无额外平滑 (快速)
    /// 1: 基础平滑 (推荐，默认)
    /// 2: 高级平滑 (解决快速绘制折线感)
    this.smoothLevel = 1,
  });

  SmoothLine.data({
    this.brushPrecision = 0.4,
    this.minPointDistance = 2.0,
    this.useBezierCurve = true,
    this.smoothLevel = 1,
    required this.points,
    required this.strokeWidthList,
    required Paint paint,
  }) : super.paint(paint);

  factory SmoothLine.fromJson(Map<String, dynamic> data) {
    return SmoothLine.data(
      brushPrecision: (data['brushPrecision'] ?? 0.4) as double,
      minPointDistance: (data['minPointDistance'] ?? 2.0) as double,
      useBezierCurve: (data['useBezierCurve'] ?? true) as bool,
      smoothLevel: (data['smoothLevel'] ?? 1) as int,
      points: (data['points'] as List<dynamic>)
          .map((dynamic e) => jsonToOffset(e as Map<String, dynamic>))
          .toList(),
      strokeWidthList:
          (data['strokeWidthList'] as List<dynamic>).map((dynamic e) => e as double).toList(),
      paint: jsonToPaint(data['paint'] as Map<String, dynamic>),
    );
  }

  final double brushPrecision;
  final double minPointDistance;
  final bool useBezierCurve;
  final int smoothLevel;

  /// 绘制点列表
  late List<Offset> points;

  /// 点之间的绘制线条权重列表
  late List<double> strokeWidthList;

  @override
  String get contentType => 'SmoothLine';

  @override
  void startDraw(Offset startPoint) {
    points = <Offset>[startPoint];
    strokeWidthList = <double>[paint.strokeWidth];
  }

  @override
  void drawing(Offset nowPoint) {
    // 点过滤优化：跳过距离过近的点
    if (points.isNotEmpty) {
      final double distance = (nowPoint - points.last).distance;

      // 如果距离小于最小点距离，跳过此点
      if (distance < minPointDistance) {
        return;
      }
    }

    final double distance = (nowPoint - points.last).distance;

    //原始画笔线条线宽
    final double s = paint.strokeWidth;

    double strokeWidth = s * (s * 2 / (s * distance));

    if (strokeWidth > s * 2) {
      strokeWidth = s * 2;
    }

    //上一个线宽
    final double preWidth = strokeWidthList.last;

    if (strokeWidth - preWidth > brushPrecision) {
      strokeWidth = preWidth + brushPrecision;
    } else if (preWidth - strokeWidth > brushPrecision) {
      strokeWidth = preWidth - brushPrecision;
    }

    //记录点位
    points.add(nowPoint);
    strokeWidthList.add(strokeWidth);
  }

  @override
  void draw(Canvas canvas, Size size, bool deeper) {
    if (points.isEmpty) {
      return;
    }

    if (points.length == 1) {
      // 单点绘制
      canvas.drawCircle(points[0], strokeWidthList[0] / 2, paint);
      return;
    }

    if (useBezierCurve && points.length > 2) {
      // 使用贝塞尔曲线绘制平滑线条
      _drawWithBezierCurve(canvas);
    } else {
      // 使用原始的直线绘制
      _drawWithStraightLines(canvas);
    }
  }

  /// 使用贝塞尔曲线绘制平滑线条
  void _drawWithBezierCurve(Canvas canvas) {
    if (smoothLevel >= 2) {
      // 高级平滑：使用插值点和改进的贝塞尔曲线
      _drawWithAdvancedSmoothing(canvas);
    } else {
      // 基础平滑：使用标准二次贝塞尔曲线
      _drawWithStandardBezier(canvas);
    }
  }

  /// 标准贝塞尔曲线绘制
  void _drawWithStandardBezier(Canvas canvas) {
    // 分段绘制，每段使用对应的笔触宽度
    Offset currentPoint = points[0];

    for (int i = 1; i < points.length - 1; i++) {
      final Offset p0 = points[i];
      final Offset p1 = points[i + 1];

      // 计算中点作为终点
      final Offset midPoint = Offset(
        (p0.dx + p1.dx) / 2,
        (p0.dy + p1.dy) / 2,
      );

      // 创建这一段的路径
      final Path segmentPath = Path();
      segmentPath.moveTo(currentPoint.dx, currentPoint.dy);
      segmentPath.quadraticBezierTo(p0.dx, p0.dy, midPoint.dx, midPoint.dy);

      // 使用对应的笔触宽度绘制
      final double width = strokeWidthList[i];
      canvas.drawPath(segmentPath, paint.copyWith(strokeWidth: width));

      currentPoint = midPoint;
    }

    // 绘制最后一段 - 使用贝塞尔曲线而不是直线
    if (points.length > 1) {
      final Offset lastPoint = points.last;
      final Offset secondLastPoint = points[points.length - 2];

      final Path lastSegment = Path();
      lastSegment.moveTo(currentPoint.dx, currentPoint.dy);
      lastSegment.quadraticBezierTo(
        secondLastPoint.dx,
        secondLastPoint.dy,
        lastPoint.dx,
        lastPoint.dy,
      );

      // 使用最后一段的宽度
      final double lastWidth = strokeWidthList.last;
      canvas.drawPath(lastSegment, paint.copyWith(strokeWidth: lastWidth));
    }
  }

  /// 高级平滑绘制 - 解决快速绘制折线感
  void _drawWithAdvancedSmoothing(Canvas canvas) {
    if (points.length < 3) {
      _drawWithStandardBezier(canvas);
      return;
    }

    // 使用 Catmull-Rom 样条插值生成更多中间点
    final List<Offset> interpolatedPoints = _interpolatePoints();
    final List<double> interpolatedWidths = _interpolateWidths();

    // 分段绘制，每段使用对应的笔触宽度
    Offset currentPoint = interpolatedPoints[0];

    for (int i = 1; i < interpolatedPoints.length - 1; i++) {
      final Offset p0 = interpolatedPoints[i];
      final Offset p1 = interpolatedPoints[i + 1];

      // 计算中点作为终点
      final Offset midPoint = Offset(
        (p0.dx + p1.dx) / 2,
        (p0.dy + p1.dy) / 2,
      );

      // 创建这一段的路径
      final Path segmentPath = Path();
      segmentPath.moveTo(currentPoint.dx, currentPoint.dy);
      segmentPath.quadraticBezierTo(p0.dx, p0.dy, midPoint.dx, midPoint.dy);

      // 使用对应的笔触宽度绘制
      final double width = interpolatedWidths[i];
      canvas.drawPath(segmentPath, paint.copyWith(strokeWidth: width));

      currentPoint = midPoint;
    }

    // 绘制最后一段
    if (interpolatedPoints.length > 1) {
      final Offset lastPoint = interpolatedPoints.last;
      final Offset secondLastPoint = interpolatedPoints[interpolatedPoints.length - 2];

      final Path lastSegment = Path();
      lastSegment.moveTo(currentPoint.dx, currentPoint.dy);
      lastSegment.quadraticBezierTo(
        secondLastPoint.dx,
        secondLastPoint.dy,
        lastPoint.dx,
        lastPoint.dy,
      );

      // 使用最后一段的宽度
      final double lastWidth = interpolatedWidths.last;
      canvas.drawPath(lastSegment, paint.copyWith(strokeWidth: lastWidth));
    }
  }

  /// 使用 Catmull-Rom 样条插值生成中间点
  List<Offset> _interpolatePoints() {
    final List<Offset> result = <Offset>[];

    // 每两个点之间插入 2 个中间点
    const int interpolationSteps = 2;

    for (int i = 0; i < points.length - 1; i++) {
      result.add(points[i]);

      // 获取四个控制点用于 Catmull-Rom 插值
      final Offset p0 = i > 0 ? points[i - 1] : points[i];
      final Offset p1 = points[i];
      final Offset p2 = points[i + 1];
      final Offset p3 = i + 2 < points.length ? points[i + 2] : points[i + 1];

      // 在 p1 和 p2 之间插值
      for (int step = 1; step <= interpolationSteps; step++) {
        final double t = step / (interpolationSteps + 1);
        final Offset interpolated = _catmullRomInterpolate(p0, p1, p2, p3, t);
        result.add(interpolated);
      }
    }

    // 添加最后一个点
    result.add(points.last);

    return result;
  }

  /// 插值笔触宽度，与插值点对应
  List<double> _interpolateWidths() {
    final List<double> result = <double>[];

    // 每两个点之间插入 2 个中间宽度
    const int interpolationSteps = 2;

    for (int i = 0; i < strokeWidthList.length - 1; i++) {
      result.add(strokeWidthList[i]);

      final double w1 = strokeWidthList[i];
      final double w2 = strokeWidthList[i + 1];

      // 在两个宽度之间线性插值
      for (int step = 1; step <= interpolationSteps; step++) {
        final double t = step / (interpolationSteps + 1);
        final double interpolatedWidth = w1 + (w2 - w1) * t;
        result.add(interpolatedWidth);
      }
    }

    // 添加最后一个宽度
    result.add(strokeWidthList.last);

    return result;
  }

  /// Catmull-Rom 样条插值
  /// 生成经过 p1 和 p2 的平滑曲线，p0 和 p3 作为控制点
  Offset _catmullRomInterpolate(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final double t2 = t * t;
    final double t3 = t2 * t;

    // Catmull-Rom 公式
    final double x = 0.5 *
        ((2 * p1.dx) +
            (-p0.dx + p2.dx) * t +
            (2 * p0.dx - 5 * p1.dx + 4 * p2.dx - p3.dx) * t2 +
            (-p0.dx + 3 * p1.dx - 3 * p2.dx + p3.dx) * t3);

    final double y = 0.5 *
        ((2 * p1.dy) +
            (-p0.dy + p2.dy) * t +
            (2 * p0.dy - 5 * p1.dy + 4 * p2.dy - p3.dy) * t2 +
            (-p0.dy + 3 * p1.dy - 3 * p2.dy + p3.dy) * t3);

    return Offset(x, y);
  }

  /// 使用直线绘制（原始方法）
  void _drawWithStraightLines(Canvas canvas) {
    for (int i = 1; i < points.length; i++) {
      canvas.drawPath(
        Path()
          ..moveTo(points[i - 1].dx, points[i - 1].dy)
          ..lineTo(points[i].dx, points[i].dy),
        paint.copyWith(strokeWidth: strokeWidthList[i], blendMode: BlendMode.src),
      );
    }
  }

  @override
  SmoothLine copy() => SmoothLine(
        brushPrecision: brushPrecision,
        minPointDistance: minPointDistance,
        useBezierCurve: useBezierCurve,
        smoothLevel: smoothLevel,
      );

  @override
  Map<String, dynamic> toContentJson() {
    return <String, dynamic>{
      'brushPrecision': brushPrecision,
      'minPointDistance': minPointDistance,
      'useBezierCurve': useBezierCurve,
      'smoothLevel': smoothLevel,
      'points': points.map((Offset e) => e.toJson()).toList(),
      'strokeWidthList': strokeWidthList,
      'paint': paint.toJson(),
    };
  }
}

import 'package:flutter/material.dart';

import 'steps/arc_to.dart';
import 'steps/arc_to_point.dart';
import 'steps/conic_to.dart';
import 'steps/cubic_to.dart';
import 'steps/line_to.dart';
import 'steps/move_to.dart';
import 'steps/operation_step.dart';
import 'steps/path_close.dart';
import 'steps/path_shift.dart';
import 'steps/quadratic_bezier_to.dart';
import 'steps/relative_arc_to_point.dart';
import 'steps/relative_conic_to.dart';
import 'steps/relative_cubic_to.dart';
import 'steps/relative_line_to.dart';
import 'steps/relative_move_to.dart';
import 'steps/relative_quadratic_bezier_to.dart';

class DrawPath {
  DrawPath({
    List<OperationStep>? steps,
    PathFillType? type,
    Path? path,
  })  : path = path ?? Path(),
        steps = steps ?? <OperationStep>[] {
    if (type != null) {
      this.path.fillType = type;
    }
  }

  factory DrawPath.fromJson(
    Map<String, dynamic> data, {
    OperationStep Function(
            String type, Map<String, dynamic> jsonStepMap, Path genPath)?
        stepFactory,
  }) {
    final List<OperationStep> steps = <OperationStep>[];

    final List<dynamic> jsonSteps = data['steps'] as List<dynamic>;

    final Path genPath = Path();

    for (final dynamic jsonStep in jsonSteps) {
      final Map<String, dynamic> jsonStepMap = jsonStep as Map<String, dynamic>;

      final String type = jsonStepMap['type'] as String;

      switch (type) {
        case 'arcTo':
          final ArcTo arcTo = ArcTo.fromJson(jsonStepMap);
          steps.add(arcTo);
          genPath.arcTo(arcTo.rect, arcTo.startAngle, arcTo.sweepAngle,
              arcTo.forceMoveTo);
          break;
        case 'arcToPoint':
          // steps.add(ArcToPoint.fromJson(jsonStepMap));
          final ArcToPoint arcToPoint = ArcToPoint.fromJson(jsonStepMap);
          steps.add(arcToPoint);
          genPath.arcToPoint(
            arcToPoint.arcEnd,
            radius: arcToPoint.radius,
            rotation: arcToPoint.rotation,
            largeArc: arcToPoint.largeArc,
            clockwise: arcToPoint.clockwise,
          );
          break;
        case 'conicTo':
          // steps.add(ConicTo.fromJson(jsonStepMap));
          final ConicTo conicTo = ConicTo.fromJson(jsonStepMap);
          steps.add(conicTo);
          genPath.conicTo(
              conicTo.x1, conicTo.y1, conicTo.x2, conicTo.y2, conicTo.w);
          break;
        case 'cubicTo':
          // steps.add(CubicTo.fromJson(jsonStepMap));
          final CubicTo cubicTo = CubicTo.fromJson(jsonStepMap);
          steps.add(cubicTo);
          genPath.cubicTo(cubicTo.x1, cubicTo.y1, cubicTo.x2, cubicTo.y2,
              cubicTo.x3, cubicTo.y3);
          break;
        case 'lineTo':
          // steps.add(LineTo.fromJson(jsonStepMap));
          final LineTo lineTo = LineTo.fromJson(jsonStepMap);
          steps.add(lineTo);
          genPath.lineTo(lineTo.x, lineTo.y);
          break;
        case 'moveTo':
          // steps.add(MoveTo.fromJson(jsonStepMap));
          final MoveTo moveTo = MoveTo.fromJson(jsonStepMap);
          steps.add(moveTo);
          genPath.moveTo(moveTo.x, moveTo.y);
          break;
        case 'close':
          // steps.add(PathClose.fromJson(jsonStepMap));
          final PathClose pathClose = PathClose.fromJson(jsonStepMap);
          steps.add(pathClose);
          genPath.close();
          break;
        case 'shift':
          // steps.add(PathShift.fromJson(jsonStepMap));
          final PathShift pathShift = PathShift.fromJson(jsonStepMap);
          steps.add(pathShift);
          genPath.shift(pathShift.offset);
          break;
        case 'quadraticBezierTo':
          // steps.add(QuadraticBezierTo.fromJson(jsonStepMap));
          final QuadraticBezierTo quadraticBezierTo =
              QuadraticBezierTo.fromJson(jsonStepMap);
          steps.add(quadraticBezierTo);
          genPath.quadraticBezierTo(
            quadraticBezierTo.x1,
            quadraticBezierTo.y1,
            quadraticBezierTo.x2,
            quadraticBezierTo.y2,
          );
          break;
        case 'relativeArcToPoint':
          // steps.add(RelativeArcToPoint.fromJson(jsonStepMap));
          final RelativeArcToPoint relativeArcToPoint =
              RelativeArcToPoint.fromJson(jsonStepMap);
          steps.add(relativeArcToPoint);
          genPath.relativeArcToPoint(
            relativeArcToPoint.arcEndDelta,
            radius: relativeArcToPoint.radius,
            rotation: relativeArcToPoint.rotation,
            largeArc: relativeArcToPoint.largeArc,
            clockwise: relativeArcToPoint.clockwise,
          );
          break;
        case 'relativeConicTo':
          // steps.add(RelativeConicTo.fromJson(jsonStepMap));
          final RelativeConicTo relativeConicTo =
              RelativeConicTo.fromJson(jsonStepMap);
          steps.add(relativeConicTo);
          genPath.relativeConicTo(
            relativeConicTo.x1,
            relativeConicTo.y1,
            relativeConicTo.x2,
            relativeConicTo.y2,
            relativeConicTo.w,
          );
          break;
        case 'relativeCubicTo':
          // steps.add(RelativeCubicTo.fromJson(jsonStepMap));
          final RelativeCubicTo relativeCubicTo =
              RelativeCubicTo.fromJson(jsonStepMap);
          steps.add(relativeCubicTo);
          genPath.relativeCubicTo(
            relativeCubicTo.x1,
            relativeCubicTo.y1,
            relativeCubicTo.x2,
            relativeCubicTo.y2,
            relativeCubicTo.x3,
            relativeCubicTo.y3,
          );
          break;
        case 'relativeLineTo':
          // steps.add(RelativeLineTo.fromJson(jsonStepMap));
          final RelativeLineTo relativeLineTo =
              RelativeLineTo.fromJson(jsonStepMap);
          steps.add(relativeLineTo);
          genPath.relativeLineTo(relativeLineTo.dx, relativeLineTo.dy);
          break;
        case 'relativeMoveTo':
          // steps.add(RelativeMoveTo.fromJson(jsonStepMap));
          final RelativeMoveTo relativeMoveTo =
              RelativeMoveTo.fromJson(jsonStepMap);
          steps.add(relativeMoveTo);
          genPath.relativeMoveTo(relativeMoveTo.dx, relativeMoveTo.dy);
          break;
        case 'relativeQuadraticBezierTo':
          // steps.add(RelativeQuadraticBezierTo.fromJson(jsonStepMap));
          final RelativeQuadraticBezierTo relativeQuadraticBezierTo =
              RelativeQuadraticBezierTo.fromJson(jsonStepMap);
          steps.add(relativeQuadraticBezierTo);
          genPath.relativeQuadraticBezierTo(
            relativeQuadraticBezierTo.x1,
            relativeQuadraticBezierTo.y1,
            relativeQuadraticBezierTo.x2,
            relativeQuadraticBezierTo.y2,
          );
          break;
        default:
          final OperationStep? step =
              stepFactory?.call(type, jsonStepMap, genPath);
          if (step != null) {
            steps.add(step);
          } else {
            throw Exception('Unknown operation step type: $type');
          }
      }
    }

    return DrawPath(
      steps: steps,
      type: data['fillType'] == null
          ? null
          : PathFillType.values[data['fillType'] as int],
      path: genPath,
    );
  }

  final List<OperationStep> steps;
  final Path path;

  void moveTo(double x, double y) {
    steps.add(MoveTo(x, y));
    path.moveTo(x, y);
  }

  void arcTo(
      Rect rect, double startAngle, double sweepAngle, bool forceMoveTo) {
    steps.add(ArcTo(
      rect: rect,
      startAngle: startAngle,
      sweepAngle: sweepAngle,
      forceMoveTo: forceMoveTo,
    ));

    path.arcTo(rect, startAngle, sweepAngle, forceMoveTo);
  }

  void arcToPoint(
    Offset arcEnd, {
    Radius radius = Radius.zero,
    double rotation = 0.0,
    bool largeArc = false,
    bool clockwise = true,
  }) {
    steps.add(ArcToPoint(arcEnd, radius, rotation, largeArc, clockwise));
    path.arcToPoint(
      arcEnd,
      radius: radius,
      rotation: rotation,
      largeArc: largeArc,
      clockwise: clockwise,
    );
  }

  void conicTo(double x1, double y1, double x2, double y2, double w) {
    steps.add(ConicTo(x1, y1, x2, y2, w));
    path.conicTo(x1, y1, x2, y2, w);
  }

  void cubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    steps.add(CubicTo(x1, y1, x2, y2, x3, y3));
    path.cubicTo(x1, y1, x2, y2, x3, y3);
  }

  void lineTo(double x, double y) {
    steps.add(LineTo(x, y));
    path.lineTo(x, y);
  }

  void quadraticBezierTo(double x1, double y1, double x2, double y2) {
    steps.add(QuadraticBezierTo(x1, y1, x2, y2));
    path.quadraticBezierTo(x1, y1, x2, y2);
  }

  void relativeArcToPoint(
    Offset arcEndDelta, {
    Radius radius = Radius.zero,
    double rotation = 0.0,
    bool largeArc = false,
    bool clockwise = true,
  }) {
    steps.add(
        RelativeArcToPoint(arcEndDelta, radius, rotation, largeArc, clockwise));
    path.relativeArcToPoint(
      arcEndDelta,
      radius: radius,
      rotation: rotation,
      largeArc: largeArc,
      clockwise: clockwise,
    );
  }

  void relativeConicTo(double x1, double y1, double x2, double y2, double w) {
    steps.add(RelativeConicTo(x1, y1, x2, y2, w));
    path.relativeConicTo(x1, y1, x2, y2, w);
  }

  void relativeCubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    steps.add(RelativeCubicTo(x1, y1, x2, y2, x3, y3));
    path.relativeCubicTo(x1, y1, x2, y2, x3, y3);
  }

  void relativeLineTo(double dx, double dy) {
    steps.add(RelativeLineTo(dx, dy));
    path.relativeLineTo(dx, dy);
  }

  void relativeQuadraticBezierTo(double x1, double y1, double x2, double y2) {
    steps.add(RelativeQuadraticBezierTo(x1, y1, x2, y2));
    path.relativeQuadraticBezierTo(x1, y1, x2, y2);
  }

  void relativeMoveTo(double dx, double dy) {
    steps.add(RelativeMoveTo(dx, dy));
    path.relativeMoveTo(dx, dy);
  }

  Path shift(Offset offset) {
    steps.add(PathShift(offset));
    return path.shift(offset);
  }

  void close() {
    steps.add(PathClose());
    path.close();
  }

  void reset() {
    steps.clear();
    path.reset();
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fillType': path.fillType.index,
      'steps': steps.map((OperationStep step) => step.toJson()).toList(),
    };
  }
}

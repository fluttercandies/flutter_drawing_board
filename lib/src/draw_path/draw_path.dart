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
  }) : steps = steps ?? <OperationStep>[] {
    if (type != null) {
      path.fillType = type;
    }
  }

  factory DrawPath.fromJson(
    Map<String, dynamic> data, {
    OperationStep Function(String type, Map<String, dynamic> jsonStepMap)?
        stepFactory,
  }) {
    final List<OperationStep> steps = <OperationStep>[];

    final List<dynamic> jsonSteps = data['steps'] as List<dynamic>;

    for (final dynamic jsonStep in jsonSteps) {
      final Map<String, dynamic> jsonStepMap = jsonStep as Map<String, dynamic>;

      final String type = jsonStepMap['type'] as String;

      switch (type) {
        case 'arcTo':
          steps.add(ArcTo.fromJson(jsonStepMap));
          break;
        case 'arcToPoint':
          steps.add(ArcToPoint.fromJson(jsonStepMap));
          break;
        case 'conicTo':
          steps.add(ConicTo.fromJson(jsonStepMap));
          break;
        case 'cubicTo':
          steps.add(CubicTo.fromJson(jsonStepMap));
          break;
        case 'lineTo':
          steps.add(LineTo.fromJson(jsonStepMap));
          break;
        case 'moveTo':
          steps.add(MoveTo.fromJson(jsonStepMap));
          break;
        case 'close':
          steps.add(PathClose.fromJson(jsonStepMap));
          break;
        case 'shift':
          steps.add(PathShift.fromJson(jsonStepMap));
          break;
        case 'quadraticBezierTo':
          steps.add(QuadraticBezierTo.fromJson(jsonStepMap));
          break;
        case 'relativeArcToPoint':
          steps.add(RelativeArcToPoint.fromJson(jsonStepMap));
          break;
        case 'relativeConicTo':
          steps.add(RelativeConicTo.fromJson(jsonStepMap));
          break;
        case 'relativeCubicTo':
          steps.add(RelativeCubicTo.fromJson(jsonStepMap));
          break;
        case 'relativeLineTo':
          steps.add(RelativeLineTo.fromJson(jsonStepMap));
          break;
        case 'relativeMoveTo':
          steps.add(RelativeMoveTo.fromJson(jsonStepMap));
          break;
        case 'relativeQuadraticBezierTo':
          steps.add(RelativeQuadraticBezierTo.fromJson(jsonStepMap));
          break;
        default:
          final OperationStep? step = stepFactory?.call(type, jsonStepMap);
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
    );
  }

  final List<OperationStep> steps;
  final Path path = Path();

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

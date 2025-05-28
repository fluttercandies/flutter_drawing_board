import 'dart:ui';

import '../../paint_extension/ex_rect.dart';

import 'operation_step.dart';

class ArcTo extends OperationStep {
  ArcTo({
    required this.rect,
    required this.startAngle,
    required this.sweepAngle,
    required this.forceMoveTo,
  });

  factory ArcTo.fromJson(Map<String, dynamic> data) {
    return ArcTo(
      rect: jsonToRect(data['rect'] as Map<String, dynamic>),
      startAngle: (data['startAngle'] as num).toDouble(),
      sweepAngle: (data['sweepAngle'] as num).toDouble(),
      forceMoveTo: data['forceMoveTo'] as bool,
    );
  }

  final Rect rect;
  final double startAngle;
  final double sweepAngle;
  final bool forceMoveTo;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': 'arcTo',
      'rect': rect.toJson(),
      'startAngle': startAngle,
      'sweepAngle': sweepAngle,
      'forceMoveTo': forceMoveTo,
    };
  }
}

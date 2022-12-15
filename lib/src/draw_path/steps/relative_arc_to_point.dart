import 'dart:ui';

import 'package:flutter_drawing_board/src/paint_extension/ex_offset.dart';
import 'package:flutter_drawing_board/src/paint_extension/ex_radius.dart';

import 'operation_step.dart';

class RelativeArcToPoint extends OperationStep {
  RelativeArcToPoint(
    this.arcEndDelta,
    this.radius,
    this.rotation,
    this.largeArc,
    this.clockwise,
  );

  factory RelativeArcToPoint.fromJson(Map<String, dynamic> data) {
    return RelativeArcToPoint(
      jsonToOffset(data['arcEndDelta'] as Map<String, dynamic>),
      jsonToRadius(data['radius'] as Map<String, dynamic>),
      data['rotation'] as double,
      data['largeArc'] as bool,
      data['clockwise'] as bool,
    );
  }

  final Offset arcEndDelta;
  final Radius radius;
  final double rotation;
  final bool largeArc;
  final bool clockwise;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': 'relativeArcToPoint',
      'arcEndDelta': arcEndDelta.toJson(),
      'radius': radius.toJson(),
      'rotation': rotation,
      'largeArc': largeArc,
      'clockwise': clockwise,
    };
  }
}

import 'dart:ui';

import 'package:flutter_drawing_board/src/paint_extension/ex_offset.dart';
import 'package:flutter_drawing_board/src/paint_extension/ex_radius.dart';

import 'operation_step.dart';

class ArcToPoint extends OperationStep {
  ArcToPoint(
    this.arcEnd,
    this.radius,
    this.rotation,
    this.largeArc,
    this.clockwise,
  );

  factory ArcToPoint.fromJson(Map<String, dynamic> data) {
    return ArcToPoint(
      jsonToOffset(data['arcEnd'] as Map<String, dynamic>),
      jsonToRadius(data['radius'] as Map<String, dynamic>),
      data['rotation'] as double,
      data['largeArc'] as bool,
      data['clockwise'] as bool,
    );
  }

  final Offset arcEnd;
  final Radius radius;
  final double rotation;
  final bool largeArc;
  final bool clockwise;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': 'arcToPoint',
      'arcEnd': arcEnd.toJson(),
      'radius': radius.toJson(),
      'rotation': rotation,
      'largeArc': largeArc,
      'clockwise': clockwise,
    };
  }
}

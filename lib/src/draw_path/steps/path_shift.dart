import 'dart:ui';

import 'package:flutter_drawing_board/src/paint_extension/ex_offset.dart';

import 'operation_step.dart';

class PathShift extends OperationStep {
  PathShift(this.offset);

  factory PathShift.fromJson(Map<String, dynamic> data) {
    return PathShift(jsonToOffset(data['offset'] as Map<String, dynamic>));
  }

  final Offset offset;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': 'shift',
      'offset': offset.toJson(),
    };
  }
}

import 'package:flutter/painting.dart';
import '../paint_extension/ex_offset.dart';
import '../paint_extension/ex_paint.dart';

import 'paint_content.dart';

/// Wrong (X) shape
class Wrong extends PaintContent {
  Wrong();

  Wrong.data({
    required this.startPoint,
    required this.endPoint,
    required Paint paint,
  }) : super.paint(paint);

  factory Wrong.fromJson(Map<String, dynamic> data) {
    return Wrong.data(
      startPoint: jsonToOffset(data['startPoint'] as Map<String, dynamic>),
      endPoint: jsonToOffset(data['endPoint'] as Map<String, dynamic>),
      paint: jsonToPaint(data['paint'] as Map<String, dynamic>),
    );
  }

  /// Start of the "X"
  Offset? startPoint;

  /// End of the "X"
  Offset? endPoint;

  @override
  String get contentType => 'Wrong';

  @override
  void startDraw(Offset startPoint) => this.startPoint = startPoint;

  @override
  void drawing(Offset nowPoint) => endPoint = nowPoint;

  @override
  void draw(Canvas canvas, Size size, bool deeper) {
    if (startPoint == null || endPoint == null) {
      return;
    }

    final Offset topLeft = startPoint!;
    final Offset bottomRight = endPoint!;
    final Offset topRight = Offset(bottomRight.dx, topLeft.dy);
    final Offset bottomLeft = Offset(topLeft.dx, bottomRight.dy);

    canvas.drawLine(topLeft, bottomRight, paint);
    canvas.drawLine(topRight, bottomLeft, paint);
  }

  @override
  Wrong copy() => Wrong();

  @override
  Map<String, dynamic> toContentJson() {
    return <String, dynamic>{
      'startPoint': startPoint?.toJson(),
      'endPoint': endPoint?.toJson(),
      'paint': paint.toJson(),
    };
  }
}

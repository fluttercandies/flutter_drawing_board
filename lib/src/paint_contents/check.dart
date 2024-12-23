import 'package:flutter/painting.dart';
import '../paint_extension/ex_offset.dart';
import '../paint_extension/ex_paint.dart';

import 'paint_content.dart';

/// Tick (check) shape based on rectangular boundary
class Check extends PaintContent {
  Check();

  Check.data({
    required this.startPoint,
    required this.endPoint,
    required Paint paint,
  }) : super.paint(paint);

  factory Check.fromJson(Map<String, dynamic> data) {
    return Check.data(
      startPoint: jsonToOffset(data['startPoint'] as Map<String, dynamic>),
      endPoint: jsonToOffset(data['endPoint'] as Map<String, dynamic>),
      paint: jsonToPaint(data['paint'] as Map<String, dynamic>),
    );
  }

  /// Start and end points for the rectangle
  Offset? startPoint;
  Offset? endPoint;

  @override
  String get contentType => 'Check';

  @override
  void startDraw(Offset startPoint) {
    this.startPoint = startPoint;
  }

  @override
  void drawing(Offset nowPoint) {
    endPoint = nowPoint;
  }

  @override
  void draw(Canvas canvas, Size size, bool deeper) {
    if (startPoint == null || endPoint == null) {
      return;
    }

    // Define the rectangular bounds
    final Rect rect = Rect.fromPoints(startPoint!, endPoint!);

    // Calculate the corners of the rectangle
    final Offset topLeft = rect.topLeft;
    final Offset topRight = rect.topRight;
    final Offset bottomLeft = rect.bottomLeft;
    final Offset bottomRight = rect.bottomRight;
    final Offset middleLeft = Offset(
      bottomLeft.dx,
      (topLeft.dy + bottomLeft.dy) / 2,
    );
    final Offset middleRight = Offset(
      bottomRight.dx,
      (topRight.dy + bottomRight.dy) / 2,
    );
    final Offset middleTheMiddleLeft = Offset(
      bottomLeft.dx,
      (middleLeft.dy + bottomLeft.dy) / 2,
    );
    final Offset middleBottom = Offset(
      (bottomLeft.dx + bottomRight.dx) / 2,
      bottomRight.dy,
    );
    final Offset middleTheMiddleBottom = Offset(
      (middleBottom.dx + bottomLeft.dx) / 2,
      middleBottom.dy,
    );

    /// Draw the two diagonal lines to form the checkmark
    /// First diagonal line (middle-the-middle-left-side to middle-the-middle-bottom-side)
    canvas.drawLine(
      middleTheMiddleLeft,
      middleTheMiddleBottom,
      paint,
    );
    /// Second diagonal line (middle-the-middle-bottom-side to middle-right-side)
    canvas.drawLine(
      middleTheMiddleBottom,
      middleRight,
      paint,
    ); 
  }

  @override
  Check copy() => Check();

  @override
  Map<String, dynamic> toContentJson() {
    return <String, dynamic>{
      'startPoint': startPoint?.toJson(),
      'endPoint': endPoint?.toJson(),
      'paint': paint.toJson(),
    };
  }
}

import 'operation_step.dart';

class CubicTo extends OperationStep {
  CubicTo(this.x1, this.y1, this.x2, this.y2, this.x3, this.y3);

  factory CubicTo.fromJson(Map<String, dynamic> data) {
    return CubicTo(
      (data['x1'] as num).toDouble(),
      (data['y1'] as num).toDouble(),
      (data['x2'] as num).toDouble(),
      (data['y2'] as num).toDouble(),
      (data['x3'] as num).toDouble(),
      (data['y3'] as num).toDouble(),
    );
  }

  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final double x3;
  final double y3;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': 'cubicTo',
      'x1': x1,
      'y1': y1,
      'x2': x2,
      'y2': y2,
      'x3': x3,
      'y3': y3,
    };
  }
}

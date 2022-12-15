import 'operation_step.dart';

class QuadraticBezierTo extends OperationStep {
  QuadraticBezierTo(this.x1, this.y1, this.x2, this.y2);

  factory QuadraticBezierTo.fromJson(Map<String, dynamic> data) {
    return QuadraticBezierTo(
      data['x1'] as double,
      data['y1'] as double,
      data['x2'] as double,
      data['y2'] as double,
    );
  }

  final double x1;
  final double y1;
  final double x2;
  final double y2;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': 'quadraticBezierTo',
      'x1': x1,
      'y1': y1,
      'x2': x2,
      'y2': y2,
    };
  }
}

import 'operation_step.dart';

class MoveTo extends OperationStep {
  const MoveTo(this.x, this.y);

  factory MoveTo.fromJson(Map<String, dynamic> data) {
    return MoveTo(
      (data['x'] as num).toDouble(),
      (data['y'] as num).toDouble(),
    );
  }

  final double x;
  final double y;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': 'moveTo',
      'x': x,
      'y': y,
    };
  }
}

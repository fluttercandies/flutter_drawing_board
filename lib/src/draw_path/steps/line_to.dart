import 'operation_step.dart';

class LineTo extends OperationStep {
  LineTo(this.x, this.y);

  factory LineTo.fromJson(Map<String, dynamic> data) {
    return LineTo(
      data['x'] as double,
      data['y'] as double,
    );
  }

  final double x;
  final double y;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': 'lineTo',
      'x': x,
      'y': y,
    };
  }
}

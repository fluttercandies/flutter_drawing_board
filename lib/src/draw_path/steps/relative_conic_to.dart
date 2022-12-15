import 'operation_step.dart';

class RelativeConicTo extends OperationStep {
  RelativeConicTo(this.x1, this.y1, this.x2, this.y2, this.w);

  factory RelativeConicTo.fromJson(Map<String, dynamic> data) {
    return RelativeConicTo(
      data['x1'] as double,
      data['y1'] as double,
      data['x2'] as double,
      data['y2'] as double,
      data['w'] as double,
    );
  }

  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final double w;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': 'relativeConicTo',
      'x1': x1,
      'y1': y1,
      'x2': x2,
      'y2': y2,
      'w': w,
    };
  }
}

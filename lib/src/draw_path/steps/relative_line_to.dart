import 'operation_step.dart';

class RelativeLineTo extends OperationStep {
  RelativeLineTo(this.dx, this.dy);

  factory RelativeLineTo.fromJson(Map<String, dynamic> data) {
    return RelativeLineTo(
      (data['dx'] as num).toDouble(),
      (data['dy'] as num).toDouble(),
    );
  }

  final double dx;
  final double dy;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': 'relativeLineTo',
      'dx': dx,
      'dy': dy,
    };
  }
}

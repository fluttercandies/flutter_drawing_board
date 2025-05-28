import 'operation_step.dart';

class RelativeMoveTo extends OperationStep {
  RelativeMoveTo(this.dx, this.dy);

  factory RelativeMoveTo.fromJson(Map<String, dynamic> data) {
    return RelativeMoveTo(
      (data['dx'] as num).toDouble(),
      (data['dy'] as num).toDouble(),
    );
  }

  final double dx;
  final double dy;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': 'relativeMoveTo',
      'dx': dx,
      'dy': dy,
    };
  }
}

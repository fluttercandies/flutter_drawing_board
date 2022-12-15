// path.close();

import 'operation_step.dart';

class PathClose extends OperationStep {
  PathClose();

  factory PathClose.fromJson(Map<String, dynamic> _) {
    return PathClose();
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'type': 'close'};
  }
}

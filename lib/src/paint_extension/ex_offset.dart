import 'package:flutter/material.dart';

extension ExOffset on Offset {
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'dx': dx, 'dy': dy};
  }
}

Offset jsonToOffset(Map<String, dynamic> data) {
  return Offset(
    (data['dx'] as num).toDouble(),
    (data['dy'] as num).toDouble(),
  );
}

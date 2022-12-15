import 'dart:ui';

extension ExRadius on Radius {
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'x': x,
      'y': y,
    };
  }
}

Radius jsonToRadius(Map<String, dynamic> data) {
  return Radius.elliptical(
    data['x'] as double,
    data['y'] as double,
  );
}

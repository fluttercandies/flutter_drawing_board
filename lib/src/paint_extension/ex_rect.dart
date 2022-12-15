import 'dart:ui';

extension ExRect on Rect {
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'left': left,
      'top': top,
      'right': right,
      'bottom': bottom,
    };
  }
}

Rect jsonToRect(Map<String, dynamic> data) {
  return Rect.fromLTRB(
    data['left'] as double,
    data['top'] as double,
    data['right'] as double,
    data['bottom'] as double,
  );
}

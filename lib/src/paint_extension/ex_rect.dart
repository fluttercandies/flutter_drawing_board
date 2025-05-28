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
    (data['left'] as num).toDouble(),
    (data['top'] as num).toDouble(),
    (data['right'] as num).toDouble(),
    (data['bottom'] as num).toDouble(),
  );
}

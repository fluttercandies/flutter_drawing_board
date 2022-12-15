import 'dart:ui';

import 'ex_color_filter.dart';
import 'ex_image_filter.dart';
import 'ex_mask_filter.dart';

/// 为`Paint`扩展`copyWith`
extension ExPaint on Paint {
  Paint copyWith({
    BlendMode? blendMode,
    Color? color,
    ColorFilter? colorFilter,
    FilterQuality? filterQuality,
    ImageFilter? imageFilter,
    bool? invertColors,
    bool? isAntiAlias,
    MaskFilter? maskFilter,
    Shader? shader,
    StrokeCap? strokeCap,
    StrokeJoin? strokeJoin,
    double? strokeWidth,
    PaintingStyle? style,
  }) {
    return Paint()
      ..blendMode = blendMode ?? this.blendMode
      ..color = color ?? this.color
      ..colorFilter = colorFilter ?? this.colorFilter
      ..filterQuality = filterQuality ?? this.filterQuality
      ..imageFilter = imageFilter ?? this.imageFilter
      ..invertColors = invertColors ?? this.invertColors
      ..isAntiAlias = isAntiAlias ?? this.isAntiAlias
      ..maskFilter = maskFilter ?? this.maskFilter
      ..shader = shader ?? this.shader
      ..strokeCap = strokeCap ?? this.strokeCap
      ..strokeJoin = strokeJoin ?? this.strokeJoin
      ..strokeWidth = strokeWidth ?? this.strokeWidth
      ..style = style ?? this.style;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'blendMode': blendMode.index,
      'color': color.value,
      if (colorFilter != null) 'colorFilter': colorFilter?.toString(),
      'filterQuality': filterQuality.index,
      if (imageFilter != null) 'imageFilter': imageFilter?.toString(),
      'invertColors': invertColors,
      'isAntiAlias': isAntiAlias,
      if (maskFilter != null) 'maskFilter': maskFilter?.toString(),
      // if (shader != null) 'shader': shader?.toString(), // 无法解析
      'strokeCap': strokeCap.index,
      'strokeJoin': strokeJoin.index,
      'strokeWidth': strokeWidth,
      'style': style.index,
    };
  }
}

Paint jsonToPaint(Map<String, dynamic> data) {
  return Paint()
    ..blendMode = BlendMode.values[data['blendMode'] as int]
    ..color = Color(data['color'] as int)
    ..colorFilter = data['colorFilter'] == null
        ? null
        : stringToColorFilter(data['colorFilter'] as String)
    ..filterQuality = FilterQuality.values[data['filterQuality'] as int]
    ..imageFilter = data['imageFilter'] == null
        ? null
        : stringToImageFilter(data['imageFilter'] as String)
    ..invertColors = data['invertColors'] as bool
    ..isAntiAlias = data['isAntiAlias'] as bool
    ..maskFilter = data['maskFilter'] == null
        ? null
        : stringToMaskFilter(data['maskFilter'] as String)
    // ..shader = data['shader'] as Shader? // 无法解析
    ..strokeCap = StrokeCap.values[data['strokeCap'] as int]
    ..strokeJoin = StrokeJoin.values[data['strokeJoin'] as int]
    ..strokeWidth = data['strokeWidth'] as double
    ..style = PaintingStyle.values[data['style'] as int];
}

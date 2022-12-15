import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/src/helper/ex_enum.dart';

import 'ex_color.dart';

/*
  @override
  String toString() {
    switch (_type) {
      case _kTypeMode:
        return 'ColorFilter.mode($_color, $_blendMode)';
      case _kTypeMatrix:
        return 'ColorFilter.matrix($_matrix)';
      case _kTypeLinearToSrgbGamma:
        return 'ColorFilter.linearToSrgbGamma()';
      case _kTypeSrgbToLinearGamma:
        return 'ColorFilter.srgbToLinearGamma()';
      default:
        return 'Unknown ColorFilter type. This is an error. If you\'re seeing this, please file an issue at https://github.com/flutter/flutter/issues/new.';
    }
  }

*/

ColorFilter? stringToColorFilter(String data) {
  if (data == 'ColorFilter.linearToSrgbGamma()') {
    return const ColorFilter.linearToSrgbGamma();
  } else if (data == 'ColorFilter.srgbToLinearGamma()') {
    return const ColorFilter.srgbToLinearGamma();
  } else if (data.startsWith('ColorFilter.mode')) {
    final Color? color = stringToColor(data.split(',')[0].split('(')[1]);
    final String blendMode = data.split(',')[1].trim().split(')')[0];
    final BlendMode? mode =
        ExEnum.tryParse<BlendMode>(BlendMode.values, blendMode);

    if (color != null && mode != null) return ColorFilter.mode(color, mode);

    return null;
  } else if (data.startsWith('ColorFilter.matrix')) {
    final String matrix = data.split('(')[1].split(')')[0];

    final List<double> matrixList =
        matrix.split(',').map((String e) => double.parse(e)).toList();

    return ColorFilter.matrix(matrixList);
  }

  return null;
}

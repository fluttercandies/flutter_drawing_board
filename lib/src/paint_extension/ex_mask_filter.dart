/*
  final BlurStyle _style;
  final double _sigma;

  @override
  String toString() => 'MaskFilter.blur($_style, ${_sigma.toStringAsFixed(1)})';
*/

import 'dart:ui';

import 'package:flutter_drawing_board/src/helper/ex_enum.dart';

MaskFilter? stringToMaskFilter(String data) {
  final String style = data.substring(data.indexOf('('), data.indexOf(','));
  final BlurStyle? blurStyle =
      ExEnum.tryParse<BlurStyle>(BlurStyle.values, style);

  final double sigma =
      double.parse(data.substring(data.indexOf(',') + 1, data.indexOf(')')));

  return blurStyle != null ? MaskFilter.blur(blurStyle, sigma) : null;
}

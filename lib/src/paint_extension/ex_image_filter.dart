/*
  @override
  String toString() => 'ImageFilter.blur($sigmaX, $sigmaY, $_modeString)';
  @override
  String toString() => 'ImageFilter.dilate($radiusX, $radiusY)';
  @override
  String toString() => 'ImageFilter.erode($radiusX, $radiusY)';
  @override
  String toString() => 'ImageFilter.compose(source -> $_shortDescription -> result)';
  @override
  String toString() => 'ImageFilter.matrix($data, $filterQuality)';
*/

import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_drawing_board/src/helper/ex_enum.dart';

ImageFilter? stringToImageFilter(String data) {
  if (data.startsWith('ImageFilter.blur')) {
    final String sigmaX = data.split(',')[0].split('(')[1];
    final String sigmaY = data.split(',')[1];
    final String mode = data.split(',')[2].trim().split(')')[0];

    final ImageFilter filter = ImageFilter.blur(
      sigmaX: double.parse(sigmaX),
      sigmaY: double.parse(sigmaY),
      tileMode:
          ExEnum.tryParse<TileMode>(TileMode.values, mode) ?? TileMode.clamp,
    );

    return filter;
  } else if (data.startsWith('ImageFilter.dilate')) {
    final String radiusX = data.split(',')[0].split('(')[1];
    final String radiusY = data.split(',')[1].trim().split(')')[0];

    return ImageFilter.dilate(
      radiusX: double.parse(radiusX),
      radiusY: double.parse(radiusY),
    );
  } else if (data.startsWith('ImageFilter.erode')) {
    final String radiusX = data.split(',')[0].split('(')[1];
    final String radiusY = data.split(',')[1].trim().split(')')[0];

    return ImageFilter.erode(
      radiusX: double.parse(radiusX),
      radiusY: double.parse(radiusY),
    );
  } else if (data.startsWith('ImageFilter.compose')) {
    final String source = data.split('source -> ')[1].split(' -> result')[0];
    final String result = data.split(' -> result')[1].split(')')[0];

    final ImageFilter? sourceFilter = stringToImageFilter(source);
    final ImageFilter? resultFilter = stringToImageFilter(result);

    if (sourceFilter != null && resultFilter != null) {
      return ImageFilter.compose(
        outer: sourceFilter,
        inner: resultFilter,
      );
    }
  } else if (data.startsWith('ImageFilter.matrix')) {
    final String matrix = data.split('(')[1].split(')')[0];

    final List<double> matrixListData =
        matrix.split(',').map((String e) => double.parse(e)).toList();
    final Float64List matrixList = Float64List.fromList(matrixListData);

    final String filterQuality =
        data.split(')')[1].split(',')[1].trim().split(')')[0];

    return ImageFilter.matrix(
      matrixList,
      filterQuality:
          ExEnum.tryParse<FilterQuality>(FilterQuality.values, filterQuality) ??
              FilterQuality.low,
    );
  }

  return null;
}

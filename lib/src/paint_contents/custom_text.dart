import 'package:flutter/painting.dart';

import 'paint_content.dart';

///文本
class CustomText extends PaintContent {
  CustomText({
    this.startPoint,
    this.textPainter,
    Paint? paint,
    this.angle,
    this.text,
  }) : super(type: PaintType.text, paint: paint) {
    size = textPainter!.text!.style!.fontSize! * 1.2;
  }

  Offset? startPoint;
  Offset? endPoint;
  TextPainter? textPainter;
  int? angle;
  String? text;
  double? size;

  ///最大宽度
  double? get maxWidth {
    switch (angle) {
      case 0:
      case 2:
        return (startPoint!.dx - endPoint!.dx).abs();
      case 1:
      case 3:
        return (startPoint!.dy - endPoint!.dy).abs();
      default:
        return (startPoint!.dx - endPoint!.dx).abs();
    }
  }

  ///获取真实的开始点
  Offset? realStart(Size size) {
    switch (angle) {
      case 0:
        return startPoint;
      case 1:
        return Offset(size.height - startPoint!.dy, startPoint!.dx);
      case 2:
        return Offset(
            size.width - startPoint!.dx, size.height - startPoint!.dy);
      case 3:
        return Offset(startPoint!.dy, size.width - startPoint!.dx);
      default:
        return startPoint;
    }
  }

  ///获取真实的结束点
  Offset? realEnd(Size size) {
    switch (angle) {
      case 0:
        return endPoint;
      case 1:
        return Offset(size.height - endPoint!.dy, endPoint!.dx);
      case 2:
        return Offset(size.width - endPoint!.dx, size.height - endPoint!.dy);
      case 3:
        return Offset(endPoint!.dy, size.width - endPoint!.dx);
      default:
        return startPoint;
    }
  }
}

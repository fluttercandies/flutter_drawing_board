import 'package:flutter/painting.dart';

///绘制类型
/// * simpleLine 自由线条
/// * straightLine 直线
/// * rectangle 矩形
/// * text 文本
/// * smoothLine 平滑自由线条
enum PaintType { simpleLine, straightLine, rectangle, text, eraser, smoothLine }

///绘制对象
abstract class PaintContent {
  PaintContent({this.type, this.paint});
  PaintType? type;
  Paint? paint;
}

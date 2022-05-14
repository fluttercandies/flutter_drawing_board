import 'package:flutter/painting.dart';

/// 绘制对象
abstract class PaintContent {
  PaintContent({this.paint});

  /// 画笔
  Paint? paint;

  /// 复制实例，避免对象传递
  PaintContent copy();

  /// 绘制核心方法
  void draw(Canvas canvas, Size size);

  /// 正在绘制
  void drawing(Offset nowPoint);

  /// 开始绘制
  void startDraw(Offset startPoint);
}

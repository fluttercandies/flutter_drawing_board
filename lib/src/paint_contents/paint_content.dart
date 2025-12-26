import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

/// 绘制内容抽象基类
///
/// 所有绘制内容（线条、形状等）的基类
/// 定义了绘制的生命周期方法和序列化接口
///
/// Paint Content Abstract Base Class
///
/// Base class for all drawing content (lines, shapes, etc.)
/// Defines the lifecycle methods and serialization interface for drawing
abstract class PaintContent {
  PaintContent();

  PaintContent.paint(this.paint);

  /// 画笔配置
  ///
  /// Paint configuration for drawing
  late Paint paint;

  /// 复制实例，避免对象引用传递
  ///
  /// Copy instance to avoid object reference passing
  PaintContent copy();

  /// 绘制核心方法
  /// [canvas] 画布对象
  /// [size] 画布尺寸
  /// [deeper] 当前是否为底层绘制（true为历史记录层，false为实时绘制层）
  ///
  /// Core drawing method
  /// [canvas] Canvas object
  /// [size] Canvas size
  /// [deeper] Whether this is deep layer drawing (true for history layer, false for real-time layer)
  void draw(Canvas canvas, Size size, bool deeper);

  /// 绘制过程中调用（手指移动时）
  ///
  /// Called during drawing (when finger is moving)
  void drawing(Offset nowPoint);

  /// 开始绘制（手指按下时）
  ///
  /// Start drawing (when finger is pressed down)
  void startDraw(Offset startPoint);

  /// 转换为JSON内容（子类实现）
  ///
  /// Convert to JSON content (implemented by subclasses)
  Map<String, dynamic> toContentJson();

  /// 内容类型标识（用于JSON序列化）
  ///
  /// Content type identifier (for JSON serialization)
  String get contentType => runtimeType.toString();

  /// 转换为JSON对象
  ///
  /// Convert to JSON object
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': contentType,
      ...toContentJson(),
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

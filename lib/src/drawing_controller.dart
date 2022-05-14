import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'helper/safe_value_notifier.dart';
import 'paint_contents/paint_content.dart';
import 'paint_contents/simple_line.dart';

/// 绘制参数
class DrawConfig {
  DrawConfig({
    required this.paintContent,
    this.angle = 0,
    this.blendMode = BlendMode.srcOver,
    this.color = Colors.red,
    this.colorFilter,
    this.filterQuality = FilterQuality.high,
    this.imageFilter,
    this.invertColors = false,
    this.isAntiAlias = false,
    this.maskFilter,
    this.shader,
    this.strokeCap = StrokeCap.round,
    this.strokeJoin = StrokeJoin.round,
    this.strokeMiterLimit = 4,
    this.strokeWidth = 4,
    this.style = PaintingStyle.stroke,
  });

  DrawConfig.def({
    required this.paintContent,
    this.angle = 0,
    this.blendMode = BlendMode.srcOver,
    this.color = Colors.red,
    this.colorFilter,
    this.filterQuality = FilterQuality.high,
    this.imageFilter,
    this.invertColors = false,
    this.isAntiAlias = false,
    this.maskFilter,
    this.shader,
    this.strokeCap = StrokeCap.round,
    this.strokeJoin = StrokeJoin.round,
    this.strokeMiterLimit = 4,
    this.strokeWidth = 4,
    this.style = PaintingStyle.stroke,
  });

  /// 旋转的角度（0:0,1:90,2:180,3:270）
  final int angle;

  /// 最后一次绘制的内容
  final PaintContent paintContent;

  /// Paint相关
  final BlendMode blendMode;
  final Color color;
  final ColorFilter? colorFilter;
  final FilterQuality filterQuality;
  final ui.ImageFilter? imageFilter;
  final bool invertColors;
  final bool isAntiAlias;
  final MaskFilter? maskFilter;
  final Shader? shader;
  final StrokeCap strokeCap;
  final StrokeJoin strokeJoin;
  final double strokeMiterLimit;
  final double strokeWidth;
  final PaintingStyle style;

  PaintContent get getPaintContent => paintContent;

  /// 生成paint
  Paint get paint => Paint()
    ..blendMode = blendMode
    ..color = color
    ..colorFilter = colorFilter
    ..filterQuality = filterQuality
    ..imageFilter = imageFilter
    ..invertColors = invertColors
    ..isAntiAlias = isAntiAlias
    ..maskFilter = maskFilter
    ..shader = shader
    ..strokeCap = strokeCap
    ..strokeJoin = strokeJoin
    ..strokeMiterLimit = strokeMiterLimit
    ..strokeWidth = strokeWidth
    ..style = style;

  DrawConfig copyWith({
    BlendMode? blendMode,
    Color? color,
    ColorFilter? colorFilter,
    FilterQuality? filterQuality,
    ui.ImageFilter? imageFilter,
    bool? invertColors,
    bool? isAntiAlias,
    MaskFilter? maskFilter,
    Shader? shader,
    StrokeCap? strokeCap,
    StrokeJoin? strokeJoin,
    double? strokeMiterLimit,
    double? strokeWidth,
    PaintingStyle? style,
    PaintContent? paintContent,
    int? angle,
  }) {
    return DrawConfig(
      paintContent: paintContent ?? this.paintContent,
      angle: angle ?? this.angle,
      blendMode: blendMode ?? this.blendMode,
      color: color ?? this.color,
      colorFilter: colorFilter ?? this.colorFilter,
      filterQuality: filterQuality ?? this.filterQuality,
      imageFilter: imageFilter ?? this.imageFilter,
      invertColors: invertColors ?? this.invertColors,
      isAntiAlias: isAntiAlias ?? this.isAntiAlias,
      maskFilter: maskFilter ?? this.maskFilter,
      shader: shader ?? this.shader,
      strokeCap: strokeCap ?? this.strokeCap,
      strokeJoin: strokeJoin ?? this.strokeJoin,
      strokeMiterLimit: strokeMiterLimit ?? this.strokeMiterLimit,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      style: style ?? this.style,
    );
  }
}

/// 绘制控制器
class DrawingController {
  DrawingController({DrawConfig? config}) {
    _history = <PaintContent>[];
    _currentIndex = 0;
    _brushPrecision = 0.4;
    realPainter = _RePaint();
    painter = _RePaint();
    drawConfig = SafeValueNotifier<DrawConfig>(config ?? DrawConfig.def(paintContent: SimpleLine()));
  }

  /// 画板数据Key
  late GlobalKey painterKey = GlobalKey();

  /// 控制器
  late SafeValueNotifier<DrawConfig> drawConfig;

  /// 表层绘制内容
  PaintContent? currentContent;

  /// 底层绘制内容(绘制记录)
  late List<PaintContent> _history;

  /// 笔触精度
  late double _brushPrecision;

  /// * 设置笔触精度
  /// * 此值仅对`smoothLine`生效
  /// * 此值越小，精度越高，笔触越平滑
  set setBrushPrecision(double value) => _brushPrecision = value;

  /// 获取当前笔触精度
  double get getBrushPrecision => _brushPrecision;

  /// 获取绘制图层/历史
  List<PaintContent> get getHistory => _history;

  /// 步骤指针
  late int _currentIndex;

  /// 表层画布刷新控制
  _RePaint? painter;

  /// 底层画布刷新控制
  _RePaint? realPainter;

  /// 获取当前步骤索引
  int get currentIndex => _currentIndex;

  /// 获取当前颜色
  Color get getColor => drawConfig.value.color;

  /// 设置绘制颜色
  set setColor(Color color) {
    if (color != drawConfig.value.color) {
      drawConfig.value = drawConfig.value.copyWith(color: color);
      currentContent = drawConfig.value.getPaintContent;
    }
  }

  /// 获取线条粗细
  double? get getThickness => currentContent?.paint?.strokeWidth;

  ///设置线条粗细
  set setThickness(double thickness) {
    if (thickness != drawConfig.value.strokeWidth) {
      drawConfig.value = drawConfig.value.copyWith(strokeWidth: thickness);
      currentContent = drawConfig.value.getPaintContent;
    }
  }

  /// 设置绘制内容
  set setPaintContent(PaintContent content) {
    content.paint ??= drawConfig.value.paint;
    drawConfig.value = drawConfig.value.copyWith(paintContent: content);
  }

  /// * 旋转画布
  /// * 设置角度
  void turn() {
    drawConfig.value = drawConfig.value.copyWith(angle: (drawConfig.value.angle + 1) % 4);
  }

  /// 开始绘制
  void startDraw(Offset startPoint) {
    currentContent = drawConfig.value.getPaintContent.copy();
    currentContent?.startDraw(startPoint);
  }

  /// 正在绘制
  void drawing(Offset nowPaint) {
    currentContent?.drawing(nowPaint);
    _refresh();
  }

  /// 结束绘制
  void endDraw() {
    final int hisLen = _history.length;

    if (hisLen > _currentIndex) {
      _history.removeRange(_currentIndex, hisLen);
    }

    if (currentContent != null) {
      _history.add(currentContent!);
      _currentIndex = _history.length;
      currentContent = null;
    }

    _refresh();
    _refreshDeep();
  }

  /// 撤销
  void undo() {
    if (_currentIndex > 0) {
      _currentIndex = _currentIndex - 1;
      _refreshDeep();
    }
  }

  /// 重做
  void redo() {
    if (_currentIndex < _history.length) {
      _currentIndex = _currentIndex + 1;
      _refreshDeep();
    }
  }

  /// 清理画布
  void clear() {
    _history.clear();
    _currentIndex = 0;
    _refreshDeep();
  }

  /// 获取图片数据
  Future<ByteData?> getImageData() async {
    try {
      final RenderRepaintBoundary boundary = painterKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: ui.window.devicePixelRatio);
      return await image.toByteData(format: ui.ImageByteFormat.png);
    } catch (e) {
      print('获取图片数据出错:$e');
      return null;
    }
  }

  /// 刷新表层画板
  void _refresh() {
    painter?._refresh();
  }

  /// 刷新底层画板
  void _refreshDeep() {
    realPainter?._refresh();
  }

  /// 销毁控制器
  void dispose() {
    drawConfig.dispose();
    realPainter?.dispose();
    painter?.dispose();
  }
}

/// 画布刷新控制器
class _RePaint extends ChangeNotifier {
  void _refresh() {
    notifyListeners();
  }
}

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
    required this.contentType,
    this.angle = 0,
    this.fingerCount = 0,
    this.size,
    this.blendMode = BlendMode.srcOver,
    this.color = Colors.black,
    this.colorFilter,
    this.filterQuality = FilterQuality.high,
    this.imageFilter,
    this.invertColors = false,
    this.isAntiAlias = false,
    this.maskFilter,
    this.shader,
    this.strokeCap = StrokeCap.round,
    this.strokeJoin = StrokeJoin.round,
    this.strokeWidth = 4,
    this.style = PaintingStyle.stroke,
  });

  DrawConfig.def({
    required this.contentType,
    this.angle = 0,
    this.fingerCount = 0,
    this.size,
    this.blendMode = BlendMode.srcOver,

    /// màu cọ
    this.color = Colors.black,
    this.colorFilter,
    this.filterQuality = FilterQuality.high,
    this.imageFilter,
    this.invertColors = false,
    this.isAntiAlias = false,
    this.maskFilter,
    this.shader,
    this.strokeCap = StrokeCap.round,
    this.strokeJoin = StrokeJoin.round,

    /// kích thước cọ
    this.strokeWidth = 4,
    this.style = PaintingStyle.stroke,
  });

  /// 旋转的角度（0:0,1:90,2:180,3:270）
  final int angle;

  final Type contentType;

  final int fingerCount;

  final Size? size;

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
  final double strokeWidth;
  final PaintingStyle style;

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
    ..strokeWidth = strokeWidth
    ..style = style;

  DrawConfig copyWith({
    Type? contentType,
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
    double? strokeWidth,
    PaintingStyle? style,
    int? angle,
    int? fingerCount,
    Size? size,
  }) {
    return DrawConfig(
      contentType: contentType ?? this.contentType,
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
      strokeWidth: strokeWidth ?? this.strokeWidth,
      style: style ?? this.style,
      fingerCount: fingerCount ?? this.fingerCount,
      size: size ?? this.size,
    );
  }
}

/// 绘制控制器
class DrawingController {
  DrawingController({
    DrawConfig? config,
    PaintContent? content,
  }) {
    _history = <PaintContent>[];
    _currentIndex = 0;
    realPainter = RePaintNotifier();
    painter = RePaintNotifier();
    drawConfig = SafeValueNotifier<DrawConfig>(
        config ?? DrawConfig.def(contentType: SimpleLine));
    setPaintContent(content ?? SimpleLine());
  }

  /// 绘制开始点
  Offset? _startPoint;

  /// 画板数据Key
  late GlobalKey painterKey = GlobalKey();

  /// 控制器
  late SafeValueNotifier<DrawConfig> drawConfig;

  /// 最后一次绘制的内容
  late PaintContent _paintContent;

  /// 当前绘制内容
  PaintContent? currentContent;

  /// 底层绘制内容(绘制记录)
  late List<PaintContent> _history;

  /// 当前controller是否存在
  bool _mounted = true;

  /// 获取绘制图层/历史
  List<PaintContent> get getHistory => _history;

  /// 步骤指针
  late int _currentIndex;

  /// 表层画布刷新控制
  RePaintNotifier? painter;

  /// 底层画布刷新控制
  RePaintNotifier? realPainter;

  /// 获取当前步骤索引
  int get currentIndex => _currentIndex;

  /// 获取当前颜色
  Color get getColor => drawConfig.value.color;

  /// 能否进行绘制
  bool get couldDraw => drawConfig.value.fingerCount <= 1;

  /// 能否开始进行绘制
  bool couldStart(int count) => drawConfig.value.fingerCount + count <= 1;

  /// 开始绘制点
  Offset? get startPoint => _startPoint;

  /// 设置画板大小
  void setBoardSize(Size? size) {
    drawConfig.value = drawConfig.value.copyWith(size: size);
  }

  /// 手指落下
  void addFingerCount(Offset offset) {
    drawConfig.value = drawConfig.value
        .copyWith(fingerCount: drawConfig.value.fingerCount + 1);
  }

  /// 手指抬起
  void reduceFingerCount(Offset offset) {
    drawConfig.value = drawConfig.value
        .copyWith(fingerCount: drawConfig.value.fingerCount - 1);
  }

  /// 设置绘制样式
  void setStyle({
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
  }) {
    drawConfig.value = drawConfig.value.copyWith(
      blendMode: blendMode,
      color: color,
      colorFilter: colorFilter,
      filterQuality: filterQuality,
      imageFilter: imageFilter,
      invertColors: invertColors,
      isAntiAlias: isAntiAlias,
      maskFilter: maskFilter,
      shader: shader,
      strokeCap: strokeCap,
      strokeJoin: strokeJoin,
      strokeWidth: strokeWidth,
      style: style,
    );
  }

  /// 设置绘制内容
  void setPaintContent(PaintContent content) {
    content.paint = drawConfig.value.paint;
    _paintContent = content;
    drawConfig.value =
        drawConfig.value.copyWith(contentType: content.runtimeType);
  }

  /// 添加一条绘制数据
  void addContent(PaintContent content) {
    _history.add(content);
    _currentIndex++;
    _refreshDeep();
  }

  /// 添加多条数据
  void addContents(List<PaintContent> contents) {
    _history.addAll(contents);
    _currentIndex += contents.length;
    _refreshDeep();
  }

  /// * 旋转画布
  /// * 设置角度
  void turn() {
    drawConfig.value =
        drawConfig.value.copyWith(angle: (drawConfig.value.angle + 1) % 4);
  }

  /// 开始绘制
  void startDraw(Offset startPoint) {
    _startPoint = startPoint;
    currentContent = _paintContent.copy();
    currentContent?.paint = drawConfig.value.paint;
    currentContent?.startDraw(startPoint);
  }

  /// 取消绘制
  void cancelDraw() {
    _startPoint = null;
    currentContent = null;
  }

  /// 正在绘制
  void drawing(Offset nowPaint) {
    currentContent?.drawing(nowPaint);
    _refresh();
  }

  /// 结束绘制
  void endDraw() {
    _startPoint = null;
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
      final RenderRepaintBoundary boundary = painterKey.currentContext!
          .findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(
          pixelRatio: View.of(painterKey.currentContext!).devicePixelRatio);
      return await image.toByteData(format: ui.ImageByteFormat.png);
    } catch (e) {
      debugPrint('获取图片数据出错:$e');
      return null;
    }
  }

  /// 获取画板内容Json
  List<Map<String, dynamic>> getJsonList() {
    return _history.map((PaintContent e) => e.toJson()).toList();
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
    if (!_mounted) {
      return;
    }

    drawConfig.dispose();
    realPainter?.dispose();
    painter?.dispose();

    _mounted = false;
  }
}

/// 画布刷新控制器
class RePaintNotifier extends ChangeNotifier {
  void _refresh() {
    notifyListeners();
  }
}

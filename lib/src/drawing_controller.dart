import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'helper/safe_value_notifier.dart';
import 'paint_contents/eraser.dart';
import 'paint_contents/paint_content.dart';
import 'paint_contents/simple_line.dart';
import 'paint_extension/ex_paint.dart';

/// 绘制参数
class DrawConfig {
  DrawConfig({
    required this.contentType,
    this.angle = 0,
    this.fingerCount = 0,
    this.size,
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
    this.strokeWidth = 4,
    this.style = PaintingStyle.stroke,
  });

  DrawConfig.def({
    required this.contentType,
    this.angle = 0,
    this.fingerCount = 0,
    this.size,
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
class DrawingController extends ChangeNotifier {
  DrawingController({
    DrawConfig? config,
    PaintContent? content,
    this.maxHistorySteps = 100,
  }) {
    _history = <PaintContent>[];
    _currentIndex = 0;
    realPainter = RePaintNotifier();
    painter = RePaintNotifier();
    drawConfig = SafeValueNotifier<DrawConfig>(config ?? DrawConfig.def(contentType: SimpleLine));
    setPaintContent(content ?? SimpleLine());
  }

  /// 历史记录最大步数，防止内存无限增长
  /// 默认 100 步，可根据需求调整
  final int maxHistorySteps;

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

  /// 橡皮擦内容
  PaintContent? eraserContent;

  /// 缓存的图片数据
  ui.Image? cachedImage;

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

  /// 是否绘制了有效内容
  bool _isDrawingValidContent = false;

  /// 获取当前步骤索引
  int get currentIndex => _currentIndex;

  /// 获取当前颜色
  Color get getColor => drawConfig.value.color;

  /// 能否开始绘制
  bool get couldStartDraw => drawConfig.value.fingerCount == 0;

  /// 能否进行绘制
  bool get couldDrawing => drawConfig.value.fingerCount == 1;

  /// 是否有正在绘制的内容
  bool get hasPaintingContent => currentContent != null || eraserContent != null;

  /// 开始绘制点
  Offset? get startPoint => _startPoint;

  /// 设置画板大小
  void setBoardSize(Size? size) {
    drawConfig.value = drawConfig.value.copyWith(size: size);
  }

  /// 手指落下
  void addFingerCount(Offset offset) {
    drawConfig.value = drawConfig.value.copyWith(fingerCount: drawConfig.value.fingerCount + 1);
  }

  /// 手指抬起
  void reduceFingerCount(Offset offset) {
    if (drawConfig.value.fingerCount <= 0) {
      return;
    }

    drawConfig.value = drawConfig.value.copyWith(fingerCount: drawConfig.value.fingerCount - 1);
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
    drawConfig.value = drawConfig.value.copyWith(contentType: content.runtimeType);
  }

  /// 添加一条绘制数据
  void addContent(PaintContent content) {
    _history.add(content);
    _currentIndex++;
    cachedImage = null;
    _refreshDeep();
  }

  /// 添加多条数据
  void addContents(List<PaintContent> contents) {
    _history.addAll(contents);
    _currentIndex += contents.length;
    cachedImage = null;
    _refreshDeep();
  }

  /// * 旋转画布
  /// * 设置角度
  void turn() {
    drawConfig.value = drawConfig.value.copyWith(angle: (drawConfig.value.angle + 1) % 4);
  }

  /// 开始绘制
  void startDraw(Offset startPoint) {
    if (_currentIndex == 0 && _paintContent is Eraser) {
      return;
    }

    _startPoint = startPoint;

    if (_paintContent is Eraser) {
      eraserContent = _paintContent.copy();
      eraserContent?.paint = drawConfig.value.paint.copyWith();
      eraserContent?.startDraw(startPoint);
    } else {
      currentContent = _paintContent.copy();
      currentContent?.paint = drawConfig.value.paint;
      currentContent?.startDraw(startPoint);
    }
  }

  /// 取消绘制
  void cancelDraw() {
    _startPoint = null;
    currentContent = null;
    eraserContent = null;
  }

  /// 正在绘制
  void drawing(Offset nowPaint) {
    if (!hasPaintingContent) {
      return;
    }

    _isDrawingValidContent = true;

    if (_paintContent is Eraser) {
      eraserContent?.drawing(nowPaint);
      _refresh();
      // 橡皮擦绘制过程中只刷新表层，提升性能
      // 底层刷新会在 endDraw() 时执行
    } else {
      currentContent?.drawing(nowPaint);
      _refresh();
    }
  }

  /// 结束绘制
  void endDraw() {
    if (!hasPaintingContent) {
      return;
    }

    if (!_isDrawingValidContent) {
      // 清理绘制内容
      _startPoint = null;
      currentContent = null;
      eraserContent = null;
      return;
    }

    _isDrawingValidContent = false;

    _startPoint = null;
    final int hisLen = _history.length;

    if (hisLen > _currentIndex) {
      _history.removeRange(_currentIndex, hisLen);
    }

    if (eraserContent != null) {
      _history.add(eraserContent!);
      _currentIndex = _history.length;
      eraserContent = null;
    }

    if (currentContent != null) {
      _history.add(currentContent!);
      _currentIndex = _history.length;
      currentContent = null;
    }

    // 修剪历史记录，防止内存无限增长
    _trimHistoryIfNeeded();

    _refresh();
    _refreshDeep();
    notifyListeners();
  }

  /// 修剪历史记录，保持在最大步数限制内
  void _trimHistoryIfNeeded() {
    if (_history.length > maxHistorySteps) {
      final int removeCount = _history.length - maxHistorySteps;
      _history.removeRange(0, removeCount);
      _currentIndex = _history.length;
      cachedImage = null; // 清除缓存，因为历史已改变
    }
  }

  /// 撤销
  void undo() {
    cachedImage = null;
    if (_currentIndex > 0) {
      _currentIndex = _currentIndex - 1;
      _refreshDeep();
      notifyListeners();
    }
  }

  /// Check if undo is available.
  /// Returns true if possible.
  bool canUndo() {
    if (_currentIndex > 0) {
      return true;
    } else {
      return false;
    }
  }

  /// 重做
  void redo() {
    cachedImage = null;
    if (_currentIndex < _history.length) {
      _currentIndex = _currentIndex + 1;
      _refreshDeep();
      notifyListeners();
    }
  }

  /// Check if redo is available.
  /// Returns true if possible.
  bool canRedo() {
    if (_currentIndex < _history.length) {
      return true;
    } else {
      return false;
    }
  }

  /// 清理画布
  void clear() {
    cachedImage = null;
    _history.clear();
    _currentIndex = 0;
    _refreshDeep();
  }

  /// 获取图片数据
  Future<ByteData?> getImageData({
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
    double? pixelRatio,
  }) async {
    try {
      final BuildContext? context = painterKey.currentContext;
      if (context == null) {
        debugPrint('画板未挂载，无法获取图片数据');
        return null;
      }

      final RenderObject? renderObject = context.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        debugPrint('渲染对象类型错误，期望 RenderRepaintBoundary');
        return null;
      }

      final double ratio = pixelRatio ?? View.of(context).devicePixelRatio;
      final ui.Image image = await renderObject.toImage(pixelRatio: ratio);

      return await image.toByteData(format: format);
    } catch (e, stack) {
      debugPrint('获取图片数据失败: $e\n$stack');
      return null;
    }
  }

  /// 获取表层图片数据
  /// 更快速，使用缓存的图片数据
  Future<ByteData?> getSurfaceImageData({
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
  }) async {
    try {
      final ui.Image? image = cachedImage;
      if (image == null) {
        debugPrint('缓存图片不存在，请先进行绘制或使用 getImageData()');
        return null;
      }
      return await image.toByteData(format: format);
    } catch (e, stack) {
      debugPrint('获取表层图片数据失败: $e\n$stack');
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
  @override
  void dispose() {
    if (!_mounted) {
      return;
    }

    drawConfig.dispose();
    realPainter?.dispose();
    painter?.dispose();

    _mounted = false;

    super.dispose();
  }
}

/// 画布刷新控制器
class RePaintNotifier extends ChangeNotifier {
  void _refresh() {
    notifyListeners();
  }
}

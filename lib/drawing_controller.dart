import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'paint_contents/custom_text.dart';
import 'paint_contents/eraser.dart';
import 'paint_contents/paint_content.dart';
import 'paint_contents/rectangle.dart';
import 'paint_contents/simple_line.dart';
import 'paint_contents/smooth_line.dart';
import 'paint_contents/straight_line.dart';

///绘制参数
class DrawConfig {
  DrawConfig({
    this.paintType,
    this.startPoint,
    this.color,
    this.thickness,
    this.angle,
    this.text,
  });

  DrawConfig.def({
    this.paintType = PaintType.simpleLine,
    this.startPoint = Offset.zero,
    this.color = Colors.red,
    this.thickness = 4.0,
    this.angle = 0,
    this.text = '输入文字',
  });

  ///绘制类型
  late PaintType? paintType;

  ///开始点
  final Offset? startPoint;

  ///绘制颜色
  final Color? color;

  ///线条粗细
  final double? thickness;

  ///旋转的角度（0:0,1:90,2:180,3:270）
  final int? angle;

  ///当前文本内容
  final String? text;

  DrawConfig copyWith({
    PaintType? paintType,
    PaintContent? currentContent,
    List<PaintContent>? history,
    int? currentIndex,
    Offset? startPoint,
    Color? color,
    double? thickness,
    int? angle,
    String? text,
  }) =>
      DrawConfig(
        paintType: paintType ?? this.paintType,
        startPoint: startPoint ?? this.startPoint,
        color: color ?? this.color,
        thickness: thickness ?? this.thickness,
        angle: angle ?? this.angle,
        text: text ?? this.text,
      );
}

///绘制控制器
class DrawingController {
  DrawingController({DrawConfig? config}) {
    realPainter = _RealPainter();
    _history = <PaintContent>[];
    _currentIndex = 0;
    _startPoint = Offset.zero;
    drawConfig = ValueNotifier<DrawConfig>(config ?? DrawConfig.def());
  }

  ///画板数据
  late GlobalKey painterKey = GlobalKey();

  ///控制器
  late ValueNotifier<DrawConfig?> drawConfig;

  ///表层绘制内容
  PaintContent? currentContent;

  ///手指落下点
  Offset? _startPoint;

  ///底层绘制内容
  late List<PaintContent> _history;

  ///获取绘制类型
  PaintType? get getType => drawConfig.value?.paintType;

  ///设置绘制类型
  set setType(PaintType? type) {
    if (type != drawConfig.value!.paintType) {
      drawConfig.value = drawConfig.value!.copyWith(paintType: type);
    }
  }

  ///获取绘制图层/历史
  List<PaintContent>? get getHistory => _history;

  ///图层指针
  late int _currentIndex;

  ///获取图层指针
  int? get currentIndex => _currentIndex;

  ///获取当前颜色
  Color? get getColor => drawConfig.value!.color;

  ///设置绘制颜色
  set setColor(Color color) {
    if (color != drawConfig.value!.color) {
      drawConfig.value = drawConfig.value!.copyWith(color: color);
    }
  }

  ///获取线条粗细
  double? get getThickness => drawConfig.value!.thickness;

  ///设置线条粗细
  set setThickness(double thickness) {
    if (thickness != drawConfig.value!.thickness) {
      drawConfig.value = drawConfig.value!.copyWith(thickness: thickness);
    }
  }

  ///旋转画布
  ///设置角度
  void turn() {
    drawConfig.value = drawConfig.value!.copyWith(angle: (drawConfig.value!.angle! + 1) % 4);
  }

  ///获取当前文本内容
  String get getText => drawConfig.value!.text!;

  ///设置当前文本内容
  set setText(String? text) {
    if (text != drawConfig.value!.text) {
      drawConfig.value = drawConfig.value!.copyWith(text: text);
    }
  }

  ///开始绘制
  void startDraw(Offset? startPoint) {
    ///刷新起点
    _startPoint = startPoint;

    ///创建画笔
    ///配置属性
    final Paint _paint = Paint();
    _paint.color = drawConfig.value!.color!;
    _paint.strokeWidth = drawConfig.value!.thickness!;
    _paint.strokeCap = StrokeCap.round;
    _paint.strokeJoin = StrokeJoin.round;
    _paint.style = PaintingStyle.stroke;

    switch (drawConfig.value!.paintType) {

      ///自由线条
      case PaintType.simpleLine:
        final Path path = Path();
        path.moveTo(startPoint!.dx, startPoint.dy);
        currentContent = SimpleLine(paint: _paint, path: path);
        break;

      ///直线
      case PaintType.straightLine:
        currentContent = StraightLine(paint: _paint, startPoint: _startPoint, endPoint: _startPoint);
        break;

      ///矩形
      case PaintType.rectangle:
        currentContent = Rectangle(paint: _paint, startPoint: _startPoint, endPoint: _startPoint);
        break;

      ///文本
      case PaintType.text:
        _paint.strokeWidth = 0;
        final TextSpan span = TextSpan(
            text: drawConfig.value!.text,
            style: TextStyle(color: drawConfig.value!.color, fontSize: drawConfig.value!.thickness));
        final TextPainter tp =
            TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr, maxLines: 1);
        currentContent = CustomText(
          paint: _paint,
          startPoint: _startPoint,
          angle: drawConfig.value!.angle,
          textPainter: tp,
          text: drawConfig.value!.text,
        );
        break;

      ///平滑自由线条
      case PaintType.smoothLine:
        final Path path = Path();
        final List<Offset> points = <Offset>[];

        path.moveTo(startPoint!.dx, startPoint.dy);
        points.add(_startPoint!);
        currentContent = SmoothLine(paint: _paint, path: path, points: points, start: _startPoint);
        break;

      ///橡皮
      case PaintType.eraser:
        final Path path = Path();
        _paint.blendMode = BlendMode.clear;
        path.moveTo(startPoint!.dx, startPoint.dy);
        currentContent = Eraser(paint: _paint, path: path);
        break;
      default:
        break;
    }
  }

  ///正在绘制
  void drawing(Offset nowPaint) {
    switch (drawConfig.value!.paintType) {
      case PaintType.simpleLine:
        _drawSimpleLine(nowPaint);
        break;
      case PaintType.straightLine:
        _drawStraightLine(nowPaint);
        break;
      case PaintType.rectangle:
        _drawRectangle(nowPaint);
        break;
      case PaintType.text:
        _drawText(nowPaint);
        break;
      case PaintType.smoothLine:
        _drawSmoothLine(nowPaint);
        break;
      case PaintType.eraser:
        _eraser(nowPaint);
        break;
      default:
        break;
    }

    _refresh();
  }

  ///结束绘制
  void endDraw() {
    final int hisLen = _history.length;
    if (hisLen > _currentIndex) {
      _history.removeRange(_currentIndex, hisLen);
    }

    ///如果绘制类型为平滑曲线
    ///进行计算重绘
    if (drawConfig.value!.paintType == PaintType.smoothLine) {
      final SmoothLine line = currentContent as SmoothLine;
      final List<Offset?>? points = line.points;
      line.path!.reset();

      for (int i = 0; i < points!.length; i += 2) {
        final Offset point = points[i]!;
        if (i == 0) {
          line.path!.moveTo(point.dx, point.dy);
        } else if (i < points.length - 1) {
          final Offset next = points[i + 1]!;
          line.path!.quadraticBezierTo(point.dx, point.dy, next.dx, next.dy);
        } else {
          line.path!.lineTo(point.dx, point.dy);
        }
      }
    }

    if (currentContent != null) {
      _history.add(currentContent!);
      _currentIndex = _history.length;
      currentContent = null;
    }

    _refresh();

    _refreshDeep();
  }

  ///绘制普通线条
  void _drawSimpleLine(Offset nowPoint) {
    final SimpleLine line = currentContent as SimpleLine;
    line.path!.lineTo(nowPoint.dx, nowPoint.dy);
    _refresh();
  }

  ///绘制直线
  void _drawStraightLine(Offset nowPoint) {
    final StraightLine line = currentContent as StraightLine;
    line.endPoint = nowPoint;
  }

  ///绘制矩形
  void _drawRectangle(Offset nowPoint) {
    final Rectangle rectangle = currentContent as Rectangle;
    rectangle.endPoint = nowPoint;
  }

  ///绘制文本
  void _drawText(Offset nowPoint) {
    final CustomText text = currentContent as CustomText;
    text.endPoint = nowPoint;
  }

  ///绘制平滑线条
  ///实际上平滑不了
  void _drawSmoothLine(Offset nowPoint) {
    final SmoothLine line = currentContent as SmoothLine;

    ///记录点位
    line.points!.add(nowPoint);

    line.path!.lineTo(nowPoint.dx, nowPoint.dy);
  }

  ///橡皮
  void _eraser(Offset nowPoint) {
    final Eraser eraser = currentContent as Eraser;

    eraser.path!.lineTo(nowPoint.dx, nowPoint.dy);
  }

  ///撤销
  void undo() {
    if (_currentIndex > 0) {
      _currentIndex = _currentIndex - 1;
      _refreshDeep();
    }
  }

  ///重做
  void redo() {
    if (_currentIndex < _history.length) {
      _currentIndex = _currentIndex + 1;
      _refreshDeep();
    }
  }

  ///清理画布
  void clear() {
    _history.clear();
    _currentIndex = 0;
    _refreshDeep();
  }

  ///获取图片数据
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

  ///刷新表层画板
  void _refresh() {
    drawConfig.value = drawConfig.value!.copyWith();
  }

  ///刷新底层画板
  void _refreshDeep() {
    realPainter?._refresh();
  }

  ///底层画布刷新控制
  _RealPainter? realPainter;

  ///销毁控制器
  void dispose() {
    drawConfig.dispose();
    realPainter?.dispose();
  }
}

///底层画布刷新控制器
class _RealPainter extends ChangeNotifier {
  void _refresh() {
    notifyListeners();
  }
}

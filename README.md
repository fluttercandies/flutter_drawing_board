# Flutter Drawing Board

A Flutter package of drawing board.  
Flutter 画板

[![pub package](https://img.shields.io/pub/v/flutter_drawing_board?logo=dart&label=stable&style=flat-square)](https://pub.dev/packages/flutter_drawing_board)
[![GitHub stars](https://img.shields.io/github/stars/fluttercandies/flutter_drawing_board?logo=github&style=flat-square)](https://github.com/fluttercandies/flutter_drawing_board/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/fluttercandies/flutter_drawing_board?logo=github&style=flat-square)](https://github.com/fluttercandies/flutter_drawing_board/network/members)
[![CodeFactor](https://img.shields.io/codefactor/grade/github/fluttercandies/flutter_drawing_board?logo=codefactor&logoColor=%23ffffff&style=flat-square)](https://www.codefactor.io/repository/github/fluttercandies/flutter_drawing_board)
<a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="FlutterCandies" title="FlutterCandies"></a>

> `0.3.0` 存在破坏性更新，移除了文本添加，文本的添加与编辑请移步 [![pub package](https://img.shields.io/pub/v/stack_board?logo=dart&label=stack_board&style=flat-square)](https://pub.dev/packages/stack_board)  

### 特性
* 基础绘制
* 自定义绘制
* 画布旋转、多指移动缩放
* 撤销、重做

### 预览

* 在线体验:[https://painter.liugl.cn](https://painter.liugl.cn)  

* 基础功能预览  

<img src="https://raw.githubusercontent.com/xSILENCEx/flutter_drawing_board/master/preview/pre1.gif" height=300>
<img src="https://raw.githubusercontent.com/xSILENCEx/flutter_drawing_board/master/preview/pre2.gif" height=300>
<img src="https://raw.githubusercontent.com/xSILENCEx/flutter_drawing_board/master/preview/pre3.gif" height=300>
<img src="https://raw.githubusercontent.com/xSILENCEx/flutter_drawing_board/master/preview/pre4.gif" height=300>
<img src="https://raw.githubusercontent.com/xSILENCEx/flutter_drawing_board/master/preview/pre5.gif" height=300>
<img src="https://raw.githubusercontent.com/xSILENCEx/flutter_drawing_board/master/preview/pre6.gif" height=300>  

&nbsp;

### 使用方法  

* 创建

```dart
//simple example

import 'package:flutter_drawing_board/flutter_drawing_board.dart';

DrawingBoard(
  background: Container(width: 400, height: 400, color: Colors.white),
  showDefaultActions: true, /// 开启默认操作选项
  showDefaultTools: true,   /// 开启默认工具栏
),
```

* 通过 DrawingController.getImageData 获取画板数据

```dart
import 'package:flutter_drawing_board/flutter_drawing_board.dart';

final DrawingController _drawingController = DrawingController();

DrawingBoard(
  controller: _drawingController,
  background: Container(width: 400, height: 400, color: Colors.white),
  showDefaultActions: true,
  showDefaultTools: true,
),

/// 获取画板数据
Future<void> _getImageData() async {
  print((await _drawingController.getImageData()).buffer.asInt8List());
}
```

* 设置绘制内容

```dart
/// 将绘制内容设置为普通线条
_drawingController.setPaintContent = SimpleLine();
```

|  内置图形   | 说明  | 参数 |
|  ----  | ----  | ---- |
| SimpleLine  | 普通线条 | / |
| SmoothLine  | 笔触线条 | double brushPrecision = 0.4 |
| StraightLine  | 直线 | / |
| Rectangle  | 矩形 | / |
| Circle  | 椭圆 | bool isEllipse = false <br>bool startFromCenter = true |
| Eraser  | 橡皮 | / |

* 设置Paint

```dart
_drawingController.setStyle();

/// 可选参数
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
})
```

* 画布操作

```dart
/// 撤销
_drawingController.undo();

/// 重做
_drawingController.redo();

/// 旋转画布
_drawingController.turn();

///清理画布
_drawingController.clear();
```

### 自定义绘制

* 创建继承自 [PaintContent](https://github.com/fluttercandies/flutter_drawing_board/blob/master/lib/src/paint_contents/paint_content.dart) 的自定义绘制类 (以三角形为例)

```dart
/// 自定义绘制三角形
class Triangle extends PaintContent {
  Triangle();

  Offset startPoint = Offset.zero;

  Offset A = Offset.zero;
  Offset B = Offset.zero;
  Offset C = Offset.zero;

  @override
  void startDraw(Offset startPoint) => this.startPoint = startPoint;

  @override
  void drawing(Offset nowPoint) {
    A = Offset(startPoint.dx + (nowPoint.dx - startPoint.dx) / 2, startPoint.dy);
    B = Offset(startPoint.dx, nowPoint.dy);
    C = nowPoint;
  }

  @override
  void draw(Canvas canvas, Size size, bool deeper) {
    final Path path = Path()
      ..moveTo(A.dx, A.dy)
      ..lineTo(B.dx, B.dy)
      ..lineTo(C.dx, C.dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  Triangle copy() => Triangle();
}
```

* 在默认工具栏中添加工具(可选)

> `showDefaultTools` 必须为 `true` 否则默认工具栏不会显示

> `List<DefToolItem> DrawingBoard.defaultTools(Type currType, DrawingController controller);`  
> 为默认工具包  
> 可以使用 `defaultToolsBuilder` 对默认绘制工具进行重写，或者直接在 `defaultTools` 中插入 `DefToolItem` 自定义工具

```dart
DrawingBoard(
  ...
  showDefaultTools: true,
  defaultToolsBuilder: (Type t, _) {
    return DrawingBoard.defaultTools(t, _drawingController)
      ..insert(   /// 将三角形工具插入默认工具栏的第二位
        1,
        DefToolItem(
          icon: Icons.change_history_rounded,
          isActive: t == Triangle,
          onTap: () => _drawingController.setPaintContent = Triangle(),
      ),
    );
  },
)
```

* 效果预览  

<img src="https://raw.githubusercontent.com/xSILENCEx/flutter_drawing_board/master/preview/pre7.gif" height=300>

# Flutter Drawing Board

A Flutter package of drawing board.  
Flutter 画板

[![pub package](https://img.shields.io/pub/v/flutter_drawing_board?logo=dart&label=stable&style=flat-square)](https://pub.dev/packages/flutter_drawing_board)
[![GitHub stars](https://img.shields.io/github/stars/fluttercandies/flutter_drawing_board?logo=github&style=flat-square)](https://github.com/fluttercandies/flutter_drawing_board/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/fluttercandies/flutter_drawing_board?logo=github&style=flat-square)](https://github.com/fluttercandies/flutter_drawing_board/network/members)
[![CodeFactor](https://img.shields.io/codefactor/grade/github/fluttercandies/flutter_drawing_board?logo=codefactor&logoColor=%23ffffff&style=flat-square)](https://www.codefactor.io/repository/github/fluttercandies/flutter_drawing_board)
<a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="FlutterCandies" title="FlutterCandies"></a>

> `0.3.0` 后存在破坏性更新，移除了文本添加，文本的添加与编辑请移步 [![pub package](https://img.shields.io/pub/v/stack_board?logo=dart&label=stack_board&style=flat-square)](https://pub.dev/packages/stack_board)  

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

* 通过 DrawingController.getJsonList 获取内容 Json

```dart
import 'package:flutter_drawing_board/flutter_drawing_board.dart';

final DrawingController _drawingController = DrawingController();

DrawingBoard(
  controller: _drawingController,
  background: Container(width: 400, height: 400, color: Colors.white),
  showDefaultActions: true,
  showDefaultTools: true,
),

/// 获取内容 Json
Future<void> _getJsonList() async {
  print(const JsonEncoder.withIndent('  ').convert(_drawingController.getJsonList()));
}
```
<details>
  <summary>View Json</summary>

```json
[
  {
    "type": "StraightLine",
    "startPoint": {
      "dx": 114.5670061088183,
      "dy": 117.50547159585983
    },
    "endPoint": {
      "dx": 252.9362813512929,
      "dy": 254.91849554320638
    },
    "paint": {
      "blendMode": 3,
      "color": 4294198070,
      "filterQuality": 3,
      "invertColors": false,
      "isAntiAlias": false,
      "strokeCap": 1,
      "strokeJoin": 1,
      "strokeWidth": 4.0,
      "style": 1
    }
  },
  {
    "type": "StraightLine",
    "startPoint": {
      "dx": 226.6379349225167,
      "dy": 152.11430225316613
    },
    "endPoint": {
      "dx": 135.67632523940733,
      "dy": 210.35948249064901
    },
    "paint": {
      "blendMode": 3,
      "color": 4294198070,
      "filterQuality": 3,
      "invertColors": false,
      "isAntiAlias": false,
      "strokeCap": 1,
      "strokeJoin": 1,
      "strokeWidth": 4.0,
      "style": 1
    }
  }
]
```
</details>


* 通过 `Json` 添加绘制内容

```dart
const Map<String, dynamic> _testLine1 = <String, dynamic>{
  'type': 'StraightLine',
  'startPoint': <String, dynamic>{'dx': 68.94337550070736, 'dy': 62.05980083656557},
  'endPoint': <String, dynamic>{'dx': 277.1373386828114, 'dy': 277.32029957032194},
  'paint': <String, dynamic>{
    'blendMode': 3,
    'color': 4294198070,
    'filterQuality': 3,
    'invertColors': false,
    'isAntiAlias': false,
    'strokeCap': 1,
    'strokeJoin': 1,
    'strokeWidth': 4.0,
    'style': 1
  }
};

const Map<String, dynamic> _testLine2 = <String, dynamic>{
  'type': 'StraightLine',
  'startPoint': <String, dynamic>{'dx': 106.35164817830423, 'dy': 255.9575653134524},
  'endPoint': <String, dynamic>{'dx': 292.76034659254094, 'dy': 92.125586665872},
  'paint': <String, dynamic>{
    'blendMode': 3,
    'color': 4294198070,
    'filterQuality': 3,
    'invertColors': false,
    'isAntiAlias': false,
    'strokeCap': 1,
    'strokeJoin': 1,
    'strokeWidth': 4.0,
    'style': 1
  }
};

  ...

/// 添加Json测试内容
void _addTestLine() {
  _drawingController.addContent(StraightLine.fromJson(_testLine1));
  _drawingController.addContents(<PaintContent>[StraightLine.fromJson(_testLine2)]);
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

  Triangle.data({
    required this.startPoint,
    required this.A,
    required this.B,
    required this.C,
    required Paint paint,
  }) : super.paint(paint);

  factory Triangle.fromJson(Map<String, dynamic> data) {
    return Triangle.data(
      startPoint: jsonToOffset(data['startPoint'] as Map<String, dynamic>),
      A: jsonToOffset(data['A'] as Map<String, dynamic>),
      B: jsonToOffset(data['B'] as Map<String, dynamic>),
      C: jsonToOffset(data['C'] as Map<String, dynamic>),
      paint: jsonToPaint(data['paint'] as Map<String, dynamic>),
    );
  }

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

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'startPoint': startPoint.toJson(),
      'A': A.toJson(),
      'B': B.toJson(),
      'C': C.toJson(),
      'paint': paint.toJson(),
    };
  }
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

# Flutter Drawing Board

A Flutter package of drawing board.  
Flutter artboard

[English](./README.md) | [中文](./README-zh-CN.md)

[![pub package](https://img.shields.io/pub/v/flutter_drawing_board?logo=dart&label=stable&style=flat-square)](https://pub.dev/packages/flutter_drawing_board)
[![GitHub stars](https://img.shields.io/github/stars/fluttercandies/flutter_drawing_board?logo=github&style=flat-square)](https://github.com/fluttercandies/flutter_drawing_board/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/fluttercandies/flutter_drawing_board?logo=github&style=flat-square)](https://github.com/fluttercandies/flutter_drawing_board/network/members)
[![CodeFactor](https://img.shields.io/codefactor/grade/github/fluttercandies/flutter_drawing_board?logo=codefactor&logoColor=%23ffffff&style=flat-square)](https://www.codefactor.io/repository/github/fluttercandies/flutter_drawing_board)
<a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="FlutterCandies" title="FlutterCandies"></a>

> There are breaking changes after `0.3.0`, text addition has been removed. For text addition and editing, please refer to [![pub package](https://img.shields.io/pub/v/stack_board?logo=dart&label=stack_board&style=flat-square)](https://pub.dev/packages/stack_board)  

### Features
* Basic drawing
* Custom drawing
* Canvas rotation, multi-touch movement, and scaling
* Undo, redo

### Preview

* Try it online::[Demo](https://xsilencex.github.io/flutter_drawing_board_demo/)  

* Preview of basic functionalities 

<img src="https://raw.githubusercontent.com/xSILENCEx/flutter_drawing_board/master/preview/pre1.gif" height=300>
<img src="https://raw.githubusercontent.com/xSILENCEx/flutter_drawing_board/master/preview/pre2.gif" height=300>
<img src="https://raw.githubusercontent.com/xSILENCEx/flutter_drawing_board/master/preview/pre3.gif" height=300>
<img src="https://raw.githubusercontent.com/xSILENCEx/flutter_drawing_board/master/preview/pre4.gif" height=300>
<img src="https://raw.githubusercontent.com/xSILENCEx/flutter_drawing_board/master/preview/pre5.gif" height=300>
<img src="https://raw.githubusercontent.com/xSILENCEx/flutter_drawing_board/master/preview/pre6.gif" height=300>  

&nbsp;

### Usage


* Create

```dart
//simple example

import 'package:flutter_drawing_board/flutter_drawing_board.dart';

DrawingBoard(
  background: Container(width: 400, height: 400, color: Colors.white),
  showDefaultActions: true, /// Enable default action options
  showDefaultTools: true,   /// Enable default toolbar
),
```

* Retrieve drawing board data using DrawingController.getImageData

```dart
import 'package:flutter_drawing_board/flutter_drawing_board.dart';

final DrawingController _drawingController = DrawingController();

DrawingBoard(
  controller: _drawingController,
  background: Container(width: 400, height: 400, color: Colors.white),
  showDefaultActions: true,
  showDefaultTools: true,
),

/// Get drawing board data
Future<void> _getImageData() async {
  print((await _drawingController.getImageData()).buffer.asInt8List());
}
```

* Retrieve content Json using DrawingController.getJsonList

```dart
import 'package:flutter_drawing_board/flutter_drawing_board.dart';

final DrawingController _drawingController = DrawingController();

DrawingBoard(
  controller: _drawingController,
  background: Container(width: 400, height: 400, color: Colors.white),
  showDefaultActions: true,
  showDefaultTools: true,
),

/// Get Json content
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


* Add drawing content using Json

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

/// Add Json test content
void _addTestLine() {
  _drawingController.addContent(StraightLine.fromJson(_testLine1));
  _drawingController.addContents(<PaintContent>[StraightLine.fromJson(_testLine2)]);
}
```

* Set drawing content

```dart
/// Set drawing content as a simple line
_drawingController.setPaintContent = SimpleLine();
```

|  Built-in Shape   | Description  | Parameters |
|  ----  | ----  | ---- |
| SimpleLine  | Simple line | / |
| SmoothLine  | Stroke line | double brushPrecision = 0.4 |
| StraightLine  | Straight line | / |
| Rectangle  | Rectangle | / |
| Circle  | Ellipse | bool isEllipse = false <br>bool startFromCenter = true |
| Eraser  | Eraser | / |

* Set Paint

```dart
_drawingController.setStyle();

/// Optional parameters
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

* Canvas operations

```dart
/// Undo
_drawingController.undo();

/// Redo
_drawingController.redo();

/// Rotate canvas
_drawingController.turn();

/// Clear canvas
_drawingController.clear();
```

### Custom Drawing

* Create a custom drawing class that inherits from [PaintContent](https://github.com/fluttercandies/flutter_drawing_board/blob/master/lib/src/paint_contents/paint_content.dart) (using a triangle as an example)

```dart
/// Custom drawing of a triangle
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

* Add a tool to the default toolbar (optional)

> `showDefaultTools` must be true otherwise the default toolbar won't display
> 
> `List<DefToolItem> DrawingBoard.defaultTools(Type currType, DrawingController controller);`
is the default toolset
>
> Use `defaultToolsBuilder` to rewrite the default drawing tools, or insert DefToolItem custom tools directly into defaultTools

```dart
DrawingBoard(
  ...
  showDefaultTools: true,
  defaultToolsBuilder: (Type t, _) {
    return DrawingBoard.defaultTools(t, _drawingController)
      ..insert(   /// Insert the triangle tool into the second position of the default toolbar
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

* Preview  

<img src="https://raw.githubusercontent.com/xSILENCEx/flutter_drawing_board/master/preview/pre7.gif" height=300>

# Flutter Drawing Board

A Flutter package of drawing board.

[![pub package](https://img.shields.io/pub/v/flutter_drawing_board?logo=dart&label=stable&style=flat-square)](https://pub.dev/packages/flutter_drawing_board)
[![GitHub stars](https://img.shields.io/github/stars/fluttercandies/flutter_drawing_board?logo=github&style=flat-square)](https://github.com/fluttercandies/flutter_drawing_board/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/fluttercandies/flutter_drawing_board?logo=github&style=flat-square)](https://github.com/fluttercandies/flutter_drawing_board/network/members)
[![CodeFactor](https://img.shields.io/codefactor/grade/github/fluttercandies/flutter_drawing_board?logo=codefactor&logoColor=%23ffffff&style=flat-square)](https://www.codefactor.io/repository/github/fluttercandies/flutter_drawing_board)
<a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="FlutterCandies" title="FlutterCandies"></a>

使用方法
```dart
//simple example

import 'package:flutter_drawing_board/flutter_drawing_board.dart';

DrawingBoard(
  background: Container(width: 400, height: 400, color: Colors.white),
  showDefaultActions: true,
  showDefaultTools: true,
),
```

```dart
//获取画板数据

import 'package:flutter_drawing_board/flutter_drawing_board.dart';

final DrawingController _drawingController = DrawingController();

DrawingBoard(
  controller: _drawingController,
  background: Container(width: 400, height: 400, color: Colors.white),
  showDefaultActions: true,
  showDefaultTools: true,
),

Future<void> _getImageData() async {
  print((await _drawingController.getImageData()).buffer.asInt8List());
}
```

## 效果预览

预览网址:[https://painter.liugl.cn](https://painter.liugl.cn)

### Phone
<img src="https://raw.githubusercontent.com/xSILENCEx/flutter_drawing_board/master/preview/phone.jpg" height=400>

### Web
<img src="https://raw.githubusercontent.com/xSILENCEx/flutter_drawing_board/master/preview/web.png" height=400>

### Windows
<img src="https://raw.githubusercontent.com/xSILENCEx/flutter_drawing_board/master/preview/win.png" height=400>

### macOS
<img src="https://raw.githubusercontent.com/xSILENCEx/flutter_drawing_board/master/preview/mac.png" height=400>

### Linux
<img src="https://raw.githubusercontent.com/xSILENCEx/flutter_drawing_board/master/preview/linux.png" height=400>

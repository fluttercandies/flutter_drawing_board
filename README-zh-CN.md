# Flutter Drawing Board

功能强大且高度可定制的 Flutter 绘图板插件，提供丰富的绘图功能和高级特性。

[English](./README.md) | [中文](./README-zh-CN.md)

[![pub package](https://img.shields.io/pub/v/flutter_drawing_board?logo=dart&label=stable&style=flat-square)](https://pub.dev/packages/flutter_drawing_board)
[![GitHub stars](https://img.shields.io/github/stars/fluttercandies/flutter_drawing_board?logo=github&style=flat-square)](https://github.com/fluttercandies/flutter_drawing_board/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/fluttercandies/flutter_drawing_board?logo=github&style=flat-square)](https://github.com/fluttercandies/flutter_drawing_board/network/members)
[![CodeFactor](https://img.shields.io/codefactor/grade/github/fluttercandies/flutter_drawing_board?logo=codefactor&logoColor=%23ffffff&style=flat-square)](https://www.codefactor.io/repository/github/fluttercandies/flutter_drawing_board)
<a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="FlutterCandies" title="FlutterCandies"></a>

> **破坏性更新**: `0.3.0` 版本之后移除了文本功能。如需文本功能，请使用 [![pub package](https://img.shields.io/pub/v/stack_board?logo=dart&label=stack_board&style=flat-square)](https://pub.dev/packages/stack_board)

> **0.9.9+ 版本行为变更**:
> - `SimpleLine()` 现在默认使用贝塞尔曲线平滑（`useBezierCurve: true`），提供更平滑的线条。如需使用旧行为，请设置 `useBezierCurve: false`。
> - JSON 导入保持向后兼容，默认 `useBezierCurve: false`。

## 特性

- **丰富的绘图工具** - 自由线条、笔触、直线、矩形、圆形和橡皮擦
- **高级平滑算法** - 贝塞尔曲线和 Catmull-Rom 样条插值，实现超平滑线条
- **手掌拒绝** - 防止平板设备上的意外手掌触摸
- **画布操作** - 平移、缩放、旋转（90° 增量）、撤销、重做、清空
- **性能优化** - 点过滤、画布缓存（~70% 提升）、橡皮擦优化（~50% 提升）
- **JSON 序列化** - 完整的绘图保存/加载支持
- **图像导出** - 支持导出为 PNG 等多种格式
- **灵活的工具栏系统** - 内置工具栏，易于自定义
- **高度可扩展** - 轻松创建自定义绘制内容类型
- **可配置历史记录** - 限制撤销/重做步数，防止内存增长（默认：100）

## 预览

**在线体验**: [Demo](https://xsilencex.github.io/flutter_drawing_board_demo/)

<img src="https://raw.githubusercontent.com/xSILENCEx/flutter_drawing_board/master/preview/pre1.gif" height=300>
<img src="https://raw.githubusercontent.com/xSILENCEx/flutter_drawing_board/master/preview/pre2.gif" height=300>
<img src="https://raw.githubusercontent.com/xSILENCEx/flutter_drawing_board/master/preview/pre3.gif" height=300>
<img src="https://raw.githubusercontent.com/xSILENCEx/flutter_drawing_board/master/preview/pre4.gif" height=300>
<img src="https://raw.githubusercontent.com/xSILENCEx/flutter_drawing_board/master/preview/pre5.gif" height=300>
<img src="https://raw.githubusercontent.com/xSILENCEx/flutter_drawing_board/master/preview/pre6.gif" height=300>

## 安装

在项目的 `pubspec.yaml` 文件中添加：

```yaml
dependencies:
  flutter_drawing_board: ^0.9.10+1
```

然后运行：

```bash
flutter pub get
```

## 快速开始

```dart
import 'package:flutter_drawing_board/flutter_drawing_board.dart';

class MyDrawingPage extends StatefulWidget {
  @override
  State<MyDrawingPage> createState() => _MyDrawingPageState();
}

class _MyDrawingPageState extends State<MyDrawingPage> {
  final DrawingController _drawingController = DrawingController();

  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 绘图板
          Expanded(
            child: DrawingBoard(
              controller: _drawingController,
              background: Container(color: Colors.white),
            ),
          ),

          // 操作栏（滑块、撤销、重做、旋转、清空）
          DrawingBar(
            controller: _drawingController,
            tools: [
              DefaultActionItem.slider(),
              DefaultActionItem.undo(),
              DefaultActionItem.redo(),
              DefaultActionItem.turn(),
              DefaultActionItem.clear(),
            ],
          ),

          // 工具栏（画笔、笔触、形状、橡皮擦）
          DrawingBar(
            controller: _drawingController,
            tools: [
              DefaultToolItem.pen(),
              DefaultToolItem.brush(),
              DefaultToolItem.rectangle(),
              DefaultToolItem.circle(),
              DefaultToolItem.straightLine(),
              DefaultToolItem.eraser(),
            ],
          ),
        ],
      ),
    );
  }
}
```

## 使用指南

### 1. 绘制内容类型

本插件提供了多种内置绘制内容类型：

#### SimpleLine - 自由线条
绘制平滑的自由线条，支持贝塞尔曲线平滑。

```dart
_drawingController.setPaintContent = SimpleLine(
  useBezierCurve: true,  // 启用贝塞尔平滑（默认：true，v0.9.9起）
  minPointDistance: 2.0, // 过滤距离小于此值的点（默认：2.0）
);
```

> **注意**: 从 v0.9.9 开始，`useBezierCurve` 默认为 `true`，提供更平滑的线条。设置为 `false` 可恢复旧的直线行为。

#### SmoothLine - 可变粗细的笔触线条
绘制具有类似压感粗细变化的笔触线条，支持高级平滑。

```dart
_drawingController.setPaintContent = SmoothLine(
  brushPrecision: 0.8,   // 线条平滑因子（值越小越平滑，默认：0.8）
  useBezierCurve: true,  // 启用贝塞尔曲线（默认：true）
  minPointDistance: 2.0, // 过滤冗余点（默认：2.0）
  smoothLevel: 1,        // 0: 快速, 1: 平衡, 2: 超平滑（默认：1）
);
```

**平滑级别:**
- `0`: 快速 - 无额外平滑
- `1`: 平衡 - 基础平滑（推荐）
- `2`: 超平滑 - Catmull-Rom 样条插值，实现丝滑曲线

#### StraightLine - 直线
```dart
_drawingController.setPaintContent = StraightLine();
```

#### Rectangle - 矩形
```dart
_drawingController.setPaintContent = Rectangle();
```

#### Circle - 圆形或椭圆
```dart
_drawingController.setPaintContent = Circle(
  isEllipse: false,       // false: 圆形, true: 椭圆（默认：false）
  startFromCenter: true,  // true: 从圆心开始, false: 对角线（默认：true）
);
```

#### Eraser - 橡皮擦
```dart
_drawingController.setPaintContent = Eraser();
```

### 2. DrawingController API

#### 创建控制器

```dart
final DrawingController _drawingController = DrawingController(
  config: DrawConfig(
    contentType: SimpleLine,
    strokeWidth: 4.0,
    color: Colors.black,
  ),
  maxHistorySteps: 100, // 限制撤销/重做历史记录（默认：100）
);
```

#### 设置画笔样式

```dart
_drawingController.setStyle(
  color: Colors.blue,
  strokeWidth: 6.0,
  strokeCap: StrokeCap.round,
  strokeJoin: StrokeJoin.round,
  blendMode: BlendMode.srcOver,
  isAntiAlias: true,
);
```

#### 画布操作

```dart
// 撤销上一步操作
_drawingController.undo();

// 重做上一步撤销的操作
_drawingController.redo();

// 顺时针旋转画布 90°
_drawingController.turn();

// 清空整个画布
_drawingController.clear();

// 检查操作是否可用
bool canUndo = _drawingController.canUndo();
bool canRedo = _drawingController.canRedo();
bool canClear = _drawingController.canClear();
```

#### 以编程方式添加内容

```dart
// 添加单个内容
_drawingController.addContent(StraightLine.fromJson(jsonData));

// 添加多个内容
_drawingController.addContents([
  SimpleLine.fromJson(line1Json),
  Rectangle.fromJson(rect1Json),
]);
```

#### 导出数据

**导出为图像**:
```dart
// 获取完整图像（包含背景）
Future<void> _exportImage() async {
  final ByteData? data = await _drawingController.getImageData(
    format: ui.ImageByteFormat.png,
  );

  if (data != null) {
    final Uint8List bytes = data.buffer.asUint8List();
    // 保存或显示图像
  }
}

// 获取表面图像（仅绘制内容，更快）
Future<void> _exportSurface() async {
  final ByteData? data = await _drawingController.getSurfaceImageData();
  // 使用图像数据
}
```

**导出为 JSON**:
```dart
void _exportJson() {
  final List<Map<String, dynamic>> jsonList = _drawingController.getJsonList();
  final String jsonString = const JsonEncoder.withIndent('  ').convert(jsonList);
  // 保存或分享 JSON
}
```

**从 JSON 导入**:
```dart
void _importJson(List<Map<String, dynamic>> jsonData) {
  final contents = jsonData.map((json) {
    final type = json['type'] as String;
    switch (type) {
      case 'SimpleLine':
        return SimpleLine.fromJson(json);
      case 'StraightLine':
        return StraightLine.fromJson(json);
      case 'Rectangle':
        return Rectangle.fromJson(json);
      case 'Circle':
        return Circle.fromJson(json);
      case 'Eraser':
        return Eraser.fromJson(json);
      default:
        return null;
    }
  }).whereType<PaintContent>().toList();

  _drawingController.addContents(contents);
}
```

### 3. DrawingBoard 配置

```dart
DrawingBoard(
  controller: _drawingController,
  background: Container(color: Colors.white),

  // 交互回调
  onPointerDown: (PointerDownEvent event) { /* ... */ },
  onPointerMove: (PointerMoveEvent event) { /* ... */ },
  onPointerUp: (PointerUpEvent event) { /* ... */ },

  // 画布交互
  boardPanEnabled: true,        // 启用平移（默认：true）
  boardScaleEnabled: true,      // 启用缩放（默认：true）
  minScale: 0.2,                // 最小缩放比例（默认：0.2）
  maxScale: 20,                 // 最大缩放比例（默认：20）
  panAxis: PanAxis.free,        // 平移方向限制（默认：自由）

  // 高级功能
  enablePalmRejection: false,   // 启用手掌拒绝（默认：false）

  // 布局
  alignment: Alignment.topCenter,
  clipBehavior: Clip.antiAlias,
  boardClipBehavior: Clip.hardEdge,

  // 用于外部操作的变换控制器
  transformationController: _transformationController,
)
```

### 4. 工具栏系统

#### DrawingBar

`DrawingBar` 组件提供灵活的工具栏布局，自动传递控制器。

```dart
// 水平工具栏（默认）
DrawingBar(
  controller: _drawingController,
  style: HorizontalToolsBarStyle(
    mainAxisAlignment: MainAxisAlignment.center,
    spacing: 8.0,
  ),
  tools: [ /* 工具组件 */ ],
)

// 垂直工具栏
DrawingBar(
  controller: _drawingController,
  style: VerticalToolsBarStyle(
    mainAxisAlignment: MainAxisAlignment.start,
    spacing: 8.0,
  ),
  tools: [ /* 工具组件 */ ],
)

// 自动换行工具栏
DrawingBar(
  controller: _drawingController,
  style: WrapToolsBarStyle(
    spacing: 8.0,
    runSpacing: 8.0,
  ),
  tools: [ /* 工具组件 */ ],
)
```

#### 默认工具项

用于切换绘制内容的预制工具按钮：

```dart
DefaultToolItem.pen()          // SimpleLine 工具
DefaultToolItem.brush()        // SmoothLine 工具
DefaultToolItem.straightLine() // StraightLine 工具
DefaultToolItem.rectangle()    // Rectangle 工具
DefaultToolItem.circle()       // Circle 工具
DefaultToolItem.eraser()       // Eraser 工具
```

自定义工具项：
```dart
DefaultToolItem(
  icon: Icons.star,
  content: MyCustomContent,
  onTap: (controller) {
    // 自定义操作
  },
  color: Colors.grey,
  activeColor: Colors.blue,
  iconSize: 24,
)
```

#### 默认操作项

预制操作按钮：

```dart
DefaultActionItem.slider()     // 笔触粗细滑块
DefaultActionItem.undo()       // 撤销按钮
DefaultActionItem.redo()       // 重做按钮
DefaultActionItem.turn()       // 旋转 90° 按钮
DefaultActionItem.clear()      // 清空画布按钮
```

自定义操作项：
```dart
DefaultActionItem(
  childBuilder: (context, controller) {
    return Icon(Icons.save);
  },
  onTap: (controller) async {
    // 保存绘图
    await _saveDrawing(controller);
  },
)
```

### 5. 高级功能

#### 手掌拒绝

通过检测大触摸面积和快速连续触摸，防止平板设备上的意外手掌触摸。

```dart
DrawingBoard(
  controller: _drawingController,
  background: Container(color: Colors.white),
  enablePalmRejection: true, // 启用手掌拒绝
)
```

**工作原理:**
- 拒绝大小 > 15.0 的触摸（可能是手掌）
- 拒绝 100ms 内的快速连续触摸（手掌 + 手指）

#### 历史记录管理

通过限制撤销/重做历史记录来控制内存使用：

```dart
final DrawingController _drawingController = DrawingController(
  maxHistorySteps: 50, // 限制为 50 步（默认：100）
);
```

#### 自定义颜色与透明度

```dart
// 设置带自定义透明度的颜色
_drawingController.setStyle(
  color: Colors.red.withValues(alpha: 0.5),
);
```

### 6. 创建自定义绘制内容

扩展 `PaintContent` 来创建自己的绘图工具：

```dart
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
    A = Offset(
      startPoint.dx + (nowPoint.dx - startPoint.dx) / 2,
      startPoint.dy,
    );
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
  Map<String, dynamic> toContentJson() {
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

**添加到工具栏:**

```dart
DrawingBar(
  controller: _drawingController,
  tools: [
    ...DefaultToolItem.values, // 所有默认工具
    DefaultToolItem(
      icon: Icons.change_history,
      content: Triangle,
      activeColor: Colors.purple,
    ),
  ],
)
```

**效果预览:**

<img src="https://raw.githubusercontent.com/xSILENCEx/flutter_drawing_board/master/preview/pre7.gif" height=300>

## 性能优化

本插件包含多项性能优化（v0.9.9+ 引入）：

- **画布缓存**（~70% 提升）- 通过缓存版本控制避免冗余图像生成
- **橡皮擦优化**（~50% 提升）- 减少橡皮擦操作期间的双重刷新
- **点过滤**（30-50% 减少）- 通过 `minPointDistance` 过滤冗余点，减少 30-50% 的数据量
- **贝塞尔平滑** - 在不牺牲性能的情况下消除折线感
- **整体**（30-50% 提升）- 渲染和内存使用提升 30-50%

## JSON 格式示例

```json
[
  {
    "type": "StraightLine",
    "startPoint": {"dx": 114.56, "dy": 117.50},
    "endPoint": {"dx": 252.93, "dy": 254.91},
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
    "type": "SimpleLine",
    "points": [
      {"dx": 100.0, "dy": 100.0},
      {"dx": 150.0, "dy": 120.0},
      {"dx": 200.0, "dy": 110.0}
    ],
    "useBezierCurve": true,
    "minPointDistance": 2.0,
    "paint": { /* ... */ }
  }
]
```

## API 参考

### DrawingController

| 方法 | 说明 |
|------|------|
| `setStyle({...})` | 更新画笔样式（颜色、粗细等） |
| `setPaintContent(PaintContent)` | 切换绘图工具 |
| `undo()` | 撤销上一步操作 |
| `redo()` | 重做上一步撤销的操作 |
| `turn()` | 旋转画布 90° |
| `clear()` | 清空画布 |
| `addContent(PaintContent)` | 添加单个内容 |
| `addContents(List<PaintContent>)` | 添加多个内容 |
| `getImageData()` | 导出为图像（包含背景） |
| `getSurfaceImageData()` | 导出表面图像（更快） |
| `getJsonList()` | 导出为 JSON |

### 内置内容类型

| 类型 | 说明 | 参数 |
|------|------|------|
| `SimpleLine` | 自由线条 | `useBezierCurve`, `minPointDistance` |
| `SmoothLine` | 笔触线条 | `brushPrecision`, `smoothLevel`, `useBezierCurve`, `minPointDistance` |
| `StraightLine` | 直线 | - |
| `Rectangle` | 矩形 | - |
| `Circle` | 圆形/椭圆 | `isEllipse`, `startFromCenter` |
| `Eraser` | 橡皮擦 | - |

## 示例

查看 [example](./example) 文件夹获取完整示例，包括：
- 基础绘图板
- 自定义绘制内容（三角形、图像）
- 颜色选择器集成
- JSON 导入/导出
- 图像导出

## 贡献

欢迎贡献！以下是你可以帮助的方式：

1. **报告错误** - 提交 issue 描述错误及其重现方法
2. **建议功能** - 提交 issue 描述你的功能请求
3. **提交 PR** - Fork 仓库，进行修改，然后提交 pull request

请确保你的代码遵循现有风格，并在适当的地方包含测试。

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](./LICENSE) 文件。

## 社区

加入我们的 QQ 群: <a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="FlutterCandies" title="FlutterCandies"></a>

## 更新日志

查看 [CHANGELOG.md](./CHANGELOG.md) 了解版本历史。

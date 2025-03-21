import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:flutter_drawing_board/paint_extension.dart';

import 'test_data.dart';

Future<ui.Image> _getImage(String path) async {
  final Completer<ImageInfo> completer = Completer<ImageInfo>();
  final NetworkImage img = NetworkImage(path);
  img.resolve(ImageConfiguration.empty).addListener(
    ImageStreamListener((ImageInfo info, _) {
      completer.complete(info);
    }),
  );

  final ImageInfo imageInfo = await completer.future;

  return imageInfo.image;
}

const Map<String, dynamic> _testLine1 = <String, dynamic>{
  'type': 'StraightLine',
  'startPoint': <String, dynamic>{
    'dx': 68.94337550070736,
    'dy': 62.05980083656557
  },
  'endPoint': <String, dynamic>{
    'dx': 277.1373386828114,
    'dy': 277.32029957032194
  },
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
  'startPoint': <String, dynamic>{
    'dx': 106.35164817830423,
    'dy': 255.9575653134524
  },
  'endPoint': <String, dynamic>{
    'dx': 292.76034659254094,
    'dy': 92.125586665872
  },
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

/// Custom drawn triangles
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
  String get contentType => 'Triangle';

  @override
  void startDraw(Offset startPoint) => this.startPoint = startPoint;

  @override
  void drawing(Offset nowPoint) {
    A = Offset(
        startPoint.dx + (nowPoint.dx - startPoint.dx) / 2, startPoint.dy);
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

/// Custom drawn image
/// url: https://web-strapi.mrmilu.com/uploads/flutter_logo_470e9f7491.png
const String _imageUrl =
    'https://web-strapi.mrmilu.com/uploads/flutter_logo_470e9f7491.png';

class ImageContent extends PaintContent {
  ImageContent(this.image, {this.imageUrl = ''});

  ImageContent.data({
    required this.startPoint,
    required this.size,
    required this.image,
    required this.imageUrl,
    required Paint paint,
  }) : super.paint(paint);

  factory ImageContent.fromJson(Map<String, dynamic> data) {
    return ImageContent.data(
      startPoint: jsonToOffset(data['startPoint'] as Map<String, dynamic>),
      size: jsonToOffset(data['size'] as Map<String, dynamic>),
      imageUrl: data['imageUrl'] as String,
      image: data['image'] as ui.Image,
      paint: jsonToPaint(data['paint'] as Map<String, dynamic>),
    );
  }

  Offset startPoint = Offset.zero;
  Offset size = Offset.zero;
  final String imageUrl;
  final ui.Image image;

  @override
  String get contentType => 'ImageContent';

  @override
  void startDraw(Offset startPoint) => this.startPoint = startPoint;

  @override
  void drawing(Offset nowPoint) => size = nowPoint - startPoint;

  @override
  void draw(Canvas canvas, Size size, bool deeper) {
    final Rect rect = Rect.fromPoints(startPoint, startPoint + this.size);
    paintImage(canvas: canvas, rect: rect, image: image, fit: BoxFit.fill);
  }

  @override
  ImageContent copy() => ImageContent(image);

  @override
  Map<String, dynamic> toContentJson() {
    return <String, dynamic>{
      'startPoint': startPoint.toJson(),
      'size': size.toJson(),
      'imageUrl': imageUrl,
      'paint': paint.toJson(),
    };
  }
}

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode) {
      exit(1);
    }
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawing Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// 绘制控制器
  final DrawingController _drawingController = DrawingController();

  final TransformationController _transformationController =
      TransformationController();

  double _colorOpacity = 1;

  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }

  /// 获取画板数据 `getImageData()`
  Future<void> _getImageData() async {
    final Uint8List? data =
        (await _drawingController.getImageData())?.buffer.asUint8List();
    if (data == null) {
      debugPrint('获取图片数据失败');
      return;
    }

    if (mounted) {
      showDialog<void>(
        context: context,
        builder: (BuildContext c) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: () => Navigator.pop(c), child: Image.memory(data)),
          );
        },
      );
    }
  }

  /// 获取画板内容 Json `getJsonList()`
  Future<void> _getJson() async {
    showDialog<void>(
      context: context,
      builder: (BuildContext c) {
        return Center(
          child: Material(
            color: Colors.white,
            child: InkWell(
              onTap: () => Navigator.pop(c),
              child: Container(
                constraints:
                    const BoxConstraints(maxWidth: 500, maxHeight: 800),
                padding: const EdgeInsets.all(20.0),
                child: SelectableText(
                  const JsonEncoder.withIndent('  ')
                      .convert(_drawingController.getJsonList()),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 添加Json测试内容
  void _addTestLine() {
    _drawingController.addContent(StraightLine.fromJson(_testLine1));
    _drawingController
        .addContents(<PaintContent>[StraightLine.fromJson(_testLine2)]);
    _drawingController.addContent(SimpleLine.fromJson(tData[0]));
    _drawingController.addContent(Eraser.fromJson(tData[1]));
  }

  void _restBoard() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey,
      appBar: AppBar(
        leading: PopupMenuButton<Color>(
          icon: const Icon(Icons.color_lens),
          onSelected: (ui.Color value) => _drawingController.setStyle(
              color: value.withValues(alpha: _colorOpacity)),
          itemBuilder: (_) {
            return <PopupMenuEntry<ui.Color>>[
              PopupMenuItem<Color>(
                child: StatefulBuilder(
                  builder: (BuildContext context,
                      Function(void Function()) setState) {
                    return Slider(
                      value: _colorOpacity,
                      onChanged: (double v) {
                        setState(() => _colorOpacity = v);
                        _drawingController.setStyle(
                          color: _drawingController.drawConfig.value.color
                              .withValues(alpha: _colorOpacity),
                        );
                      },
                    );
                  },
                ),
              ),
              ...Colors.accents.map((ui.Color color) {
                return PopupMenuItem<ui.Color>(
                    value: color,
                    child: Container(width: 100, height: 50, color: color));
              }),
            ];
          },
        ),
        title: const Text('Drawing Test'),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.line_axis), onPressed: _addTestLine),
          IconButton(
              icon: const Icon(Icons.javascript_outlined), onPressed: _getJson),
          IconButton(icon: const Icon(Icons.check), onPressed: _getImageData),
          IconButton(
              icon: const Icon(Icons.restore_page_rounded),
              onPressed: _restBoard),
        ],
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.grey,
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return DrawingBoard(
                      // boardPanEnabled: false,
                      // boardScaleEnabled: false,
                      transformationController: _transformationController,
                      controller: _drawingController,
                      background: Container(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        color: Colors.white,
                      ),
                      showDefaultActions: true,
                      showDefaultTools: true,
                      defaultToolsBuilder: (Type t, _) {
                        return DrawingBoard.defaultTools(t, _drawingController)
                          ..insert(
                            1,
                            DefToolItem(
                              icon: Icons.change_history_rounded,
                              isActive: t == Triangle,
                              onTap: () => _drawingController
                                  .setPaintContent(Triangle()),
                            ),
                          )
                          ..insert(
                            2,
                            DefToolItem(
                              icon: Icons.image_rounded,
                              isActive: t == ImageContent,
                              onTap: () async {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext c) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                );

                                try {
                                  _drawingController
                                      .setPaintContent(ImageContent(
                                    await _getImage(_imageUrl),
                                    imageUrl: _imageUrl,
                                  ));
                                } catch (e) {
                                  //
                                } finally {
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                }
                              },
                            ),
                          );
                      },
                    );
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: SelectableText(
                  'https://github.com/fluttercandies/flutter_drawing_board',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

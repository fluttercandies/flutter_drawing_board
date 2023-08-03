import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';

typedef ColorPickerBuilder = Widget Function(
  BuildContext context,
  Color? initialColor,
  ValueChanged<Color> onChanged,
);

/// 颜色选择器
class ColorPic extends StatelessWidget {
  const ColorPic({
    Key? key,
    this.nowColor,
    this.builder,
    this.closeAfterPicked = false,
  }) : super(key: key);

  final Color? nowColor;
  final ColorPickerBuilder? builder;
  final bool closeAfterPicked;

  static Widget defaultColorPickerBuilder(
    BuildContext context,
    Color initialColor,
    ValueChanged<Color> onChanged,
  ) {
    return ColorPicker(
      color: initialColor,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color? _pickColor = nowColor;

    return Material(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (!closeAfterPicked)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(icon: const Icon(CupertinoIcons.clear), onPressed: () => Navigator.pop(context)),
                  IconButton(
                    icon: const Icon(CupertinoIcons.check_mark),
                    onPressed: () => Navigator.pop(context, _pickColor),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: (builder ?? ColorPic.defaultColorPickerBuilder).call(
                context,
                _pickColor ?? Colors.red,
                (Color c) {
                  _pickColor = c;
                  if (closeAfterPicked) {
                    Navigator.pop(context, _pickColor);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

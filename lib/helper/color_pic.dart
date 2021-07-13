import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

///颜色选择器
class ColorPic extends StatelessWidget {
  const ColorPic({Key? key, this.nowColor}) : super(key: key);

  final Color? nowColor;

  @override
  Widget build(BuildContext context) {
    Color? _pickColor = nowColor;

    return Material(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                    icon: const Icon(CupertinoIcons.clear),
                    onPressed: () => Navigator.pop(context)),
                IconButton(
                    icon: const Icon(CupertinoIcons.check_mark),
                    onPressed: () => Navigator.pop(context, _pickColor)),
              ],
            ),
            ColorPicker(
                pickerColor: _pickColor!,
                onColorChanged: (Color c) => _pickColor = c),
          ],
        ),
      ),
    );
  }
}

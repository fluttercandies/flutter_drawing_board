import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';

/// 颜色选择器
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
                  onPressed: () => Navigator.pop(context, _pickColor),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ColorPicker(
                color: _pickColor ?? Colors.red,
                onChanged: (Color c) => _pickColor = c,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

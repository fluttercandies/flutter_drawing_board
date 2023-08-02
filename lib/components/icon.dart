import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/components/styles/default_icon_style.dart';
import 'package:flutter_svg/svg.dart';

class FIcon extends StatelessWidget {
  FIcon({
    Key? key,
    required this.icon,
    this.color,
    this.size,
  })  : primaryColor = null,
        secondaryColor = null,
        super(key: key);

  /// string icon thông qua static field của class FIcons
  final String icon;

  /// tone màu icon thứ nhất [twotone]
  final Color? primaryColor;

  /// tone màu icon thứ 2 [twotone]
  final Color? secondaryColor;

  /// màu icon mặc định là màu grey10
  final Color? color;

  /// size icon, mặc định là 24
  final double? size;

  @override
  Widget build(BuildContext context) {
    String _icon;
    final FDefaultIconStyle? _defaultIconStyle = FDefaultIconStyle.of(context);

    final Color _effectiveColor = color ?? _defaultIconStyle?.color ?? const Color(0xFF000000);
    final double _effectiveSize = size ?? _defaultIconStyle?.size ?? 24;

    _icon = icon
        .replaceAll('fill="black"', 'fill="#${_effectiveColor.toString().substring(10, 16)}"')
        .replaceAll('stroke="black"', 'stroke="#${_effectiveColor.toString().substring(10, 16)}"');

    return SvgPicture.string(
      _icon,
      height: _effectiveSize,
      width: _effectiveSize,
    );
  }
}

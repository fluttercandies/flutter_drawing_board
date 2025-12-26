import 'package:flutter/material.dart';

import '../../helpers.dart';
import '../../paint_contents.dart';
import '../drawing_controller.dart';

class DefaultToolItem extends StatelessWidget {
  const DefaultToolItem({
    super.key,
    required this.icon,
    required this.content,
    this.onTap,
    this.color,
    this.activeColor = Colors.blue,
    this.iconSize = 24,
    this.backgroundColor,
  });

  factory DefaultToolItem.pen() {
    return DefaultToolItem(
      onTap: (DrawingController controller) => controller.setPaintContent(SimpleLine()),
      icon: Icons.edit,
      content: SimpleLine,
    );
  }

  factory DefaultToolItem.brush() {
    return DefaultToolItem(
      onTap: (DrawingController controller) => controller.setPaintContent(SmoothLine()),
      icon: Icons.brush,
      content: SmoothLine,
    );
  }

  factory DefaultToolItem.eraser() {
    return DefaultToolItem(
      onTap: (DrawingController controller) => controller.setPaintContent(Eraser()),
      icon: Icons.cleaning_services,
      content: Eraser,
    );
  }

  factory DefaultToolItem.rectangle() {
    return DefaultToolItem(
      onTap: (DrawingController controller) => controller.setPaintContent(Rectangle()),
      icon: Icons.rectangle_outlined,
      content: Rectangle,
    );
  }

  factory DefaultToolItem.circle() {
    return DefaultToolItem(
      onTap: (DrawingController controller) => controller.setPaintContent(Circle()),
      icon: Icons.circle_outlined,
      content: Circle,
    );
  }

  factory DefaultToolItem.straightLine() {
    return DefaultToolItem(
      onTap: (DrawingController controller) => controller.setPaintContent(StraightLine()),
      icon: Icons.show_chart,
      content: StraightLine,
    );
  }

  final void Function(DrawingController controller)? onTap;
  final Type content;
  final IconData icon;
  final double iconSize;
  final Color? color;
  final Color activeColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final DrawingController? controller = DrawingControllerProvider.maybeOf(context);

    if (controller == null) {
      throw Exception(
        'DefaultToolItem must be placed within a DrawingBar or DrawingControllerProvider',
      );
    }

    return TextButton(
      onPressed: () => onTap?.call(controller),
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.white,
        padding: const EdgeInsets.all(5),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      ),
      child: ExValueBuilder<DrawConfig>(
        valueListenable: controller.drawConfig,
        shouldRebuild: (DrawConfig p, DrawConfig n) =>
            p.contentType != n.contentType &&
            (p.contentType == content || n.contentType == content),
        builder: (BuildContext context, DrawConfig value, Widget? child) {
          final bool isActive = value.contentType == content;

          return Icon(icon, size: iconSize, color: isActive ? activeColor : (color ?? Colors.grey));
        },
      ),
    );
  }
}

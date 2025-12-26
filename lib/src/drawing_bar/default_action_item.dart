import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../drawing_controller.dart';

class DefaultActionItem extends StatelessWidget {
  const DefaultActionItem({
    super.key,
    required this.childBuilder,
    this.onTap,
    this.backgroundColor,
  });

  factory DefaultActionItem.slider({SliderThemeData? theme, double? min, double? max}) {
    return DefaultActionItem(
      childBuilder: (BuildContext context, DrawingController controller) {
        return SizedBox(
          height: 24,
          child: SliderTheme(
            data: theme ?? SliderTheme.of(context),
            child: Slider(
              value: controller.drawConfig.value.strokeWidth,
              max: max ?? 50,
              min: min ?? 1,
              onChanged: (double value) {
                controller.setStyle(strokeWidth: value);
              },
            ),
          ),
        );
      },
    );
  }

  factory DefaultActionItem.undo() {
    return DefaultActionItem(
      onTap: (DrawingController controller) => controller.undo(),
      childBuilder: (BuildContext context, DrawingController controller) {
        return Icon(
          CupertinoIcons.arrow_turn_up_left,
          color: controller.canUndo() ? null : Colors.grey,
          size: 24,
        );
      },
    );
  }

  factory DefaultActionItem.redo() {
    return DefaultActionItem(
      onTap: (DrawingController controller) => controller.redo(),
      childBuilder: (BuildContext context, DrawingController controller) {
        return Icon(
          CupertinoIcons.arrow_turn_up_right,
          color: controller.canRedo() ? null : Colors.grey,
          size: 24,
        );
      },
    );
  }

  factory DefaultActionItem.turn() {
    return DefaultActionItem(
      onTap: (DrawingController controller) => controller.turn(),
      childBuilder: (BuildContext context, DrawingController controller) {
        return const Icon(CupertinoIcons.rotate_right, size: 24);
      },
    );
  }

  factory DefaultActionItem.clear() {
    return DefaultActionItem(
      onTap: (DrawingController controller) => controller.clear(),
      childBuilder: (BuildContext context, DrawingController controller) {
        return Icon(
          CupertinoIcons.trash,
          size: 24,
          color: controller.canClear() ? null : Colors.grey,
        );
      },
    );
  }

  final Widget Function(BuildContext context, DrawingController controller) childBuilder;
  final void Function(DrawingController controller)? onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final DrawingController? controller = DrawingControllerProvider.maybeOf(context);

    if (controller == null) {
      throw Exception(
        'DefaultActionItem must be placed within a DrawingBar or DrawingControllerProvider',
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
      child: ListenableBuilder(
        listenable: Listenable.merge(<Listenable?>[controller.drawConfig, controller]),
        builder: (BuildContext context, Widget? child) {
          return childBuilder(context, controller);
        },
      ),
    );
  }
}

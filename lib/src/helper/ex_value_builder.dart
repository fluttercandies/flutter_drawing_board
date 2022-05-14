// 拷贝ValueListenableBuilder
// 添加shouldRebuild方法

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_drawing_board/src/helper/safe_state.dart';

typedef ValueWidgetBuilder<T> = Widget Function(
    BuildContext context, T value, Widget? child);

class ExValueBuilder<T> extends StatefulWidget {
  const ExValueBuilder({
    Key? key,
    required this.valueListenable,
    required this.builder,
    this.child,
    this.shouldRebuild,
  }) : super(key: key);

  final ValueListenable<T> valueListenable;

  final ValueWidgetBuilder<T> builder;

  final Widget? child;

  ///是否进行重建
  final bool Function(T previous, T next)? shouldRebuild;

  @override
  State<StatefulWidget> createState() => _ExValueBuilderState<T>();
}

class _ExValueBuilderState<T> extends State<ExValueBuilder<T>>
    with SafeState<ExValueBuilder<T>> {
  late T value;

  @override
  void initState() {
    super.initState();
    value = widget.valueListenable.value;
    widget.valueListenable.addListener(_valueChanged);
  }

  @override
  void didUpdateWidget(ExValueBuilder<T> oldWidget) {
    if (oldWidget.valueListenable != widget.valueListenable) {
      oldWidget.valueListenable.removeListener(_valueChanged);
      value = widget.valueListenable.value;
      widget.valueListenable.addListener(_valueChanged);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.valueListenable.removeListener(_valueChanged);
    super.dispose();
  }

  void _valueChanged() {
    ///条件判断
    if (widget.shouldRebuild?.call(value, widget.valueListenable.value) ??
        true) {
      safeSetState(() {
        value = widget.valueListenable.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, value, widget.child);
  }
}

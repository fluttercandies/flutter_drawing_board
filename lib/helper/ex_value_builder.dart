//扩展ValueListenableBuilder
//添加shouldRebuild

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

typedef ValueWidgetBuilder<T> = Widget Function(BuildContext context, T value, Widget child);

class ExValueBuilder<T> extends StatefulWidget {
  const ExValueBuilder({
    Key key,
    @required this.valueListenable,
    @required this.builder,
    this.child,
    this.shouldRebuild,
  })  : assert(valueListenable != null),
        assert(builder != null),
        super(key: key);

  final ValueListenable<T> valueListenable;

  final ValueWidgetBuilder<T> builder;

  final bool Function(T previous, T next) shouldRebuild;

  final Widget child;

  @override
  State<StatefulWidget> createState() => _ExValueBuilderState<T>();
}

class _ExValueBuilderState<T> extends State<ExValueBuilder<T>> {
  T value;

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
    if (widget.shouldRebuild == null || widget.shouldRebuild(value, widget.valueListenable.value)) {
      setState(() {
        value = widget.valueListenable.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, value, widget.child);
  }
}

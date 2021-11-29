import 'package:flutter/material.dart';

/// ValueNotifier安全扩展
class SafeValueNotifier<T> extends ValueNotifier<T> {
  SafeValueNotifier(T value) : super(value);

  bool _mounted = true;

  @override
  set value(T newValue) {
    if (_mounted) super.value = newValue;
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
}

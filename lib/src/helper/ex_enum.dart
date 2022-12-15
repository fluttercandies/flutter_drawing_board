/// enum解析工具
/// tools of convert enum
class ExEnum {
  const ExEnum._();

  static bool _isEnum<T>(Object item) {
    final List<String> splitItem = item.toString().split('.');
    return splitItem.length > 1 && splitItem[0] == T.toString();
  }

  static T? tryParse<T extends Object>(List<T> values, String? item) {
    if (item == null) return null;
    if (!_isEnum<T>(item)) throw Exception('Item $item is not ${T.toString()}');

    for (final T value in values) {
      if (value.toString() == item) return value;
    }

    return null;
  }
}

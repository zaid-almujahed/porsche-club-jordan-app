abstract final class JsonReaders {
  static String string(Map<String, dynamic> json, String key) {
    final Object? value = json[key];
    if (value == null) throw FormatException('Missing JSON field: $key');
    return value.toString();
  }

  static String? nullableString(Map<String, dynamic> json, String key) {
    final Object? value = json[key];
    return value?.toString();
  }

  static int integer(Map<String, dynamic> json, String key) {
    final Object? value = json[key];
    if (value is int) return value;
    return int.parse(string(json, key));
  }

  static double decimal(Map<String, dynamic> json, String key) {
    final Object? value = json[key];
    if (value is num) return value.toDouble();
    return double.parse(string(json, key));
  }

  static bool boolean(
    Map<String, dynamic> json,
    String key, {
    bool fallback = false,
  }) {
    final Object? value = json[key];
    if (value == null) return fallback;
    if (value is bool) return value;
    return value.toString().toLowerCase() == 'true' || value.toString() == '1';
  }

  static DateTime dateTime(Map<String, dynamic> json, String key) {
    return DateTime.parse(string(json, key));
  }

  static DateTime? nullableDateTime(Map<String, dynamic> json, String key) {
    final String? value = nullableString(json, key);
    return value == null ? null : DateTime.parse(value);
  }

  static T enumValue<T extends Enum>(
    List<T> values,
    Object? rawValue, {
    required T fallback,
  }) {
    if (rawValue == null) return fallback;
    final String normalizedValue = _normalizeEnumName(rawValue.toString());
    return values.firstWhere(
      (T value) => _normalizeEnumName(value.name) == normalizedValue,
      orElse: () => fallback,
    );
  }

  static List<String> strings(Map<String, dynamic> json, String key) {
    final Object? value = json[key];
    if (value is! List<dynamic>) return const <String>[];
    return List<String>.unmodifiable(value.map((Object? item) => '$item'));
  }

  static List<Map<String, dynamic>> maps(
    Map<String, dynamic> json,
    String key,
  ) {
    final Object? value = json[key];
    if (value is! List<dynamic>) return const <Map<String, dynamic>>[];
    return List<Map<String, dynamic>>.unmodifiable(
      value.map((Object? item) => Map<String, dynamic>.from(item! as Map)),
    );
  }

  static String _normalizeEnumName(String value) {
    return value.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');
  }
}

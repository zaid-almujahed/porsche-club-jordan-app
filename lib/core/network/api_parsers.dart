import '../errors/app_exception.dart';

Map<String, dynamic> requireJsonMap(
  Object? value, {
  String description = 'response',
}) {
  final Object? unwrapped = unwrapApiData(value);
  if (unwrapped is Map) return Map<String, dynamic>.from(unwrapped);
  throw AppException('The server returned an invalid $description.');
}

List<Map<String, dynamic>> requireJsonMapList(
  Object? value, {
  String description = 'response',
}) {
  final Object? unwrapped = unwrapApiData(value);
  if (unwrapped is! List) {
    throw AppException('The server returned an invalid $description.');
  }
  return unwrapped
      .map<Map<String, dynamic>>((Object? item) {
        if (item is! Map) {
          throw AppException(
            'The server returned an invalid $description item.',
          );
        }
        return Map<String, dynamic>.from(item);
      })
      .toList(growable: false);
}

/// Accepts direct FastAPI responses and common `{data: ...}` envelopes.
Object? unwrapApiData(Object? value) {
  if (value is! Map) return value;
  final Map<String, dynamic> map = Map<String, dynamic>.from(value);
  if (map.containsKey('data')) return map['data'];
  if (map.containsKey('result')) return map['result'];
  return map;
}

String? firstString(Map<String, dynamic> json, Iterable<String> keys) {
  for (final String key in keys) {
    final Object? value = json[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  }
  return null;
}

int? firstInt(Map<String, dynamic> json, Iterable<String> keys) {
  for (final String key in keys) {
    final Object? value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    final int? parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
  }
  return null;
}

double? firstDouble(Map<String, dynamic> json, Iterable<String> keys) {
  for (final String key in keys) {
    final Object? value = json[key];
    if (value is num) return value.toDouble();
    final double? parsed = double.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
  }
  return null;
}

DateTime? firstDateTime(Map<String, dynamic> json, Iterable<String> keys) {
  final String? value = firstString(json, keys);
  return value == null ? null : DateTime.tryParse(value);
}

import 'dart:async';

/// Small in-memory cache for read-only member data.
///
/// It deliberately does not persist authentication or form data. Entries are
/// cleared whenever the authenticated member changes or signs out.
class MemoryCache {
  final Map<String, _CacheEntry<Object?>> _entries =
      <String, _CacheEntry<Object?>>{};
  final Map<String, Future<Object?>> _inFlight = <String, Future<Object?>>{};

  T? read<T>(String key) {
    final _CacheEntry<Object?>? entry = _entries[key];
    if (entry == null) return null;
    if (entry.expiresAt.isBefore(DateTime.now())) {
      _entries.remove(key);
      return null;
    }
    final Object? value = entry.value;
    return value is T ? value : null;
  }

  void write<T>(String key, T value, {required Duration ttl}) {
    _entries[key] = _CacheEntry<Object?>(
      value: value,
      expiresAt: DateTime.now().add(ttl),
    );
  }

  Future<T> getOrLoad<T>(
    String key,
    Future<T> Function() loader, {
    required Duration ttl,
    bool force = false,
  }) async {
    if (!force) {
      final T? cached = read<T>(key);
      if (cached != null) return cached;

      final Future<Object?>? existing = _inFlight[key];
      if (existing != null) return (await existing) as T;
    }

    final Future<T> request = loader();
    _inFlight[key] = request;
    try {
      final T value = await request;
      write<T>(key, value, ttl: ttl);
      return value;
    } finally {
      if (identical(_inFlight[key], request)) _inFlight.remove(key);
    }
  }

  void remove(String key) {
    _entries.remove(key);
    _inFlight.remove(key);
  }

  void removeWhere(bool Function(String key) test) {
    _entries.removeWhere((String key, _) => test(key));
    _inFlight.removeWhere((String key, _) => test(key));
  }

  void clear() {
    _entries.clear();
    _inFlight.clear();
  }
}

class _CacheEntry<T> {
  const _CacheEntry({required this.value, required this.expiresAt});

  final T value;
  final DateTime expiresAt;
}

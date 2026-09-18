import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the bearer token outside the widget tree.
abstract interface class TokenStore {
  Future<String?> read();

  Future<void> write(String token);

  Future<void> clear();
}

class SecureTokenStore implements TokenStore {
  SecureTokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _tokenKey = 'pcj_access_token';

  final FlutterSecureStorage _storage;
  String? _cachedToken;
  bool _hasLoadedToken = false;

  @override
  Future<String?> read() async {
    if (_hasLoadedToken) return _cachedToken;
    _cachedToken = await _storage.read(key: _tokenKey);
    _hasLoadedToken = true;
    return _cachedToken;
  }

  @override
  Future<void> write(String token) async {
    final String cleanToken = token.trim();
    _cachedToken = cleanToken;
    _hasLoadedToken = true;
    await _storage.write(key: _tokenKey, value: cleanToken);
  }

  @override
  Future<void> clear() async {
    _cachedToken = null;
    _hasLoadedToken = true;
    await _storage.delete(key: _tokenKey);
  }
}

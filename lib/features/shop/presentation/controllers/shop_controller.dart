import 'package:flutter/foundation.dart';

import 'package:pcj_v4/core/state/async_state.dart';
import 'package:pcj_v4/shared/domain/entities/product.dart';

import '../../domain/repositories/shop_repository.dart';

class ShopController extends ChangeNotifier {
  ShopController({required ShopRepository repository})
    : _repository = repository;

  final ShopRepository _repository;
  AsyncState<List<Product>> _products =
      const AsyncState<List<Product>>.initial();
  List<Product> _allProducts = const <Product>[];
  List<String> _categories = const <String>[];
  String? _selectedCategory;
  int _requestId = 0;

  AsyncState<List<Product>> get products => _products;
  List<String> get categories => _categories;
  String? get selectedCategory => _selectedCategory;

  Future<void> load({bool force = false}) async {
    if (!force && (_products.isLoading || _products.hasData)) return;
    await _fetch();
  }

  void selectCategory(String? category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    if (_products.hasData) _applyFilter();
    notifyListeners();
  }

  Future<void> _fetch() async {
    final int requestId = ++_requestId;
    _products = AsyncState<List<Product>>.loading(previousData: _products.data);
    notifyListeners();
    try {
      final List<Product> products = List<Product>.unmodifiable(
        await _repository.getProducts(),
      );
      if (requestId != _requestId) return;
      _allProducts = products;
      _categories = List<String>.unmodifiable(
        products
            .map((Product product) => product.category.trim())
            .where((String value) => value.isNotEmpty)
            .toSet(),
      );
      _applyFilter();
    } catch (error, stackTrace) {
      if (requestId != _requestId) return;
      _products = AsyncState<List<Product>>.failure(
        error,
        stackTrace,
        previousData: _products.data,
      );
    }
    if (requestId != _requestId) return;
    notifyListeners();
  }

  void _applyFilter() {
    final String selected = _selectedCategory?.trim().toLowerCase() ?? '';
    final List<Product> visible = selected.isEmpty
        ? _allProducts
        : _allProducts
              .where(
                (Product product) =>
                    product.category.trim().toLowerCase() == selected,
              )
              .toList(growable: false);
    _products = AsyncState<List<Product>>.success(
      List<Product>.unmodifiable(visible),
    );
  }

  void reset() {
    _requestId++;
    _products = const AsyncState<List<Product>>.initial();
    _allProducts = const <Product>[];
    _categories = const <String>[];
    _selectedCategory = null;
    notifyListeners();
  }
}

import 'package:pcj_v4/core/errors/app_exception.dart';
import 'package:pcj_v4/core/network/api_parsers.dart';
import 'package:pcj_v4/core/network/pcj_api_client.dart';
import 'package:pcj_v4/core/cache/memory_cache.dart';
import 'package:pcj_v4/features/shop/domain/repositories/shop_repository.dart';
import 'package:pcj_v4/shared/domain/entities/cart.dart';
import 'package:pcj_v4/shared/domain/entities/order.dart';

import '../models/product_model.dart';

class ApiShopRepository implements ShopRepository {
  ApiShopRepository({
    required PcjApiClient apiClient,
    required MemoryCache cache,
  }) : _apiClient = apiClient,
       _cache = cache;

  final PcjApiClient _apiClient;
  final MemoryCache _cache;
  List<CartItem> _localCartItems = const <CartItem>[];

  @override
  Future<List<Product>> getProducts({String? category}) async {
    final List<Product> products = await _cache.getOrLoad<List<Product>>(
      'shop:products',
      () async => _mapList(
        await _apiClient.get('/member/items'),
        keys: const <String>['items', 'products'],
        description: 'items response',
      ).map<Product>(ProductModel.fromJson).toList(growable: false),
      ttl: const Duration(minutes: 5),
    );
    final String normalized = category?.trim().toLowerCase() ?? '';
    if (normalized.isEmpty || normalized == 'all categories') return products;
    return products
        .where(
          (Product product) => product.category.toLowerCase() == normalized,
        )
        .toList(growable: false);
  }

  @override
  Future<Product> getProduct(String productId) async {
    return _cache.getOrLoad<Product>(
      'shop:product:$productId',
      () async => ProductModel.fromJson(
        requireJsonMap(
          await _apiClient.get(
            '/member/items/${Uri.encodeComponent(productId)}',
          ),
          description: 'item response',
        ),
      ),
      ttl: const Duration(minutes: 5),
    );
  }

  @override
  Future<Cart> getCart() async {
    // Cart route names are known, but their request fields and response
    // schemas are not. Keep this cart session-only until that contract is
    // supplied; do not guess payload keys that could create the wrong order.
    return _localCart();
  }

  @override
  Future<Cart> addToCart(AddToCartRequest request) async {
    if (!request.variant.isInStock || request.quantity > request.variant.stock) {
      throw const AppException('The selected product variant is out of stock.');
    }
    final List<CartItem> items = List<CartItem>.of(_localCartItems);
    final int existingIndex = items.indexWhere(
      (CartItem item) => item.variantId == request.variantId,
    );
    final ProductColorOption? selectedColor = _findColor(
      request.product,
      request.variant.colorName,
    );
    if (existingIndex >= 0) {
      final CartItem existing = items[existingIndex];
      final int quantity = existing.quantity + request.quantity;
      if (quantity > request.variant.stock) {
        throw const AppException(
          'The requested quantity exceeds the available stock.',
        );
      }
      items[existingIndex] = CartItem(
        id: existing.id,
        product: request.product,
        quantity: quantity,
        selectedColor: selectedColor,
        selectedSize: request.variant.size,
        variantId: request.variant.id,
      );
    } else {
      items.add(
        CartItem(
          id: request.variant.id,
          product: request.product,
          quantity: request.quantity,
          selectedColor: selectedColor,
          selectedSize: request.variant.size,
          variantId: request.variant.id,
        ),
      );
    }
    _localCartItems = List<CartItem>.unmodifiable(items);
    return _localCart();
  }

  @override
  Future<Cart> updateCartItemQuantity(String cartItemId, int quantity) async {
    if (quantity < 1) return removeCartItem(cartItemId);
    final List<CartItem> items = List<CartItem>.of(_localCartItems);
    final int index = items.indexWhere((CartItem item) => item.id == cartItemId);
    if (index < 0) throw const AppException('The cart item was not found.');
    final CartItem item = items[index];
    final ProductVariant? variant = item.product.variants
        .cast<ProductVariant?>()
        .firstWhere(
          (ProductVariant? value) => value?.id == item.variantId,
          orElse: () => null,
        );
    if (variant != null && quantity > variant.stock) {
      throw const AppException(
        'The requested quantity exceeds the available stock.',
      );
    }
    items[index] = CartItem(
      id: item.id,
      product: item.product,
      quantity: quantity,
      selectedColor: item.selectedColor,
      selectedSize: item.selectedSize,
      variantId: item.variantId,
    );
    _localCartItems = List<CartItem>.unmodifiable(items);
    return _localCart();
  }

  @override
  Future<Cart> removeCartItem(String cartItemId) async {
    _localCartItems = _localCartItems
        .where((CartItem item) => item.id != cartItemId)
        .toList(growable: false);
    return _localCart();
  }

  @override
  Future<Order> placeOrder(PlaceOrderRequest request) async {
    throw const UnsupportedApiOperationException(
      'Checkout is ready in the app, but the PCJ checkout request and payment '
      'handoff contract have not been supplied yet.',
    );
  }

  @override
  void clearLocalState() {
    _localCartItems = const <CartItem>[];
  }

  Cart _localCart() {
    final String currency = _localCartItems.isEmpty
        ? 'JOD'
        : _localCartItems.first.product.currency;
    return Cart(
      items: List<CartItem>.unmodifiable(_localCartItems),
      shippingFee: 0,
      currency: currency,
    );
  }

  static ProductColorOption? _findColor(Product product, String? name) {
    final String normalized = name?.trim().toLowerCase() ?? '';
    for (final ProductColorOption color in product.colors) {
      if (color.name.trim().toLowerCase() == normalized) return color;
    }
    return null;
  }

  static List<Map<String, dynamic>> _mapList(
    Object? response, {
    required List<String> keys,
    required String description,
  }) {
    Object? value = unwrapApiData(response);
    if (value is Map) {
      final Map<Object?, Object?> responseMap = Map<Object?, Object?>.from(
        value,
      );
      for (final String key in keys) {
        final Object? candidate = responseMap[key];
        if (candidate is List) {
          value = candidate;
          break;
        }
      }
    }
    if (value is! List) {
      throw AppException('The server returned an invalid $description.');
    }
    return value
        .whereType<Map>()
        .map<Map<String, dynamic>>((Map item) {
          return Map<String, dynamic>.from(item);
        })
        .toList(growable: false);
  }
}

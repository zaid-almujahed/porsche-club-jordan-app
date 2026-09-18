import 'package:flutter/material.dart';

import 'package:pcj_v4/core/errors/app_exception.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/core/utils/app_formatters.dart';
import 'package:pcj_v4/shared/domain/entities/cart.dart';
import 'package:pcj_v4/shared/domain/entities/product.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

import '../controllers/product_details_controller.dart';
import '../widgets/product_details_widgets.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({
    super.key,
    required this.controller,
    required this.onAddedToCart,
  });

  final ProductDetailsController controller;
  final ValueChanged<Cart> onAddedToCart;

  Future<void> _addToCart() async {
    final Cart? cart = await controller.addToCart();
    if (cart != null) onAddedToCart(cart);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        final Product? product = controller.state.data;
        return Scaffold(
          backgroundColor: AppColors.canvas,
          appBar: const PorscheAppBar(title: 'Shop', showBack: true),
          bottomNavigationBar: product == null
              ? null
              : SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                    decoration: const BoxDecoration(
                      color: AppColors.canvas,
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: controller.selectedVariant != null
                        ? PrimaryActionButton(
                            label: controller.isAddingToCart
                                ? 'Adding...'
                                : 'Add to Cart',
                            onPressed: controller.isAddingToCart
                                ? null
                                : _addToCart,
                            height: 64,
                          )
                        : const SecondaryActionButton(
                            label: 'OUT OF STOCK',
                            height: 64,
                          ),
                  ),
                ),
          body: AppPageBody(
            topPadding: AppSpacing.section,
            child: AsyncStateView<Product>(
              state: controller.state,
              onRetry: controller.refresh,
              builder: (BuildContext context, Product product) {
                final String selectedImage = product.imageUrls.isEmpty
                    ? ''
                    : product.imageUrls[controller.selectedImageIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: 1,
                      child: AppAssetImage(
                        path: selectedImage,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(24),
                        ),
                        fallbackIcon: Icons.checkroom,
                      ),
                    ),
                    if (product.imageUrls.isNotEmpty) ...<Widget>[
                      const SizedBox(height: AppSpacing.lg),
                      ProductThumbnails(
                        images: product.imageUrls,
                        selectedIndex: controller.selectedImageIndex,
                        onSelected: controller.selectImage,
                      ),
                    ],
                    const SizedBox(height: 44),
                    Text(
                      product.category.toUpperCase(),
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 54,
                        fontWeight: FontWeight.w400,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      AppFormatters.money(
                        controller.selectedPrice,
                        product.currency,
                      ),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 29,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    const Divider(),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(product.description, style: AppTextStyles.bodyLarge),
                    if (controller.availableColors.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 44),
                      ColorSelector(
                        colors: controller.availableColors,
                        selectedColor: controller.selectedColor,
                        onSelected: controller.selectColor,
                      ),
                    ],
                    if (controller.availableSizes.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 44),
                      SizeSelector(
                        sizes: controller.availableSizes,
                        selectedSize: controller.selectedSize,
                        onSelected: controller.selectSize,
                      ),
                    ],
                    const SizedBox(height: 36),
                    QuantitySelector(
                      quantity: controller.quantity,
                      canIncrement:
                          controller.quantity < controller.maximumQuantity,
                      onIncrement: controller.incrementQuantity,
                      onDecrement: controller.decrementQuantity,
                    ),
                    if (controller.cartError != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        readableError(controller.cartError!),
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

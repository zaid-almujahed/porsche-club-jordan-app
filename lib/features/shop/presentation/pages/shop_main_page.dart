import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pcj_v4/core/routing/app_router.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/domain/entities/product.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

import '../controllers/shop_controller.dart';
import '../widgets/product_page_widgets.dart';

class ShopMainPage extends StatelessWidget {
  const ShopMainPage({
    super.key,
    required this.controller,
    this.unreadNotificationCount,
  });

  final ShopController controller;
  final ValueListenable<int>? unreadNotificationCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.canvas,
      appBar: PorscheAppBar(
        title: 'Shop',
        showCart: true,
        showNotifications: true,
        unreadNotificationCount: unreadNotificationCount,
        onCartPressed: () => context.push(AppRoutes.checkout),
        onNotificationsPressed: () => context.push(AppRoutes.notifications),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          return AppPageBody(
            topPadding: AppSpacing.lg,
            bottomPadding:
                AppLayout.navigationBarHeight + AppSpacing.pageBottom,
            onRefresh: () => controller.load(force: true),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // if (controller.categories.isNotEmpty)
                //   _ShopCategories(
                //     categories: controller.categories,
                //     selectedCategory: controller.selectedCategory,
                //     onSelected: controller.selectCategory,
                //   ),
                // const SizedBox(height: 36),
                AsyncStateView<List<Product>>(
                  state: controller.products,
                  onRetry: () => controller.load(force: true),
                  isEmpty: (List<Product> products) => products.isEmpty,
                  emptyMessage: 'No products are currently available.',
                  builder: (BuildContext context, List<Product> products) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 26,
                            mainAxisSpacing: 44,
                            childAspectRatio: 0.58,
                          ),
                      itemBuilder: (BuildContext context, int index) {
                        final Product product = products[index];
                        return ProductTile(
                          product: product,
                          onTap: () => context.push(
                            AppRoutes.productDetailsLocation(product.id),
                            extra: product,
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ShopCategories extends StatelessWidget {
  const _ShopCategories({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final List<String?> values = <String?>[null, ...categories];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: values.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xl),
        itemBuilder: (BuildContext context, int index) {
          final String? value = values[index];
          final bool selected = value == selectedCategory;
          return InkWell(
            onTap: () => onSelected(value),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: selected
                    ? const Border(
                        bottom: BorderSide(
                          color: AppColors.textPrimary,
                          width: 2,
                        ),
                      )
                    : null,
              ),
              child: Text(
                value?.toUpperCase() ?? 'ALL CATEGORIES',
                style: AppTextStyles.label.copyWith(
                  color: selected ? AppColors.textPrimary : AppColors.textFaint,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

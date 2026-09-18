import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pcj_v4/core/routing/app_router.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/domain/entities/product.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

import '../controllers/shop_controller.dart';
import '../widgets/product_page_widgets.dart';

class ShopMainPage extends StatelessWidget {
  const ShopMainPage({super.key, required this.controller});

  final ShopController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.canvas,
      appBar: PorscheAppBar(
        title: 'Shop',
        showCart: true,
        onCartPressed: () => context.push(AppRoutes.checkout),
      ),
      bottomNavigationBar: const AppBottomNavigation(selected: AppSection.shop),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          return AppPageBody(
            topPadding: AppSpacing.lg,
            bottomPadding:
                AppLayout.navigationBarHeight + AppSpacing.pageBottom,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 36),
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

import 'package:flutter/material.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/core/utils/app_formatters.dart';
import 'package:pcj_v4/shared/domain/entities/product.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'View ${product.name}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    AppAssetImage(
                      path: product.primaryImageUrl ?? '',
                      borderRadius: const BorderRadius.all(
                        Radius.circular(AppRadii.large),
                      ),
                      fallbackIcon: Icons.checkroom,
                    ),
                    if (product.badge != null || !product.isInStock)
                      Positioned(
                        top: 18,
                        left: 14,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            color: Color(0xCC131313),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            child: Text(
                              product.isInStock
                                  ? product.badge!
                                  : 'OUT OF STOCK',
                              style: AppTextStyles.label,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                product.name,
                style: AppTextStyles.label.copyWith(fontSize: 15),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppFormatters.money(product.price, product.currency),
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

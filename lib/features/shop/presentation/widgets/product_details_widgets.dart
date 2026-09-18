import 'package:flutter/material.dart';

import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/domain/entities/product.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

class ColorSelector extends StatelessWidget {
  const ColorSelector({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onSelected,
  });

  final List<ProductColorOption> colors;
  final ProductColorOption? selectedColor;
  final ValueChanged<ProductColorOption> onSelected;

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) return const SizedBox.shrink();
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            const Text('COLOR', style: AppTextStyles.label),
            const Spacer(),
            Text(selectedColor?.name ?? '', style: AppTextStyles.bodyLarge),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: colors.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (BuildContext context, int index) {
              final ProductColorOption option = colors[index];
              final bool selected = option == selectedColor;
              return Semantics(
                button: true,
                selected: selected,
                label: option.name,
                child: InkWell(
                  onTap: () => onSelected(option),
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 52,
                    decoration: BoxDecoration(
                      color: Color(option.argbValue),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryBright
                            : AppColors.border,
                        width: selected ? 2 : 1,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SizeSelector extends StatelessWidget {
  const SizeSelector({
    super.key,
    required this.sizes,
    required this.selectedSize,
    required this.onSelected,
  });

  final List<String> sizes;
  final String? selectedSize;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (sizes.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('SIZE', style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: sizes.map((String size) {
            final bool selected = size == selectedSize;
            return InkWell(
              onTap: () => onSelected(size),
              borderRadius: BorderRadius.circular(AppRadii.small),
              child: Container(
                width: 65,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selected
                        ? AppColors.primaryBright
                        : AppColors.border,
                    width: selected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.small),
                ),
                child: Text(size, style: AppTextStyles.label),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.canIncrement,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final bool canIncrement;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('QUANTITY', style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: 154,
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadii.small),
          ),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: quantity <= 1 ? null : onDecrement,
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                child: Text(
                  '$quantity',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge,
                ),
              ),
              IconButton(
                onPressed: canIncrement ? onIncrement : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ProductThumbnails extends StatelessWidget {
  const ProductThumbnails({
    super.key,
    required this.images,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> images;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (BuildContext context, int index) {
          final bool selected = index == selectedIndex;
          return InkWell(
            onTap: () => onSelected(index),
            borderRadius: BorderRadius.circular(AppRadii.large),
            child: Container(
              width: 86,
              decoration: BoxDecoration(
                border: Border.all(
                  color: selected ? AppColors.primaryBright : AppColors.border,
                  width: selected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(AppRadii.large),
              ),
              child: AppAssetImage(
                path: images[index],
                borderRadius: const BorderRadius.all(Radius.circular(22)),
                fallbackIcon: Icons.checkroom,
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pcj_v4/core/routing/app_router.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/core/utils/app_formatters.dart';
import 'package:pcj_v4/shared/domain/entities/event.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

class CategoryFilters extends StatelessWidget {
  const CategoryFilters({
    super.key,
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
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: values.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (BuildContext context, int index) {
          final String? value = values[index];
          return _FilterChip(
            label: value?.toUpperCase() ?? 'ALL EVENTS',
            selected: value == selectedCategory,
            onTap: () => onSelected(value),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(AppRadii.pill);
    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.panelDark,
          border: Border.all(
            color: selected ? AppColors.primaryBright : AppColors.border,
          ),
          borderRadius: borderRadius,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(child: Text(label, style: AppTextStyles.label)),
          ),
        ),
      ),
    );
  }
}

class UpcomingEventsCarousel extends StatefulWidget {
  const UpcomingEventsCarousel({super.key, required this.upcomingEvents});

  final List<Event> upcomingEvents;

  @override
  State<UpcomingEventsCarousel> createState() => _UpcomingEventsCarouselState();
}

class _UpcomingEventsCarouselState extends State<UpcomingEventsCarousel> {
  late final PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.94);
  }

  @override
  void didUpdateWidget(UpcomingEventsCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedIndex >= widget.upcomingEvents.length) {
      _selectedIndex = 0;
      if (_pageController.hasClients) _pageController.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double cardWidth = constraints.maxWidth * 0.94;
        final double imageHeight = cardWidth / 0.86;

        return Column(
          children: <Widget>[
            SizedBox(
              height: imageHeight + 92,
              child: PageView.builder(
                controller: _pageController,
                padEnds: false,
                itemCount: widget.upcomingEvents.length,
                onPageChanged: (int index) {
                  setState(() => _selectedIndex = index);
                },
                itemBuilder: (BuildContext context, int index) {
                  final Event event = widget.upcomingEvents[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == widget.upcomingEvents.length - 1
                          ? 0
                          : AppSpacing.md,
                    ),
                    child: _UpcomingEventCard(
                      event: event,
                      onTap: () => context.push(
                        AppRoutes.eventDetailsLocation(event.id),
                        extra: event,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _CarouselDots(
              itemCount: widget.upcomingEvents.length,
              selectedIndex: _selectedIndex,
              onSelected: (int index) {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _CarouselDots extends StatelessWidget {
  const _CarouselDots({
    required this.itemCount,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int itemCount;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(itemCount, (int index) {
        final bool selected = index == selectedIndex;
        return InkWell(
          onTap: () => onSelected(index),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: selected ? 20 : 7,
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryBright : AppColors.textFaint,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
          ),
        );
      }),
    );
  }
}

class _UpcomingEventCard extends StatelessWidget {
  const _UpcomingEventCard({required this.event, required this.onTap});

  final Event event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
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
                    path: event.posterUrl,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(AppRadii.large),
                    ),
                    fallbackIcon: Icons.directions_car_outlined,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.large),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[Color(0x22000000), Color(0xE6000000)],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          event.category.toUpperCase(),
                          style: AppTextStyles.label,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          event.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.pageTitle.copyWith(fontSize: 32),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _EventMeta(
              icon: Icons.schedule_outlined,
              value: AppFormatters.dateAndTime(event.startsAt).toUpperCase(),
            ),
            const SizedBox(height: AppSpacing.md),
            _EventMeta(
              icon: Icons.location_on_outlined,
              value: event.location.toUpperCase(),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventMeta extends StatelessWidget {
  const _EventMeta({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 17, color: AppColors.textFaint),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pcj_v4/core/routing/app_router.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/domain/entities/event.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

import '../controllers/events_controller.dart';
import '../widgets/event_page_widgets.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key, required this.controller});

  final EventsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.canvas,
      appBar: const PorscheAppBar(title: 'Events'),
      bottomNavigationBar: const AppBottomNavigation(
        selected: AppSection.events,
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          return AppPageBody(
            topPadding: AppSpacing.section,
            bottomPadding:
                AppLayout.navigationBarHeight + AppSpacing.pageBottom,
            child: AsyncStateView<List<Event>>(
              state: controller.events,
              onRetry: () => controller.load(force: true),
              builder: (BuildContext context, List<Event> events) {
                Event? featured;
                for (final Event event in events) {
                  if (event.isFeatured) {
                    featured = event;
                    break;
                  }
                }
                final Event? featuredEvent =
                    featured ?? (events.isEmpty ? null : events.first);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (featuredEvent != null) ...<Widget>[
                      FeaturedEvent(
                        event: featuredEvent,
                        onPressed: () => context.push(
                          AppRoutes.eventDetailsLocation(featuredEvent.id),
                          extra: featuredEvent,
                        ),
                      ),
                      const SizedBox(height: 38),
                    ],
                    if (controller.categories.isNotEmpty)
                      CategoryFilters(
                        categories: controller.categories,
                        selectedCategory: controller.selectedCategory,
                        onSelected: controller.selectCategory,
                      ),
                    const SizedBox(height: 42),
                    const SectionTitleRow(title: 'Upcoming Events'),
                    const SizedBox(height: 28),
                    if (events.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Text(
                          'No events are currently available.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLarge,
                        ),
                      )
                    else
                      UpcomingEventsCarousel(upcomingEvents: events),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

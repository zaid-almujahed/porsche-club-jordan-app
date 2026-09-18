import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pcj_v4/core/routing/app_router.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/domain/entities/event.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

import '../controllers/event_details_controller.dart';
import '../widgets/event_details_widgets.dart';

class EventDetailsPage extends StatelessWidget {
  const EventDetailsPage({super.key, required this.controller});

  final EventDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        final Event? current = controller.state.data;
        return Scaffold(
          backgroundColor: AppColors.canvas,
          appBar: PorscheAppBar(
            title: current?.title ?? 'Event Details',
            showBack: true,
          ),
          body: AppPageBody(
            topPadding: 0,
            child: AsyncStateView<Event>(
              state: controller.state,
              onRetry: controller.refresh,
              builder: (BuildContext context, Event event) {
                final List<String> gallery = event.galleryUrls.isEmpty
                    ? <String>[event.posterUrl]
                    : event.galleryUrls;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 150),
                    EventGallery(images: gallery),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'SPONSORED BY',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SponsorsList(sponsors: event.sponsors),
                    const SizedBox(height: AppSpacing.md),
                    const Divider(),
                    const SizedBox(height: 26),
                    Text(
                      'Event Overview',
                      style: AppTextStyles.pageTitle.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(event.description, style: AppTextStyles.bodyLarge),
                    const SizedBox(height: AppSpacing.md),
                    const Divider(),
                    const SizedBox(height: 28),
                    EventStatistics(
                      capacity: event.capacity,
                      registeredCount: event.registeredCount,
                      startsAt: event.startsAt,
                      weatherCelsius: event.weatherCelsius,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    LocationCard(
                      location: event.location,
                      mapImageUrl: event.mapImageUrl,
                      latitude: event.latitude,
                      longitude: event.longitude,
                    ),
                    const SizedBox(height: 54),
                    if (event.isAtCapacity)
                      const SecondaryActionButton(label: 'Event At Capacity')
                    else
                      PrimaryActionButton(
                        label: 'Register for Event',
                        onPressed: () => context.push(
                          AppRoutes.eventRegistrationLocation(event.id),
                          extra: event,
                        ),
                      ),
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

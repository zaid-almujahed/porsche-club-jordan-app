import 'package:flutter/material.dart';

import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/core/utils/app_formatters.dart';
import 'package:pcj_v4/shared/domain/entities/event.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

class EventPreviewCard extends StatelessWidget {
  const EventPreviewCard({super.key, required this.event, required this.onTap});

  final Event event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.medium),
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
                      Radius.circular(AppRadii.medium),
                    ),
                    fallbackIcon: Icons.directions_car_outlined,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[Color(0x22000000), Color(0xE6000000)],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          event.category.toUpperCase(),
                          style: AppTextStyles.label,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          event.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.sectionTitle.copyWith(
                            fontSize: 21,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '◷  ${AppFormatters.dateAndTime(event.startsAt).toUpperCase()}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '⌖  ${event.location.toUpperCase()}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label,
            ),
          ],
        ),
      ),
    );
  }
}

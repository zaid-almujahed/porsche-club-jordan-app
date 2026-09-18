import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/core/utils/app_formatters.dart';

import 'package:pcj_v4/shared/widgets/app_widgets.dart';

//Contains event statistics; weather, cap, time, location

class EventStatistics extends StatelessWidget {
  const EventStatistics({
    super.key,
    required this.capacity,
    required this.registeredCount,
    required this.startsAt,
    this.weatherCelsius,
  });

  final int capacity;
  final int registeredCount;
  final DateTime startsAt;
  final int? weatherCelsius;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          //Weather
          child: StatisticCard(
            icon: Icons.wb_sunny_outlined,
            label: 'WEATHER',
            value: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: weatherCelsius == null ? '--°' : '$weatherCelsius°',
                    style: const TextStyle(color: Colors.white, fontSize: 32),
                  ),
                  const TextSpan(
                    text: 'C',
                    style: TextStyle(color: Color(0xBFFFFFFF), fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: StatisticCard(
            icon: Icons.alarm,
            label: 'TIME',
            value: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: AppFormatters.time(startsAt),
                    style: const TextStyle(
                      color: Color(0xFFE5E2E1),
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: StatisticCard(
            icon: Icons.group,
            label: 'CAPACITY',
            value: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: '$registeredCount ',
                    style: const TextStyle(
                      color: Color(0xFFE5E2E1),
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: '/ $capacity',
                    style: const TextStyle(
                      color: Color(0xFFB12B28),
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class StatisticCard extends StatelessWidget {
  const StatisticCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 121,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: <Color>[
            Color(0x331A1A1A),
            Color(0xCC000000),
            Color(0x8C000000),
            Color(0x191A1A1A),
          ],
        ),
        border: Border.all(color: const Color(0x33FBFCFF), width: 1.13),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 29,
            child: Row(
              children: <Widget>[
                Icon(icon, size: 15, color: const Color(0xFFB12B28)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Color(0xFFFBFCFF),
                      fontSize: 11.28,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: const BoxDecoration(
                color: Color(0xFF181817),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: FittedBox(fit: BoxFit.scaleDown, child: value),
            ),
          ),
        ],
      ),
    );
  }
}

class LocationCard extends StatelessWidget {
  const LocationCard({
    super.key,
    required this.location,
    this.mapImageUrl,
    this.latitude,
    this.longitude,
  });

  final String location;
  final String? mapImageUrl;
  final double? latitude;
  final double? longitude;

  @override
  Widget build(BuildContext context) {
    final bool hasCoordinates = latitude != null &&
        longitude != null &&
        (latitude != 0 || longitude != 0);
    return Container(
      height: 189,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: <Color>[
            Color(0x331A1A1A),
            Color(0xCC000000),
            Color(0x8C000000),
            Color(0x191A1A1A),
          ],
        ),
        border: Border.all(color: const Color(0x33FBFCFF), width: 1.13),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 29,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.location_on_outlined,
                    size: 15,
                    color: Color(0xFFB12B28),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'LOCATION',
                    style: TextStyle(
                      color: Color(0xFFFBFCFF),
                      fontSize: 11.28,
                      height: 1,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      location.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xBFFBFCFF),
                        fontSize: 11.28,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: hasCoordinates
                  ? GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(latitude!, longitude!),
                        zoom: 14,
                      ),
                      markers: <Marker>{
                        Marker(
                          markerId: const MarkerId('event-location'),
                          position: LatLng(latitude!, longitude!),
                          infoWindow: InfoWindow(title: location),
                        ),
                      },
                      mapToolbarEnabled: false,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                    )
                  : AppAssetImage(
                      path: mapImageUrl ?? '',
                      fit: BoxFit.cover,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(12),
                      ),
                      fallbackIcon: Icons.map_outlined,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class EventGallery extends StatefulWidget {
  const EventGallery({super.key, required this.images});

  final List<String> images;

  @override
  State<EventGallery> createState() => _EventGallery();
}

class _EventGallery extends State<EventGallery> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 360,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            physics: const PageScrollPhysics(),
            onPageChanged: (int index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (BuildContext context, int index) {
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  AppAssetImage(path: widget.images[index], fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: <Color>[
                          Color(0xFF131313),
                          Color(0x7F131313),
                          Color(0x00131313),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 106),

        //carousel indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(widget.images.length, (int index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 9,
              height: 9,
              margin: const EdgeInsets.symmetric(horizontal: 4.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == _currentPage
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.40),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class SponsorsList extends StatelessWidget {
  const SponsorsList({super.key, required this.sponsors});

  final List<String> sponsors;

  @override
  Widget build(BuildContext context) {
    if (sponsors.isEmpty) {
      return const SizedBox(
        width: double.infinity,
        height: 32,
        child: Text(
          "NONE",
          textAlign: TextAlign.center,
          style: AppTextStyles.sectionTitle,
        ),
      );
    }

    return SizedBox(
      height: 32,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Text(
                sponsors.join(', '),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge,
              ),
            ),
          );
        },
      ),
    );
  }
}

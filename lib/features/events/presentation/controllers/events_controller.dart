import 'package:flutter/foundation.dart';

import 'package:pcj_v4/core/state/async_state.dart';
import 'package:pcj_v4/shared/domain/entities/event.dart';

import '../../domain/repositories/events_repository.dart';

class EventsController extends ChangeNotifier {
  EventsController({required EventsRepository repository})
    : _repository = repository;

  final EventsRepository _repository;
  AsyncState<List<Event>> _events = const AsyncState<List<Event>>.initial();
  List<Event> _allEvents = const <Event>[];
  static const String upcomingCategory = 'Upcoming Events';
  static const String pastCategory = 'Past Events';

  List<String> _categories = const <String>[upcomingCategory, pastCategory];
  String _selectedCategory = upcomingCategory;
  int _requestId = 0;

  AsyncState<List<Event>> get events => _events;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get sectionTitle => _selectedCategory;

  Future<void> load({bool force = false}) async {
    if (!force && (_events.isLoading || _events.hasData)) return;
    await _fetch(forceRefresh: force);
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    if (_events.hasData) _applyFilter();
    notifyListeners();
  }

  Future<void> _fetch({required bool forceRefresh}) async {
    final int requestId = ++_requestId;
    _events = AsyncState<List<Event>>.loading(previousData: _events.data);
    notifyListeners();
    try {
      final List<Event> events = List<Event>.unmodifiable(
        await _repository.getEvents(forceRefresh: forceRefresh),
      );
      if (requestId != _requestId) return;
      _allEvents = events;
      _applyFilter();
    } catch (error, stackTrace) {
      if (requestId != _requestId) return;
      _events = AsyncState<List<Event>>.failure(
        error,
        stackTrace,
        previousData: _events.data,
      );
    }
    if (requestId != _requestId) return;
    notifyListeners();
  }

  void _applyFilter() {
    final DateTime now = DateTime.now();
    final bool showPast = _selectedCategory == pastCategory;
    final List<Event> visible =
        _allEvents
            .where((Event event) {
              final bool hasEnded = event.hasEndedAt(now);
              return showPast ? hasEnded : !hasEnded;
            })
            .toList(growable: false)
          ..sort((Event left, Event right) {
            return showPast
                ? right.startsAt.compareTo(left.startsAt)
                : left.startsAt.compareTo(right.startsAt);
          });
    _events = AsyncState<List<Event>>.success(
      List<Event>.unmodifiable(visible),
    );
  }

  void reset() {
    _requestId++;
    _events = const AsyncState<List<Event>>.initial();
    _allEvents = const <Event>[];
    _categories = const <String>[upcomingCategory, pastCategory];
    _selectedCategory = upcomingCategory;
    notifyListeners();
  }
}

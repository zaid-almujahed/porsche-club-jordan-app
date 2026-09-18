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
  List<String> _categories = const <String>[];
  String? _selectedCategory;
  int _requestId = 0;

  AsyncState<List<Event>> get events => _events;
  List<String> get categories => _categories;
  String? get selectedCategory => _selectedCategory;

  Future<void> load({bool force = false}) async {
    if (!force && (_events.isLoading || _events.hasData)) return;
    await _fetch();
  }

  void selectCategory(String? category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    if (_events.hasData) _applyFilter();
    notifyListeners();
  }

  Future<void> _fetch() async {
    final int requestId = ++_requestId;
    _events = AsyncState<List<Event>>.loading(previousData: _events.data);
    notifyListeners();
    try {
      final List<Event> events = List<Event>.unmodifiable(
        await _repository.getEvents(),
      );
      if (requestId != _requestId) return;
      _allEvents = events;
      _categories = List<String>.unmodifiable(
        events
            .map((Event event) => event.category.trim())
            .where((String value) => value.isNotEmpty)
            .toSet(),
      );
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
    final String selected = _selectedCategory?.trim().toLowerCase() ?? '';
    final List<Event> visible = selected.isEmpty
        ? _allEvents
        : _allEvents
              .where(
                (Event event) =>
                    event.category.trim().toLowerCase() == selected,
              )
              .toList(growable: false);
    _events = AsyncState<List<Event>>.success(
      List<Event>.unmodifiable(visible),
    );
  }

  void reset() {
    _requestId++;
    _events = const AsyncState<List<Event>>.initial();
    _allEvents = const <Event>[];
    _categories = const <String>[];
    _selectedCategory = null;
    notifyListeners();
  }
}

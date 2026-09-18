import 'package:flutter/foundation.dart';

import 'package:pcj_v4/core/state/async_state.dart';
import 'package:pcj_v4/shared/domain/entities/event_booking.dart';

import '../../domain/repositories/user_events_repository.dart';

class UserEventsController extends ChangeNotifier {
  UserEventsController({required UserEventsRepository repository})
    : _repository = repository;

  final UserEventsRepository _repository;
  AsyncState<List<EventBooking>> _bookings =
      const AsyncState<List<EventBooking>>.initial();
  bool _showUpcoming = true;
  int _requestId = 0;
  final Set<String> _cancellingEventIds = <String>{};
  Object? _actionError;

  AsyncState<List<EventBooking>> get bookings => _bookings;
  bool get showUpcoming => _showUpcoming;
  Object? get actionError => _actionError;
  bool isCancelling(String eventId) => _cancellingEventIds.contains(eventId);

  Future<void> load({bool force = false}) async {
    if (!force && (_bookings.isLoading || _bookings.hasData)) return;
    await _fetch();
  }

  Future<void> showTab({required bool upcoming}) async {
    if (_showUpcoming == upcoming) return;
    _showUpcoming = upcoming;
    notifyListeners();
    await _fetch();
  }

  Future<bool> cancelRegistration(EventBooking booking) async {
    final String eventId = booking.event.id;
    if (_cancellingEventIds.contains(eventId)) return false;
    _cancellingEventIds.add(eventId);
    _actionError = null;
    notifyListeners();
    try {
      await _repository.cancelRegistration(eventId);
      await _fetch();
      return true;
    } catch (error) {
      _actionError = error;
      return false;
    } finally {
      _cancellingEventIds.remove(eventId);
      notifyListeners();
    }
  }

  Future<void> _fetch() async {
    final int requestId = ++_requestId;
    _bookings = AsyncState<List<EventBooking>>.loading(
      previousData: _bookings.data,
    );
    notifyListeners();
    try {
      final List<EventBooking> bookings = List<EventBooking>.unmodifiable(
        await _repository.getBookings(upcoming: _showUpcoming),
      );
      if (requestId != _requestId) return;
      _bookings = AsyncState<List<EventBooking>>.success(bookings);
    } catch (error, stackTrace) {
      if (requestId != _requestId) return;
      _bookings = AsyncState<List<EventBooking>>.failure(
        error,
        stackTrace,
        previousData: _bookings.data,
      );
    }
    if (requestId != _requestId) return;
    notifyListeners();
  }

  void reset() {
    _requestId++;
    _bookings = const AsyncState<List<EventBooking>>.initial();
    _showUpcoming = true;
    _cancellingEventIds.clear();
    _actionError = null;
    notifyListeners();
  }
}

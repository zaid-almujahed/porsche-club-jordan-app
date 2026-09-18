import 'package:pcj_v4/core/errors/app_exception.dart';
import 'package:pcj_v4/core/state/async_state.dart';
import 'package:pcj_v4/core/state/safe_change_notifier.dart';
import 'package:pcj_v4/features/events/domain/repositories/events_repository.dart';
import 'package:pcj_v4/features/profile/domain/repositories/profile_repository.dart';
import 'package:pcj_v4/shared/domain/entities/event.dart';
import 'package:pcj_v4/shared/domain/entities/event_booking.dart';
import 'package:pcj_v4/shared/domain/entities/vehicle.dart';

class EventRegistrationController extends SafeChangeNotifier {
  EventRegistrationController({
    required EventsRepository eventsRepository,
    required ProfileRepository profileRepository,
    required this.eventId,
    Event? initialEvent,
  }) : _eventsRepository = eventsRepository,
       _profileRepository = profileRepository,
       _eventState = initialEvent == null
           ? const AsyncState<Event>.initial()
           : AsyncState<Event>.success(initialEvent);

  final EventsRepository _eventsRepository;
  final ProfileRepository _profileRepository;
  final String eventId;

  AsyncState<Event> _eventState;
  AsyncState<List<Vehicle>> _vehicles =
      const AsyncState<List<Vehicle>>.initial();
  Vehicle? _selectedVehicle;
  int _guestCount = 0;
  bool _guestNoticeAccepted = false;
  bool _isSubmitting = false;
  Object? _submissionError;

  AsyncState<Event> get eventState => _eventState;
  AsyncState<List<Vehicle>> get vehicles => _vehicles;
  Vehicle? get selectedVehicle => _selectedVehicle;
  int get guestCount => _guestCount;
  bool get guestNoticeAccepted => _guestNoticeAccepted;
  bool get isSubmitting => _isSubmitting;
  Object? get submissionError => _submissionError;

  double get guestsTotal => (_eventState.data?.guestFee ?? 0) * _guestCount;
  double get total => (_eventState.data?.registrationFee ?? 0) + guestsTotal;

  Future<void> load({bool force = false}) async {
    await Future.wait(<Future<void>>[
      _loadEvent(force: force),
      loadVehicles(force: force),
    ]);
  }

  Future<void> _loadEvent({required bool force}) async {
    if (!force && (_eventState.isLoading || _eventState.hasData)) return;
    _eventState = AsyncState<Event>.loading(previousData: _eventState.data);
    notifyListeners();
    try {
      _eventState = AsyncState<Event>.success(
        await _eventsRepository.getEvent(eventId),
      );
    } catch (error, stackTrace) {
      _eventState = AsyncState<Event>.failure(
        error,
        stackTrace,
        previousData: _eventState.data,
      );
    }
    notifyListeners();
  }

  Future<void> loadVehicles({bool force = false}) async {
    if (!force && (_vehicles.isLoading || _vehicles.hasData)) return;
    _vehicles = AsyncState<List<Vehicle>>.loading(previousData: _vehicles.data);
    notifyListeners();
    try {
      final List<Vehicle> values = await _profileRepository.getVehicles();
      _vehicles = AsyncState<List<Vehicle>>.success(values);
      if (_selectedVehicle == null && values.isNotEmpty) {
        _selectedVehicle = values.first;
      }
    } catch (error, stackTrace) {
      _vehicles = AsyncState<List<Vehicle>>.failure(
        error,
        stackTrace,
        previousData: _vehicles.data,
      );
    }
    notifyListeners();
  }

  void selectVehicle(Vehicle? value) {
    _selectedVehicle = value;
    _submissionError = null;
    notifyListeners();
  }

  void incrementGuests() {
    final int limit = _eventState.data?.guestLimit ?? 0;
    if (_guestCount >= limit) return;
    _guestCount++;
    _guestNoticeAccepted = false;
    notifyListeners();
  }

  void decrementGuests() {
    if (_guestCount == 0) return;
    _guestCount--;
    _guestNoticeAccepted = false;
    notifyListeners();
  }

  void acceptGuestNotice() {
    _guestNoticeAccepted = true;
    _submissionError = null;
    notifyListeners();
  }

  Future<EventBooking?> submit() async {
    final Event? event = _eventState.data;
    if (_isSubmitting || event == null || event.isAtCapacity) return null;
    if (_guestCount > 0 && !_guestNoticeAccepted) {
      _submissionError = const AppException(
        'Please acknowledge the guest admission notice before registering.',
      );
      notifyListeners();
      return null;
    }

    _isSubmitting = true;
    _submissionError = null;
    notifyListeners();
    try {
      return await _eventsRepository.registerForEvent(
        EventRegistrationRequest(eventId: event.id, guestCount: _guestCount),
      );
    } catch (error) {
      if (error is AppException &&
          error.statusCode == 400 &&
          error.message.toLowerCase().contains('full')) {
        _submissionError = const AppException(
          'Registration could not be completed because this event has reached '
          'capacity.',
          statusCode: 400,
        );
      } else {
        _submissionError = error;
      }
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}

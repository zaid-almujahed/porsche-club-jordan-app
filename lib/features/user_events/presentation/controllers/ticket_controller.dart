import 'package:pcj_v4/core/state/async_state.dart';
import 'package:pcj_v4/core/state/safe_change_notifier.dart';
import 'package:pcj_v4/shared/domain/entities/event_booking.dart';

import '../../domain/repositories/user_events_repository.dart';

class TicketController extends SafeChangeNotifier {
  TicketController({
    required UserEventsRepository repository,
    required this.bookingId,
    EventBooking? initialBooking,
  }) : _repository = repository,
       _booking = initialBooking == null
           ? const AsyncState<EventBooking>.initial()
           : AsyncState<EventBooking>.success(initialBooking),
       _ticket = initialBooking?.ticket == null
           ? const AsyncState<EventTicket>.initial()
           : AsyncState<EventTicket>.success(initialBooking!.ticket!);

  final UserEventsRepository _repository;
  final String bookingId;
  AsyncState<EventBooking> _booking;
  AsyncState<EventTicket> _ticket;

  AsyncState<EventBooking> get booking => _booking;
  AsyncState<EventTicket> get ticket => _ticket;

  Future<void> load({bool force = false}) async {
    if (!force &&
        (_ticket.isLoading || (_booking.hasData && _ticket.hasData))) {
      return;
    }
    if (force || !_booking.hasData) {
      _booking = AsyncState<EventBooking>.loading(previousData: _booking.data);
      notifyListeners();
      try {
        _booking = AsyncState<EventBooking>.success(
          await _repository.getBooking(bookingId),
        );
      } catch (error, stackTrace) {
        _booking = AsyncState<EventBooking>.failure(error, stackTrace);
        notifyListeners();
        return;
      }
    }

    final EventTicket? includedTicket = _booking.data?.ticket;
    if (_booking.data?.status == EventBookingStatus.attended) {
      _ticket = AsyncState<EventTicket>.success(
        includedTicket ??
            EventTicket(
              id: _booking.data!.id,
              qrImageUrl: '',
              holderName: 'Member',
              attendanceStatus: 'Attended',
            ),
      );
      notifyListeners();
      return;
    }
    // Never request or display access credentials for a paid RSVP until the
    // backend explicitly reports a completed payment.
    if (!_booking.data!.isPaymentComplete) {
      _ticket = const AsyncState<EventTicket>.initial();
      notifyListeners();
      return;
    }
    // If attendance has already been recorded, do not call the QR endpoint:
    // the backend contract explicitly disallows generating the code again.
    // A supplied non-empty token is also already sufficient for display.
    if (includedTicket != null &&
        (!includedTicket.canDisplayQr ||
            (!force && includedTicket.qrToken.isNotEmpty))) {
      _ticket = AsyncState<EventTicket>.success(includedTicket);
      notifyListeners();
      return;
    }

    _ticket = AsyncState<EventTicket>.loading(previousData: _ticket.data);
    notifyListeners();
    try {
      _ticket = AsyncState<EventTicket>.success(
        await _repository.getTicket(_booking.data!.event.id),
      );
    } catch (error, stackTrace) {
      _ticket = AsyncState<EventTicket>.failure(error, stackTrace);
    }
    notifyListeners();
  }
}

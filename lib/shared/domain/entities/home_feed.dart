import 'event.dart';
import 'offer.dart';
import 'product.dart';

class HomeFeed {
  const HomeFeed({
    required this.featuredEvent,
    required this.seasonEvents,
    required this.popularProducts,
    required this.featuredOffers,
  });

  final Event? featuredEvent;
  final List<Event> seasonEvents;
  final List<Product> popularProducts;
  final List<Offer> featuredOffers;
}

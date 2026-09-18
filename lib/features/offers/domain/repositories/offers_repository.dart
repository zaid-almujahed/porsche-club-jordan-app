import 'package:pcj_v4/shared/domain/entities/offer.dart';

abstract interface class OffersRepository {
  Future<List<Offer>> getOffers({String? category});

  Future<Offer> getOffer(String offerId);

  Future<void> claimOffer(String offerId);

  Future<List<Offer>> getClaimedOffers();

  void clearLocalState();
}

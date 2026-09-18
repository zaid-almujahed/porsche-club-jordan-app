import 'package:pcj_v4/core/errors/app_exception.dart';
import 'package:pcj_v4/core/network/api_parsers.dart';
import 'package:pcj_v4/core/network/pcj_api_client.dart';
import 'package:pcj_v4/core/cache/memory_cache.dart';
import 'package:pcj_v4/features/offers/domain/repositories/offers_repository.dart';

import '../models/offer_model.dart';

class ApiOffersRepository implements OffersRepository {
  ApiOffersRepository({
    required PcjApiClient apiClient,
    required MemoryCache cache,
  }) : _apiClient = apiClient,
       _cache = cache;

  final PcjApiClient _apiClient;
  final MemoryCache _cache;
  final Set<String> _claimedOfferIds = <String>{};

  @override
  Future<List<Offer>> getOffers({String? category}) async {
    final List<Offer> rawOffers = await _cache.getOrLoad<List<Offer>>(
      'offers:all',
      () async => _readList(
        await _apiClient.get('/member/offers'),
      ).map<Offer>(OfferModel.fromJson).toList(growable: false),
      ttl: const Duration(minutes: 5),
    );
    try {
      final List<Offer> claimed = await getClaimedOffers();
      _claimedOfferIds.addAll(claimed.map((Offer offer) => offer.id));
    } catch (_) {
      // Existing claims are supplementary to the main offers catalogue. A
      // temporary failure must not make every offer disappear.
    }
    final List<Offer> offers = rawOffers
        .map(
          (Offer offer) => _claimedOfferIds.contains(offer.id)
              ? offer.copyWith(isClaimed: true)
              : offer,
        )
        .toList(growable: false);
    final String normalized = category?.trim().toLowerCase() ?? '';
    if (normalized.isEmpty || normalized == 'all') return offers;
    return offers
        .where((Offer offer) => offer.category.toLowerCase() == normalized)
        .toList(growable: false);
  }

  @override
  Future<Offer> getOffer(String offerId) async {
    return OfferModel.fromJson(
      requireJsonMap(
        await _apiClient.get('/member/offers/${Uri.encodeComponent(offerId)}'),
        description: 'offer response',
      ),
    );
  }

  @override
  Future<void> claimOffer(String offerId) async {
    await _apiClient.post(
      '/member/offers/${Uri.encodeComponent(offerId)}/claim',
    );
    _claimedOfferIds.add(offerId);
    _cache.remove('offers:claimed');
  }

  @override
  Future<List<Offer>> getClaimedOffers() {
    return _cache.getOrLoad<List<Offer>>(
      'offers:claimed',
      () async => _readList(await _apiClient.get('/member/my-offers'))
          .map<Offer>(
            (Map<String, dynamic> json) =>
                OfferModel.fromJson(json).copyWith(isClaimed: true),
          )
          .toList(growable: false),
      ttl: const Duration(minutes: 2),
    );
  }

  @override
  void clearLocalState() {
    _claimedOfferIds.clear();
  }

  static List<Map<String, dynamic>> _readList(Object? response) {
    Object? value = unwrapApiData(response);
    if (value is Map && value['offers'] is List) value = value['offers'];
    if (value is! List) {
      throw const AppException(
        'The server returned an invalid offers response.',
      );
    }
    return value
        .whereType<Map>()
        .map<Map<String, dynamic>>((Map item) {
          return Map<String, dynamic>.from(item);
        })
        .toList(growable: false);
  }
}

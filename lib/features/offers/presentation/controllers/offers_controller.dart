import 'package:flutter/foundation.dart';

import 'package:pcj_v4/core/state/async_state.dart';
import 'package:pcj_v4/shared/domain/entities/offer.dart';

import '../../domain/repositories/offers_repository.dart';

class OffersController extends ChangeNotifier {
  OffersController({required OffersRepository repository})
    : _repository = repository;

  final OffersRepository _repository;
  AsyncState<List<Offer>> _offers = const AsyncState<List<Offer>>.initial();
  List<Offer> _allOffers = const <Offer>[];
  List<String> _categories = const <String>[];
  String? _selectedCategory;
  int _requestId = 0;
  final Set<String> _claimingOfferIds = <String>{};
  Object? _actionError;

  AsyncState<List<Offer>> get offers => _offers;
  List<String> get categories => _categories;
  String? get selectedCategory => _selectedCategory;
  Object? get actionError => _actionError;
  bool isClaiming(String offerId) => _claimingOfferIds.contains(offerId);

  Future<void> load({bool force = false}) async {
    if (!force && (_offers.isLoading || _offers.hasData)) return;
    await _fetch();
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    if (_offers.hasData) _applyFilter();
    notifyListeners();
  }

  Future<bool> claimOffer(Offer offer) async {
    if (offer.isClaimed || _claimingOfferIds.contains(offer.id)) return false;
    _claimingOfferIds.add(offer.id);
    _actionError = null;
    notifyListeners();
    try {
      await _repository.claimOffer(offer.id);
      _allOffers = _allOffers
          .map(
            (Offer value) => value.id == offer.id
                ? value.copyWith(isClaimed: true)
                : value,
          )
          .toList(growable: false);
      _applyFilter();
      return true;
    } catch (error) {
      _actionError = error;
      return false;
    } finally {
      _claimingOfferIds.remove(offer.id);
      notifyListeners();
    }
  }

  Future<void> _fetch() async {
    final int requestId = ++_requestId;
    _offers = AsyncState<List<Offer>>.loading(previousData: _offers.data);
    notifyListeners();
    try {
      final List<Offer> offers = List<Offer>.unmodifiable(
        await _repository.getOffers(),
      );
      if (requestId != _requestId) return;
      _allOffers = offers;
      _categories = const <String>['NUQUL', 'PARTNERS'];
      _selectedCategory ??= _categories.first;
      _applyFilter();
    } catch (error, stackTrace) {
      if (requestId != _requestId) return;
      _offers = AsyncState<List<Offer>>.failure(
        error,
        stackTrace,
        previousData: _offers.data,
      );
    }
    if (requestId != _requestId) return;
    notifyListeners();
  }

  void _applyFilter() {
    final String selected = _selectedCategory?.trim().toLowerCase() ?? '';
    final List<Offer> visible = _allOffers.where((Offer offer) {
      if (selected == 'nuqul') return offer.isNuqulExclusive;
      if (selected == 'partners') return !offer.isNuqulExclusive;
      return true;
    }).toList(growable: false)
      ..sort((Offer left, Offer right) {
        if (left.isClaimed == right.isClaimed) return 0;
        return left.isClaimed ? 1 : -1;
      });
    _offers = AsyncState<List<Offer>>.success(
      List<Offer>.unmodifiable(visible),
    );
  }

  void reset() {
    _requestId++;
    _offers = const AsyncState<List<Offer>>.initial();
    _allOffers = const <Offer>[];
    _categories = const <String>[];
    _selectedCategory = null;
    _claimingOfferIds.clear();
    _actionError = null;
    notifyListeners();
  }
}

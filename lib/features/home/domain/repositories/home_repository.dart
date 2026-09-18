import 'package:pcj_v4/shared/domain/entities/home_feed.dart';

abstract interface class HomeRepository {
  Future<HomeFeed> getHomeFeed();
}

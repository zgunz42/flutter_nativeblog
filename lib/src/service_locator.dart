import 'package:get_it/get_it.dart';
import 'package:nativeblog/src/config.dart';
import 'package:nativeblog/src/managers/app_manager.dart';
import 'package:nativeblog/src/services/preferences_service.dart';
import 'package:nativeblog/src/services/ads_service.dart';
import 'package:nativeblog/src/services/analytics_service.dart';
import 'package:nativeblog/src/services/socialfeed_service.dart';

final sl = GetIt();

initialize(AppConfig config){
  // Services
  // sl.registerLazySingleton<WordpressApiService>(() => WordpressApiService);
  sl.registerLazySingleton<PreferencesService>(() => PreferencesService());
  sl.registerLazySingleton<InstagramFeedService>(() => InstagramFeedService());
  sl.registerLazySingleton<AnalyticsService>(() => AnalyticsService());
  sl.registerLazySingleton<AdsService>(() => AdsService());
  
  // Managers
  sl.registerSingleton<AppManager>(AppManagerImpl());
}
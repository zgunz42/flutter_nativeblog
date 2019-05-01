import 'package:get_it/get_it.dart';
import 'package:nativeblog/src/managers/app_manager.dart';
import 'package:nativeblog/src/services/preferences_service.dart';

final sl = GetIt();

initialize(){
  // Services
  // sl.registerLazySingleton<WordpressApiService>(() => WordpressApiService);
  sl.registerLazySingleton<PreferencesService>(() => PreferencesService());
  
  // Managers
  sl.registerSingleton<AppManager>(AppManagerImpl());
}
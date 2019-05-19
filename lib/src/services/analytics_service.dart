import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class AnalyticsService {
  FirebaseAnalytics _analytics;

  FirebaseAnalyticsObserver get analyticsObserver => FirebaseAnalyticsObserver(analytics: _analytics);

  AnalyticsService() {
    _analytics = FirebaseAnalytics();
  }

  void openExternalLink(String url) {
    _analytics.logEvent(name: 'open_browser', parameters: {'url': url});
  }
}
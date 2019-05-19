import 'package:flutter/material.dart';
import 'package:nativeblog/src/service_locator.dart';
import 'package:nativeblog/src/services/analytics_service.dart';
import 'package:nativeblog/src/ui/routers.dart';
import 'package:nativeblog/src/ui/theme/theme.dart';

class NativeBlogApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Native Blog',
      debugShowCheckedModeBanner: false,
      theme: nativeBlogTheme,
      navigatorObservers: [
        sl.get<AnalyticsService>().analyticsObserver,
        appRouter
      ],
      initialRoute: appRouter.preloadingPath,
      onGenerateRoute: appRouter.generator,
    );
  }
}

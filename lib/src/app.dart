import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:nativeblog/src/ui/routers.dart';
import 'package:nativeblog/src/ui/theme/theme.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class NativeBlogApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    final myAppId = 'ca-app-pub-2758740163872909~4629240182';
    FirebaseAnalytics analytics = FirebaseAnalytics();
    FirebaseAdMob.instance.initialize(appId: myAppId);
    
    return MaterialApp(
      title: 'Native Blog Info',
      debugShowCheckedModeBanner: false,
      theme: nativeBlogTheme,
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics), appRouter],
      initialRoute: '/',
      onGenerateRoute: appRouter.generator,
    );
  }
}

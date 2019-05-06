import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:nativeblog/src/ui/routers.dart';
import 'package:nativeblog/src/ui/theme/theme.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:onesignal/onesignal.dart';

class NativeBlogApp extends StatelessWidget {
  void _requestForNotification() async {
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    var settings = {
      OSiOSSettings.autoPrompt: true,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };

    OneSignal.shared.setNotificationReceivedHandler((notification) {
      final _debugLabelString =
          "Received notification: \n${notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      print(_debugLabelString);
    });

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      final _debugLabelString =
          "Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      print(_debugLabelString);
    });

    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      print("SUBSCRIPTION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      print("PERMISSION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.setEmailSubscriptionObserver(
        (OSEmailSubscriptionStateChanges changes) {
      print("EMAIL SUBSCRIPTION STATE CHANGED ${changes.jsonRepresentation()}");
    });

    // NOTE: Replace with your own app ID from https://www.onesignal.com
    await OneSignal.shared
        .init("1819f7d0-451a-4de4-aee6-c911af5d378f", iOSSettings: settings);
    await OneSignal.shared.consentGranted(true);
    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);

    OneSignal.shared.getPermissionSubscriptionState().then((status) {
      print(status.subscriptionStatus.jsonRepresentation());
      print(status.permissionStatus.jsonRepresentation());
    });
  }

  @override
  Widget build(BuildContext context) {
    final myAppId = 'ca-app-pub-2758740163872909~4629240182';
    FirebaseAnalytics analytics = FirebaseAnalytics();
    FirebaseAdMob.instance.initialize(appId: myAppId);
    _requestForNotification();
    return MaterialApp(
      title: 'Native Blog Info',
      debugShowCheckedModeBanner: false,
      theme: nativeBlogTheme,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
        appRouter
      ],
      initialRoute: '/',
      onGenerateRoute: appRouter.generator,
    );
  }
}

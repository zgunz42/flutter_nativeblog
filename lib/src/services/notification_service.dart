import 'package:onesignal/onesignal.dart';

class NotificationService {
  OneSignal _notification;
  NotificationService() {
    _notification = OneSignal.shared;
  }
  void requestForNotification() async {
    _notification.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    var settings = {
      OSiOSSettings.autoPrompt: true,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };

    _notification.setNotificationReceivedHandler((notification) {
      final _debugLabelString =
          "Received notification: \n${notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      print(_debugLabelString);
    });

    _notification
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      final _debugLabelString =
          "Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      print(_debugLabelString);
    });

    _notification.setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      print("SUBSCRIPTION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

    _notification.setPermissionObserver((OSPermissionStateChanges changes) {
      print("PERMISSION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

    _notification.setEmailSubscriptionObserver(
        (OSEmailSubscriptionStateChanges changes) {
      print("EMAIL SUBSCRIPTION STATE CHANGED ${changes.jsonRepresentation()}");
    });

    // NOTE: Replace with your own app ID from https://www.onesignal.com
    await _notification.init("1819f7d0-451a-4de4-aee6-c911af5d378f",
        iOSSettings: settings);
    await _notification.consentGranted(true);
    _notification.setInFocusDisplayType(OSNotificationDisplayType.notification);

    _notification.getPermissionSubscriptionState().then((status) {
      print(status.subscriptionStatus.jsonRepresentation());
      print(status.permissionStatus.jsonRepresentation());
    });
  }
}

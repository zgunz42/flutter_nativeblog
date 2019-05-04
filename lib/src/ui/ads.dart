import 'package:firebase_admob/firebase_admob.dart';

final String adUnitId = 'ca-app-pub-2758740163872909/7136339246';
final MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  keywords: <String>['blog', 'hosting'],
  childDirected: false,
  testDevices: ["1285DBC10C54E30C48998C8FA9E431F3"]
);
BannerAd _displayBannerAds() {
  return BannerAd(
    adUnitId: adUnitId,
    size: AdSize.smartBanner,
    targetingInfo: targetingInfo,
    listener: (MobileAdEvent event) {
      print("BannerAd event is $event");
    },
  );
}

InterstitialAd _fullWidthAds() {
  return InterstitialAd(
      adUnitId: 'ca-app-pub-2758740163872909/3895345653',
      targetingInfo: targetingInfo,
      listener: (event) {
        print("BannerAd event is $event");
      });
}

final bottomAds = _displayBannerAds();
final fullAds = _fullWidthAds();

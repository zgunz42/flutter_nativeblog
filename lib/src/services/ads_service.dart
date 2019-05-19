import 'package:admob_flutter/admob_flutter.dart';

class AdsService {
  Admob _ads;
  AdsService () {
    final myAppId = 'ca-app-pub-2758740163872909~4629240182';
    _ads = Admob.initialize(myAppId);
  }
}
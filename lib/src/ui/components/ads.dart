import 'package:flutter/material.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'dart:math';

final String _kAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
final String _kAdTestId = 'ca-app-pub-3940256099942544/6300978111';
final String _kFullUnitId = 'ca-app-pub-2758740163872909/3895345653';



class Ads extends StatelessWidget {
  const Ads({Key key, this.bannerSize}) : super(key: key);
  final AdmobBannerSize bannerSize;

  factory Ads.random() {
    final size = Random.secure().nextInt(2);
    return Ads(bannerSize: size == 0 ? AdmobBannerSize.LARGE_BANNER: AdmobBannerSize.MEDIUM_RECTANGLE,);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Stack(
        children: <Widget>[
          AdmobBanner(
            adUnitId: _kAdTestId,
            adSize: bannerSize,
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Opacity(
              opacity: 0.35,
              child: Container(
                color: Colors.yellow,
                padding: EdgeInsets.all(4.0),
                child: Text('iklan', style: TextStyle(color: Colors.white)),
              ),
            ),
          )
        ],
      ),
    );
  }
}

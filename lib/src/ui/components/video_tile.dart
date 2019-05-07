import 'package:flutter/material.dart';
import 'package:nativeblog/src/ui/components/image_placeholder.dart';
import 'package:timeago/timeago.dart' as timeago;

const double _kImageHeight = 240;

class VideoTile extends StatelessWidget {
  final String title;
  final String thumbnail;
  final String videoUrl;
  final DateTime publishedAt;
  final String channelName;

  const VideoTile(
      {Key key,
      this.title,
      this.thumbnail,
      this.videoUrl,
      this.publishedAt,
      this.channelName})
      : super(key: key);

  static Widget _template(
      {Widget title,
      Widget image,
      Widget info,
      Widget subInfo,
      TextTheme textTheme}) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          image,
          Container(
            height: 8,
          ),
          Container(
              padding: EdgeInsets.only(left: 16.0, right: 16, top: 8),
              child: title),
          Container(
            height: 4,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[info, subInfo],
            ),
          ),
          Container(
            height: 8,
          ),
        ],
      ),
    );
  }

  static Widget get shimmer => _template(
        title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Flexible(
                child: Container(
                  color: Colors.white,
                  height: 14.0,
                ),
              ),
              Container(
                height: 8.0,
                width: 0.0,
              ),
              Container(
                color: Colors.white,
                height: 14.0,
                width: 90.0,
              )
            ]),
        image: Container(
            width: double.infinity, height: _kImageHeight, color: Colors.white),
        info: Container(width: 50.0, height: 12.0, color: Colors.white),
        subInfo: Container(width: 50.0, height: 12.0, color: Colors.white),
      );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {},
      child: _template(
          title: Text(
            title,
            style: textTheme.subhead,
          ),
          image: Container(
            foregroundDecoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                    colors: [Colors.black.withAlpha(100), Colors.transparent, Colors.black.withAlpha(50)], )
            ),
            child: ImagePlaceholder(
              thumbnail,
              height: _kImageHeight,
            ),
          ),
          info: Text(channelName),
          subInfo: Text(timeago.format(publishedAt, locale: 'id'),
              style: textTheme.caption)),
    );
  }
}

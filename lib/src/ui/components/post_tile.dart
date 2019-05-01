import 'package:flutter/material.dart';
import 'package:googleapis/blogger/v3.dart';
import 'package:nativeblog/src/ui/components/image_placeholder.dart';
import 'package:nativeblog/src/ui/routers.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends StatelessWidget {
  const PostCard({Key key, this.article}) : super(key: key);
  final Post article;

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
          Container(
              padding: EdgeInsets.only(left: 16.0, right: 16, top: 8),
              child: title),
          Container(
            height: 8,
          ),
          image,
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
            width: double.infinity, height: 140.0, color: Colors.white),
        info: Container(width: 50.0, height: 12.0, color: Colors.white),
        subInfo: Container(width: 50.0, height: 12.0, color: Colors.white),
      );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    Widget gallery;
    if (article?.images != null && article.images.length > 1) {
      gallery = Container(
          height: 140,
          child: Row(
            children: List.generate(article.images.length, (index) {
              return Flexible(
                flex: 1,
                child: ImagePlaceholder(
                  article.images[index].url,
                ),
              );
            }).toList(),
          ));
    } else {
      gallery = ImagePlaceholder(
        article.images?.first?.url,
        height: 140,
      );
    }

    return _template(
        title: Text(
          article.title,
          style: textTheme.subhead,
        ),
        image: gallery,
        info: Text(article.author.displayName, style: textTheme.caption),
        subInfo: Text(timeago.format(article.published, locale: 'id'),
            style: textTheme.caption));
  }
}

class PostTile extends StatelessWidget {
  const PostTile({Key key, this.article, this.expanded}) : super(key: key);

  final Post article;

  final bool expanded;

  static Widget get shimmer => Padding(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: Column(
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
                  ),
                  Container(
                    height: 23.0,
                    width: 0.0,
                  ),
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                            width: 50.0, height: 12.0, color: Colors.white),
                        Container(
                            width: 50.0, height: 12.00, color: Colors.white),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: 16.0,
              height: 0.0,
            ),
            Container(width: 120.0, height: 80.0, color: Colors.white),
          ],
        ),
        padding: EdgeInsets.all(16.0),
      );

  @override
  Widget build(BuildContext context) {
    Widget child;
    child = _compactTile(Theme.of(context).textTheme);
    return InkWell(
      onTap: () {
        appRouter.navigate(context, path: appRouter.detailPath, t: article);
      },
      child: Container(
        color: Colors.white,
        child: child,
      ),
    );
  }

  _compactTile(TextTheme textTheme) {
    return ListTile(
        title:
            Text(article.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        contentPadding: EdgeInsets.all(16.0),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                article.author.displayName,
                style: textTheme.caption,
              ),
              Text(
                timeago.format(article.published, locale: 'id'),
                style: textTheme.caption,
              )
            ],
          ),
        ),
        trailing: Hero(
          tag: 'thumbnail_${article.id}',
          transitionOnUserGestures: true,
          child: ImagePlaceholder(
            article.images?.first?.url,
            width: 120,
            height: 80,
          ),
        ));
  }

  Widget _galleryTile(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(16),
          child: Text(
            article.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: textTheme.title.copyWith(
                fontSize: 16, fontWeight: FontWeight.w500, wordSpacing: 1.25),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ImagePlaceholder(
            article.images?.first?.url,
            width: double.infinity,
            height: 160,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                article.author.displayName,
                style: textTheme.caption,
              ),
              Text(
                timeago.format(article.published, locale: 'id'),
                style: textTheme.caption,
              )
            ],
          ),
        ),
      ],
    );
  }
}

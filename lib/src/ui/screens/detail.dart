import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/blogger/v3.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:nativeblog/src/helpers/ui.dart';
import 'package:html/dom.dart' as dom;
import 'package:nativeblog/src/managers/app_manager.dart';
import 'package:nativeblog/src/service_locator.dart';
import 'package:nativeblog/src/ui/components/image_placeholder.dart';
import 'package:rx_widgets/rx_widgets.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:nativeblog/src/ui/routers.dart';
import 'package:share/share.dart';


class Detail extends StatelessWidget {
  Detail(this.article, {this.category}) : assert(article != null);

  static const _kAppBarHeight = 256.0;

  final Post article;
  final String category;

  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final readindTime = estimateReadingTime(article.content);
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    return Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(builder: (context, constrain) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                primary: true,
                pinned: true,
                expandedHeight: _kAppBarHeight,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.none,
                  background: Hero(
                    tag: 'thumbnail_${article.id}',
                    transitionOnUserGestures: true,
                    child: ImagePlaceholder(
                      article.images?.first?.url,
                      height: _kAppBarHeight,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                    margin: EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        Text(article.title,
                            style: textTheme.title
                                .copyWith(fontWeight: FontWeight.bold)),
                        // article meta
                        Container(
                          margin: EdgeInsets.only(top: 16),
                          // height: 200,
                          child: Row(
                            // crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 12,
                              ),
                              ClipOval(
                                child: Container(
                                  color: Colors.grey.shade200,
                                  child: ImagePlaceholder(
                                      'https:${article.author.image?.url}',
                                      width: 60,
                                      height: 60),
                                ),
                              ),
                              Container(
                                width: 12,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  RichText(
                                      text: TextSpan(
                                          children: [
                                        TextSpan(
                                            text: article.author.displayName,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor)),
                                        TextSpan(text: ' . '),
                                        TextSpan(
                                            text: timeago
                                                .format(article.published))
                                      ],
                                          style: textTheme.subhead.copyWith(
                                              fontWeight: FontWeight.w500))),
                                  Container(
                                    height: 8.0,
                                  ),
                                  Text('${readindTime.inMinutes} menit mebaca')
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 16.0,
                        ),
                        DefaultTextStyle(
                          style: TextStyle(color: Colors.white),
                          child: Row(
                            children:
                                List.generate(article.labels.length, (index) {
                              return Container(
                                padding: EdgeInsets.all(4.0),
                                child: Container(
                                  padding: EdgeInsets.all(2.0),
                                  child: Text(
                                    article.labels[index],
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 11),
                                  ),
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withAlpha(60),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    )),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Html(
                    data: article.content,
                    onLinkTap: (url) {
                      String uri = Uri.encodeQueryComponent(url);
                      appRouter.navigateTo(
                          context, "/open_url?url=$uri");
                    },
                    defaultTextStyle:
                        TextStyle(fontSize: 15.0, letterSpacing: 0.75),
                    useRichText: true,
                    linkStyle: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600),
                    customRender: (node, child) {
                      dom.Element el = node;
                      print('custom element');
                      print(el.localName);
                      if (el.localName == 'img') {
                        return ImagePlaceholder(el.attributes['src']);
                      }
                      if (el.localName == 'code') {
                        return Scrollable(
                          axisDirection: AxisDirection.left,
                          viewportBuilder: (context, offset) => Container(
                                color: Colors.black,
                                child: DefaultTextStyle(
                                  style: TextStyle(color: Colors.white),
                                  child: Column(
                                    children: child,
                                  ),
                                ),
                              ),
                        );
                      }
                    },
                  ),
                ),
              ),
              // comments area
              // buildCommentBox()
            ],
          );
        }));
  }

  SliverFillRemaining buildCommentBox() {
    return SliverFillRemaining(
              child: Container(
                child: RxCommandBuilder<List<Comment>>(
                  commandResults:
                      sl.get<AppManager>().displayPostCommentCmd.results,
                  busyBuilder: (context) {
                    return Center(child: Text('mengambil komentar'));
                  },
                  placeHolderBuilder: (context) {
                    return Center(child: Text('menyiapkan komentar'));
                  },
                  dataBuilder: (context, comments) {
                    ListView.builder(
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return ListTile(
                          title: Text(comment.content),
                          subtitle: Text(comment.published.toIso8601String()),
                        );
                      },
                      itemCount: comments.length,
                    );
                  },
                ),
              ),
            );
  }
}

class _BottomSheet extends StatelessWidget {
  _BottomSheet({
    @required this.url,
  }) : assert(url != null);

  final dynamic url;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Container(
          width: double.infinity,
          child: Material(
            color: Theme.of(context).cardColor,
            elevation: 24.0,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: ButtonBar(
                alignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  FlatButton(
                    textColor: Theme.of(context).accentColor,
                    child: Text('Share'),
                    onPressed: () => _share(),
                  ),
                  RaisedButton(
                    color: Theme.of(context).accentColor,
                    colorBrightness: Brightness.dark,
                    child: Text('Full article'),
                    onPressed: () => {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _share() {
    Share.share('$url?reff=app');
  }
}

class _Actions extends StatelessWidget {
  _Actions({
    this.actions,
  })  : assert(actions != null),
        assert(actions.isNotEmpty);

  final List<IconButton> actions;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SafeArea(
        child: Container(
          width: 56.0 * actions.length,
          height: 56.0,
          child: Material(
            color: Theme.of(context).primaryColor,
            elevation: 4.0,
            shape: BeveledRectangleBorder(
              borderRadius:
                  BorderRadius.only(bottomRight: Radius.circular(16.0)),
            ),
            child: ListView.builder(
              itemCount: actions.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                return actions[index];
              },
            ),
          ),
        ),
      ),
    );
  }
}

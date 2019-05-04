import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/blogger/v3.dart';
import 'package:nativeblog/src/managers/app_manager.dart';
import 'package:nativeblog/src/service_locator.dart';
import 'package:nativeblog/src/ui/screens/browse.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:nativeblog/src/ui/screens/detail.dart';
import 'package:rx_widgets/rx_widgets.dart';
import 'package:nativeblog/src/ui/ads.dart' as ads;

class AppRouter extends Router with NavigatorObserver {
  String rootPath = "/";
  String detailPath = "/details";
  String launchUrlPath = "/open_url";
  FirebaseAnalytics analytics;
  dynamic _cached;

  AppRouter() {
    analytics = FirebaseAnalytics();
    _initRouters();
  }

  navigate<T>(BuildContext buildContext, {String path, T t}) {
    _cached = t;
    navigateTo(buildContext, path);
  }

  @override
  Future navigateTo(BuildContext context, String path, {bool replace = false, bool clearStack = false, TransitionType transition, Duration transitionDuration = const Duration(milliseconds: 250), transitionBuilder}) {
    analytics.setCurrentScreen(screenName: path);
    ads.bottomAds..load()..dispose();
    return super.navigateTo(context, path, replace: replace, clearStack: clearStack, transition: transition, transitionDuration: transitionDuration, transitionBuilder: transitionBuilder);
  }

  void _initRouters() {
    notFoundHandler = Handler(handlerFunc: (context, query) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Router NotFound')));
    }, type: HandlerType.function);

    define('$launchUrlPath',
        handler: Handler(
            handlerFunc: (context, query) {
              final url = Uri.decodeQueryComponent(query['url']?.first);
              analytics.logEvent(name: 'open_internal_browser', parameters: {'url': url});
              launch(
                url,
                option: CustomTabsOption(
                  enableDefaultShare: true,
                  enableUrlBarHiding: true,
                  showPageTitle: true,
                  animation: CustomTabsAnimation.slideIn(),
                ),
              );
            },
            type: HandlerType.function));
    define(detailPath,
        handler: ObjectOrParamsHandler<Post>(
            handlerObj: (context, query, post) {
              return Detail(post);
            },
            handlerFunc: (context, query) {
              final postId = query['postId']?.first;
              print(_cached.id == postId);
              if(_cached != null){
                return Detail(_cached);
              }

              ads.fullAds..load()..show();

              sl.get<AppManager>().displayPostCmd(postId);
              return RxLoader<Post>(
                commandResults: sl.get<AppManager>().displayPostCmd.results,
                placeHolderBuilder: (context) {
                  final textTheme = Theme.of(context).textTheme;
                  return Scaffold(
                    body: Center(
                        child: Text(
                      'Mengambil Artikel..',
                      style: textTheme.title,
                    )),
                  );
                },
                dataBuilder: (context, post) {
                  return Detail(post);
                },
              );
            }), transitionType: TransitionType.inFromLeft);

    define(rootPath, handler: Handler(handlerFunc: (context, query) {
      analytics.logAppOpen();
      return Browse();
    }));
  }
}

typedef Widget HandlerObj<T>(
    BuildContext context, Map<String, List<String>> parameters, T item);

class ObjectOrParamsHandler<T> extends Handler {
  final HandlerObj<T> handlerObj;
  ObjectOrParamsHandler(
      {HandlerType type, HandlerFunc handlerFunc, this.handlerObj})
      : super(type: type, handlerFunc: handlerFunc);
}

final AppRouter appRouter = AppRouter();

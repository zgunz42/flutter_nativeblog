import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/blogger/v3.dart';
import 'package:nativeblog/src/managers/app_manager.dart';
import 'package:nativeblog/src/service_locator.dart';
import 'package:nativeblog/src/ui/screens/browse.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:nativeblog/src/ui/screens/detail.dart';
import 'package:rx_widgets/rx_widgets.dart';

class AppRouter extends Router with NavigatorObserver {
  String rootPath = "/";
  String detailPath = "/details";
  String launchUrlPath = "/open_url";
  dynamic _cached;

  AppRouter() {
    _initRouters();
  }

  navigate<T>(BuildContext buildContext, {String path, T t}) {
    _cached = t;
    navigateTo(buildContext, path);
  }

  void _initRouters() {
    notFoundHandler = Handler(handlerFunc: (context, query) {
      print('router not found');
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Router NotFound')));
    });

    define(launchUrlPath,
        handler: Handler(
            handlerFunc: (context, query) {
              final url = query['url']?.first;
              launch(
                '$url',
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
            }));

    define(rootPath, handler: Handler(handlerFunc: (context, query) {
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

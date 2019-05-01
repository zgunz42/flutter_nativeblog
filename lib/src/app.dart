import 'package:flutter/material.dart';
import 'package:nativeblog/src/ui/routers.dart';
import 'package:nativeblog/src/ui/theme/theme.dart';

class NativeBlogApp extends StatelessWidget {
  NativeBlogApp({Key key}) : super(key: key) {
    
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Native Blog Info',
      debugShowCheckedModeBanner: false,
      theme: nativeBlogTheme,
      navigatorObservers: [appRouter],
      initialRoute: '/',
      onGenerateRoute: appRouter.generator,
    );
  }
}

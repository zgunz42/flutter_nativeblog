import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nativeblog/src/ui/theme/colors.dart' as colors;

ThemeData nativeBlogTheme = _buildNativeBlogTheme();

ThemeData _buildNativeBlogTheme() {
  final baseTheme = ThemeData.light();
  final SystemUiOverlayStyle uiStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.black26);

  SystemChrome.setSystemUIOverlayStyle(uiStyle);

  return baseTheme.copyWith(
      appBarTheme: AppBarTheme(
        iconTheme: baseTheme.iconTheme.copyWith(
          color: Colors.black87
        ),
        textTheme: baseTheme.textTheme.apply(
          displayColor: Colors.black87,
          bodyColor: Colors.black87
        ),
        color: Colors.white, 
        elevation: 0.37,
        brightness: Brightness.dark),
        backgroundColor: Colors.white,
      splashColor: colors.primaryColor,
      buttonTheme: baseTheme.buttonTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)
      ),
      bottomAppBarTheme: baseTheme.bottomAppBarTheme.copyWith(
        color: colors.primaryColor,
      ),
      tabBarTheme: baseTheme.tabBarTheme.copyWith(
        labelColor: Colors.black87,
        indicatorSize: TabBarIndicatorSize.tab
      ),
      colorScheme: baseTheme.colorScheme.copyWith(
        onError: Colors.red
      ),
      indicatorColor: colors.primaryColor,
      textTheme: _buildTextTheme(baseTheme.textTheme));
}

TextTheme _buildTextTheme(TextTheme baseTheme) {
  return baseTheme
      .copyWith(
          title: baseTheme.title
              .copyWith(fontFamily: 'Open Sans', fontWeight: FontWeight.w600),
          subtitle: baseTheme.title
              .copyWith(fontFamily: 'Open Sans', fontWeight: FontWeight.w500),
          body1: baseTheme.body1
              .copyWith(fontFamily: 'Montserrat', fontSize: 14.0),
          body2: baseTheme.body2
              .copyWith(fontFamily: 'Montserrat', fontSize: 16.0))
      .apply(displayColor: Colors.black87, bodyColor: Colors.black87);
}

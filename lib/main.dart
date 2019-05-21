import 'package:flutter/material.dart';
import 'package:nativeblog/src/app.dart';
import 'package:nativeblog/src/config.dart';
import 'package:nativeblog/src/service_locator.dart';

void main() {
  initialize(AppConfig(
    appName: 'NativeBlog',
    bloggerApi: 'AIzaSyCs6jkJ5_v_Fer-Y6AYr1lLsukpDnXzwsI'
  ));
  runApp(NativeBlogApp());
}
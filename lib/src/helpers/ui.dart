import 'package:flutter/material.dart';

Widget addClick(Widget child, VoidCallback handler) {
  return GestureDetector(
    child: child,
    onTap: handler,
  );
}

String cleanTitle(String originalTitle) {
  List<String> split = originalTitle.split(' - ');
  return split[0];
}

String timestamp(DateTime oldDate) {
  String timestamp;
  DateTime currentDate = DateTime.now();
  Duration difference = currentDate.difference(oldDate);
  if (difference.inSeconds < 60) {
    timestamp = 'Now';
  } else if (difference.inMinutes < 60) {
    timestamp = '${difference.inMinutes}M';
  } else if (difference.inHours < 24) {
    timestamp = '${difference.inHours}H';
  } else if (difference.inDays < 30) {
    timestamp = '${difference.inDays}D';
  }
  return timestamp;
}

int _kWordLength = 500;

int countWordInSecond(String text, int wpm) {
  int totalWords = text.trim().split(RegExp(r'\s+', multiLine: true)).length;
  int wps = ( wpm ?? _kWordLength ) ~/ 60;
  return (totalWords ~/ wps) * 60;
}

Duration estimateReadingTime(String text) {
  final int readInSeconds = countWordInSecond(text, 200);
  return Duration(seconds: readInSeconds);
}

import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  const ErrorView(
      {Key key, @required this.onRetry, @required this.title, this.message})
      : super(key: key);

  final VoidCallback onRetry;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            style: textTheme.title,
          ),
          Text(message, style: textTheme.subhead.copyWith(color: Colors.grey)),
          GestureDetector(
            onTap: onRetry,
            child: Row(
              children: <Widget>[
                RotatedBox(
                    quarterTurns: 50,
                    child: Container(
                        width: 14, height: 14, child: Icon(Icons.rotate_left))),
                Container(width: 8),
                Text('Retry Preview Action')
              ],
            ),
          )
        ],
      ),
    );
  }
}

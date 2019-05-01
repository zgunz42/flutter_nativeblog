import 'package:flutter/material.dart';
import 'package:nativeblog/src/ui/components/dot_loading.dart';

class Loading extends StatefulWidget {

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {

    final dotController = DotProgressController();

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        constraints: BoxConstraints(
          minHeight: double.infinity
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/splash_logo.png', width: 50.0, height: 50.0, fit: BoxFit.contain,),
            DotProgressIndicator(
              controller: dotController,
              height: 20.0,
            )
          ],
        ),
      ),
    );
  }
}
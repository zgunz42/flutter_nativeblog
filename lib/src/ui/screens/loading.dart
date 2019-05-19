import 'package:flutter/material.dart';
import 'package:nativeblog/src/ui/components/dot_loading.dart';
import 'package:nativeblog/src/ui/routers.dart' as routers;


class Loading extends StatefulWidget {
  final String redirectUrl;
  final Stream<double> process;

  const Loading({Key key, this.redirectUrl, this.process}) : super(key: key);
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  String redirectUrl;
  DotProgressController dotController;

  @override
  void initState() {
    redirectUrl = widget.redirectUrl ?? routers.appRouter.rootPath;
    dotController = DotProgressController();
    widget.process.listen((progress) {
      if(mounted) {
        dotController.setPendingTask(progress);
      }
    }).onDone(() => routers.appRouter.navigateTo(context, redirectUrl, replace: true, clearStack: true));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            Image.asset('assets/images/icon-foreground.png', width: 80.0, height: 80.0, fit: BoxFit.contain,
            color: Colors.white
            ),
            Container(height: 20,),
            DotProgressIndicator(
              controller: dotController,
              padding: 4.0,
              height: 60.0,
            )
          ],
        ),
      ),
    );
  }
}
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class DotProgressController {
  DotProgressController({this.total = 5});
  final int total;
  _DotProgressIndicatorState _state;

  void addFinishTask(int total) {
    _state.setState(() {
      _state.pending += total;
    });
  }

  void togglePause(){
    _state.pause = true;
  }

  void setPendingTask(double progress) {

    _state.setState(() {
      _state.pending = (progress).clamp(1, total);
    });
  }

  void addPercentFinishTask(double percent) {
    if (percent > 100.0) throw 'over the maximum value allowed';
    final int totalLoadedDot = lerpDouble(0, 5, percent / 100.0).round();
    _state.setState(() {
      _state.pending = totalLoadedDot - _state.finish;
    });
  }

  void finishAll() {
    _state.setState(() {
      _state.pending = _state.total - _state.finish;
    });
  }
}

///indicator
class DotProgressIndicator extends ProgressIndicator {
  DotProgressIndicator({@required this.controller, this.padding, this.height, this.fadeSecond, this.total});

  final int total;
  final int fadeSecond;
  final double height;
  final double padding;
  
  final DotProgressController controller;

  @override
  _DotProgressIndicatorState createState() => _DotProgressIndicatorState();
}

class _DotProgressIndicatorState extends State<DotProgressIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  int finish;
  int total;
  int pending;
  bool pause;

  final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeInOut);

  Animation<double> totalFade;

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
    finish = 0;
    pending = 0;
    pause = false;
    total = widget.controller.total ?? widget.total ?? 5;
    controller =
        AnimationController(duration: Duration(milliseconds: widget.fadeSecond ?? 500), vsync: this);
    totalFade = controller
        .drive(Tween<double>(begin: 0.15, end: 1.0).chain(_easeInTween));
    if (!isFullyLoaded()) {
      controller.addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          if (pending > 0) {
            finish += 1;
            pending -= 1;
          }
          if(!pause) 
            controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          if(!pause)
            controller.forward();
        }
      });
      controller.forward();
    }
  }

  bool isFullyLoaded() {
    return pending == 0 && finish == total;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DotProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isFullyLoaded() && !controller.isCompleted) {
      if (pending > 0) {
        finish += 1;
        pending -= 1;
      }
      controller.reverse();
    } else if (controller.isDismissed) if (!isFullyLoaded())
      controller.animateTo(controller.upperBound);
    else
      controller.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      value: 'app loaded $finish from $total',
      child: Container(
        constraints: BoxConstraints(
          minWidth: double.infinity, 
          minHeight: widget.height ?? 40.0,
        ),
        child: AnimatedBuilder(
          animation: controller,
          builder: (BuildContext context, Widget child) {
            return CustomPaint(
              painter: DotLoadingPainter(
                  active: finish,
                  fadeOpacitiy: totalFade.value,
                  total: total,
                  padding: widget.padding,
                  fadeColor: Colors.white),
            );
          },
        ),
      ),
    );
  }
}

/// draw dot like facebook lite indicator
class DotLoadingPainter extends CustomPainter {
  DotLoadingPainter(
      {this.total,
      this.maxBlock,
      this.fadeColor,
      this.active = 0,
      this.padding = 0.0,
      this.fadeOpacitiy = 0.15,
      this.fadeLast});

  final int total;
  final int active;
  final bool fadeLast;
  final double padding;
  final double fadeOpacitiy;
  final Color fadeColor;
  final int maxBlock;

  DotInfo drawDotBlock(int position,
      {Paint fill,
      double padding = 4.0,
      double radius = 1.0,
      double size = 15.0,
      double startAtX = 0.0,
      double startAtY = 0.0}) {
    fill ??= Paint();
    if (active < position) {
      fill.color = fadeColor.withOpacity(0.15);
    } else if (active > position) {
      fill.color = fadeColor;
    } else {
      fill.color = fadeColor.withOpacity(fadeOpacitiy);
    }
    final double sizeWithPadding = size + padding;
    final double xPos = position * sizeWithPadding + startAtX;
    return DotInfo(xPos, 0.0, size, radius, fill);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double paintWidth = size.width / total;
    final double paintHeight = size.height / total;
    final double blocSize = min(paintWidth, paintHeight);
    final double sizeWithPadding = blocSize + padding;
    final double contentWidth = total * sizeWithPadding;
    double sizeadd = 0;
    if (size.width > contentWidth) {
      sizeadd = (size.width - contentWidth) / 2;
    }
    for (int i = 0; i < total; i++) {
      final DotInfo dotInfo =
          drawDotBlock(i, size: blocSize, startAtX: sizeadd);
      canvas.drawRRect(dotInfo.toRRect(), dotInfo.fill);
    }
  }

  @override
  bool shouldRepaint(DotLoadingPainter oldDelegate) {
    return true;
  }
}

class DotInfo {
  DotInfo(this.xPos, this.yPos, this.size, this.radius, this.fill);
  final double xPos;
  final double yPos;
  final double size;
  final double radius;
  final Paint fill;

  RRect toRRect() {
    return RRect.fromLTRBR(
        xPos, yPos, xPos + size, yPos + size, Radius.circular(radius));
  }
}

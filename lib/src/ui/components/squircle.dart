import 'package:flutter/material.dart';
import 'package:nativeblog/src/helpers/ui.dart';

class ToolModel {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  ToolModel(this.icon, this.title, this.onTap);
}

class ToolTile extends StatelessWidget {
  const ToolTile({Key key, this.icon, this.title, this.background, this.onTap})
      : super(key: key);

  final Icon icon;
  final Widget title;
  final Color background;
  final VoidCallback onTap;

  factory ToolTile.fromModel({ToolModel model, Color background, }) {
    return ToolTile(
      icon: Icon(model.icon, color: Colors.white,),
      title: Text(model.title, ),
      onTap: model.onTap,
      background: background,
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            child: new Material(
              color: background ?? theme.primaryColor,
              elevation: 1.0,
              shape: new SquircleBorder(
                side: BorderSide(color: background ?? theme.primaryColor, width: 3.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: icon,
              ),
            ),
          ),
          Container(
            height: 8.0,
          ),
          DefaultTextStyle(
            style: theme.textTheme.caption,
            child: title,
          )
        ],
      ),
    );
  }
}

class SquircleBorder extends ShapeBorder {
  final BorderSide side;
  final double superRadius;

  const SquircleBorder({
    this.side: BorderSide.none,
    this.superRadius: 5.0,
  })  : assert(side != null),
        assert(superRadius != null);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  ShapeBorder scale(double t) {
    return new SquircleBorder(
      side: side.scale(t),
      superRadius: superRadius * t,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return _squirclePath(rect.deflate(side.width), superRadius);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    return _squirclePath(rect, superRadius);
  }

  static Path _squirclePath(Rect rect, double superRadius) {
    final c = rect.center;
    final dx = c.dx * (1.0 / superRadius);
    final dy = c.dy * (1.0 / superRadius);
    return new Path()
      ..moveTo(c.dx, 0.0)
      ..relativeCubicTo(c.dx - dx, 0.0, c.dx, dy, c.dx, c.dy)
      ..relativeCubicTo(0.0, c.dy - dy, -dx, c.dy, -c.dx, c.dy)
      ..relativeCubicTo(-(c.dx - dx), 0.0, -c.dx, -dy, -c.dx, -c.dy)
      ..relativeCubicTo(0.0, -(c.dy - dy), dx, -c.dy, c.dx, -c.dy)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {
    switch (side.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        var path = getOuterPath(rect.deflate(side.width / 2.0),
            textDirection: textDirection);
        canvas.drawPath(path, side.toPaint());
    }
  }
}

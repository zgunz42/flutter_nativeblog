import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rx_command/rx_command.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:rx_widgets/rx_widgets.dart'
import 'package:shimmer/shimmer.dart';

typedef ScrollPoint = int Function(Offset percent);
typedef ListTypeBuilder = Widget Function(
    BuildContext context, ListItemType type);
typedef LayoutTypeOf<T> = ListItemType Function(int item);
typedef LoadMore = Future<void> Function(int page);
typedef ItemBuilder<T> = Widget Function(
    BuildContext context, T data, ListItemType itemType);
enum ListItemType { list, gallery, card }

class LazyList<T> extends StatefulWidget {
  const LazyList(
      {Key key,
      @required this.initPageNumber,
      @required this.commandResults,
      @required this.dataBuilder,
      @required this.shimmerBuilder,
      @required this.onMore,
      @required this.onRefresh,
      this.itemTypeLayout,
      this.touchPoint,
      this.delay})
      : super(key: key);
  final int initPageNumber;
  final Stream<CommandResult<List<T>>> commandResults;
  final ItemBuilder<T> dataBuilder;
  final LoadMore onMore;
  final RefreshCallback onRefresh;
  final ScrollPoint touchPoint;
  final LayoutTypeOf<T> itemTypeLayout;
  final ListTypeBuilder shimmerBuilder;
  final Duration delay;

  @override
  _LazyListState createState() => _LazyListState<T>();
}

final Animatable<double> _kRotationTween = CurveTween(curve: Curves.easeInCirc);

class _LazyListState<T> extends State<LazyList>
    with SingleTickerProviderStateMixin<LazyList> {
  // final List<T> items = [];
  int lastPageIndex = 1;

  AnimationController animCntrl;

  ScrollController scrollCntrl;

  StreamSubscription<CommandResult<List<T>>> subscription;

  Stream<CommandResult<List<T>>> commandResults;

  CommandResult<List<T>> lastReceivedItem =
      new CommandResult<List<T>>(null, null, false);

  Offset hideOffset;

  Duration updateDelay;

  bool inFetch;

  @override
  void initState() {
    commandResults = widget.commandResults;
    subscription = commandResults.listen((result) {
      setState(() {
        lastReceivedItem = result;
      });
    });
    updateDelay = widget.delay ?? Duration(milliseconds: 300);
    inFetch = false;
    scrollCntrl = ScrollController();
    animCntrl = AnimationController(vsync: this);

    scrollCntrl.addListener(() async {
      if (scrollCntrl.position.pixels >= scrollCntrl.position.maxScrollExtent) {
        if (!inFetch) {
          try {
            inFetch = true;
            await Future.delayed(
                updateDelay, () => widget.onMore(lastPageIndex));
            lastPageIndex += 1;
            animCntrl.repeat(period: Duration(milliseconds: 500)).orCancel;
          } catch (e) {
            print(e);
          }
          inFetch = false;
        }
      }
      // hideOffset = Offset.lerp(
      //     Offset.zero, Offset(0.0, 1.0), scrollCntrl.position.pixels);
      // widget.touchPoint(hideOffset);

      // user stop from scrolling
      // if (scrollCntrl.position.activity.isScrolling != true) {}
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.onRefresh();
  }

  @override
  dispose() {
    super.dispose();
    animCntrl.dispose();
    subscription?.cancel();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    subscription?.cancel();

    subscription = commandResults.listen((result) {
      setState(() {
        print('updateWidget ${lastReceivedItem.data}');
        lastReceivedItem = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<Widget> content = <Widget>[];
    Widget action;

    if (lastReceivedItem.hasData && lastReceivedItem.data.isNotEmpty) {
      content.addAll(_buildItemList(lastReceivedItem.data));
    }
    if (lastReceivedItem.isExecuting) {
      content.add(_buildShimmerList(5));
    } else {
      action = _buildAction('Loading more content', Icons.refresh, Colors.white,
          theme.primaryColor.withOpacity(0.3));
    }

    if (lastReceivedItem.hasError && !inFetch) {
      content.add(Center(
        child: Text('got some error: ${lastReceivedItem.error}'),
      ));
    }

    return Container(
      color: Colors.white,
      child: RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: CustomScrollView(
          controller: scrollCntrl,
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate(content),
            ),
            SliverToBoxAdapter(
              child: action,
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildItemList(List posts) {
    List<Widget> content = [];
    for (var index = 0; index < posts.length; index++) {
      if (index < posts.length - 1 && index > 0) {
        content.add(Divider(
          height: 2.0,
        ));
      }
      content.add(widget.dataBuilder(
          context, posts[index], widget.itemTypeLayout(index)));
    }
    return content;
  }

  Widget _buildShimmerList(int count) {
    final List<Widget> items = List.generate(
        count,
        (index) => Flexible(
            flex: 20,
            child: widget.shimmerBuilder(
              context,
              widget.itemTypeLayout(index),
            ))).toList();

    return Shimmer.fromColors(
      baseColor: Colors.grey[300],
      highlightColor: Colors.grey[100],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items,
      ),
    );
  }

  Widget _buildAction(
      String message, IconData icon, Color color, Color background) {
    return Container(
      width: double.infinity,
      height: 40.0,
      color: background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              child: RotationTransition(
                  turns: _kRotationTween.animate(animCntrl),
                  child: Icon(icon, color: color))),
          Container(width: 12),
          Text(
            message,
            style: TextStyle(color: color),
          )
        ],
      ),
    );
  }
}

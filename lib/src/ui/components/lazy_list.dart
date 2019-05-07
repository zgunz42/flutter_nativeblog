import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nativeblog/src/ui/components/ads.dart';
import 'package:nativeblog/src/ui/components/squircle.dart';
import 'package:nativeblog/src/ui/icons.dart';
import 'package:rx_command/rx_command.dart';
import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter_native_admob/flutter_native_admob.dart';
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
      this.primary = false,
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
  final bool primary;

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

  // MobileAd ads;

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
    // displayBannerAds().load();
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
    // ads.dispose();
    subscription?.cancel();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    subscription?.cancel();
    // ads.isLoaded().then((hasLoad) {
    //   if (!hasLoad) ads.load();
    // });

    subscription = commandResults.listen((result) {
      setState(() {
        print('updateWidget ${lastReceivedItem.data}');
        lastReceivedItem = result;
      });
    });
  }

  Widget buildCrauselItem(String title, String imageUrl, VoidCallback onTap) {
    return ClipRRect(
      borderRadius: new BorderRadius.circular(20.0),
      child: Container(
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(imageUrl), fit: BoxFit.cover)),
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.black.withAlpha(100), Colors.transparent]),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 16,
              right: 30,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  Container(
                    height: 8,
                  ),
                  OutlineButton(
                    color: Colors.white,
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                    child: Text(
                      'SEE MORE',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: onTap,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCrausel() {
    return CarouselSlider(
      items: <Widget>[
        buildCrauselItem(
            'Best Blogging Android Apps', 'assets/images/vscode.png', () {}),
        buildCrauselItem('Master The Art Of Blogging With These 8 Tips',
            'assets/images/escape-shortlink.png', () {}),
        buildCrauselItem(
            'Knowing These 8 Secrets Will Make Your Blogging Look Amazing',
            'assets/images/settings-proxy-ubuntu.jpg',
            () {}),
        buildCrauselItem('The Truth About Blogging In 3 Little Words',
            'assets/images/hugo-blogger.png', () {}),
        buildCrauselItem('8 Reasons Blogging Is A Waste Of Time',
            'assets/images/slow-pc.png', () {}),
      ],
      enableInfiniteScroll: true,
      autoPlay: true,
      enlargeCenterPage: true,
    );
  }

  Widget _buildToolList() {
    List<ToolModel> models = <ToolModel>[
      ToolModel(NativeBlogIcons.qrcode, 'Scan QR', () {}),
      ToolModel(NativeBlogIcons.shortlink, 'Shortlink', () {}),
      ToolModel(NativeBlogIcons.shop, 'Toko Online', () {}),
      ToolModel(NativeBlogIcons.job, 'Lowongan', () {}),
      ToolModel(NativeBlogIcons.promo, 'Penawaran', () {}),
      ToolModel(NativeBlogIcons.games, 'Permainan', () {}),
      ToolModel(NativeBlogIcons.livetv, 'Tv Online', () {}),
      ToolModel(NativeBlogIcons.moremenu, 'Menu Lainnya', () {}),
    ];

    return SliverGrid(
      delegate: SliverChildListDelegate(List.generate(
          models.length,
          (index) => ToolTile.fromModel(
              model: models[index],
              background: index == models.length - 1
                  ? Colors.grey.shade200
                  : Theme.of(context).primaryColor)).toList()),
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<Widget> content = <Widget>[];
    final List<Widget> slivers = <Widget>[];
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

    // displayBannerAds().show();

    if (widget.primary) {
      slivers.addAll([
        SliverToBoxAdapter(child: _buildCrausel()),
        SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Favorite Menu',
                    style: Theme.of(context)
                        .textTheme
                        .title
                        .copyWith(fontSize: 15)),
                Container(height: 4),
                Text('Menu yang sering kamu gunakan',
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        .copyWith(color: Colors.grey.shade400, fontSize: 11)),
              ],
            ),
          ),
        ),
        _buildToolList(),
      ]);
    }

    slivers.addAll([
      SliverList(
        delegate: SliverChildListDelegate(content),
      ),
      SliverToBoxAdapter(
        child: action,
      )
    ]);

    return Container(
      color: Colors.white,
      child: RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: CustomScrollView(
          controller: scrollCntrl,
          slivers: slivers,
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
      if (index != 0 && index % 5 == 0) {
        content.add(Ads.random());
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

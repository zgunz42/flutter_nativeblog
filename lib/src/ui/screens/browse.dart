import 'package:flutter/material.dart';
import 'package:googleapis/blogger/v3.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:nativeblog/src/managers/app_manager.dart';
import 'package:nativeblog/src/service_locator.dart';
import 'package:nativeblog/src/ui/components/search.dart';
import 'package:nativeblog/src/ui/components/video_tile.dart';
import 'package:nativeblog/src/ui/icons.dart';
import 'package:nativeblog/src/ui/components/lazy_list.dart';
import 'package:nativeblog/src/ui/components/post_tile.dart';

class Browse extends StatefulWidget {
  const Browse({Key key, this.platform, this.categories}) : super(key: key);

  final TargetPlatform platform;
  final List<String> categories;

  @override
  _BrowseState createState() => _BrowseState();
}

class _BrowseState extends State<Browse>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  TabController tabCntrl;
  int activeMenuIndex;
  Offset hideOffset;
  List<String> tabs;
  bool hideTab;

  @override
  dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    tabCntrl.dispose();
  }

  @override
  void initState() {
    tabCntrl = TabController(vsync: this, length: 7);
    activeMenuIndex = 0;
    hideTab = false;
    WidgetsBinding.instance.addObserver(this);
    tabs = [
      'Rekomendasi',
      'Teknologi',
      'Olahraga',
      'Kesehatan',
      'Hiburan',
      'Showbiz',
      'Fashion'
    ];

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final browseContent = initbrowseContent();
    return Scaffold(
      appBar: AppBar(
        title: Title(
          title: 'Nativeblog',
          child: Text(
            'NativeBlog',
            style: theme.textTheme.title.copyWith(fontSize: 23.0),
          ),
          color: Colors.white,
        ),
        actions: <Widget>[SearchButton()],
        bottom: !hideTab ? TabBar(
          controller: tabCntrl,
          isScrollable: true,
          tabs: tabs.map((it) => Tab(text: it)).toList(),
        ) : null,
      ),
      body: SafeArea(child: browseContent.values.elementAt(activeMenuIndex)),
      bottomNavigationBar: BottomNavigationBar(
          fixedColor: Theme.of(context).primaryColor,
          type: BottomNavigationBarType.fixed,
          currentIndex: activeMenuIndex,
          onTap: updateBrowseContent,
          items: browseContent.keys.toList()),
    );
  }

  void updateBrowseContent(int index) {
    setState(() {
      hideTab = index != 0 ? true : false;
      activeMenuIndex = index;
    });
  }
}

Map<BottomNavigationBarItem, Widget> initbrowseContent() {
  final Map<BottomNavigationBarItem, Widget> browseContent =
      <BottomNavigationBarItem, Widget>{};
  final blogNavItem = BottomNavigationBarItem(
      icon: Icon(NativeBlogIcons.home), title: Text('Blog'));
  final videoNavItem = BottomNavigationBarItem(
      icon: Icon(NativeBlogIcons.film_play), title: Text('Video'));
  final snsNavItem = BottomNavigationBarItem(
      icon: Icon(NativeBlogIcons.earth), title: Text('Linimasa'));
  final notifNavItem = BottomNavigationBarItem(
      icon: Icon(NativeBlogIcons.bullhorn), title: Text('Notification'));
  final profileNavItem = BottomNavigationBarItem(
      icon: Icon(NativeBlogIcons.user), title: Text('Me'));

  browseContent[blogNavItem] = LazyList(
    initPageNumber: 1,
    primary: true,
    commandResults: sl.get<AppManager>().updateArticlesCmd.results,
    dataBuilder: (context, data, type) {
      return type == ListItemType.list
          ? PostTile(article: data)
          : PostCard(article: data);
    },
    shimmerBuilder: (context, type) {
      return type == ListItemType.list ? PostTile.shimmer : PostCard.shimmer;
    },
    onMore: (page) async => sl.get<AppManager>().pageArticleCmd(page),
    onRefresh: () async => sl.get<AppManager>().prefetchCmd(false),
    itemTypeLayout: (index) {
      return index % 4 != 2 ? ListItemType.list : ListItemType.card;
    },
  );
  browseContent[videoNavItem] = LazyList(
    initPageNumber: 1,
    commandResults: sl.get<AppManager>().updateVideosCmd.results,
    dataBuilder: (context, data, type) {
      print(data.toJson());
      return Container(
        padding: EdgeInsets.only(bottom: 8),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[300]))
          ),
          child: VideoTile(
            title: data.title,
            thumbnail: data.thumbnails.medium.url,
            channelName: data.channelTitle,
            publishedAt: data.publishedAt,
          ),
        ),
      );
    },
    shimmerBuilder: (context, type) {
      return VideoTile.shimmer;
    },
    onMore: (page) async => sl.get<AppManager>().updateVideosCmd(),
    onRefresh: () async => sl.get<AppManager>().updateVideosCmd(),
    itemTypeLayout: (index) => ListItemType.card,
  );
  browseContent[snsNavItem] = Center(child: Text('Linimasa Container'));
  browseContent[notifNavItem] = Center(child: Text('Notifikasi Container'));
  browseContent[profileNavItem] = Center(child: Text('Profile Container'));
  return browseContent;
}

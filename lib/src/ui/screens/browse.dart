import 'package:flutter/material.dart';
import 'package:googleapis/blogger/v3.dart';
import 'package:nativeblog/src/managers/app_manager.dart';
import 'package:nativeblog/src/service_locator.dart';
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

class _BrowseState extends State<Browse> with TickerProviderStateMixin {
  TabController tabCntrl;

  Offset hideOffset;

  @override
  dispose() {
    super.dispose();
    tabCntrl.dispose();
  }

  @override
  void initState() {
    tabCntrl = TabController(vsync: this, length: 7);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: FlutterLogo(
          style: FlutterLogoStyle.horizontal,
          size: 120,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(NativeBlogIcons.magnifier),
            tooltip: 'search for article',
            onPressed: () =>
                showSearch(context: context, delegate: PostSearchDelegated()),
          )
        ],
        bottom: TabBar(
          controller: tabCntrl,
          isScrollable: true,
          tabs: <Widget>[
            Tab(
              text: 'Rekomendasi',
            ),
            Tab(
              text: 'Teknologi',
            ),
            Tab(
              text: 'Olahraga',
            ),
            Tab(
              text: 'Kesehatan',
            ),
            Tab(
              text: 'Hiburan',
            ),
            Tab(
              text: 'Showbiz',
            ),
            Tab(
              text: 'Fashion',
            ),
          ],
        ),
      ),
      body: SafeArea(
          child: LazyList(
            initPageNumber: 1,
            commandResults: sl.get<AppManager>().updateArticlesCmd.results,
            dataBuilder: (context, data, type) {
              return type == ListItemType.list
                  ? PostTile(article: data)
                  : PostCard(article: data);
            },
            shimmerBuilder: (context, type) {
              return type == ListItemType.list
                  ? PostTile.shimmer
                  : PostCard.shimmer;
            },
            onMore: (page) async => sl.get<AppManager>().pageArticleCmd(page),
            onRefresh: () async => sl.get<AppManager>().prefetchCmd(false),
            itemTypeLayout: (index) {
              return index % 4 != 2 ? ListItemType.list : ListItemType.card;
            },
          )),
      bottomNavigationBar: BottomNavigationBar(
          fixedColor: Theme.of(context).primaryColor,
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(NativeBlogIcons.home), title: Text('Blog')),
            BottomNavigationBarItem(
                icon: Icon(NativeBlogIcons.film_play), title: Text('Video')),
            BottomNavigationBarItem(
                icon: Icon(NativeBlogIcons.earth), title: Text('Update')),
            BottomNavigationBarItem(
                icon: Icon(NativeBlogIcons.bullhorn), title: Text('Info')),
            BottomNavigationBarItem(
                icon: Icon(NativeBlogIcons.user), title: Text('Me'))
          ]),
    );
  }
}

//TODO: move to another file

class PostSearchDelegated extends SearchDelegate<Post> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      query.isEmpty
          ? IconButton(
              tooltip: 'Voice Search',
              icon: const Icon(Icons.mic),
              onPressed: () {
                query = 'TODO: implement voice input';
              },
            )
          : IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.clear),
              onPressed: () {
                query = '';
                showSuggestions(context);
              },
            ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text('No result'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _SuggestionList(
      query: 'bisa',
      onSelected: (query) {},
      suggestions: ['bisa coba', 'bisa saja', 'bisa pasti', 'bisa'],
    );
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({this.suggestions, this.query, this.onSelected});

  final List<String> suggestions;
  final String query;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int i) {
        final String suggestion = suggestions[i];
        return ListTile(
          leading: query.isEmpty ? const Icon(Icons.history) : const Icon(null),
          title: RichText(
            text: TextSpan(
              text: suggestion.substring(0, query.length),
              style:
                  theme.textTheme.subhead.copyWith(fontWeight: FontWeight.bold),
              children: <TextSpan>[
                TextSpan(
                  text: suggestion.substring(query.length),
                  style: theme.textTheme.subhead,
                ),
              ],
            ),
          ),
          onTap: () {
            onSelected(suggestion);
          },
        );
      },
    );
  }
}

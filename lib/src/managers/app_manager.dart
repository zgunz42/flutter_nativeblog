import 'package:nativeblog/src/helpers/client.dart';
import 'package:rx_command/rx_command.dart';
import 'package:connectivity/connectivity.dart';
import 'package:googleapis/blogger/v3.dart';
import 'package:googleapis/youtube/v3.dart' as youtube;

abstract class AppManager {
  int get postPerPage;

  RxCommand<bool, void> prefetchCmd;

  RxCommand<String, String> searchArticleCmd;

  RxCommand<bool, bool> onlineCheckCmd;

  RxCommand<String, Post> displayPostCmd;

  RxCommand<void, List<Post>> updateArticlesCmd;

  RxCommand<void, List<youtube.SearchResultSnippet>> updateVideosCmd;

  RxCommand<String, List<Comment>> displayPostCommentCmd;

  // RxCommand<String,

  RxCommand<int, int> pageArticleCmd;
}

class AppManagerImpl implements AppManager {
  AppManagerImpl({String blogId = '7342017194742683056', String channelId = 'UCepgnl-TtJ8DurHdC6EE22w'}) {
    BloggerApi blog = BloggerApi(BloggerClient());
    youtube.YoutubeApi video = youtube.YoutubeApi(BloggerClient());
    Map<int, PostList> pages = <int, PostList>{};
    Map<String, List<CommentList>> comments = <String, List<CommentList>>{};

    searchArticleCmd = RxCommand.createSync<String, String>((term) => term);
    onlineCheckCmd = RxCommand.createSync<bool, bool>((online) => online,
        initialLastResult: true);
    pageArticleCmd = RxCommand.createSync<int, int>((index) => index,
        initialLastResult: 1, emitInitialCommandResult: true, emitLastResult: true);
    displayPostCmd = RxCommand.createAsync((postId) {
      displayPostCommentCmd(postId);
      return blog.posts.get(blogId, postId, fetchImages: true);
    });

    prefetchCmd = RxCommand.createSync((force) {
      if(force) pages.clear();
      updateArticlesCmd();
    });

    displayPostCommentCmd = RxCommand.createAsync((postId) async {
      final postComment = await blog.comments.list(blogId, postId, fetchBodies: true, maxResults: 15);
      comments.putIfAbsent(postId, () => []);
      comments[postId].add(postComment);

      return postComment.items;
    });


    updateVideosCmd = RxCommand.createAsyncNoParam(() async {
      youtube.SearchListResponse searchResult = await video.search.list('snippet', channelId: channelId);
      return searchResult.items.map((s) => s.snippet);
    });

    updateArticlesCmd = RxCommand.createAsyncNoParam(() async {
      final index = pageArticleCmd.lastResult;
      final List<Post> results = [];
      var pageToken;

      for (var pageIndex = 1; pageIndex <= index; pageIndex++) {
        if (pages.containsKey(pageIndex)) {
          pageToken = pages[pageIndex].nextPageToken;
        } else {
          pages[pageIndex] = await blog.posts.list(blogId,
              fetchImages: true, fetchBodies: true, pageToken: pageToken);
        }
        results.addAll(pages[pageIndex].items);
      }
      print(index);
      print(results);
      return results;
    },
        emitLastResult: true,
        initialLastResult: [],
        emitInitialCommandResult: true,
        emitsLastValueToNewSubscriptions: true);

    Connectivity().onConnectivityChanged.listen((network) {
      onlineCheckCmd(network != ConnectivityResult.none);
    });

    pageArticleCmd
        .debounce(Duration(milliseconds: 300))
        .listen(updateArticlesCmd);

    searchArticleCmd
        .debounce(Duration(milliseconds: 300))
        .distinct()
        .listen((_) => updateArticlesCmd());
  }

  @override
  RxCommand<bool, void> prefetchCmd;

  @override
  RxCommand<String, String> searchArticleCmd;

  RxCommand<void, List<Post>> updateArticlesCmd;

  @override
  RxCommand<bool, bool> onlineCheckCmd;

  @override
  RxCommand<int, int> pageArticleCmd;

  @override
  RxCommand<String, Post> displayPostCmd;

  @override
  int get postPerPage => 10;

  @override
  RxCommand<String, List<Comment>> displayPostCommentCmd;

  @override
  RxCommand<void, List<youtube.SearchResultSnippet>> updateVideosCmd;
}

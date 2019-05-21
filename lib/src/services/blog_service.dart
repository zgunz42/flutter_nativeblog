import 'package:http/io_client.dart';
import 'package:nativeblog/src/helpers/client.dart';
import 'package:nativeblog/src/models/article.dart';
import 'package:googleapis/blogger/v3.dart';

abstract class PostProvider<T> {
  IOClient get client;
  String get cursor;
  Map<String, List<int>> _storage;  // cached article is here
  List<Article> get articles;

  Future<List<String>> labels();

  Future<List<Article>> loadPage(String cursor, {int total}) {
    // get total cursor we need to load
    // for each cursor load data into the article
  }

  Article mapToArticle(T raw);

  Future<List<Article>> nextPage(String cursor);

  Future<List<Article>> previewPage(String cursor);

  Future<List<Article>> fetchToProvider() {
    final List<Post> results = [];
    var pageToken;

    for (var pageIndex = 1; pageIndex <= index; pageIndex++) {
      if (pages.containsKey(pageIndex)) {
        pageToken = pages[pageIndex].nextPageToken;
      } else {
        pages[pageIndex] = await blog.posts.list(blogId,
            fetchImages: true,
            fetchBodies: true,
            labels: currentLabel,
            pageToken: pageToken);
      }
      results.addAll(pages[pageIndex].items);
    }
    return results;
  }

  Future<void> clearAll();
}

class BloggerProvider implements PostProvider<Post> {
  // remove
  final String token;
  BloggerApi _blog;

  BloggerProvider(this.token) {
    _blog = BloggerApi(this.client);
  }

  @override
  IOClient get client => ApiClient(parameter: {token: this.token});

  @override
  Article mapToArticle(Post raw) {
    return Article(
        title: raw.title,
        author: raw.author.displayName ?? '',
        content: raw.content,
        publishIn: raw.published,
        reference: Uri.parse(raw.url),
        tag: raw.labels.first);
  }

  @override
  Future<List<Article>> loadArticle() {
    // TODO: implement loadArticle
    return null;
  }
}

class BlogService {
  final List<PostProvider> providers;

  BlogService(this.providers);

  _getProviderArticles() {}

  Future<List<Article>> allArticle({PostProvider target}) {}
}

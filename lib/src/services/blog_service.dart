import 'package:http/io_client.dart';
import 'package:nativeblog/src/models/article.dart';
import 'package:googleapis/blogger/v3.dart';

abstract class PostProvider<T> {
  IOClient client;
  Future<List<Article>> loadArticle();

  Article article(T raw);
}

class BloggerProvider implements PostProvider<Post> {
  // remove
  final String token;

  BloggerProvider(this.token);

  @override
  IOClient client;


  @override
  Article article(Post raw) {
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

import 'package:http/http.dart';
import 'package:http/io_client.dart';

class BloggerClient extends IOClient {
  final String token = 'AIzaSyCs6jkJ5_v_Fer-Y6AYr1lLsukpDnXzwsI';

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    final query = <String, String>{};
    query.addAll(request.url.queryParameters);
    query['key'] = token;
    return super.send(Request(
        request.method,
        request.url.replace(
            queryParameters: query)));
  }
}

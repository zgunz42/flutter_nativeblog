import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:dio/dio.dart' as dio;

abstract class ApiRequest implements BaseRequest {

  BaseRequest copyWith({String method, Uri url}) {
    return Request(
      method ?? this.method,
      url ?? this.url
    );
  }
}

class ApiClient extends IOClient {
  final Map<String, dynamic> parameter;

  ApiClient({this.parameter});

  Request _interceptRequest(BaseRequest request) {
    final query = <String, String>{};
    // merge the parameter into the query
    query.addAll(request.url.queryParameters);

    return Request(
        request.method,
        request.url.replace(
            queryParameters: query));
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return super.send(_interceptRequest(request));
  }
}

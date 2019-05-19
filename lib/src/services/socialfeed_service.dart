import 'package:dio/dio.dart';

class InstagramFeedService {
  static const String _accessToken= '12762631417.e49958d.023c439ae2a04c0aa9731ef52fa6adb3';
  Dio _client;

  InstagramFeedService() {
    BaseOptions options = BaseOptions(
      baseUrl: 'https://api.instagram.com/v1',
      queryParameters: {'access_token': _accessToken}
    );
    _client = Dio(options);
  }

  getLatestMedia() async {
    final response = await _client.get('users/self/media/recent', options: Options(responseType: ResponseType.json));
    if(response.data['meta'] == 200) {
      return response.data['data'];
    }
  }
}
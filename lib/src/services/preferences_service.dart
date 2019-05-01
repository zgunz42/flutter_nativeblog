import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _feedsKey = 'selectedFeed';
  static const _preferedFeedsKey = 'preferedFeedsKey';

  void setPreferredFeed(String f) async {}

  Future<void> _saveToSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
  }

  Future<void> _loadFromSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
  }
}

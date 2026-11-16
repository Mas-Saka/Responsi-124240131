import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalService {
  static const String userBoxName = 'users';

  static Future<void> init() async {
    await Hive.openBox(userBoxName);
  }

  static Future<bool> register(String username, String password) async {
    final box = Hive.box(userBoxName);
    final exists = box.values.any(
      (user) =>
          user['username'].toString().toLowerCase() == username.toLowerCase(),
    );
    if (exists) return false;

    await box.add({'username': username, 'password': password});
    return true;
  }

  static Future<bool> login(String username, String password) async {
    final box = Hive.box(userBoxName);
    for (final user in box.values) {
      if (user['username'].toString().toLowerCase() == username.toLowerCase() &&
          user['password'] == password) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', username);
        return true;
      }
    }
    return false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('username');
  }

  static Future<bool> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'Pengguna';
  }

  static Future<List<int>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList('favoriteIds') ?? [])
        .map((id) => int.tryParse(id) ?? 0)
        .where((id) => id > 0)
        .toList();
  }

  static Future<void> saveFavorites(List<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favoriteIds',
      ids.map((id) => id.toString()).toList(),
    );
  }
}

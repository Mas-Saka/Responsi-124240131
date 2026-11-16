import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/berita.dart';

class LocalService {
  static const String userBoxName = 'users';
  static const String bookmarkBoxName = 'bookmarks';

  static Future<void> init() async {
    await Hive.openBox(userBoxName);
    await Hive.openBox(bookmarkBoxName);
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
    final username = await getUsername();
    final box = Hive.box(bookmarkBoxName);
    return box.values
        .where((item) => item['username'] == username)
        .map<int>((item) => (item['id'] as num).toInt())
        .toList();
  }

  static Future<List<Berita>> getBookmarks() async {
    final username = await getUsername();
    final box = Hive.box(bookmarkBoxName);
    return box.values
        .where((item) => item['username'] == username)
        .map<Berita>(
          (item) => Berita.fromJson(
            Map<String, dynamic>.from(item['article']),
          ),
        )
        .toList();
  }

  static Future<bool> isBookmarked(int id) async {
    final ids = await getFavorites();
    return ids.contains(id);
  }

  static Future<void> saveBookmark(Berita berita) async {
    final username = await getUsername();
    final box = Hive.box(bookmarkBoxName);
    final key = '${username}_${berita.id}';
    await box.put(key, {
      'username': username,
      'id': berita.id,
      'article': berita.toJson(),
    });
  }

  static Future<void> removeBookmark(int id) async {
    final username = await getUsername();
    final box = Hive.box(bookmarkBoxName);
    await box.delete('${username}_$id');
  }

  static Future<void> toggleBookmark(Berita berita) async {
    if (await isBookmarked(berita.id)) {
      await removeBookmark(berita.id);
    } else {
      await saveBookmark(berita);
    }
  }
}

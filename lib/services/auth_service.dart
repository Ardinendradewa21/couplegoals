import 'package:hive/hive.dart';
import 'package:couplegoals/models/user.dart';

class AuthService {
  final Box<User> _userBox = Hive.box<User>('users');
  final Box _sessionBox = Hive.box('session');

  // Fungsi ini sudah benar
  String? getCurrentUserId() {
    return _sessionBox.get('currentUser');
  }

  Future<bool> registerUser(String username, String password) async {
    if (_userBox.containsKey(username)) {
      return false; // User sudah terdaftar
    }

    // --- PERBAIKAN 1 ---
    // Ganti 'username:' menjadi 'id:' agar sesuai dengan model User.dart
    // Tambahkan profilePicturePath: null agar lengkap
    final user = User(
      id: username,
      password: password,
      profilePicturePath: null,
    );
    // -------------------

    await _userBox.put(username, user);
    return true;
  }

  Future<bool> loginUser(String username, String password) async {
    final user = _userBox.get(username);

    if (user != null && user.password == password) {
      // --- PERBAIKAN 2 ---
      // Ganti 'user.username' menjadi 'user.id'
      await _sessionBox.put('currentUser', user.id);
      // -------------------

      return true;
    }
    return false;
  }

  // Fungsi ini sudah benar
  Future<User?> getCurrentUser() async {
    final userId = _sessionBox.get('currentUser');
    if (userId != null) {
      return _userBox.get(userId);
    }
    return null;
  }

  // Fungsi ini sudah benar
  Future<void> logoutUser() async {
    await _sessionBox.delete('currentUser');
  }
}

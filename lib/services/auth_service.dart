import 'package:hive/hive.dart';
import 'package:couplegoals/models/user.dart';

class AuthService {
  final Box<User> _userBox = Hive.box<User>('users');
  final Box _sessionBox = Hive.box('session');

  // Fungsi Register
  Future<bool> registerUser(String username, String password) async {
    // Cek apakah username sudah ada
    final userExists = _userBox.values.any((user) => user.username == username);

    if (userExists) {
      return false; // Registrasi gagal (username sudah dipakai)
    }

    // Buat user baru
    final newUser = User(username: username, password: password);
    await _userBox.add(newUser);
    return true; // Registrasi sukses
  }

  // Fungsi Login
  Future<bool> loginUser(String username, String password) async {
    // Cari user berdasarkan username
    try {
      final user = _userBox.values.firstWhere(
        (user) => user.username == username && user.password == password,
      );

      // Jika user ditemukan dan password cocok
      // Simpan sesi login (simpan username-nya saja)
      await _sessionBox.put('currentUser', user.username);
      return true; // Login sukses
    } catch (e) {
      // Jika user tidak ditemukan (firstWhere error)
      return false; // Login gagal
    }
  }

  // Cek sesi
  String? getCurrentUser() {
    return _sessionBox.get('currentUser');
  }

  // Logout
  Future<void> logout() async {
    await _sessionBox.delete('currentUser');
  }
}

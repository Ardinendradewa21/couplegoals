import 'package:hive/hive.dart';

part 'user.g.dart'; // File ini akan digenerate otomatis

@HiveType(typeId: 0) // typeId harus unik untuk setiap model Hive
class User extends HiveObject {
  @HiveField(0)
  late String username;

  @HiveField(1)
  late String password; // CATATAN: Di project nyata, password harus di-hash!
  // Untuk project akhir, plain text tidak masalah.

  @HiveField(2)
  String? imagePath; // Path ke gambar profil di device

  User({required this.username, required this.password, this.imagePath});
}

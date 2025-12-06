import 'package:hive/hive.dart';

part 'user.g.dart'; // File ini akan digenerate ulang

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  late String id; // <-- GANTI 'username' menjadi 'id'

  @HiveField(1)
  late String password;

  @HiveField(2)
  String? profilePicturePath;

  User({
    required this.id, // <-- GANTI 'username' menjadi 'id'
    required this.password,
    this.profilePicturePath,
  });
}

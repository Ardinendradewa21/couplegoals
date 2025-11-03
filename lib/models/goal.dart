import 'package:hive/hive.dart';

part 'goal.g.dart';

@HiveType(
  typeId: 4,
) // Melanjutkan typeId (0:User, 1:Trans, 2:TransType, 3:Budget)
class Goal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String walletId; // 'Pribadi' atau 'Keluarga'

  @HiveField(2)
  String name; // misal: "Liburan ke Bali"

  @HiveField(3)
  double targetAmount;

  @HiveField(4)
  double currentAmount;

  Goal({
    required this.id,
    required this.walletId,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
  });
}

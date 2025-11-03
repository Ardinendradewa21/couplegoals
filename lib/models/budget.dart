import 'package:hive/hive.dart';

part 'budget.g.dart'; // File ini akan di-generate oleh build_runner

@HiveType(typeId: 3) // typeId 0=User, 1=Transaction, 2=TransactionType
class Budget extends HiveObject {
  // Kita akan gunakan ID unik sbg key di Hive: "walletId-kategori"
  // Jadi 'id' ini tidak perlu di-store di dalam field
  // HiveObject sudah punya 'key'

  @HiveField(0)
  final String walletId; // 'Pribadi' atau 'Keluarga'

  @HiveField(1)
  final String category; // Kategori budget (misal: "Makan")

  @HiveField(2)
  final double amount; // Jumlah budget (misal: 1000000)

  Budget({
    required this.walletId,
    required this.category,
    required this.amount,
  });

  // Helper untuk membuat ID unik sebagai key
  static String getHiveKey(String walletId, String category) {
    return '$walletId-$category';
  }
}

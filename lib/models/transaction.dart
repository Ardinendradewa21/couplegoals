import 'package:hive/hive.dart';

part 'transaction.g.dart'; // Ini akan digenerate

// Enum untuk tipe transaksi
@HiveType(typeId: 2) // typeId 0 untuk User, 1 kita cadangkan, 2 untuk enum
enum TransactionType {
  @HiveField(0)
  pemasukan,

  @HiveField(1)
  pengeluaran,
}

@HiveType(typeId: 1) // typeId 1 untuk Transaction
class Transaction extends HiveObject {
  @HiveField(0)
  late String id; // ID unik untuk filtering/delete

  @HiveField(1)
  late double amount;

  @HiveField(2)
  late String description; // Deskripsi/catatan

  @HiveField(3)
  late DateTime date;

  @HiveField(4)
  late String category;

  @HiveField(5)
  late TransactionType type;

  @HiveField(6)
  late String walletId; // 'Pribadi' atau 'Keluarga'

  Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.category,
    required this.type,
    required this.walletId,
  });
}

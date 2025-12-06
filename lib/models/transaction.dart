import 'package:hive/hive.dart';

part 'transaction.g.dart'; // Ini akan digenerate ulang

@HiveType(typeId: 2)
enum TransactionType {
  @HiveField(0)
  pemasukan,

  @HiveField(1)
  pengeluaran,
}

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  late String id;
  @HiveField(1)
  late String walletId;
  @HiveField(2)
  late TransactionType type;
  @HiveField(3)
  late double amount;
  @HiveField(4)
  late String category;
  @HiveField(5)
  late DateTime date;
  @HiveField(6)
  late String notes; // Kita sudah ganti dari 'description'

  @HiveField(7) // <-- DI SINI LETAKNYA
  late String userId; // Penanda pemilik data

  Transaction({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    required this.notes,
    required this.userId, // <-- DAN DI SINI (CONSTRUCTOR)
  });
}

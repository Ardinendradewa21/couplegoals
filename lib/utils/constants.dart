import 'package:flutter/material.dart';

class AppConstants {
  // Kategori default
  static const Map<String, dynamic> defaultCategory = {
    'name': 'Lainnya',
    'icon': Icons.more_horiz,
    'type': 'Pengeluaran',
    'color': Colors.grey,
    'isTransfer': false,
  };

  // Daftar kategori LENGKAP
  static const List<Map<String, dynamic>> categories = [
    // --- KATEGORI SPESIAL (TRANSFER) ---
    {
      'name': 'Transfer',
      'icon': Icons.swap_horiz,
      'type': 'Transfer', // Tipe khusus
      'color': Colors.teal,
      'isTransfer': true, // Flag penanda
    },

    // Pengeluaran
    {
      'name': 'Makan',
      'icon': Icons.fastfood,
      'type': 'Pengeluaran',
      'color': Colors.red,
    },
    {
      'name': 'Transport',
      'icon': Icons.directions_bus,
      'type': 'Pengeluaran',
      'color': Colors.blue,
    },
    {
      'name': 'Rumah',
      'icon': Icons.home,
      'type': 'Pengeluaran',
      'color': Colors.brown,
    },
    {
      'name': 'Anak',
      'icon': Icons.child_friendly,
      'type': 'Pengeluaran',
      'color': Colors.purple,
    },
    {
      'name': 'Hiburan',
      'icon': Icons.movie,
      'type': 'Pengeluaran',
      'color': Colors.orange,
    },
    {
      'name': 'Belanja',
      'icon': Icons.shopping_bag,
      'type': 'Pengeluaran',
      'color': Colors.pink,
    },
    {
      'name': 'Tabungan',
      'icon': Icons.savings,
      'type': 'Pengeluaran',
      'color': Colors.teal,
    },
    {
      'name': 'Lainnya (Keluar)',
      'icon': Icons.more_horiz,
      'type': 'Pengeluaran',
      'color': Colors.grey,
    },

    // Pemasukan
    {
      'name': 'Gaji',
      'icon': Icons.wallet,
      'type': 'Pemasukan',
      'color': Colors.green,
    },
    {
      'name': 'Bonus',
      'icon': Icons.card_giftcard,
      'type': 'Pemasukan',
      'color': Colors.cyan,
    },
    {
      'name': 'Investasi',
      'icon': Icons.trending_up,
      'type': 'Pemasukan',
      'color': Colors.indigo,
    },
    {
      'name': 'Lainnya (Masuk)',
      'icon': Icons.more_horiz,
      'type': 'Pemasukan',
      'color': Colors.lime,
    },
  ];

  static List<Map<String, dynamic>> get expenseCategories {
    return categories
        .where(
          (cat) => cat['type'] == 'Pengeluaran' && cat['isTransfer'] != true,
        )
        .toList();
  }

  static List<Map<String, dynamic>> get incomeCategories {
    return categories
        .where((cat) => cat['type'] == 'Pemasukan' && cat['isTransfer'] != true)
        .toList();
  }

  static Map<String, dynamic> getCategoryData(String categoryName) {
    return categories.firstWhere(
      (cat) => cat['name'] == categoryName,
      orElse: () => defaultCategory,
    );
  }
}

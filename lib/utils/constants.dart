import 'package:flutter/material.dart';

class AppConstants {
  // Kategori default jika tidak ditemukan
  static const Map<String, dynamic> defaultCategory = {
    'name': 'Lainnya',
    'icon': Icons.more_horiz,
    'type': 'Pengeluaran',
    'color': Colors.grey,
  };

  // Daftar kategori
  static const List<Map<String, dynamic>> categories = [
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

  // Helper untuk filter
  static List<Map<String, dynamic>> get expenseCategories {
    return categories.where((cat) => cat['type'] == 'Pengeluaran').toList();
  }

  static List<Map<String, dynamic>> get incomeCategories {
    return categories.where((cat) => cat['type'] == 'Pemasukan').toList();
  }

  // --- INI METHOD YANG HILANG ---
  // Method helper untuk mendapatkan data (icon, color) berdasarkan nama kategori
  static Map<String, dynamic> getCategoryData(String categoryName) {
    // Cari di daftar kategori
    return categories.firstWhere(
      (cat) => cat['name'] == categoryName,
      // Jika tidak ketemu (misal: kategori dihapus), kembalikan default
      orElse: () => defaultCategory,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:couplegoals/models/transaction.dart';
import 'package:couplegoals/utils/constants.dart';
import 'package:couplegoals/utils/formatters.dart';
import 'package:couplegoals/widgets/transaction_detail_dialog.dart';
import 'package:couplegoals/widgets/transaction_tile.dart';
import 'package:intl/intl.dart';
import 'package:couplegoals/services/auth_service.dart'; // <-- 1. IMPORT BARU

class TransactionHistoryPage extends StatefulWidget {
  final String walletId;
  const TransactionHistoryPage({super.key, required this.walletId});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final _searchController = TextEditingController();
  final AuthService _authService = AuthService(); // <-- 2. INISIALISASI BARU
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  DateTimeRange? _selectedDateRange;

  final List<String> _filterCategories = [
    'Semua',
    'Pemasukan',
    ...AppConstants.expenseCategories.map((e) => e['name'] as String),
    'Transfer', // Jangan lupa tambahkan 'Transfer'
  ];

  void _showTransactionDetail(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => TransactionDetailDialog(transaction: transaction),
    );
  }

  void _pickDateRange() async {
    // ... (Fungsi ini sudah benar, tidak perlu diubah) ...
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange:
          _selectedDateRange ?? DateTimeRange(start: firstDayOfMonth, end: now),
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histori Transaksi'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterBar(),
          const Divider(height: 1),
          Expanded(
            child: ValueListenableBuilder<Box<Transaction>>(
              valueListenable: Hive.box<Transaction>(
                'transactions',
              ).listenable(),
              builder: (context, box, _) {
                // --- 3. DAPATKAN USER ID & FILTER ---
                final String? userId = _authService.getCurrentUserId();
                if (userId == null) {
                  return const Center(child: Text("Sesi tidak ditemukan."));
                }

                // INI PERBAIKANNYA: Filter berdasarkan walletId DAN userId
                List<Transaction> transactions = box.values
                    .where(
                      (t) =>
                          t.walletId == widget.walletId && t.userId == userId,
                    )
                    .toList();
                // ------------------------------------

                // Filter by Category
                if (_selectedCategory != 'Semua') {
                  if (_selectedCategory == 'Pemasukan') {
                    transactions = transactions
                        .where(
                          (t) =>
                              t.type == TransactionType.pemasukan &&
                              t.category != 'Transfer',
                        )
                        .toList();
                  } else {
                    transactions = transactions
                        .where((t) => t.category == _selectedCategory)
                        .toList();
                  }
                }

                // Filter by Date Range
                if (_selectedDateRange != null) {
                  // ... (Logika filter tanggal Anda sudah benar) ...
                  transactions = transactions.where((t) {
                    final date = t.date;
                    final start = _selectedDateRange!.start;
                    final end = _selectedDateRange!.end;
                    final isAfterStart =
                        date.isAfter(start.subtract(const Duration(days: 1))) ||
                        DateFormat('yyyy-MM-dd').format(date) ==
                            DateFormat('yyyy-MM-dd').format(start);
                    final isBeforeEnd =
                        date.isBefore(end.add(const Duration(days: 1))) ||
                        DateFormat('yyyy-MM-dd').format(date) ==
                            DateFormat('yyyy-MM-dd').format(end);
                    return isAfterStart && isBeforeEnd;
                  }).toList();
                }

                // Filter by Search Query
                if (_searchQuery.isNotEmpty) {
                  // ... (Logika filter search Anda sudah benar) ...
                  transactions = transactions
                      .where(
                        (t) =>
                            t.notes.toLowerCase().contains(_searchQuery) ||
                            t.category.toLowerCase().contains(_searchQuery),
                      )
                      .toList();
                }

                transactions.sort((a, b) => b.date.compareTo(a.date));

                if (transactions.isEmpty) {
                  return const Center(
                    child: Text(
                      'Tidak ada transaksi ditemukan.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return TransactionTile(
                      transaction: transaction,
                      onTap: () => _showTransactionDetail(transaction),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    // ... (Widget ini sudah benar, tidak perlu diubah) ...
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Cari di catatan atau kategori...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    // ... (Widget ini sudah benar, tidak perlu diubah) ...
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
              },
              items: _filterCategories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: _pickDateRange,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _selectedDateRange == null ? 'Tanggal' : '...',
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (_selectedDateRange != null)
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () =>
                            setState(() => _selectedDateRange = null),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

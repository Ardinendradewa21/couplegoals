import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:couplegoals/models/transaction.dart';
import 'package:couplegoals/utils/constants.dart';
import 'package:couplegoals/services/auth_service.dart';

class AddTransactionSheet extends StatefulWidget {
  final String walletId;

  const AddTransactionSheet({super.key, required this.walletId});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final Uuid _uuid = const Uuid();
  final AuthService _authService = AuthService(); // Ini sudah benar

  late TransactionType _selectedType;
  late String _selectedCategory;
  late DateTime _selectedDate;

  List<Map<String, dynamic>> _currentCategories = [];

  @override
  void initState() {
    super.initState();
    // Set default values
    _selectedType = TransactionType.pengeluaran;
    _currentCategories = AppConstants.expenseCategories;
    _selectedCategory = _currentCategories.first['name'] as String;
    _selectedDate = DateTime.now();
  }

  void _onTypeChanged(TransactionType? type) {
    if (type == null) return;
    setState(() {
      _selectedType = type;
      _currentCategories = (type == TransactionType.pemasukan)
          ? AppConstants.incomeCategories
          : AppConstants.expenseCategories;
      _selectedCategory = _currentCategories.first['name'] as String;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() {
    // --- PERBAIKAN 1: Tambahkan validasi form ---
    if (!_formKey.currentState!.validate()) {
      return; // Hentikan jika form tidak valid
    }
    // ------------------------------------------

    final String? userId = _authService.getCurrentUserId(); // Ini sudah benar
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Sesi tidak ditemukan. Silakan login ulang.'),
        ),
      );
      return;
    }

    try {
      final double amount = double.parse(_amountController.text);
      final String notes = _notesController.text;

      final newTransaction = Transaction(
        id: _uuid.v4(),
        walletId: widget.walletId,
        type: _selectedType,
        category: _selectedCategory,
        amount: amount,
        date: _selectedDate,

        // --- PERBAIKAN 2: 'description:' diubah jadi 'notes:' ---
        notes: notes,

        // ----------------------------------------------------
        userId: userId, // Ini sudah benar
      );

      final transactionBox = Hive.box<Transaction>('transactions');
      // Gunakan .put(key, value) agar konsisten dengan update
      transactionBox.put(newTransaction.id, newTransaction);

      print('Transaksi berhasil disimpan!');

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('--- ERROR SAAT SIMPAN TRANSAKSI ---');
      print(e.toString());
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Gagal menyimpan transaksi: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        // ... (sisa kode build Anda SAMA PERSIS dan sudah benar) ...
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24,
          left: 24,
          right: 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tambah Transaksi',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.pengeluaran,
                    label: Text('Pengeluaran'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                  ButtonSegment(
                    value: TransactionType.pemasukan,
                    label: Text('Pemasukan'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<TransactionType> newSelection) {
                  _onTypeChanged(newSelection.first);
                },
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor:
                      _selectedType == TransactionType.pengeluaran
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  selectedForegroundColor:
                      _selectedType == TransactionType.pengeluaran
                      ? Colors.red.shade700
                      : Colors.green.shade700,
                  foregroundColor: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah (Rp)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah harus diisi';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Format angka salah';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
                items: _currentCategories.map<DropdownMenuItem<String>>((
                  Map<String, dynamic> categoryMap,
                ) {
                  return DropdownMenuItem<String>(
                    value: categoryMap['name'],
                    child: Row(
                      children: [
                        Icon(
                          categoryMap['icon'],
                          color: categoryMap['color'],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(categoryMap['name']),
                      ],
                    ),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (value) =>
                    value == null ? 'Kategori harus dipilih' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tanggal: ${DateFormat('d MMM y', 'id_ID').format(_selectedDate)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Ubah'),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Simpan Transaksi',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

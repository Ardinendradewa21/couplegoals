import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:couplegoals/models/transaction.dart';
import 'package:couplegoals/utils/constants.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

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

  TransactionType _selectedType = TransactionType.pengeluaran;
  String? _selectedCategory; // Dibuat nullable
  DateTime _selectedDate = DateTime.now();
  final Uuid _uuid = const Uuid();

  // State untuk daftar kategori yang dinamis
  List<Map<String, dynamic>> _currentCategories =
      AppConstants.expenseCategories;

  @override
  void initState() {
    super.initState();
    // Set kategori default
    _currentCategories = AppConstants.expenseCategories;
    _selectedCategory = _currentCategories[0]['name'];
  }

  void _onTypeChanged(TransactionType? type) {
    if (type == null) return;
    setState(() {
      _selectedType = type;
      // Ganti daftar kategori & reset pilihan
      if (type == TransactionType.pemasukan) {
        _currentCategories = AppConstants.incomeCategories;
      } else {
        _currentCategories = AppConstants.expenseCategories;
      }
      _selectedCategory = _currentCategories[0]['name'];
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        // Seharusnya tidak terjadi, tapi sebagai penjaga
        return;
      }

      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        // Validasi tambahan
        return;
      }

      final newTransaction = Transaction(
        id: _uuid.v4(),
        walletId: widget.walletId,
        amount: amount,
        category: _selectedCategory!,
        date: _selectedDate,
        type: _selectedType,
        description: _notesController.text,
      );

      // Simpan ke Hive
      final box = Hive.box<Transaction>('transactions');
      box.put(newTransaction.id, newTransaction);

      Navigator.of(context).pop(); // Tutup bottom sheet
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mengatasi tampilan keyboard
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: 20 + keyboardSpace,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Tambah Transaksi',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),

              // Segmented Button untuk Tipe
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
                      ? Colors.red.shade100
                      : Colors.green.shade100,
                  selectedForegroundColor:
                      _selectedType == TransactionType.pengeluaran
                      ? Colors.red.shade900
                      : Colors.green.shade900,
                  foregroundColor: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),

              // Form Jumlah
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Jumlah (Rp)',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
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

              // Dropdown Kategori (INI YANG DIPERBAIKI)
              DropdownButtonFormField<String>(
                value: _selectedCategory, // value di sini sudah benar
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                // Kita map dari _currentCategories
                items: _currentCategories.map<DropdownMenuItem<String>>((
                  Map<String, dynamic> categoryData,
                ) {
                  // Perbaikan: Ambil 'name' dari Map
                  final categoryName = categoryData['name'] as String;
                  return DropdownMenuItem<String>(
                    value: categoryName,
                    child: Row(
                      children: [
                        Icon(
                          categoryData['icon'],
                          color: categoryData['color'],
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(categoryName),
                      ],
                    ),
                  );
                }).toList(), // Jangan lupa .toList()
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) => value == null ? 'Pilih Kategori' : null,
              ),
              const SizedBox(height: 16),

              // Form Catatan
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Pilihan Tanggal
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

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan Transaksi'),
                  onPressed: _submitData,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:couplegoals/models/budget.dart';
import 'package:couplegoals/utils/constants.dart';

class SetBudgetSheet extends StatefulWidget {
  final String walletId; // 'Pribadi' atau 'Keluarga'
  final Budget? existingBudget; // Untuk mode edit

  const SetBudgetSheet({
    super.key,
    required this.walletId,
    this.existingBudget,
  });

  @override
  State<SetBudgetSheet> createState() => _SetBudgetSheetState();
}

class _SetBudgetSheetState extends State<SetBudgetSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    if (widget.existingBudget != null) {
      _selectedCategory = widget.existingBudget!.category;
      _amountController.text = widget.existingBudget!.amount.toInt().toString();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _handleSaveBudget() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      if (amount <= 0) return;

      final budgetBox = Hive.box<Budget>('budgets');

      final newBudget = Budget(
        walletId: widget.walletId,
        category: _selectedCategory!,
        amount: amount,
      );

      // Gunakan key unik "walletId-category" untuk "upsert" (update or insert)
      final hiveKey = Budget.getHiveKey(widget.walletId, _selectedCategory!);
      await budgetBox.put(hiveKey, newBudget);

      if (mounted) {
        Navigator.of(context).pop(); // Tutup bottom sheet
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter kategori agar hanya kategori pengeluaran yg bisa di-budget
    final expenseCategories = AppConstants.categories
        .where((cat) => cat['type'] == 'Pengeluaran')
        .toList();

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existingBudget != null
                  ? 'Edit Budget'
                  : 'Atur Budget Baru',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // Kategori
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              // Jika mode edit, disable dropdown
              onChanged: widget.existingBudget != null
                  ? null
                  : (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
              items: expenseCategories.map<DropdownMenuItem<String>>((
                Map<String, dynamic> category,
              ) {
                return DropdownMenuItem<String>(
                  value: category['name'],
                  child: Row(
                    children: [
                      Icon(
                        category['icon'],
                        color: category['color'],
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(category['name'] as String),
                    ],
                  ),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null ? 'Pilih satu kategori' : null,
              disabledHint: _selectedCategory != null
                  ? Text(_selectedCategory!)
                  : null,
            ),
            const SizedBox(height: 16),
            // Jumlah
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Jumlah Budget (Rp)',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jumlah tidak boleh kosong';
                }
                if (double.tryParse(value) == null ||
                    double.parse(value) <= 0) {
                  return 'Masukkan jumlah yang valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            // Tombol Simpan
            ElevatedButton(
              onPressed: _handleSaveBudget,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Simpan Budget',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

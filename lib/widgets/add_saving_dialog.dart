import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:couplegoals/models/goal.dart';
import 'package:couplegoals/models/transaction.dart';
import 'package:couplegoals/utils/formatters.dart';
import 'package:couplegoals/services/auth_service.dart';
import 'package:uuid/uuid.dart';

class AddSavingDialog extends StatefulWidget {
  final Goal goal;
  const AddSavingDialog({super.key, required this.goal});

  @override
  State<AddSavingDialog> createState() => _AddSavingDialogState();
}

class _AddSavingDialogState extends State<AddSavingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _submitSaving() async {
    if (!_formKey.currentState!.validate()) return;

    // --- 3. DAPATKAN USER ID ---
    final String? userId = _authService.getCurrentUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Sesi tidak ditemukan.')),
      );
      return;
    }
    // -------------------------

    setState(() => _isLoading = true);
    final double amount = double.tryParse(_amountController.text) ?? 0.0;

    // 1. Buat Transaksi Pengeluaran
    final transactionBox = Hive.box<Transaction>('transactions');
    final newTransaction = Transaction(
      id: const Uuid().v4(),
      walletId: widget.goal.walletId,
      type: TransactionType.pengeluaran,
      amount: amount,
      category: 'Tabungan',
      date: DateTime.now(),
      notes: 'Menabung untuk "${widget.goal.name}"',
      userId: userId, // <-- 4. SIMPAN USER ID
    );
    await transactionBox.put(newTransaction.id, newTransaction);

    // 2. Update Goal
    widget.goal.currentAmount += amount;
    await widget.goal.save();

    if (mounted) Navigator.of(context).pop();
  }

  // ... (sisa kode build Anda SAMA PERSIS) ...
  @override
  Widget build(BuildContext context) {
    final sisaTarget = widget.goal.targetAmount - widget.goal.currentAmount;
    return AlertDialog(
      title: const Text('Tambah Tabungan'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Target: ${widget.goal.name}'),
            const SizedBox(height: 4),
            Text(
              'Sisa Target: ${Formatters.formatCurrency(sisaTarget)}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Jumlah Tabungan',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jumlah tidak boleh kosong';
                }
                final double? amount = double.tryParse(value);
                if (amount == null) {
                  return 'Format angka salah';
                }
                if (amount > sisaTarget) {
                  return 'Melebihi sisa target!';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitSaving,
          child: _isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}

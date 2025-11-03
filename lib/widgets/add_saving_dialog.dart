import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:couplegoals/models/goal.dart';
import 'package:couplegoals/models/transaction.dart';
import 'package:couplegoals/utils/formatters.dart';
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
  bool _isLoading = false;

  void _submitSaving() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final double amount = double.tryParse(_amountController.text) ?? 0.0;
      if (amount <= 0) {
        setState(() => _isLoading = false);
        return;
      }

      // 1. Buat Transaksi Pengeluaran
      // Ini penting agar uang di dompet utama berkurang
      final transactionBox = Hive.box<Transaction>('transactions');
      final newTransaction = Transaction(
        id: const Uuid().v4(),
        walletId: widget.goal.walletId,
        type: TransactionType.pengeluaran,
        amount: amount,
        category: 'Tabungan', // Kategori khusus untuk goals
        date: DateTime.now(),
        description: 'Menabung untuk "${widget.goal.name}"',
      );
      await transactionBox.put(newTransaction.id, newTransaction);

      // 2. Update Goal
      // (Kita menggunakan .save() karena Goal extends HiveObject)
      widget.goal.currentAmount += amount;
      await widget.goal.save();

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Tambah Tabungan',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Target: ${widget.goal.name}'),
            Text(
              'Sisa Target: ${Formatters.formatCurrency(widget.goal.targetAmount - widget.goal.currentAmount)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Jumlah Tabungan',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jumlah tidak boleh kosong';
                }
                if (double.tryParse(value) == null) {
                  return 'Format angka salah';
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:couplegoals/models/goal.dart';
import 'package:uuid/uuid.dart';

class AddGoalSheet extends StatefulWidget {
  final String walletId;
  const AddGoalSheet({super.key, required this.walletId});

  @override
  State<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<AddGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  bool _isLoading = false;

  void _submitGoal() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final String name = _nameController.text;
      final double targetAmount =
          double.tryParse(_targetAmountController.text) ?? 0.0;

      if (targetAmount <= 0) {
        setState(() => _isLoading = false);
        // Tampilkan error jika mau
        return;
      }

      final newGoal = Goal(
        id: const Uuid().v4(),
        walletId: widget.walletId,
        name: name,
        targetAmount: targetAmount,
        currentAmount: 0.0,
        userId: 'some-user-id', // Ganti dengan userId yang sesuai
      );

      final goalsBox = Hive.box<Goal>('goals');
      await goalsBox.put(newGoal.id, newGoal);

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buat Target Baru',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Target (misal: Liburan ke Bali)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Nama target tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetAmountController,
              decoration: const InputDecoration(
                labelText: 'Jumlah Target (misal: 10000000)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monetization_on_outlined),
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jumlah target tidak boleh kosong';
                }
                if (double.tryParse(value) == null) {
                  return 'Format angka salah';
                }
                if (double.parse(value) <= 0) {
                  return 'Target harus lebih dari 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitGoal,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                    : const Text(
                        'Simpan Target',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:couplegoals/models/transaction.dart';
import 'package:couplegoals/services/auth_service.dart'; 
import 'package:uuid/uuid.dart';

class TransferWalletSheet extends StatefulWidget {
  const TransferWalletSheet({super.key});

  @override
  State<TransferWalletSheet> createState() => _TransferWalletSheetState();
}

class _TransferWalletSheetState extends State<TransferWalletSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final AuthService _authService = AuthService(); // <-- 2. INISIALISASI BARU
  String _fromWallet = 'Pribadi';
  String _toWallet = 'Keluarga';
  bool _isLoading = false;

  void _saveTransfer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fromWallet == _toWallet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dompet asal dan tujuan tidak boleh sama'),
        ),
      );
      return;
    }

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
    try {
      final double amount = double.parse(_amountController.text);
      final box = Hive.box<Transaction>('transactions');
      final uuid = const Uuid();
      final now = DateTime.now();

      // 1. Transaksi KELUAR dari dompet ASAL
      final txOut = Transaction(
        id: uuid.v4(),
        walletId: _fromWallet,
        type: TransactionType.pengeluaran,
        amount: amount,
        category: 'Transfer',
        date: now,
        notes: 'Transfer ke $_toWallet',
        userId: userId, // <-- 4. TAMBAHKAN USER ID
      );
      await box.put(txOut.id, txOut);

      // 2. Transaksi MASUK ke dompet TUJUAN
      final txIn = Transaction(
        id: uuid.v4(),
        walletId: _toWallet,
        type: TransactionType.pemasukan,
        amount: amount,
        category: 'Transfer',
        date: now,
        notes: 'Transfer dari $_fromWallet',
        userId: userId, // <-- 4. TAMBAHKAN USER ID
      );
      await box.put(txIn.id, txIn);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal transfer: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transfer Antar Dompet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildWalletDropdown(
                    'Dari',
                    _fromWallet,
                    (val) => setState(() => _fromWallet = val!),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                  child: Icon(Icons.arrow_forward, color: Colors.teal),
                ),
                Expanded(
                  child: _buildWalletDropdown(
                    'Ke',
                    _toWallet,
                    (val) => setState(() => _toWallet = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Jumlah (Rp)',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              validator: (val) =>
                  (val == null ||
                      val.isEmpty ||
                      double.tryParse(val) == null ||
                      double.parse(val) <= 0)
                  ? 'Jumlah tidak valid'
                  : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveTransfer,
                icon: _isLoading
                    ? const SizedBox.shrink()
                    : const Icon(Icons.swap_horiz),
                label: Text(_isLoading ? 'Memproses...' : 'Transfer Sekarang'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletDropdown(
    String label,
    String value,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      items: [
        'Pribadi',
        'Keluarga',
      ].map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

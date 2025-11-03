import 'package:flutter/material.dart';
import 'package:couplegoals/models/transaction.dart';
import 'package:couplegoals/utils/constants.dart';
import 'package:couplegoals/utils/formatters.dart';

class TransactionDetailDialog extends StatelessWidget {
  final Transaction transaction;
  const TransactionDetailDialog({super.key, required this.transaction});

  void _deleteTransaction(BuildContext context) async {
    // Tampilkan konfirmasi
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi?'),
        content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete == true && context.mounted) {
      // (transaction extends HiveObject, jadi kita bisa panggil .delete())
      await transaction.delete();
      Navigator.of(context).pop(); // Tutup dialog detail
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryData = AppConstants.getCategoryData(transaction.category);
    final isExpense = transaction.type == TransactionType.pengeluaran;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text('Detail Transaksi'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(categoryData['icon'], color: categoryData['color']),
              title: Text(
                transaction.category,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                isExpense ? 'Pengeluaran' : 'Pemasukan',
                style: TextStyle(color: isExpense ? Colors.red : Colors.green),
              ),
            ),
            const Divider(),
            _buildDetailRow(
              'Jumlah:',
              '${isExpense ? '-' : '+'} ${Formatters.formatCurrency(transaction.amount)}',
            ),
            _buildDetailRow(
              'Tanggal:',
              Formatters.formatDate(transaction.date),
            ),
            _buildDetailRow('Dompet:', transaction.walletId),
            const SizedBox(height: 10),
            Text('Catatan:', style: TextStyle(color: Colors.grey[600])),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                transaction.description.isEmpty
                    ? '(Tidak ada catatan)'
                    : transaction.description,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => _deleteTransaction(context),
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          label: const Text('Hapus', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tutup'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

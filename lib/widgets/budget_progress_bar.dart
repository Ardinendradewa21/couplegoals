import 'package:flutter/material.dart';
import 'package:couplegoals/utils/constants.dart';
import 'package:couplegoals/utils/formatters.dart';

class BudgetProgressBar extends StatelessWidget {
  final String category;
  final double currentSpend;
  final double totalBudget;

  const BudgetProgressBar({
    super.key,
    required this.category,
    required this.currentSpend,
    required this.totalBudget,
  });

  Color _getProgressColor(double percentage) {
    if (percentage >= 0.9) {
      return Colors.red.shade700; // 90% ke atas
    }
    if (percentage >= 0.75) {
      return Colors.orange.shade700; // 75% ke atas
    }
    return Colors.green.shade600; // Di bawah 75%
  }

  @override
  Widget build(BuildContext context) {
    if (totalBudget <= 0) {
      return const SizedBox.shrink(); // Jangan tampilkan jika budget 0
    }

    final percentage = (currentSpend / totalBudget).clamp(0.0, 1.0);
    final categoryData = AppConstants.getCategoryData(category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    categoryData['icon'],
                    color: categoryData['color'],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '${(percentage * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(percentage),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(percentage),
            ),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 6),
          Text(
            // Fungsi ini sekarang sudah dikenali
            '${Formatters.formatCurrency(currentSpend)} / ${Formatters.formatCurrency(totalBudget)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

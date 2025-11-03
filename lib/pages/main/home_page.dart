import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:couplegoals/models/budget.dart';
import 'package:couplegoals/models/transaction.dart';
import 'package:couplegoals/utils/constants.dart';
import 'package:couplegoals/utils/formatters.dart'; // (Tetap perlu untuk formatCurrency)
import 'package:fl_chart/fl_chart.dart';
import 'package:couplegoals/widgets/budget_progress_bar.dart';
import 'package:couplegoals/widgets/set_budget_sheet.dart';
import 'package:couplegoals/pages/main/history_page.dart';
import 'package:couplegoals/widgets/transaction_detail_dialog.dart';
import 'package:couplegoals/widgets/transaction_tile.dart';

class HomePage extends StatefulWidget {
  final String walletId;
  final Function(String) onWalletChanged;

  const HomePage({
    super.key,
    required this.walletId,
    required this.onWalletChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _touchedIndex = -1;

  void _showSetBudgetSheet({Budget? existingBudget}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SetBudgetSheet(
        walletId: widget.walletId,
        existingBudget: existingBudget,
      ),
    );
  }

  // 2. Fungsi baru untuk detail
  void _showTransactionDetail(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => TransactionDetailDialog(transaction: transaction),
    );
  }

  Map<String, dynamic> _processData(
    Box<Transaction> transactionBox,
    Box<Budget> budgetBox,
  ) {
    final transactions = transactionBox.values
        .where((t) => t.walletId == widget.walletId)
        .toList();
    final budgets = budgetBox.values
        .where((b) => b.walletId == widget.walletId)
        .toList();

    double totalPemasukan = 0;
    double totalPengeluaran = 0;
    Map<String, double> categorySpendMap = {};
    for (var cat in AppConstants.expenseCategories) {
      categorySpendMap[cat['name']] = 0.0;
    }
    for (var transaction in transactions) {
      if (transaction.type == TransactionType.pemasukan) {
        totalPemasukan += transaction.amount;
      } else {
        totalPengeluaran += transaction.amount;
        categorySpendMap.update(
          transaction.category,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }
    double saldoAkhir = totalPemasukan - totalPengeluaran;
    Map<String, double> budgetMap = {};
    for (var budget in budgets) {
      budgetMap[budget.category] = budget.amount;
    }
    return {
      'transactions': transactions,
      'totalPemasukan': totalPemasukan,
      'totalPengeluaran': totalPengeluaran,
      'saldoAkhir': saldoAkhir,
      'categorySpendMap': categorySpendMap,
      'budgetMap': budgetMap,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ValueListenableBuilder<Box<Transaction>>(
        valueListenable: Hive.box<Transaction>('transactions').listenable(),
        builder: (context, transactionBox, _) {
          return ValueListenableBuilder<Box<Budget>>(
            valueListenable: Hive.box<Budget>('budgets').listenable(),
            builder: (context, budgetBox, _) {
              final data = _processData(transactionBox, budgetBox);
              final List<Transaction> transactions = data['transactions'];
              final double totalPemasukan = data['totalPemasukan'];
              final double totalPengeluaran = data['totalPengeluaran'];
              final double saldoAkhir = data['saldoAkhir'];
              final Map<String, double> categorySpendMap =
                  data['categorySpendMap'];
              final Map<String, double> budgetMap = data['budgetMap'];
              transactions.sort((a, b) => b.date.compareTo(a.date));

              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildWalletSelector(),
                  const SizedBox(height: 16),
                  _buildSummaryCard(
                    saldoAkhir,
                    totalPemasukan,
                    totalPengeluaran,
                  ),
                  const SizedBox(height: 20),
                  _buildPieChartCard(categorySpendMap, totalPengeluaran),
                  const SizedBox(height: 20),
                  _buildBudgetSection(categorySpendMap, budgetMap),
                  const SizedBox(height: 20),

                  // 3. UPDATE: Tambah tombol "Lihat Semua"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Histori Transaksi Terkini',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransactionHistoryPage(
                                walletId: widget.walletId,
                              ),
                            ),
                          );
                        },
                        child: const Text('Lihat Semua'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  transactions.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada transaksi.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transactions.length > 5
                              ? 5
                              : transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            // 4. UPDATE: Gunakan TransactionTile
                            return TransactionTile(
                              transaction: transaction,
                              onTap: () => _showTransactionDetail(transaction),
                            );
                          },
                        ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildWalletSelector() {
    return Center(
      child: ToggleButtons(
        isSelected: [
          widget.walletId == 'Pribadi',
          widget.walletId == 'Keluarga',
        ],
        onPressed: (index) {
          final newWallet = index == 0 ? 'Pribadi' : 'Keluarga';
          widget.onWalletChanged(newWallet);
          setState(() {
            _touchedIndex = -1;
          });
        },
        borderRadius: BorderRadius.circular(12),
        selectedColor: Colors.white,
        fillColor: Colors.teal,
        color: Colors.teal,
        constraints: const BoxConstraints(minHeight: 40.0, minWidth: 100.0),
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.person),
                SizedBox(width: 8),
                Text('Pribadi'),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.group),
                SizedBox(width: 8),
                Text('Keluarga'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double saldo, double pemasukan, double pengeluaran) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Saldo',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Text(
              Formatters.formatCurrency(saldo),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIncomeExpenseRow(
                  'Pemasukan',
                  pemasukan,
                  Colors.green.shade600,
                ),
                _buildIncomeExpenseRow(
                  'Pengeluaran',
                  pengeluaran,
                  Colors.red.shade600,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseRow(String title, double amount, Color color) {
    return Row(
      children: [
        Icon(
          title == 'Pemasukan' ? Icons.arrow_upward : Icons.arrow_downward,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              Formatters.formatCurrency(amount),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPieChartCard(
    Map<String, double> categorySpendMap,
    double totalPengeluaran,
  ) {
    final sections = categorySpendMap.entries
        .where((entry) => entry.value > 0)
        .toList();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Pengeluaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            if (sections.isEmpty)
              const Center(
                child: Text(
                  'Belum ada data pengeluaran.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback:
                                (FlTouchEvent event, pieTouchResponse) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        pieTouchResponse == null ||
                                        pieTouchResponse.touchedSection ==
                                            null) {
                                      _touchedIndex = -1;
                                      return;
                                    }
                                    _touchedIndex = pieTouchResponse
                                        .touchedSection!
                                        .touchedSectionIndex;
                                  });
                                },
                          ),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: List.generate(sections.length, (i) {
                            final entry = sections[i];
                            final categoryData = AppConstants.getCategoryData(
                              entry.key,
                            );
                            final isTouched = (i == _touchedIndex);
                            final fontSize = isTouched ? 16.0 : 12.0;
                            final radius = isTouched ? 60.0 : 50.0;
                            final percentage =
                                (entry.value / totalPengeluaran) * 100;
                            return PieChartSectionData(
                              color: categoryData['color'],
                              value: entry.value,
                              title: '${percentage.toStringAsFixed(0)}%',
                              radius: radius,
                              titleStyle: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: sections.map((entry) {
                        final categoryData = AppConstants.getCategoryData(
                          entry.key,
                        );
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                color: categoryData['color'],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  entry.key,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSection(
    Map<String, double> categorySpendMap,
    Map<String, double> budgetMap,
  ) {
    final budgetedCategories = budgetMap.keys.toList();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progress Budget Bulanan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_task, color: Colors.teal),
                  tooltip: 'Atur Budget',
                  onPressed: () => _showSetBudgetSheet(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (budgetedCategories.isEmpty)
              const Center(
                child: Text(
                  'Belum ada budget diatur.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...budgetedCategories.map((category) {
                final currentSpend = categorySpendMap[category] ?? 0.0;
                final totalBudget = budgetMap[category]!;
                return InkWell(
                  onTap: () {
                    final existingBudget = Hive.box<Budget>(
                      'budgets',
                    ).get(Budget.getHiveKey(widget.walletId, category));
                    if (existingBudget != null) {
                      _showSetBudgetSheet(existingBudget: existingBudget);
                    }
                  },
                  child: BudgetProgressBar(
                    category: category,
                    currentSpend: currentSpend,
                    totalBudget: totalBudget,
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  // 5. HAPUS _buildTransactionTile()
  // ... (Fungsi _buildTransactionTile yang lama dihapus dari sini) ...
}

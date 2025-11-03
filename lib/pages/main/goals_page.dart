import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:couplegoals/models/goal.dart';
import 'package:couplegoals/utils/formatters.dart';
import 'package:couplegoals/widgets/add_goal_sheet.dart';
import 'package:couplegoals/widgets/add_saving_dialog.dart';

class GoalsPage extends StatefulWidget {
  // 1. Terima walletId dari MainNavigation
  final String walletId;
  const GoalsPage({super.key, required this.walletId});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  // Fungsi untuk menampilkan modal Add Goal
  void _showAddGoalSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddGoalSheet(walletId: widget.walletId),
    );
  }

  // Fungsi untuk menampilkan dialog Add Saving
  void _showAddSavingDialog(Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AddSavingDialog(goal: goal),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Target Tabungan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ValueListenableBuilder<Box<Goal>>(
        valueListenable: Hive.box<Goal>('goals').listenable(),
        builder: (context, box, _) {
          // 2. Filter goals berdasarkan walletId yang aktif
          final goals = box.values
              .where((goal) => goal.walletId == widget.walletId)
              .toList();

          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum Ada Target',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Ayo buat target tabungan pertamamu!',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _showAddGoalSheet,
                    icon: const Icon(Icons.add),
                    label: const Text('Buat Target Baru'),
                  ),
                ],
              ),
            );
          }

          // 3. Tampilkan list goals
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              final double percentage = (goal.currentAmount / goal.targetAmount)
                  .clamp(0.0, 1.0);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  onTap: () => _showAddSavingDialog(goal),
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: percentage.isNaN ? 0.0 : percentage,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.teal,
                          ),
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Formatters.formatCurrency(goal.currentAmount),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${(percentage * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'dari ${Formatters.formatCurrency(goal.targetAmount)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalSheet,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

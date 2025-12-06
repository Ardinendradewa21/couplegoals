import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:couplegoals/models/user.dart';
import 'package:couplegoals/models/budget.dart';
import 'package:couplegoals/models/goal.dart';
import 'package:couplegoals/models/transaction.dart';
import 'package:couplegoals/pages/splash_page.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  // Pastikan Flutter binding siap
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(BudgetAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(GoalAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());

  // Buka box yang akan kita gunakan
  await Hive.openBox<User>('users');
  await Hive.openBox('session'); // Box sederhana untuk simpan sesi login
  await Hive.openBox<Budget>('budgets');
  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<Goal>('goals');

  await initializeDateFormatting('id_ID', null);

  runApp(const SelarasApp());
}

class SelarasApp extends StatelessWidget {
  const SelarasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Selaras',
      theme: ThemeData(
        primarySwatch: Colors.teal, // Kita bisa sesuaikan tema nanti
        fontFamily:
            'Inter', // (Pastikan Anda menambahakan font Inter ke assets)
      ),
      debugShowCheckedModeBanner: false,
      home: SplashPage(), // Kita mulai dari SplashPage untuk cek sesi
    );
  }
}

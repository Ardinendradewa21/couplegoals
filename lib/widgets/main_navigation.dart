import 'package:flutter/material.dart';
import 'package:couplegoals/pages/main/goals_page.dart';
import 'package:couplegoals/pages/main/home_page.dart';
import 'package:couplegoals/pages/main/profile_page.dart';
import 'package:couplegoals/pages/main/tools_page.dart';
import 'package:couplegoals/widgets/add_transaction_sheet.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  String _selectedWallet = 'Pribadi';

  void _onWalletChanged(String newWallet) {
    setState(() {
      _selectedWallet = newWallet;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddTransactionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddTransactionSheet(walletId: _selectedWallet);
      },
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return HomePage(
          walletId: _selectedWallet,
          onWalletChanged: _onWalletChanged,
        );
      case 1:
        // --- 1. UPDATE DI SINI ---
        // GoalsPage sekarang juga perlu tahu wallet yang aktif
        return GoalsPage(walletId: _selectedWallet);
      case 2:
        return const ToolsPage();
      case 3:
        return const ProfilePage();
      default:
        return HomePage(
          walletId: _selectedWallet,
          onWalletChanged: _onWalletChanged,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _buildCurrentPage()),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionSheet,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Sisi Kiri
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNavItem(Icons.home, 'Home', 0),
                  _buildNavItem(Icons.flag, 'Goals', 1),
                ],
              ),
              // Sisi Kanan
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNavItem(Icons.build, 'Tools', 2),
                  _buildNavItem(Icons.person, 'Profil', 3),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = (_selectedIndex == index);
    final color = isSelected ? Colors.teal : Colors.grey;
    return MaterialButton(
      minWidth: 40,
      onPressed: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}

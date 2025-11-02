import 'package:flutter/material.dart';
import 'package:couplegoals/pages/auth/login_page.dart';
import 'package:couplegoals/services/auth_service.dart';
import 'package:couplegoals/widgets/main_navigation.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  void _checkSession() async {
    // Beri jeda sedikit agar splash screen terlihat
    await Future.delayed(const Duration(seconds: 2));

    final username = _authService.getCurrentUser();

    if (mounted) {
      if (username != null) {
        // Jika ada sesi, lempar ke Halaman Utama
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainNavigation()),
        );
      } else {
        // Jika tidak ada sesi, lempar ke Login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI Sederhana untuk Splash Screen
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Memuat..."),
          ],
        ),
      ),
    );
  }
}

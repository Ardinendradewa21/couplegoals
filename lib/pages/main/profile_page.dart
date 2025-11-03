import 'package:flutter/material.dart';
import 'package:couplegoals/pages/auth/login_page.dart';
import 'package:couplegoals/services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(title: Text("Profil Saya")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Halaman Profil & Saran/Kesan (Tahap Selanjutnya)"),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade300,
              ),
              onPressed: () async {
                await authService.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false,
                  );
                }
              },
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}

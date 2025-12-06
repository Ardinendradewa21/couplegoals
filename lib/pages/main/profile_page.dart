import 'dart:io';
import 'package:flutter/material.dart';
import 'package:couplegoals/pages/auth/login_page.dart';
import 'package:couplegoals/pages/feedback_page.dart';
import 'package:couplegoals/services/auth_service.dart';
import 'package:couplegoals/services/location_service.dart';
import 'package:couplegoals/models/user.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();

  String _currentUsername = 'Memuat...';
  String _locationMessage = 'Klik tombol refresh untuk mencari lokasi';
  String? _currentProfilePath; // Path foto lokal

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _getLocation();
  }

  void _loadUserData() async {
    final user = await _authService.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _currentUsername = user.id;
        _currentProfilePath = user.profilePicturePath;
      });
    }
  }

  // --- FUNGSI BARU: Ganti Foto Profil ---
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // Munculkan pilihan: Galeri atau Kamera
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final pickedFile = await picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile == null) return;

    // Simpan file ke penyimpanan lokal aplikasi agar persisten
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = path.basename(pickedFile.path);
    final savedImage = await File(
      pickedFile.path,
    ).copy('${appDir.path}/$fileName');

    // Update User di Hive
    final userBox = Hive.box<User>('users');
    final user = userBox.get(_currentUsername);
    if (user != null) {
      user.profilePicturePath = savedImage.path;
      await user.save();
    }

    if (mounted) {
      setState(() {
        _currentProfilePath = savedImage.path;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Foto profil diperbarui!')));
    }
  }
  // --------------------------------------

  void _getLocation() async {
    setState(() => _locationMessage = 'Mencari lokasi...');

    final locationData = await _locationService.getCurrentLocation();
    if (locationData != null) {
      // --- FUNGSI BARU: Geocoding ---
      final address = await _locationService.getAddressFromCoordinates(
        locationData.latitude!,
        locationData.longitude!,
      );

      if (mounted) {
        setState(() {
          if (address != null) {
            _locationMessage = address;
          } else {
            // Fallback jika geocoding gagal tapi koordinat dapat
            _locationMessage =
                'Lat: ${locationData.latitude!.toStringAsFixed(4)}, Lon: ${locationData.longitude!.toStringAsFixed(4)}';
          }
        });
      }
    } else if (mounted) {
      setState(() {
        _locationMessage = 'Gagal mendapatkan lokasi. Pastikan GPS aktif.';
      });
    }
  }

  void _logout() async {
    await _authService.logoutUser();
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(color: Colors.teal.shade50),
            child: Column(
              children: [
                // --- FOTO PROFIL DENGAN TOMBOL EDIT ---
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.teal.shade200,
                      backgroundImage: _currentProfilePath != null
                          ? FileImage(File(_currentProfilePath!))
                                as ImageProvider
                          : const AssetImage('assets/profile.jpg'),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.teal,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // --------------------------------------
                const SizedBox(height: 16),
                Text(
                  _currentUsername,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // LBS (Alamat)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.teal.shade100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.red.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _locationMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildMenuTile(
            icon: Icons.feedback,
            title: 'Saran & Kesan Mata Kuliah',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const FeedbackPage()),
            ),
          ),
          _buildMenuTile(
            icon: Icons.refresh,
            title: 'Refresh Lokasi',
            onTap: _getLocation,
          ),
          const Divider(),
          _buildMenuTile(
            icon: Icons.logout,
            title: 'Logout',
            color: Colors.red,
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.teal),
      title: Text(title, style: TextStyle(color: color, fontSize: 16)),
      trailing: Icon(Icons.chevron_right, color: color ?? Colors.grey),
      onTap: onTap,
    );
  }
}

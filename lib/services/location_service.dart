import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geo;

class LocationService {
  final Location _location = Location();

  Future<bool> _checkService() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
    }
    return serviceEnabled;
  }

  Future<PermissionStatus> _checkPermission() async {
    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
    }
    return permissionGranted;
  }

  Future<LocationData?> getCurrentLocation() async {
    try {
      if (!await _checkService()) return null;
      if (await _checkPermission() == PermissionStatus.deniedForever)
        return null;

      return await _location.getLocation();
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }

  Future<String?> getAddressFromCoordinates(double lat, double long) async {
    try {
      // Geocoding membutuhkan koneksi internet!
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        lat,
        long,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];

        // Kita susun bagian-bagian alamat, dan hapus yang kosong/null
        final addressParts = [
          place.street, // Nama jalan/nomor
          place.subLocality, // Kelurahan/Desa
          place.locality, // Kecamatan/Kota
          place.subAdministrativeArea, // Kota/Kabupaten
          place.administrativeArea, // Provinsi
        ];

        // Filter bagian yang null atau kosong, lalu gabungkan dengan koma
        final formattedAddress = addressParts
            .where((part) => part != null && part.isNotEmpty)
            .toSet() // Hapus duplikat (kadang nama jalan = nama kelurahan)
            .join(', ');

        // Jika hasilnya kosong (jarang terjadi), kembalikan null agar pakai koordinat
        return formattedAddress.isEmpty ? null : formattedAddress;
      }
      return null;
    } catch (e) {
      print("Geocoding Error: $e");
      return null;
    }
  }
}

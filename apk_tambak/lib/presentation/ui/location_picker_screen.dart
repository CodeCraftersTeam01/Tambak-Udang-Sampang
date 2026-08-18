import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/utils/toast_helper.dart';

class LocationPickerScreen extends StatefulWidget {
  final double initialLat;
  final double initialLong;

  const LocationPickerScreen({
    super.key,
    required this.initialLat,
    required this.initialLong,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();
  LatLng _currentCenter = const LatLng(-7.1884, 113.2435);
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _currentCenter = LatLng(widget.initialLat, widget.initialLong);
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ToastHelper.showError('Layanan lokasi (GPS) tidak aktif.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ToastHelper.showError('Izin akses lokasi ditolak.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ToastHelper.showError('Izin lokasi ditolak permanen.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newLatLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentCenter = newLatLng;
      });
      _mapController.move(newLatLng, 15.0);
      ToastHelper.showSuccess('Lokasi GPS ditemukan.');
    } catch (e) {
      ToastHelper.showError('Gagal mendapatkan lokasi GPS: ${e.toString()}');
    } finally {
      setState(() => _isLocating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1326),
      appBar: AppBar(
        title: const Text('Pilih Lokasi Kolam'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isLocating
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6CD3F7)))
                : const Icon(Icons.my_location),
            onPressed: _isLocating ? null : _getUserLocation,
          )
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 15.0,
              onPositionChanged: (position, hasGesture) {
                if (position.center != null) {
                  setState(() {
                    _currentCenter = position.center!;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.codeplex.tambakudang',
              ),
            ],
          ),
          // Fixed center pin marker (Gojek-style)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 36), // Align pin tip with center point
              child: Icon(
                Icons.location_on,
                size: 48,
                color: Colors.red.shade600,
              ),
            ),
          ),
          // Bottom selection bar
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF131B2E).withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Koordinat Terpilih',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Lat: ${_currentCenter.latitude.toStringAsFixed(7)}\nLng: ${_currentCenter.longitude.toStringAsFixed(7)}',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _currentCenter);
                    },
                    child: const Text('PILIH LOKASI INI'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

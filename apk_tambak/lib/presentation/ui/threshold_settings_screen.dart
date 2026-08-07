import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../main.dart';

class ThresholdSettingsScreen extends StatefulWidget {
  final int pondId;
  final String pondName;

  const ThresholdSettingsScreen({
    super.key,
    required this.pondId,
    required this.pondName,
  });

  @override
  State<ThresholdSettingsScreen> createState() => _ThresholdSettingsScreenState();
}

class _ThresholdSettingsScreenState extends State<ThresholdSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  int _selectedSensorTypeId = 1; // Default to pH (ID 1)
  final _minController = TextEditingController();
  final _maxController = TextEditingController();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _sensorTypes = [
    {'id': 1, 'name': 'pH'},
    {'id': 2, 'name': 'TDS (ppm)'},
    {'id': 3, 'name': 'Dissolved Oxygen (mg/L)'},
    {'id': 4, 'name': 'Suhu Air (°C)'},
    {'id': 5, 'name': 'Ketinggian Air (cm)'},
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await globalApiClient.dio.post('/api/thresholds/update', data: {
        'pond_id': widget.pondId,
        'sensor_type_id': _selectedSensorTypeId,
        'min_value': _minController.text.isNotEmpty ? double.tryParse(_minController.text) : null,
        'max_value': _maxController.text.isNotEmpty ? double.tryParse(_maxController.text) : null,
      });

      if (mounted) {
        if (response.data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Batas parameter berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          throw Exception(response.data['message'] ?? 'Gagal memperbarui batas.');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Batas Parameter Sensor',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 0,
                      color: AppColors.primary.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Mengatur batas peringatan untuk Kolam: ${widget.pondName}',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Jenis Sensor',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedSensorTypeId,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: _sensorTypes.map((type) {
                        return DropdownMenuItem<int>(
                          value: type['id'] as int,
                          child: Text(type['name'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedSensorTypeId = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Batas Minimum (Peringatan Terlalu Rendah)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _minController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: 'Masukkan nilai minimum',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (double.tryParse(value) == null) {
                            return 'Harus berupa angka desimal';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Batas Maksimum (Peringatan Terlalu Tinggi)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _maxController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: 'Masukkan nilai maksimum',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (double.tryParse(value) == null) {
                            return 'Harus berupa angka desimal';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Simpan Konfigurasi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

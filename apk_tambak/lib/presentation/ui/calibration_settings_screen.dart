import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../main.dart';

class CalibrationSettingsScreen extends StatefulWidget {
  final int pondId;
  final String pondName;

  const CalibrationSettingsScreen({
    super.key,
    required this.pondId,
    required this.pondName,
  });

  @override
  State<CalibrationSettingsScreen> createState() => _CalibrationSettingsScreenState();
}

class _CalibrationSettingsScreenState extends State<CalibrationSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  int? _deviceId;
  String? _deviceName;

  final _phSlopeController = TextEditingController();
  final _phOffsetController = TextEditingController();
  final _doScaleController = TextEditingController();
  final _doOffsetController = TextEditingController();
  final _tdsScaleController = TextEditingController();
  final _tdsOffsetController = TextEditingController();
  final _suhuOffsetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDeviceAndCalibration();
  }

  Future<void> _fetchDeviceAndCalibration() async {
    try {
      final calResponse = await globalApiClient.dio.get('/api/devices/${widget.pondId}/calibration');
      if (calResponse.data['success'] == true && calResponse.data['data'] != null) {
        final data = calResponse.data['data'];
        
        if (data['device'] != null) {
          _deviceId = data['device']['id'];
          _deviceName = data['device']['name'];
        } else {
          _deviceId = data['device_id'];
          _deviceName = 'Sensor Node';
        }

        _phSlopeController.text = (data['ph_slope'] ?? 3.5).toString();
        _phOffsetController.text = (data['ph_offset'] ?? 1.9).toString();
        _doScaleController.text = (data['do_scale'] ?? 0.5).toString();
        _doOffsetController.text = (data['do_offset'] ?? 0).toString();
        _tdsScaleController.text = (data['tds_scale'] ?? 1.0).toString();
        _tdsOffsetController.text = (data['tds_offset'] ?? 0).toString();
        _suhuOffsetController.text = (data['suhu_offset'] ?? 0).toString();
      }
    } catch (e) {
      debugPrint('Error fetching calibration data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submit() async {
    if (_deviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada perangkat sensor yang terhubung ke kolam ini.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await globalApiClient.dio.post('/api/calibration/update', data: {
        'device_id': _deviceId,
        'pond_id': widget.pondId,
        'ph_slope': double.parse(_phSlopeController.text),
        'ph_offset': double.parse(_phOffsetController.text),
        'do_scale': double.parse(_doScaleController.text),
        'do_offset': double.parse(_doOffsetController.text),
        'tds_scale': double.parse(_tdsScaleController.text),
        'tds_offset': double.parse(_tdsOffsetController.text),
        'suhu_offset': double.parse(_suhuOffsetController.text),
      });

      if (mounted) {
        if (response.data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kalibrasi berhasil diperbarui dan dikirim ke perangkat'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          throw Exception(response.data['message'] ?? 'Gagal memperbarui kalibrasi.');
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
    _phSlopeController.dispose();
    _phOffsetController.dispose();
    _doScaleController.dispose();
    _doOffsetController.dispose();
    _tdsScaleController.dispose();
    _tdsOffsetController.dispose();
    _suhuOffsetController.dispose();
    super.dispose();
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Harus diisi';
            if (double.tryParse(value) == null) return 'Harus berupa angka';
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Kalibrasi Parameter Sensor',
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
          : _deviceId == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.device_unknown, size: 80, color: AppColors.textSecondary),
                        const SizedBox(height: 16),
                        const Text(
                          'Perangkat Tidak Ditemukan',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tidak ada perangkat sensor yang terdaftar untuk Kolam "${widget.pondName}". Silakan daftarkan perangkat terlebih dahulu.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
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
                                const Icon(Icons.settings_input_component, color: AppColors.primary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Perangkat: $_deviceName',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Kolam: ${widget.pondName}',
                                        style: const TextStyle(color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildField('pH Slope (Batas kemiringan pH)', _phSlopeController),
                        _buildField('pH Offset (Koreksi nilai pH)', _phOffsetController),
                        _buildField('DO Scale (Skala Oksigen terlarut)', _doScaleController),
                        _buildField('DO Offset (Koreksi Oksigen terlarut)', _doOffsetController),
                        _buildField('TDS Scale (Skala Padatan terlarut)', _tdsScaleController),
                        _buildField('TDS Offset (Koreksi Padatan terlarut)', _tdsOffsetController),
                        _buildField('Suhu Offset (Koreksi nilai suhu)', _suhuOffsetController),
                        const SizedBox(height: 32),
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
                            'Kirim Kalibrasi ke Perangkat',
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

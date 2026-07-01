import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/mqtt_manager.dart';
import '../../data/datasources/produksi_remote_datasource.dart';
import '../../domain/entities/kolam_entity.dart';
import '../../main.dart';

class LogInputScreen extends StatefulWidget {
  final KolamEntity kolam;

  const LogInputScreen({super.key, required this.kolam});

  @override
  State<LogInputScreen> createState() => _LogInputScreenState();
}

class _LogInputScreenState extends State<LogInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pakanController = TextEditingController();
  final _mbwController = TextEditingController();
  final _mortalityController = TextEditingController();

  late double _suhu;
  late double _ph;
  late double _doValue;
  late double _tds;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Auto-fill from latest MQTT data
    final latestData = globalMqttManager.latestData;
    _suhu = (latestData['suhu'] as num?)?.toDouble() ?? 0.0;
    _ph = (latestData['ph'] as num?)?.toDouble() ?? 0.0;
    _doValue = (latestData['do'] as num?)?.toDouble() ?? 0.0;
    _tds = (latestData['tds'] as num?)?.toDouble() ?? 0.0;
  }

  @override
  void dispose() {
    _pakanController.dispose();
    _mbwController.dispose();
    _mortalityController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final dataSource = ProduksiRemoteDataSourceImpl(apiClient: globalApiClient);

        await dataSource.submitLog(
          kolamId: widget.kolam.id,
          suhu: _suhu,
          ph: _ph,
          doValue: _doValue,
          tds: _tds,
          pakanKg: double.parse(_pakanController.text),
          mbwGram: double.parse(_mbwController.text),
          mortality: int.parse(_mortalityController.text),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Log berhasil disubmit!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Input Log Harian',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Auto-filled Sensor Data Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data Sensor (Auto-fill)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildReadOnlyField('Suhu Air (°C)', _suhu.toStringAsFixed(1)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildReadOnlyField('pH Air', _ph.toStringAsFixed(1)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildReadOnlyField('DO (mg/L)', _doValue.toStringAsFixed(1)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildReadOnlyField('TDS', _tds.toStringAsFixed(0)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Manual Input Data Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Input Manual',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    _buildInputField('Pakan (Kg)', _pakanController, Icons.food_bank),
                    const SizedBox(height: 16),
                    _buildInputField('MBW (Gram)', _mbwController, Icons.monitor_weight),
                    const SizedBox(height: 16),
                    _buildInputField('Mortality (Ekor)', _mortalityController, Icons.warning, isInt: true),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Simpan Log',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, {bool isInt = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return 'Wajib diisi';
        if (num.tryParse(val) == null) return 'Harus berupa angka';
        if (isInt && int.tryParse(val) == null) return 'Harus angka bulat';
        return null;
      },
    );
  }
}

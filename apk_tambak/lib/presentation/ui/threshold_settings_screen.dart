import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../main.dart';
import '../../core/utils/toast_helper.dart';

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
  List<dynamic> _rules = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRules();
  }

  Future<void> _fetchRules() async {
    setState(() => _isLoading = true);
    try {
      final response = await globalApiClient.dio.get('/api/thresholds?pond_id=${widget.pondId}');
      if (response.data['success'] == true) {
        setState(() {
          _rules = response.data['data'] ?? [];
        });
      } else {
        ToastHelper.showError('Gagal memuat aturan batas.');
      }
    } catch (e) {
      ToastHelper.showError('Gagal memuat aturan: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteRule(int id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131B2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF1E293B)),
        ),
        title: const Text('Hapus Aturan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        content: const Text('Apakah Anda yakin ingin menghapus aturan batas sensor ini?', style: TextStyle(color: Color(0xFFDAE2FD))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await globalApiClient.dio.delete('/api/thresholds/$id');
      if (response.data['success'] == true) {
        ToastHelper.showSuccess('Aturan berhasil dihapus.');
        _fetchRules();
      } else {
        ToastHelper.showError(response.data['message'] ?? 'Gagal menghapus aturan.');
      }
    } catch (e) {
      ToastHelper.showError('Error: ${e.toString()}');
    }
  }

  void _showAddRuleSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131B2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _AddRuleForm(
        pondId: widget.pondId,
        onSuccess: () {
          Navigator.pop(context);
          _fetchRules();
        },
      ),
    );
  }

  String _getSensorLabel(String code) {
    switch (code) {
      case 'ph':
        return 'pH';
      case 'do':
        return 'DO (Dissolved Oxygen)';
      case 'temperature':
        return 'Suhu Air';
      case 'tds':
        return 'TDS';
      case 'water_level':
        return 'Ketinggian Air';
      default:
        return code.toUpperCase();
    }
  }

  IconData _getSensorIcon(String code) {
    switch (code) {
      case 'ph':
        return Icons.opacity;
      case 'do':
        return Icons.science_outlined;
      case 'temperature':
        return Icons.thermostat;
      case 'tds':
        return Icons.blur_on;
      case 'water_level':
        return Icons.waves;
      default:
        return Icons.settings_input_component;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Batas Parameter - ${widget.pondName}'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _rules.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada batas parameter diatur.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Menggunakan batas default sistem.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _showAddRuleSheet,
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Aturan'),
                      )
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _rules.length,
                  itemBuilder: (context, index) {
                    final rule = _rules[index];
                    final sensorType = rule['sensor_type'] ?? '';
                    final docStart = rule['doc_start'] ?? 0;
                    final docEnd = rule['doc_end'];
                    final minValue = rule['min_value'];
                    final maxValue = rule['max_value'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131B2E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6CD3F7).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_getSensorIcon(sensorType), color: const Color(0xFF6CD3F7)),
                        ),
                        title: Text(
                          _getSensorLabel(sensorType),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Fase: DOC $docStart - ${docEnd == null ? "Infinity" : "$docEnd Hari"}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Batas: Min ${minValue ?? "-"} | Max ${maxValue ?? "-"}',
                              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                          onPressed: () => _deleteRule(rule['id']),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: _rules.isNotEmpty
          ? FloatingActionButton(
              onPressed: _showAddRuleSheet,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

class _AddRuleForm extends StatefulWidget {
  final int pondId;
  final VoidCallback onSuccess;

  const _AddRuleForm({
    required this.pondId,
    required this.onSuccess,
  });

  @override
  State<_AddRuleForm> createState() => _AddRuleFormState();
}

class _AddRuleFormState extends State<_AddRuleForm> {
  final _formKey = GlobalKey<FormState>();
  String _selectedSensor = 'ph';
  final _docStartController = TextEditingController();
  final _docEndController = TextEditingController();
  final _minController = TextEditingController();
  final _maxController = TextEditingController();
  bool _isSaving = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // CONSTRAINT 2.1: doc_start vs doc_end check
    final int docStart = int.parse(_docStartController.text);
    final int? docEnd = _docEndController.text.isNotEmpty ? int.parse(_docEndController.text) : null;

    if (docEnd != null && docStart > docEnd) {
      ToastHelper.showError('Mulai DOC tidak boleh lebih besar dari Selesai DOC.');
      return;
    }

    // CONSTRAINT 2.2: At least one boundary filled
    final double? minVal = _minController.text.isNotEmpty ? double.parse(_minController.text) : null;
    final double? maxVal = _maxController.text.isNotEmpty ? double.parse(_maxController.text) : null;

    if (minVal == null && maxVal == null) {
      ToastHelper.showError('Harap isi setidaknya batas minimum atau batas maksimum.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final response = await globalApiClient.dio.post('/api/thresholds', data: {
        'pond_id': widget.pondId,
        'sensor_type': _selectedSensor,
        'doc_start': docStart,
        'doc_end': docEnd,
        'min_value': minVal,
        'max_value': maxVal,
      });

      if (response.data['success'] == true) {
        ToastHelper.showSuccess('Aturan batas berhasil disimpan.');
        widget.onSuccess();
      } else {
        ToastHelper.showError(response.data['message'] ?? 'Gagal menyimpan aturan.');
      }
    } catch (e) {
      ToastHelper.showError('Error: ${e.toString()}');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _docStartController.dispose();
    _docEndController.dispose();
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tambah Aturan Batas',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 16),

              // Sensor Dropdown
              const Text('Sensor', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedSensor,
                dropdownColor: const Color(0xFF131B2E),
                decoration: const InputDecoration(),
                items: const [
                  DropdownMenuItem(value: 'ph', child: Text('pH')),
                  DropdownMenuItem(value: 'do', child: Text('DO (Dissolved Oxygen)')),
                  DropdownMenuItem(value: 'temperature', child: Text('Suhu Air')),
                  DropdownMenuItem(value: 'tds', child: Text('TDS')),
                  DropdownMenuItem(value: 'water_level', child: Text('Ketinggian Air')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSensor = val);
                },
              ),
              const SizedBox(height: 16),

              // DOC Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Mulai DOC (Hari)', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _docStartController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '0',
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Harap diisi';
                            if (int.tryParse(val) == null) return 'Harus angka';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Selesai DOC (Hari)', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _docEndController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Infinity',
                          ),
                          validator: (val) {
                            if (val != null && val.isNotEmpty && int.tryParse(val) == null) return 'Harus angka';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Boundaries Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Batas Min', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _minController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            hintText: 'Min',
                          ),
                          validator: (val) {
                            if (val != null && val.isNotEmpty && double.tryParse(val) == null) return 'Harus desimal';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Batas Max', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _maxController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            hintText: 'Max',
                          ),
                          validator: (val) {
                            if (val != null && val.isNotEmpty && double.tryParse(val) == null) return 'Harus desimal';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Color(0xFF0B1326), strokeWidth: 2),
                      )
                    : const Text('Simpan Aturan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

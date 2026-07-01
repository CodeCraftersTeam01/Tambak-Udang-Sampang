import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/datasources/panen_remote_datasource.dart';
import '../../main.dart';

class PanenScreen extends StatefulWidget {
  const PanenScreen({super.key});

  @override
  State<PanenScreen> createState() => _PanenScreenState();
}

class _PanenScreenState extends State<PanenScreen> {
  bool _isLoading = true;
  String _error = '';
  List<Map<String, dynamic>> _panenList = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final dataSource = PanenRemoteDataSourceImpl(apiClient: globalApiClient);
      final list = await dataSource.getPanenList();
      if (mounted) {
        setState(() {
          _panenList = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _showAddPanenModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _AddPanenForm(
            onSuccess: () {
              Navigator.pop(context);
              _fetchData();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Harvest (Panen)', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPanenModal,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_error.isNotEmpty) return Center(child: Text(_error, style: const TextStyle(color: Colors.red)));
    if (_panenList.isEmpty) return const Center(child: Text('Belum ada data panen', style: TextStyle(color: AppColors.textSecondary)));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _panenList.length,
      itemBuilder: (context, index) {
        final panen = _panenList[index];
        final kg = panen['jumlah_panen_kg']?.toString() ?? '0';
        final jenis = panen['jenis_panen']?.toString().toUpperCase() ?? '-';
        final size = panen['shrimp_size']?.toString() ?? '-';
        final price = panen['sale_price']?.toString() ?? '-';
        final dateRaw = panen['tanggal_panen']?.toString() ?? '-';
        final dateStr = dateRaw.contains('T') ? dateRaw.split('T').first : dateRaw;

        return Card(
          color: AppColors.surface,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          shadowColor: Colors.black12,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tanggal: $dateStr', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16.0,
                  runSpacing: 4.0,
                  children: [
                    Text('Jenis: $jenis', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                    Text('Weight: $kg Kg', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                    Text('Size: $size', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                    Text('Price: Rp $price', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AddPanenForm extends StatefulWidget {
  final VoidCallback onSuccess;

  const _AddPanenForm({required this.onSuccess});

  @override
  State<_AddPanenForm> createState() => _AddPanenFormState();
}

class _AddPanenFormState extends State<_AddPanenForm> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _weightController = TextEditingController();
  final _sizeController = TextEditingController();
  final _priceController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _dateController.text = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _dateController.dispose();
    _weightController.dispose();
    _sizeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submitPanen() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final dataSource = PanenRemoteDataSourceImpl(apiClient: globalApiClient);
        await dataSource.addPanen(
          kolamId: 1, // Defaulting to Kolam 1
          tanggalPanen: _dateController.text,
          jumlahPanenKg: double.parse(_weightController.text),
          jenisPanen: 'total', // Default for now
          shrimpSize: _sizeController.text,
          salePrice: double.parse(_priceController.text),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data Panen berhasil disimpan!'), backgroundColor: Colors.green),
          );
          widget.onSuccess();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Record Harvest (Panen)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            _buildInputField('Tanggal Panen', _dateController, Icons.calendar_today, readOnly: true),
            const SizedBox(height: 16),
            _buildInputField('Total Weight (Kg)', _weightController, Icons.scale),
            const SizedBox(height: 16),
            _buildInputField('Shrimp Size', _sizeController, Icons.straighten),
            const SizedBox(height: 16),
            _buildInputField('Sale Price', _priceController, Icons.monetization_on),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitPanen,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Simpan Panen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, {bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: readOnly ? TextInputType.text : const TextInputType.numberWithOptions(decimal: true),
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
        return null;
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/datasources/pakan_remote_datasource.dart';
import '../../main.dart';

class PakanScreen extends StatefulWidget {
  const PakanScreen({super.key});

  @override
  State<PakanScreen> createState() => _PakanScreenState();
}

class _PakanScreenState extends State<PakanScreen> {
  bool _isLoading = true;
  String _error = '';
  List<Map<String, dynamic>> _pakanList = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final dataSource = PakanRemoteDataSourceImpl(apiClient: globalApiClient);
      final list = await dataSource.getPakanList();
      if (mounted) {
        setState(() {
          _pakanList = list;
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

  void _showAddPakanDialog() {
    final formKey = GlobalKey<FormState>();
    final brandController = TextEditingController();
    final quantityController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Tambah Pakan', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: brandController,
                      decoration: InputDecoration(
                        labelText: 'Brand / Nama Pakan',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      validator: (val) => (val == null || val.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: quantityController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Quantity (Kg)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Wajib diisi';
                        if (double.tryParse(val) == null) return 'Harus angka';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setStateDialog(() => isSubmitting = true);
                            try {
                              final dataSource = PakanRemoteDataSourceImpl(apiClient: globalApiClient);
                              await dataSource.addPakan(
                                kolamId: 1, // Defaulting to 1 since no selector is required yet
                                namaPakan: brandController.text,
                                jumlah: double.parse(quantityController.text),
                                tipe: 'masuk',
                              );
                              if (mounted) {
                                Navigator.pop(context);
                                _fetchData();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pakan berhasil ditambahkan'), backgroundColor: AppColors.primary));
                              }
                            } catch (e) {
                              setStateDialog(() => isSubmitting = false);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
                              }
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: isSubmitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Simpan', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Feed Stock', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPakanDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Pakan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_error.isNotEmpty) return Center(child: Text(_error, style: const TextStyle(color: Colors.red)));
    if (_pakanList.isEmpty) return const Center(child: Text('Belum ada data pakan', style: TextStyle(color: AppColors.textSecondary)));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pakanList.length,
      itemBuilder: (context, index) {
        final pakan = _pakanList[index];
        final nama = pakan['nama_pakan'] ?? '-';
        final jumlah = pakan['jumlah_perminggu_kg']?.toString() ?? '0';
        final dateRaw = pakan['created_at']?.toString() ?? '-';
        final dateStr = dateRaw.contains('T') ? dateRaw.split('T').first : dateRaw;

        return Card(
          color: AppColors.surface,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          shadowColor: Colors.black12,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: const Icon(Icons.inventory_2, color: AppColors.primary),
            ),
            title: Text(nama, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            subtitle: Text('Tanggal: $dateStr', style: const TextStyle(color: AppColors.textSecondary)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('IN', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                Text('$jumlah Kg', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
          ),
        );
      },
    );
  }
}

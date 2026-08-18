import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../data/repositories/local_guest_repository.dart';
import 'guest_monitoring_screen.dart';

class GuestListScreen extends StatefulWidget {
  const GuestListScreen({super.key});

  @override
  State<GuestListScreen> createState() => _GuestListScreenState();
}

class _GuestListScreenState extends State<GuestListScreen> {
  final LocalGuestRepository _repository = LocalGuestRepository();
  List<LocalPond> _ponds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPonds();
  }

  Future<void> _loadPonds() async {
    setState(() => _isLoading = true);
    final ponds = await _repository.getPonds();
    setState(() {
      _ponds = ponds;
      _isLoading = false;
    });
  }

  Future<void> _deletePond(LocalPond pond) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131B2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF1E293B)),
        ),
        title: const Text('Hapus Kolam Lokal', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        content: const Text('Apakah Anda yakin ingin menghapus kolam lokal ini?', style: TextStyle(color: Color(0xFFDAE2FD))),
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

    if (confirm == true) {
      await _repository.deletePond(pond.id);
      ToastHelper.showSuccess('Kolam lokal berhasil dihapus');
      _loadPonds();
    }
  }

  void _showAddPondBottomSheet() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final mqttController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131B2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tambah Kolam Lokal',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Kolam',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Nama kolam harus diisi';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: mqttController,
                  decoration: const InputDecoration(
                    labelText: 'ID MQTT (e.g. t01)',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'ID MQTT harus diisi';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final newPond = LocalPond(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      namaKolam: nameController.text.trim(),
                      mqttId: mqttController.text.trim(),
                    );
                    await _repository.savePond(newPond);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ToastHelper.showSuccess('Kolam lokal berhasil ditambahkan');
                      _loadPonds();
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mode Lokal (Tamu)'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _ponds.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline, size: 64, color: AppColors.textSecondary),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum ada kolam lokal.',
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Silakan tambahkan kolam baru untuk memantau data kincir dan sensor.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _showAddPondBottomSheet,
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Kolam'),
                        )
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ponds.length,
                  itemBuilder: (context, index) {
                    final pond = _ponds[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.water, color: AppColors.primary),
                        ),
                        title: Text(
                          pond.namaKolam,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        ),
                        subtitle: Text(
                          'ID MQTT: ${pond.mqttId}',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.error),
                              onPressed: () => _deletePond(pond),
                            ),
                            const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GuestMonitoringScreen(pond: pond),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: _ponds.isNotEmpty
          ? FloatingActionButton(
              onPressed: _showAddPondBottomSheet,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
    );
  }
}

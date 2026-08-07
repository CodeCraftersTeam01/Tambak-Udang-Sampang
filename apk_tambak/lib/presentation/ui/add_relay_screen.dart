import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../bloc/kolam_bloc.dart';
import '../bloc/kolam_event.dart';
import '../bloc/kolam_state.dart';
import '../../domain/entities/kolam_entity.dart';
import '../../data/models/kolam_model.dart';
import '../../data/models/relay_model.dart';

class AddRelayScreen extends StatefulWidget {
  final Map<String, dynamic> kolamPayload;
  final int jumlahRelay;
  final KolamEntity? kolamToEdit;

  const AddRelayScreen({
    super.key,
    required this.kolamPayload,
    required this.jumlahRelay,
    this.kolamToEdit,
  });

  @override
  State<AddRelayScreen> createState() => _AddRelayScreenState();
}

class _AddRelayScreenState extends State<AddRelayScreen> {
  final _formKey = GlobalKey<FormState>();
  late List<TextEditingController> _controllers;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.jumlahRelay,
      (index) {
        String initialText = 'Kincir ${index + 1}';
        if (widget.kolamToEdit != null && widget.kolamToEdit!.relays.length > index) {
          initialText = widget.kolamToEdit!.relays[index].namaRelay;
        }
        return TextEditingController(text: initialText);
      }
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final List<String> relayNames = _controllers.map((c) => c.text).toList();

      if (widget.kolamToEdit != null) {
        context.read<KolamBloc>().add(UpdateKolamWithRelays(
          widget.kolamToEdit!.id,
          widget.kolamPayload,
          relayNames,
        ));
      } else {
        context.read<KolamBloc>().add(AddKolamWithRelays(
          widget.kolamPayload,
          relayNames,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Konfigurasi Relay',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocListener<KolamBloc, KolamState>(
                listener: (context, state) {
                  if (state is KolamLoading) {
                    setState(() => _isLoading = true);
                  } else {
                    setState(() => _isLoading = false);
                    if (state is KolamAddSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kolam & Relay berhasil ditambahkan')),
                      );
                      Navigator.pop(context, state.kolam);
                    } else if (state is KolamUpdateSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kolam & Relay berhasil diupdate')),
                      );
                      // Provide an updated kolam locally for instant UI reflection if state.kolam not provided
                      Navigator.pop(context, state.kolam ?? KolamModel(
                        id: widget.kolamToEdit!.id,
                        pemilik: widget.kolamToEdit!.pemilik,
                        nama: widget.kolamPayload['nama_kolam'],
                        mqttId: widget.kolamPayload['mqtt_id'],
                        lat: widget.kolamPayload['lat'],
                        long: widget.kolamPayload['long'],
                        status: widget.kolamPayload['status'],
                        statusLabel: widget.kolamPayload['status'] == 1 ? 'Aktif' : (widget.kolamPayload['status'] == 2 ? 'Panen' : 'Tidak Aktif'),
                        luas: widget.kolamPayload['luas_kolam'],
                        targetPanen: widget.kolamToEdit!.targetPanen,
                        detailUdang: widget.kolamPayload['detail_udang'],
                        relays: _controllers.map((c) => RelayModel(id: 0, kolamId: widget.kolamToEdit!.id, namaRelay: c.text)).toList(),
                      ));
                    } else if (state is KolamError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
                      );
                    }
                  }
                },
                child: widget.jumlahRelay == 0 ? _buildEmptyState() : _buildForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Tidak ada relay. Lanjutkan?'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading ? const CircularProgressIndicator() : const Text('Simpan'),
          )
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...List.generate(widget.jumlahRelay, (index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Nama Relay ${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ),
                    TextFormField(
                      controller: _controllers[index],
                      decoration: InputDecoration(
                        hintText: 'Contoh: Kincir Ujung',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _isLoading ? null : _submit,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Simpan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

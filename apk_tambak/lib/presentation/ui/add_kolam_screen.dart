import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/kolam_entity.dart';
import '../widgets/liquid_glass_card.dart';
import 'add_relay_screen.dart';

class AddKolamScreen extends StatefulWidget {
  final KolamEntity? kolamToEdit;

  const AddKolamScreen({super.key, this.kolamToEdit});

  @override
  State<AddKolamScreen> createState() => _AddKolamScreenState();
}

class _AddKolamScreenState extends State<AddKolamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _mqttController = TextEditingController();
  final _luasController = TextEditingController();
  final _detailController = TextEditingController();
  final _kincirController = TextEditingController();
  int _status = 1;
  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.kolamToEdit != null) {
      _namaController.text = widget.kolamToEdit!.nama;
      _mqttController.text = 't0${widget.kolamToEdit!.id}';
      _luasController.text = widget.kolamToEdit!.luas.toString();
      _detailController.text = widget.kolamToEdit!.detailUdang;
      _kincirController.text = widget.kolamToEdit!.relays.length.toString();
      _status = widget.kolamToEdit!.status;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _mqttController.dispose();
    _luasController.dispose();
    _detailController.dispose();
    _kincirController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> payload = {
        "pemilik": 1, 
        "nama_kolam": _namaController.text,
        "mqtt_id": _mqttController.text,
        "lat": widget.kolamToEdit?.lat ?? "-7.2",
        "long": widget.kolamToEdit?.long ?? "112.7",
        "status": _status,
        "luas_kolam": double.tryParse(_luasController.text) ?? 0.0,
        "detail_udang": _detailController.text,
      };
      if (_selectedImage != null) {
        payload["image_file"] = _selectedImage; // multipart readiness
      }
      
      int jumlahRelay = int.tryParse(_kincirController.text) ?? 0;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddRelayScreen(
            kolamPayload: payload,
            jumlahRelay: jumlahRelay,
            kolamToEdit: widget.kolamToEdit,
          ),
        ),
      ).then((result) {
        if (result != null) {
          Navigator.pop(context, result);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: Colors.transparent,
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6CD3F7).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back, color: Color(0xFF6CD3F7)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      widget.kolamToEdit != null ? 'Edit Kolam' : 'Tambah Kolam',
                      style: const TextStyle(
                        color: Color(0xFFDAE2FD),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: LiquidGlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top section for image selection (SECTOR 4)
                          _buildImageUploadSection(),

                          _buildInputLabel('Nama Kolam'),
                          TextFormField(
                            controller: _namaController,
                            style: const TextStyle(color: Color(0xFFDAE2FD)),
                            decoration: _inputDecoration('Contoh: Kolam A1'),
                            validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),

                          _buildInputLabel('ID MQTT / Topik'),
                          TextFormField(
                            controller: _mqttController,
                            style: const TextStyle(color: Color(0xFFDAE2FD)),
                            decoration: _inputDecoration('Contoh: t01'),
                            validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildInputLabel('Luas Kolam (m²)'),
                          TextFormField(
                            controller: _luasController,
                            style: const TextStyle(color: Color(0xFFDAE2FD)),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _inputDecoration('Contoh: 1000.5'),
                            validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),

                          _buildInputLabel('Detail Udang (Jenis)'),
                          TextFormField(
                            controller: _detailController,
                            style: const TextStyle(color: Color(0xFFDAE2FD)),
                            decoration: _inputDecoration('Contoh: Vannamei'),
                            validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),

                          _buildInputLabel('Status Kolam'),
                          DropdownButtonFormField<int>(
                            value: _status,
                            dropdownColor: const Color(0xFF131B2E),
                            style: const TextStyle(color: Color(0xFFDAE2FD)),
                            items: const [
                              DropdownMenuItem(value: 1, child: Text('Aktif')),
                              DropdownMenuItem(value: 2, child: Text('Panen')),
                              DropdownMenuItem(value: 0, child: Text('Tidak Aktif')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _status = value);
                              }
                            },
                            decoration: _inputDecoration('Pilih status'),
                          ),
                          const SizedBox(height: 16),

                          _buildInputLabel('Jumlah Kincir (Relay)'),
                          TextFormField(
                            controller: _kincirController,
                            style: const TextStyle(color: Color(0xFFDAE2FD)),
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('Contoh: 4'),
                            validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 32),

                          GestureDetector(
                            onTap: _isLoading ? null : _submit,
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6CD3F7), Color(0xFF2E3192)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: _isLoading 
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Lanjut',
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInputLabel('Foto Kolam (Opsional)'),
        GestureDetector(
          onTap: _selectedImage == null ? _pickImage : null,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _selectedImage == null
                ? CustomPaint(
                    painter: DashedBorderPainter(
                      color: Colors.white.withOpacity(0.15),
                      gap: 6.0,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined, color: const Color(0xFF6CD3F7).withOpacity(0.8), size: 40),
                          const SizedBox(height: 12),
                          const Text(
                            'Upload Foto Kolam (Opsional)',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Ketuk untuk memilih dari galeri',
                            style: TextStyle(
                              color: Colors.white30,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _clearImage,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDAE2FD)),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6CD3F7)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedBorderPainter({
    this.color = Colors.white24,
    this.strokeWidth = 1.5,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    ));

    final Path dashedPath = Path();
    for (final pathMetric in path.computeMetrics()) {
      double drawLength = 0.0;
      while (drawLength < pathMetric.length) {
        dashedPath.addPath(
          pathMetric.extractPath(drawLength, drawLength + gap),
          Offset.zero,
        );
        drawLength += gap * 2;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

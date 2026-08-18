import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/toast_helper.dart';
import '../../main.dart'; // For globalApiClient

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = true;
  bool _isSaving = false;
  
  String _name = '';
  String _email = '';
  String _nomorHp = '';
  String _alamat = '';
  String _roleName = '';
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nomorHpController = TextEditingController();
  final _alamatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nomorHpController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await globalApiClient.dio.get('/api/profile');
      if (response.statusCode == 200) {
        final userData = response.data['data'];
        setState(() {
          _name = userData['name']?.toString() ?? '';
          _email = userData['email']?.toString() ?? '';
          _nomorHp = userData['nomor_hp']?.toString() ?? '';
          _alamat = userData['alamat']?.toString() ?? '';
          _roleName = userData['role']?['name']?.toString() ?? 'petambak';
          
          _nameController.text = _name;
          _emailController.text = _email;
          _nomorHpController.text = _nomorHp;
          _alamatController.text = _alamat;
          
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ToastHelper.showError('Gagal mengambil data profil');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ToastHelper.showError('Terjadi kesalahan koneksi');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final Map<String, dynamic> payload = {
        'name': _nameController.text,
        'email': _emailController.text,
        'nomor_hp': _nomorHpController.text,
        'alamat': _alamatController.text,
      };

      final response = await globalApiClient.dio.put('/api/profile', data: payload);
      if (response.statusCode == 200) {
        final userData = response.data['data'];
        setState(() {
          _name = userData['name']?.toString() ?? '';
          _email = userData['email']?.toString() ?? '';
          _nomorHp = userData['nomor_hp']?.toString() ?? '';
          _alamat = userData['alamat']?.toString() ?? '';
          
          _isSaving = false;
        });
        ToastHelper.showSuccess('Profil berhasil diperbarui');
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate profile was updated
        }
      } else {
        setState(() {
          _isSaving = false;
        });
        ToastHelper.showError(response.data['message'] ?? 'Gagal memperbarui profil');
      }
    } on DioException catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (e.response != null && e.response?.data != null) {
        ToastHelper.showError(e.response?.data['message'] ?? 'Gagal memperbarui profil');
      } else {
        ToastHelper.showError('Terjadi kesalahan koneksi');
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      ToastHelper.showError('Terjadi kesalahan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6CD3F7)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 72,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        _roleName.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Name Field
                    _buildTextField(
                      controller: _nameController,
                      label: 'Nama Lengkap',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama lengkap harus diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email harus diisi';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone Field
                    _buildTextField(
                      controller: _nomorHpController,
                      label: 'Nomor WhatsApp / HP',
                      icon: Icons.phone_android_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Address Field
                    _buildTextField(
                      controller: _alamatController,
                      label: 'Alamat',
                      icon: Icons.location_on_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Color(0xFF0B1326), strokeWidth: 2),
                            )
                          : const Text('Simpan Perubahan'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    bool obscureText = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6CD3F7)),
      ),
    );
  }
}

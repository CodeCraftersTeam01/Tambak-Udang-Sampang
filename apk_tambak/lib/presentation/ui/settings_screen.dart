import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/toast_helper.dart';
import '../../main.dart'; // For globalApiClient
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = true;
  bool _alertsEnabled = true;
  String _name = '';
  String _email = '';
  String _roleName = 'petambak';

  @override
  void initState() {
    super.initState();
    _fetchProfile();
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
          _roleName = userData['role']?['name']?.toString() ?? 'petambak';
          _alertsEnabled = userData['alerts_enabled'] == true || userData['alerts_enabled'] == 1;
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

  Future<void> _toggleAlerts(bool value) async {
    setState(() {
      _alertsEnabled = value;
    });

    try {
      final response = await globalApiClient.dio.post('/api/profile/toggle-alerts');
      if (response.statusCode == 200) {
        final returnedValue = response.data['data']['alerts_enabled'] == true;
        setState(() {
          _alertsEnabled = returnedValue;
        });
        ToastHelper.showSuccess(response.data['message'] ?? 'Pengaturan notifikasi diperbarui');
      } else {
        setState(() {
          _alertsEnabled = !value;
        });
        ToastHelper.showError('Gagal memperbarui pengaturan notifikasi');
      }
    } catch (e) {
      setState(() {
        _alertsEnabled = !value;
      });
      ToastHelper.showError('Terjadi kesalahan koneksi');
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF131B2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF1E293B)),
              ),
              title: const Text(
                'Ubah Password',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: currentPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password Lama',
                          prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Password lama harus diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password Baru',
                          prefixIcon: Icon(Icons.lock_reset, color: AppColors.primary),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password baru harus diisi';
                          if (v.length < 6) return 'Password minimal 6 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Konfirmasi Password Baru',
                          prefixIcon: Icon(Icons.lock_clock, color: AppColors.primary),
                        ),
                        validator: (v) {
                          if (v != newPasswordController.text) return 'Password konfirmasi tidak cocok';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            final response = await globalApiClient.dio.put(
                              '/api/profile/change-password',
                              data: {
                                'current_password': currentPasswordController.text,
                                'new_password': newPasswordController.text,
                                'new_password_confirmation': confirmPasswordController.text,
                              },
                            );

                            if (response.statusCode == 200) {
                              ToastHelper.showSuccess('Password berhasil diperbarui');
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            } else {
                              ToastHelper.showError(response.data['message'] ?? 'Gagal mengubah password');
                            }
                          } on DioException catch (e) {
                            final msg = e.response?.data['message'] ?? 'Gagal mengubah password';
                            ToastHelper.showError(msg);
                          } catch (e) {
                            ToastHelper.showError('Terjadi kesalahan');
                          } finally {
                            if (context.mounted) {
                              setDialogState(() {
                                isSaving = false;
                              });
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Color(0xFF0B1326), strokeWidth: 2))
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF131B2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF1E293B)),
          ),
          title: const Text('Keluar dari Akun', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          content: const Text('Apakah Anda yakin ingin keluar dari sistem?', style: TextStyle(color: Color(0xFFDAE2FD))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Color(0xFF94A3B8))),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pengaturan'),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF6CD3F7)))
            : ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  // Profile Header Block
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF131B2E),
                      border: Border.symmetric(
                        horizontal: BorderSide(color: Color(0xFF1E293B)),
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.person, size: 36, color: AppColors.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _email,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _roleName.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Section 1: AKUN
                  _buildSectionHeader('AKUN'),
                  _buildSettingsCard([
                    ListTile(
                      leading: const Icon(Icons.person_outline, color: AppColors.primary),
                      title: const Text('Edit Profil'),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                        ).then((updated) {
                          if (updated == true) {
                            _fetchProfile();
                          }
                        });
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.lock_outline, color: AppColors.primary),
                      title: const Text('Ubah Password'),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: _showChangePasswordDialog,
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // Section 2: PREFERENSI
                  _buildSectionHeader('PREFERENSI'),
                  _buildSettingsCard([
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                      title: const Text('Notifikasi Peringatan'),
                      subtitle: const Text('Terima peringatan sensor via push notification'),
                      value: _alertsEnabled,
                      activeColor: AppColors.primary,
                      onChanged: _toggleAlerts,
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // Section 3: SESI
                  _buildSectionHeader('SESI'),
                  _buildSettingsCard([
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      onTap: _showLogoutDialog,
                    ),
                  ]),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(children: children),
    );
  }
}

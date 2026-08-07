import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../bloc/kolam_bloc.dart';
import '../bloc/kolam_event.dart';
import '../bloc/kolam_state.dart';
import '../../domain/entities/kolam_entity.dart';
import 'pond_detail_screen.dart';
import 'profile_screen.dart';
import 'add_kolam_screen.dart';

import '../widgets/liquid_glass_card.dart';

class KolamListScreen extends StatefulWidget {
  const KolamListScreen({super.key});

  @override
  State<KolamListScreen> createState() => _KolamListScreenState();
}

class _KolamListScreenState extends State<KolamListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<KolamBloc>().add(FetchKolams());
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daftar Kolam',
                      style: TextStyle(
                        color: Color(0xFFDAE2FD),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfileScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6CD3F7).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Color(0xFF6CD3F7)),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Search Bar using LiquidGlassCard
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: LiquidGlassCard(
                  borderRadius: BorderRadius.circular(100),
                  child: const TextField(
                    style: TextStyle(color: Color(0xFFDAE2FD)),
                    decoration: InputDecoration(
                      hintText: 'Cari kolam...',
                      hintStyle: TextStyle(color: Colors.white38),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF6CD3F7)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
              ),
              
              // List
              Expanded(
                child: BlocBuilder<KolamBloc, KolamState>(
                  builder: (context, state) {
                    if (state is KolamLoading || state is KolamInitial) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    } else if (state is KolamError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: AppColors.error, fontSize: 16),
                        ),
                      );
                    } else if (state is KolamLoaded) {
                      final kolams = state.kolams;
                      if (kolams.isEmpty) {
                        return const Center(
                          child: Text(
                            'Belum ada data kolam.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        itemCount: kolams.length,
                        itemBuilder: (context, index) {
                          return _buildKolamCard(kolams[index]);
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddKolamScreen()),
          ).then((_) {
            if (context.mounted) {
              context.read<KolamBloc>().add(FetchKolams());
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildKolamCard(KolamEntity kolam) {
    final images = [
      'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1516257984-b1b4d707412e?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=600&q=80',
    ];
    final imageUrl = images[kolam.id % images.length];

    return LiquidGlassCard(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Header
          Stack(
            children: [
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF6CD3F7).withOpacity(0.2),
                    child: const Center(
                      child: Icon(Icons.water, color: Color(0xFF6CD3F7), size: 50),
                    ),
                  ),
                ),
              ),
              // Status Chip on top-right of image
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF131B2E).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: kolam.status == 1 ? const Color(0xFF6CD3F7) : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        kolam.statusLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDAE2FD),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Info Section
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kolam.nama,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDAE2FD),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildModernInfoRow(Icons.aspect_ratio_rounded, 'Luas', '${kolam.luas} m²'),
                    _buildModernInfoRow(Icons.track_changes_rounded, 'Target', '${kolam.targetPanen} Kg'),
                  ],
                ),
              ],
            ),
          ),
          
          // Button Section
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PondDetailScreen(kolam: kolam),
                  ),
                ).then((_) {
                  if (context.mounted) {
                    context.read<KolamBloc>().add(FetchKolams());
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6CD3F7), Color(0xFF2E3192)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Detail Monitoring',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6CD3F7).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF6CD3F7)),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.white60),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFDAE2FD)),
            ),
          ],
        ),
      ],
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/kolam_entity.dart';
import '../../core/network/mqtt_manager.dart';
import '../../data/datasources/laporan_remote_datasource.dart';
import '../../core/utils/pdf_generator_service.dart';
import '../../main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/kolam_bloc.dart';
import '../bloc/kolam_event.dart';
import '../bloc/kolam_state.dart';
import 'add_kolam_screen.dart';
import 'log_input_screen.dart';
import 'produksi_chart_screen.dart';

class PondDetailScreen extends StatefulWidget {
  final KolamEntity kolam;

  const PondDetailScreen({super.key, required this.kolam});

  @override
  State<PondDetailScreen> createState() => _PondDetailScreenState();
}

class _PondDetailScreenState extends State<PondDetailScreen> {
  late KolamEntity _currentKolam;


  @override
  void initState() {
    super.initState();
    _currentKolam = widget.kolam;
    _currentKolam = widget.kolam;
    if (_currentKolam.mqttId != null && _currentKolam.mqttId!.isNotEmpty) {
      globalMqttManager.connect(_currentKolam.mqttId!);
    }
  }

  @override
  void dispose() {
    // We shouldn't disconnect on dispose if we want background notifications,
    // but for now we follow the existing pattern.
    globalMqttManager.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<KolamBloc, KolamState>(
      listener: (context, state) {
        if (state is KolamDeleteSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kolam berhasil dihapus')),
          );
          Navigator.pop(context); // Go back after delete
        } else if (state is KolamError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            color: Colors.white,
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
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _currentKolam.nama,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddKolamScreen(kolamToEdit: _currentKolam),
                            ),
                          ).then((updatedKolam) {
                            if (context.mounted && updatedKolam != null && updatedKolam is KolamEntity) {
                              setState(() {
                                _currentKolam = updatedKolam;
                                _currentKolam = updatedKolam;
                                if (_currentKolam.mqttId != null && _currentKolam.mqttId!.isNotEmpty) {
                                  globalMqttManager.connect(_currentKolam.mqttId!);
                                }
                              });
                            }
                          });
                        } else if (value == 'delete') {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Hapus Kolam'),
                              content: const Text('Apakah Anda yakin ingin menghapus kolam ini? Data yang dihapus tidak dapat dikembalikan.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close dialog
                                    context.read<KolamBloc>().add(DeleteKolam(_currentKolam.id));
                                  },
                                  child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Edit Kolam'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Hapus Kolam', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<Map<String, dynamic>>(
                  stream: globalMqttManager.sensorDataStream,
                  initialData: const {
                    'suhu': 0.0,
                    'ph': 0.0,
                    'do': 0.0,
                    'tds': 0.0,
                    'aerator': 'OFF',
                  },
                  builder: (context, snapshot) {
          final sensorData = snapshot.data!;
          
          final suhuDouble = (sensorData['suhu'] as num).toDouble();
          final phDouble = (sensorData['ph'] as num).toDouble();
          final doDouble = (sensorData['do'] as num).toDouble();
          final tdsDouble = (sensorData['tds'] as num).toDouble();

          final suhuStyle = _getSuhuStyle(suhuDouble);
          final phStyle = _getPhStyle(phDouble);
          final doStyle = _getDoStyle(doDouble);
          final tdsStyle = _getTdsStyle(tdsDouble);

          final suhu = suhuDouble.toStringAsFixed(1);
          final ph = phDouble.toStringAsFixed(1);
          final doVal = doDouble.toStringAsFixed(1);
          final tdsVal = tdsDouble.toStringAsFixed(0);
          final aeratorState = sensorData['aerator'] == 'ON';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Real-Time Sensor Data',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildSensorCard(
                        title: 'SUHU AIR',
                        value: '$suhu°C',
                        subtitle: 'Status: ${suhuStyle['status']}',
                        icon: Icons.thermostat,
                        isWarning: suhuStyle['status'] != 'Normal',
                        gaugePercentage: (suhuDouble / 50.0).clamp(0.0, 1.0),
                        gaugeType: 'vertical',
                      ),
                      _buildSensorCard(
                        title: 'DISSOLVED OXYGEN',
                        value: '$doVal mg/L',
                        subtitle: 'Status: ${doStyle['status']}',
                        icon: Icons.water,
                        isWarning: doStyle['status'] != 'Aman',
                        gaugePercentage: (doDouble / 20.0).clamp(0.0, 1.0),
                        gaugeType: 'radial',
                      ),
                      _buildSensorCard(
                        title: 'PH AIR',
                        value: ph,
                        subtitle: 'Status: ${phStyle['status']}',
                        icon: Icons.science,
                        isWarning: phStyle['status'] != 'Normal',
                        gaugePercentage: (phDouble / 14.0).clamp(0.0, 1.0),
                        gaugeType: 'horizontal',
                      ),
                      _buildSensorCard(
                        title: 'TDS',
                        value: '$tdsVal PPM',
                        subtitle: 'Status: ${tdsStyle['status']}',
                        icon: Icons.opacity,
                        isWarning: tdsStyle['status'] != 'Normal',
                        gaugePercentage: (tdsDouble / 2000.0).clamp(0.0, 1.0),
                        gaugeType: 'cylinder',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Custom Chart Button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProduksiChartScreen(kolam: _currentKolam),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.show_chart, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'Lihat Grafik Pertumbuhan',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Custom PDF Button
                  GestureDetector(
                    onTap: () async {
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Menyiapkan laporan PDF...')),
                        );
                        final dataSource = LaporanRemoteDataSourceImpl(apiClient: globalApiClient);
                        final data = await dataSource.getLaporan(_currentKolam.id);
                        await PdfGeneratorService.generateAndPrintKolamReport(data);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal membuat laporan: $e')),
                          );
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.picture_as_pdf, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Unduh Laporan PDF',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Aerator Control
                  const Text(
                    'Kontrol Multi-Relay Kincir Air',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Master Switches
                  if (_currentKolam.relays.isNotEmpty)
                    ValueListenableBuilder<Map<String, bool>>(
                      valueListenable: globalMqttManager.relayStatuses,
                      builder: (context, relayStatuses, child) {
                        final isMasterOn = relayStatuses['master'] ?? false;
                        
                        bool isAllOn = true;
                        bool isAllOff = true;
                        if (_currentKolam.relays.isEmpty) {
                          isAllOn = false; 
                          isAllOff = false;
                        } else {
                          for (int i = 1; i <= _currentKolam.relays.length; i++) {
                            final isOn = relayStatuses['$i'] ?? false;
                            if (isOn) isAllOff = false;
                            if (!isOn) isAllOn = false;
                          }
                        }
                        
                        return Column(
                          children: [
                            const Text(
                              'Master Switch (Gateway)',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (_currentKolam.mqttId != null) {
                                        globalMqttManager.publishMasterControl(_currentKolam.mqttId!, true);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isMasterOn ? AppColors.primary : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: isMasterOn ? AppColors.primary : Colors.grey.shade300, width: 2),
                                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text('Master ON', style: TextStyle(color: isMasterOn ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (_currentKolam.mqttId != null) {
                                        globalMqttManager.publishMasterControl(_currentKolam.mqttId!, false);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: !isMasterOn ? AppColors.error : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: !isMasterOn ? AppColors.error : Colors.grey.shade300, width: 2),
                                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text('Master OFF', style: TextStyle(color: !isMasterOn ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Kontrol Masal (Grid)',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      for (int i = 0; i < _currentKolam.relays.length; i++) {
                                        if (_currentKolam.mqttId != null) {
                                          globalMqttManager.publishRelayControl(_currentKolam.mqttId!, i + 1, true);
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isAllOn ? Colors.green : Colors.white,
                                      foregroundColor: isAllOn ? Colors.white : AppColors.primary,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(color: isAllOn ? Colors.green : AppColors.primary, width: 2),
                                      ),
                                    ),
                                    child: const Text('Nyalakan Semua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      for (int i = 0; i < _currentKolam.relays.length; i++) {
                                        if (_currentKolam.mqttId != null) {
                                          globalMqttManager.publishRelayControl(_currentKolam.mqttId!, i + 1, false);
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isAllOff ? Colors.red : Colors.white,
                                      foregroundColor: isAllOff ? Colors.white : Colors.red,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(color: isAllOff ? Colors.red : Colors.red, width: 2),
                                      ),
                                    ),
                                    child: const Text('Matikan Semua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 2.2,
                              children: List.generate(_currentKolam.relays.length, (index) {
                                final relayIndexStr = '${index + 1}';
                                final isOn = relayStatuses[relayIndexStr] ?? false;
                                return GestureDetector(
                                  onTap: () {
                                    if (_currentKolam.mqttId != null) {
                                      globalMqttManager.publishRelayControl(_currentKolam.mqttId!, index + 1, !isOn);
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    decoration: BoxDecoration(
                                      color: isOn ? Colors.green : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: isOn ? Colors.green : Colors.grey.shade300, width: 2),
                                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _currentKolam.relays[index].namaRelay, 
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isOn ? Colors.white : AppColors.primary,
                                          ),
                                        ),
                                        Icon(
                                          isOn ? Icons.power : Icons.power_off,
                                          color: isOn ? Colors.white : AppColors.primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        );
                      },
                    ),

                  
                  const SizedBox(height: 120), // padding for bottom custom FAB
                ],
              ),
            ),
          );
        },
      ),
              ),
            ],
          ), // Column
        ), // SafeArea
      ), // Container body
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          height: 56,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LogInputScreen(kolam: _currentKolam),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
              ),
              alignment: Alignment.center,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_document, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Input Log Harian',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ), // Scaffold
  ); // BlocListener
} // build method

  Map<String, dynamic> _getSuhuStyle(double value) {
    if (value < 25.0) return {'status': 'Dingin'};
    if (value <= 32.0) return {'status': 'Normal'};
    return {'status': 'Panas'};
  }

  Map<String, dynamic> _getDoStyle(double value) {
    if (value < 5.0) return {'status': 'Kritis'};
    return {'status': 'Aman'};
  }

  Map<String, dynamic> _getPhStyle(double value) {
    String status = 'Normal';
    if (value < 7.0) status = 'Asam';
    if (value > 8.5) status = 'Basa';
    return {'status': status};
  }

  Map<String, dynamic> _getTdsStyle(double value) {
    if (value < 1000) return {'status': 'Normal'};
    return {'status': 'Tinggi'};
  }

  Widget _buildSensorCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    bool isWarning = false,
    double? gaugePercentage,
    String? gaugeType,
  }) {
    const textColor = AppColors.textPrimary;
    const secondaryTextColor = AppColors.textSecondary;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.95, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            if (isWarning)
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.warning_rounded,
                  color: Colors.red,
                  size: 18,
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(icon, size: 20, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: secondaryTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          value,
                          key: ValueKey<String>(value),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (gaugePercentage != null && gaugeType == 'horizontal') ...[
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 14,
                          width: double.infinity,
                          child: CustomPaint(
                            painter: HorizontalPhBarPainter(
                              percentage: gaugePercentage,
                              thumbColor: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 10,
                          color: secondaryTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (gaugePercentage != null && gaugeType != 'horizontal') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: gaugeType == 'vertical'
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Center(
                              child: AspectRatio(
                                aspectRatio: 0.3,
                                child: CustomPaint(
                                  painter: VerticalLiquidFillPainter(
                                    percentage: gaugePercentage,
                                    trackColor: Colors.grey.shade200,
                                    progressColor: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : gaugeType == 'cylinder'
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Center(
                                  child: AspectRatio(
                                    aspectRatio: 0.5,
                                    child: CustomPaint(
                                      painter: TdsCylinderPainter(
                                        percentage: gaugePercentage,
                                        trackColor: Colors.grey.shade300,
                                        particleColor: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: AspectRatio(
                                  aspectRatio: 2.0,
                                  child: CustomPaint(
                                    painter: SemiCircleGaugePainter(
                                      percentage: gaugePercentage,
                                      trackColor: Colors.grey.shade200,
                                      progressColor: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SemiCircleGaugePainter extends CustomPainter {
  final double percentage;
  final Color trackColor;
  final Color progressColor;

  SemiCircleGaugePainter({
    required this.percentage,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height); 
    final radius = size.height;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw track (pi to 2*pi)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      trackPaint,
    );

    // Draw progress
    final sweepAngle = math.pi * percentage.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant SemiCircleGaugePainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
           oldDelegate.trackColor != trackColor ||
           oldDelegate.progressColor != progressColor;
  }
}

class VerticalLiquidFillPainter extends CustomPainter {
  final double percentage;
  final Color trackColor;
  final Color progressColor;

  VerticalLiquidFillPainter({
    required this.percentage,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.fill;
    
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.fill;

    // Draw full track as a rounded rectangle
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(20),
    );
    canvas.drawRRect(rect, trackPaint);

    // Calculate height of the progress fill
    final progressHeight = size.height * percentage.clamp(0.0, 1.0);
    if (progressHeight > 0) {
      final progressRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(0, size.height - progressHeight, size.width, progressHeight),
        bottomLeft: const Radius.circular(20),
        bottomRight: const Radius.circular(20),
        topLeft: progressHeight >= size.height - 1 ? const Radius.circular(20) : Radius.zero,
        topRight: progressHeight >= size.height - 1 ? const Radius.circular(20) : Radius.zero,
      );
      canvas.drawRRect(progressRect, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant VerticalLiquidFillPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
           oldDelegate.trackColor != trackColor ||
           oldDelegate.progressColor != progressColor;
  }
}

class HorizontalPhBarPainter extends CustomPainter {
  final double percentage;
  final Color thumbColor;

  HorizontalPhBarPainter({
    required this.percentage,
    required this.thumbColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw gradient bar
    final rect = Rect.fromLTWH(0, size.height / 2 - 4, size.width, 8);
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

    final gradient = const LinearGradient(
      colors: [
        Colors.red,
        Colors.orange,
        Colors.yellow,
        Colors.green,
        Colors.blue,
        Colors.purple,
      ],
    ).createShader(rect);

    final trackPaint = Paint()..shader = gradient;
    canvas.drawRRect(rRect, trackPaint);

    // 2. Draw thumb
    final thumbX = size.width * percentage.clamp(0.0, 1.0);
    final thumbCenter = Offset(thumbX, size.height / 2);
    
    // Draw thumb shadow
    final thumbShadowPaint = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.fill;
    canvas.drawCircle(thumbCenter, 7, thumbShadowPaint);
    
    // Draw outer border (white for contrast)
    final thumbBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(thumbCenter, 6, thumbBorderPaint);

    // Draw inner thumb core
    final thumbCorePaint = Paint()
      ..color = thumbColor == Colors.white ? AppColors.primary : thumbColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(thumbCenter, 4, thumbCorePaint);
  }

  @override
  bool shouldRepaint(covariant HorizontalPhBarPainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.thumbColor != thumbColor;
  }
}

class TdsCylinderPainter extends CustomPainter {
  final double percentage;
  final Color trackColor;
  final Color particleColor;

  TdsCylinderPainter({
    required this.percentage,
    required this.trackColor,
    required this.particleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = trackColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height - 8)
      ..arcToPoint(Offset(8, size.height), radius: const Radius.circular(8), clockwise: false)
      ..lineTo(size.width - 8, size.height)
      ..arcToPoint(Offset(size.width, size.height - 8), radius: const Radius.circular(8), clockwise: false)
      ..lineTo(size.width, 0);

    canvas.drawPath(path, paintLine);

    for (int i = 1; i <= 4; i++) {
      final y = size.height * (i / 5);
      canvas.drawLine(
        Offset(size.width - 6, y),
        Offset(size.width, y),
        paintLine,
      );
    }

    if (percentage > 0) {
      final fillHeight = (size.height - 4) * percentage.clamp(0.0, 1.0);
      
      final particlePaint = Paint()
        ..color = particleColor
        ..style = PaintingStyle.fill;

      canvas.save();
      
      final fillPath = Path()
        ..moveTo(0, size.height - fillHeight)
        ..lineTo(0, size.height - 8)
        ..arcToPoint(Offset(8, size.height), radius: const Radius.circular(8), clockwise: false)
        ..lineTo(size.width - 8, size.height)
        ..arcToPoint(Offset(size.width, size.height - 8), radius: const Radius.circular(8), clockwise: false)
        ..lineTo(size.width, size.height - fillHeight)
        ..close();

      canvas.clipPath(fillPath);

      final random = math.Random(42); 
      final numParticles = (60 * percentage).toInt() + 10; 

      for (int i = 0; i < numParticles; i++) {
        final x = random.nextDouble() * size.width;
        final y = size.height - (random.nextDouble() * fillHeight);
        final r = random.nextDouble() * 2 + 1; 
        canvas.drawCircle(Offset(x, y), r, particlePaint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant TdsCylinderPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
           oldDelegate.trackColor != trackColor ||
           oldDelegate.particleColor != particleColor;
  }
}




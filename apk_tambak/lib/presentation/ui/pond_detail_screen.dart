import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/kolam_entity.dart';
import '../../core/network/mqtt_manager.dart';
import '../../data/datasources/laporan_remote_datasource.dart';
import '../../core/utils/pdf_generator_service.dart';
import '../../main.dart';
import 'log_input_screen.dart';
import 'produksi_chart_screen.dart';

class PondDetailScreen extends StatefulWidget {
  final KolamEntity kolam;

  const PondDetailScreen({super.key, required this.kolam});

  @override
  State<PondDetailScreen> createState() => _PondDetailScreenState();
}

class _PondDetailScreenState extends State<PondDetailScreen> {

  @override
  void initState() {
    super.initState();
    globalMqttManager.connect();
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.kolam.nama,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: StreamBuilder<Map<String, dynamic>>(
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
          
          final suhu = (sensorData['suhu'] as num).toStringAsFixed(1);
          final ph = (sensorData['ph'] as num).toStringAsFixed(1);
          final doVal = (sensorData['do'] as num).toStringAsFixed(1);
          final tdsVal = (sensorData['tds'] as num).toStringAsFixed(0);
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
                        subtitle: 'Status: Normal',
                        icon: Icons.thermostat,
                      ),
                      _buildSensorCard(
                        title: 'DISSOLVED OXYGEN',
                        value: '$doVal mg/L',
                        subtitle: 'Range Aman > 5.0',
                        icon: Icons.water,
                      ),
                      _buildSensorCard(
                        title: 'PH AIR',
                        value: ph,
                        subtitle: 'Range Ideal 7.5 - 8.5',
                        icon: Icons.science,
                      ),
                      _buildSensorCard(
                        title: 'TDS',
                        value: tdsVal,
                        subtitle: 'Air Normal',
                        icon: Icons.opacity,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProduksiChartScreen(kolam: widget.kolam),
                        ),
                      );
                    },
                    icon: const Icon(Icons.show_chart),
                    label: const Text('Lihat Grafik Pertumbuhan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Menyiapkan laporan PDF...')),
                        );
                        final dataSource = LaporanRemoteDataSourceImpl(apiClient: globalApiClient);
                        final data = await dataSource.getLaporan(widget.kolam.id);
                        await PdfGeneratorService.generateAndPrintKolamReport(data);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal membuat laporan: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Unduh Laporan PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Aerator Control
                  const Text(
                    'Kontrol Perangkat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.wind_power, color: AppColors.primary),
                            ),
                            const SizedBox(width: 16),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kincir Air (Aerator)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Manual Override',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: aeratorState,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) {
                            globalMqttManager.publishAeratorControl(val);
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 100), // padding for bottom FAB
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          width: double.infinity,
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LogInputScreen(kolam: widget.kolam),
                ),
              );
            },
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            elevation: 4,
            icon: const Icon(Icons.edit_document),
            label: const Text(
              'Input Log Harian',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSensorCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

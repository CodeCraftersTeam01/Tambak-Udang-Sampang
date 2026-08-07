import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/kolam_entity.dart';
import '../../core/network/mqtt_manager.dart';
import '../../data/datasources/laporan_remote_datasource.dart';
import '../../data/datasources/monitoring_remote_datasource.dart';
import '../../core/utils/pdf_generator_service.dart';
import '../../main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/kolam_bloc.dart';
import '../bloc/kolam_event.dart';
import '../bloc/kolam_state.dart';
import 'add_kolam_screen.dart';
import 'log_input_screen.dart';
import 'produksi_chart_screen.dart';
import 'threshold_settings_screen.dart';
import 'calibration_settings_screen.dart';
import '../widgets/liquid_glass_card.dart';

class PondDetailScreen extends StatefulWidget {
  final KolamEntity kolam;

  const PondDetailScreen({super.key, required this.kolam});

  @override
  State<PondDetailScreen> createState() => _PondDetailScreenState();
}

class _PondDetailScreenState extends State<PondDetailScreen> {
  late KolamEntity _currentKolam;
  final List<double> _suhuHistory = [];
  final List<double> _phHistory = [];
  final List<double> _doHistory = [];
  final List<double> _tdsHistory = [];
  StreamSubscription<Map<String, dynamic>>? _sensorDataSubscription;
  StateSetter? _modalStateSetter;



  Future<void> _hydrateInitialData() async {
    try {
      final dataSource = MonitoringRemoteDataSourceImpl(apiClient: globalApiClient);
      final response = await dataSource.getLatestMonitoring(_currentKolam.id);
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final sensors = data['sensors'] as List<dynamic>?;
        if (sensors != null) {
          final Map<String, dynamic> mappedData = {};
          for (var s in sensors) {
            final code = s['code'] as String?;
            final val = s['value'];
            if (code != null && val != null) {
              if (code == 'temperature') {
                mappedData['suhu'] = val;
              } else if (code == 'ph') {
                mappedData['ph'] = val;
              } else if (code == 'do') {
                mappedData['do'] = val;
              } else if (code == 'tds') {
                mappedData['tds'] = val;
              }
            }
          }
          globalMqttManager.updateState(mappedData);
        }
      }

      final historyResponse = await dataSource.getSensorHistory(_currentKolam.id);
      if (historyResponse['success'] == true && historyResponse['data'] != null) {
        final historyData = historyResponse['data']['history'] as Map<String, dynamic>?;
        if (historyData != null) {
          void _populateHistory(List<double> buffer, List<dynamic>? list) {
            buffer.clear();
            if (list != null) {
              for (var item in list) {
                final val = item['value'];
                if (val != null) {
                  buffer.add((val as num).toDouble());
                }
              }
              while (buffer.length > 150) {
                buffer.removeAt(0);
              }
            }
          }
          setState(() {
            _populateHistory(_suhuHistory, historyData['temperature']);
            _populateHistory(_phHistory, historyData['ph']);
            _populateHistory(_doHistory, historyData['do']);
            _populateHistory(_tdsHistory, historyData['tds']);
          });
        }
      }
    } catch (e) {
      debugPrint('Error hydrating initial monitoring data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _currentKolam = widget.kolam;
    _hydrateInitialData();
    if (_currentKolam.mqttId != null && _currentKolam.mqttId!.isNotEmpty) {
      globalMqttManager.connect(_currentKolam.mqttId!);
    }



    _sensorDataSubscription = globalMqttManager.sensorDataStream.listen((data) {
      if (mounted) {
        setState(() {
          void _updateBuffer(List<double> buffer, dynamic val) {
            if (val == null) return;
            if (val is String && val.toUpperCase() == 'ERROR') return;
            final doubleVal = val is num ? val.toDouble() : double.tryParse(val.toString());
            if (doubleVal != null) {
              buffer.add(doubleVal);
              if (buffer.length > 150) {
                buffer.removeAt(0);
              }
            }
          }
          _updateBuffer(_suhuHistory, data['suhu']);
          _updateBuffer(_phHistory, data['ph']);
          _updateBuffer(_doHistory, data['do']);
          _updateBuffer(_tdsHistory, data['tds']);
        });
        _modalStateSetter?.call(() {});
      }
    });
  }

  @override
  void dispose() {
    _sensorDataSubscription?.cancel();
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
        backgroundColor: const Color(0xFF0B1326), // Dark Navy
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
            
            bool checkError(dynamic val) {
              if (val == null) return false;
              if (val is String && val.toUpperCase() == 'ERROR') return true;
              return false;
            }

            double getDoubleVal(dynamic val) {
              if (val == null) return 0.0;
              if (val is num) return val.toDouble();
              if (val is String) {
                return double.tryParse(val) ?? 0.0;
              }
              return 0.0;
            }

            final isSuhuError = checkError(sensorData['suhu']);
            final isPhError = checkError(sensorData['ph']);
            final isDoError = checkError(sensorData['do']);
            final isTdsError = checkError(sensorData['tds']);

            final suhuDouble = isSuhuError ? 0.0 : getDoubleVal(sensorData['suhu']);
            final phDouble = isPhError ? 0.0 : getDoubleVal(sensorData['ph']);
            final doDouble = isDoError ? 0.0 : getDoubleVal(sensorData['do']);
            final tdsDouble = isTdsError ? 0.0 : getDoubleVal(sensorData['tds']);

            final suhuStyle = isSuhuError ? {'status': 'Error'} : _getSuhuStyle(suhuDouble);
            final phStyle = isPhError ? {'status': 'Error'} : _getPhStyle(phDouble);
            final doStyle = isDoError ? {'status': 'Error'} : _getDoStyle(doDouble);
            final tdsStyle = isTdsError ? {'status': 'Error'} : _getTdsStyle(tdsDouble);

            final suhu = isSuhuError ? 'Sensor Error' : '${suhuDouble.toStringAsFixed(1)}°C';
            final ph = isPhError ? 'Sensor Error' : phDouble.toStringAsFixed(1);
            final doVal = isDoError ? 'Sensor Error' : '${doDouble.toStringAsFixed(1)} mg/L';
            final tdsVal = isTdsError ? 'Sensor Error' : '${tdsDouble.toStringAsFixed(0)} PPM';



            return CustomScrollView(
              slivers: [
                      SliverAppBar(
                        expandedHeight: 250.0,
                        pinned: true,
                        stretch: true,
                        backgroundColor: const Color(0xFF0B1326),
                        iconTheme: const IconThemeData(color: Colors.white),
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: const BoxDecoration(
                        color: Colors.black38,
                        shape: BoxShape.circle,
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
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
                                  if (_currentKolam.mqttId != null && _currentKolam.mqttId!.isNotEmpty) {
                                    globalMqttManager.connect(_currentKolam.mqttId!);
                                  }
                                });
                              }
                            });
                          } else if (value == 'threshold') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ThresholdSettingsScreen(
                                  pondId: _currentKolam.id,
                                  pondName: _currentKolam.nama,
                                ),
                              ),
                            );
                          } else if (value == 'calibration') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CalibrationSettingsScreen(
                                  pondId: _currentKolam.id,
                                  pondName: _currentKolam.nama,
                                ),
                              ),
                            );
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
                            value: 'threshold',
                            child: Text('Batas Parameter Sensor'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'calibration',
                            child: Text('Kalibrasi Sensor'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Hapus Kolam', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Builder(
                      builder: (context) {
                        final images = [
                          'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=600&q=80',
                          'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?auto=format&fit=crop&w=600&q=80',
                          'https://images.unsplash.com/photo-1516257984-b1b4d707412e?auto=format&fit=crop&w=600&q=80',
                          'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=600&q=80',
                        ];
                        final defaultImageUrl = images[_currentKolam.id % images.length];
                        final imageUrl = _currentKolam.imageUrl ?? defaultImageUrl;
                        return Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF131B2E),
                            child: const Center(
                              child: Icon(Icons.water, color: Color(0xFF6CD3F7), size: 50),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _currentKolam.nama.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFDAE2FD),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${_currentKolam.statusLabel} • Luas: ${_currentKolam.luas} m²',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white60,
                          ),
                        ),
                        const Divider(height: 32, thickness: 1, color: Colors.white10),
                        const Text(
                          'Real-Time Sensor Data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDAE2FD),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 170,
                    ),
                    delegate: SliverChildListDelegate([
                      _buildSensorCard(
                        title: 'SUHU AIR',
                        value: suhu,
                        subtitle: 'Status: ${suhuStyle['status']}',
                        icon: Icons.thermostat,
                        isWarning: isSuhuError || suhuStyle['status'] != 'Normal',
                        gaugePercentage: isSuhuError ? null : (suhuDouble / 50.0).clamp(0.0, 1.0),
                        gaugeType: 'vertical',
                        onTap: () => _showSensorHistoryModal('SUHU AIR', _suhuHistory, '°C', Icons.thermostat),
                      ),
                      _buildSensorCard(
                        title: 'DISSOLVED OXYGEN',
                        value: doVal,
                        subtitle: 'Status: ${doStyle['status']}',
                        icon: Icons.water,
                        isWarning: isDoError || doStyle['status'] != 'Aman',
                        gaugePercentage: isDoError ? null : (doDouble / 20.0).clamp(0.0, 1.0),
                        gaugeType: 'radial',
                        onTap: () => _showSensorHistoryModal('DISSOLVED OXYGEN', _doHistory, 'mg/L', Icons.water),
                      ),
                      _buildSensorCard(
                        title: 'PH AIR',
                        value: ph,
                        subtitle: 'Status: ${phStyle['status']}',
                        icon: Icons.science,
                        isWarning: isPhError || phStyle['status'] != 'Normal',
                        gaugePercentage: isPhError ? null : (phDouble / 14.0).clamp(0.0, 1.0),
                        gaugeType: 'horizontal',
                        onTap: () => _showSensorHistoryModal('PH AIR', _phHistory, 'pH', Icons.science),
                      ),
                      _buildSensorCard(
                        title: 'TDS',
                        value: tdsVal,
                        subtitle: 'Status: ${tdsStyle['status']}',
                        icon: Icons.opacity,
                        isWarning: isTdsError || tdsStyle['status'] != 'Normal',
                        gaugePercentage: isTdsError ? null : (tdsDouble / 2000.0).clamp(0.0, 1.0),
                        gaugeType: 'cylinder',
                        onTap: () => _showSensorHistoryModal('TDS', _tdsHistory, 'PPM', Icons.opacity),
                      ),
                    ]),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            alignment: Alignment.center,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.show_chart, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Lihat Grafik Pertumbuhan',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LogInputScreen(kolam: _currentKolam),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2E3192), Color(0xFF1B1464)],
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
                                Icon(Icons.edit_document, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Input Log Harian',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Kontrol Multi-Relay Kincir Air',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                if (_currentKolam.relays.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: ValueListenableBuilder<Map<String, bool>>(
                      valueListenable: globalMqttManager.relayStatuses,
                      builder: (context, relayStatuses, child) {
                        return SliverList(
                          delegate: SliverChildListDelegate([
                            const Text(
                              'Kontrol Masal (Grid)',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFDAE2FD)),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      for (int i = 0; i < _currentKolam.relays.length; i++) {
                                        if (_currentKolam.mqttId != null) {
                                          globalMqttManager.publishRelayControl(_currentKolam.mqttId!, i + 1, true);
                                        }
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF6CD3F7), Color(0xFF2E3192)],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'Nyalakan Semua',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      for (int i = 0; i < _currentKolam.relays.length; i++) {
                                        if (_currentKolam.mqttId != null) {
                                          globalMqttManager.publishRelayControl(_currentKolam.mqttId!, i + 1, false);
                                        }
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF131B2E),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.red.withOpacity(0.5)),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'Matikan Semua',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ]),
                        );
                      },
                    ),
                  ),
                if (_currentKolam.relays.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: ValueListenableBuilder<Map<String, bool>>(
                      valueListenable: globalMqttManager.relayStatuses,
                      builder: (context, relayStatuses, child) {
                        return SliverToBoxAdapter(
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _currentKolam.relays.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              mainAxisExtent: 80,
                            ),
                            itemBuilder: (context, index) {
                              final relayIndexStr = '${index + 1}';
                              final isOn = relayStatuses[relayIndexStr] ?? false;
                              return GestureDetector(
                                onTap: () {
                                  if (_currentKolam.mqttId != null) {
                                    globalMqttManager.publishRelayControl(_currentKolam.mqttId!, index + 1, !isOn);
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: isOn
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFF6CD3F7).withOpacity(0.3),
                                              blurRadius: 12,
                                              spreadRadius: 1,
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: LiquidGlassCard(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isOn ? const Color(0xFF6CD3F7) : Colors.white.withOpacity(0.1),
                                          width: isOn ? 1.5 : 1.0,
                                        ),
                                        color: isOn ? const Color(0xFF6CD3F7).withOpacity(0.1) : Colors.transparent,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              _currentKolam.relays[index].namaRelay, 
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isOn ? const Color(0xFF6CD3F7) : const Color(0xFFDAE2FD).withOpacity(0.6),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Icon(
                                            isOn ? Icons.power : Icons.power_off,
                                            color: isOn ? const Color(0xFF6CD3F7) : Colors.white24,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              ],
            );
          },
        ),

      ),
    );
  }

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

  void _showSensorHistoryModal(String title, List<double> buffer, String unit, IconData icon) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            _modalStateSetter = setModalState;

            final hasData = buffer.isNotEmpty;
            final high = hasData ? buffer.reduce(math.max) : 0.0;
            final low = hasData ? buffer.reduce(math.min) : 0.0;
            final avg = hasData ? (buffer.reduce((a, b) => a + b) / buffer.length) : 0.0;

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: AppColors.primary, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem('Tertinggi', hasData ? '${high.toStringAsFixed(1)} $unit' : '-'),
                        _buildSummaryItem('Terendah', hasData ? '${low.toStringAsFixed(1)} $unit' : '-'),
                        _buildSummaryItem('Rata-rata', hasData ? '${avg.toStringAsFixed(1)} $unit' : '-'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Grafik 5 Menit Terakhir (150 Data)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 180,
                      child: hasData
                          ? (() {
                              double? minThreshold;
                              double? maxThreshold;
                              if (title.toUpperCase().contains('SUHU')) {
                                minThreshold = 26.0;
                                maxThreshold = 32.0;
                              } else if (title.toUpperCase().contains('PH')) {
                                minThreshold = 7.0;
                                maxThreshold = 8.5;
                              } else if (title.toUpperCase().contains('DO') || title.toUpperCase().contains('OKSIGEN')) {
                                minThreshold = 5.0;
                              } else if (title.toUpperCase().contains('TDS') || title.toUpperCase().contains('SALIN')) {
                                maxThreshold = 1000.0;
                              }

                              bool hasBreached = false;
                              for (var val in buffer) {
                                if (minThreshold != null && val < minThreshold) {
                                  hasBreached = true;
                                  break;
                                }
                                if (maxThreshold != null && val > maxThreshold) {
                                  hasBreached = true;
                                  break;
                                }
                              }

                              final lineColor = hasBreached ? Colors.red : AppColors.primary;
                              final areaColor = hasBreached ? Colors.red.withOpacity(0.15) : AppColors.primary.withOpacity(0.1);

                              return LineChart(
                                LineChartData(
                                  gridData: const FlGridData(show: false),
                                  titlesData: const FlTitlesData(
                                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40,
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  extraLinesData: ExtraLinesData(
                                    horizontalLines: [
                                      if (minThreshold != null)
                                        HorizontalLine(
                                          y: minThreshold,
                                          color: Colors.red.withOpacity(0.5),
                                          strokeWidth: 1.5,
                                          dashArray: [5, 5],
                                          label: HorizontalLineLabel(
                                            show: true,
                                            alignment: Alignment.topRight,
                                            style: const TextStyle(fontSize: 9, color: Colors.red, fontWeight: FontWeight.bold),
                                            labelResolver: (line) => 'Min: $minThreshold',
                                          ),
                                        ),
                                      if (maxThreshold != null)
                                        HorizontalLine(
                                          y: maxThreshold,
                                          color: Colors.red.withOpacity(0.5),
                                          strokeWidth: 1.5,
                                          dashArray: [5, 5],
                                          label: HorizontalLineLabel(
                                            show: true,
                                            alignment: Alignment.topRight,
                                            style: const TextStyle(fontSize: 9, color: Colors.red, fontWeight: FontWeight.bold),
                                            labelResolver: (line) => 'Max: $maxThreshold',
                                          ),
                                        ),
                                    ],
                                  ),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: buffer.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                                      isCurved: true,
                                      color: lineColor,
                                      barWidth: 3,
                                      dotData: const FlDotData(show: false),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: areaColor,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            })()
                          : const Center(
                              child: Text('Belum ada riwayat data', style: TextStyle(color: AppColors.textSecondary)),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      _modalStateSetter = null;
    });
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildSensorCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    bool isWarning = false,
    double? gaugePercentage,
    String? gaugeType,
    VoidCallback? onTap,
  }) {
    const textColor = Color(0xFFDAE2FD);
    const secondaryTextColor = Colors.white60;

    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.95, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: LiquidGlassCard(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(icon, size: 20, color: const Color(0xFF6CD3F7)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: secondaryTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isWarning) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.warning_rounded,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              child: Text(
                                value,
                                key: ValueKey<String>(value),
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (gaugePercentage != null && gaugeType == 'horizontal') ...[
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 10,
                          width: double.infinity,
                          child: CustomPaint(
                            painter: HorizontalPhBarPainter(
                              percentage: gaugePercentage,
                              thumbColor: const Color(0xFF6CD3F7),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: secondaryTextColor,
                        ),
                        maxLines: 1,
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
                                    trackColor: Colors.white12,
                                    progressColor: const Color(0xFF6CD3F7),
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
                                        trackColor: Colors.white24,
                                        particleColor: const Color(0xFF6CD3F7),
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
                                      trackColor: Colors.white12,
                                      progressColor: const Color(0xFF6CD3F7),
                                    ),
                                  ),
                                ),
                              ),
                  ),
                ],
              ],
            ),
          ),
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






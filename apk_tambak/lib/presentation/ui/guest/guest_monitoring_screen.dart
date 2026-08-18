import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/mqtt_manager.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../data/repositories/local_guest_repository.dart';
import '../../widgets/liquid_glass_card.dart';

class GuestMonitoringScreen extends StatefulWidget {
  final LocalPond pond;

  const GuestMonitoringScreen({super.key, required this.pond});

  @override
  State<GuestMonitoringScreen> createState() => _GuestMonitoringScreenState();
}

class _GuestMonitoringScreenState extends State<GuestMonitoringScreen> {
  StreamSubscription<Map<String, dynamic>>? _sensorDataSubscription;
  Timer? _feedbackTimer;
  bool _relayState = false;
  bool _isWaitingForFeedback = false;
  bool _targetRelayState = false;

  Map<String, dynamic> _sensorData = {
    'suhu': 0.0,
    'ph': 0.0,
    'do': 0.0,
    'tds': 0.0,
  };

  @override
  void initState() {
    super.initState();
    final cleanMqttId = widget.pond.mqttId.startsWith('pkm2026/')
        ? widget.pond.mqttId.substring('pkm2026/'.length)
        : widget.pond.mqttId;

    _connectMqtt(cleanMqttId);

    _sensorDataSubscription = globalMqttManager.sensorDataStream.listen((data) {
      if (mounted) {
        setState(() {
          _sensorData = data;
        });
      }
    });

    globalMqttManager.relayStatuses.addListener(_onRelayStatusesChanged);

    // Hydrate initial state
    final currentStatuses = globalMqttManager.relayStatuses.value;
    if (currentStatuses['1'] != null) {
      _relayState = currentStatuses['1']!;
    }
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    _sensorDataSubscription?.cancel();
    globalMqttManager.relayStatuses.removeListener(_onRelayStatusesChanged);
    globalMqttManager.disconnect();
    super.dispose();
  }

  Future<void> _connectMqtt(String mqttId) async {
    try {
      await globalMqttManager.connect(mqttId);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError('Gagal terhubung ke MQTT Broker');
      }
    }
  }

  void _onRelayStatusesChanged() {
    if (!mounted) return;
    final currentStatuses = globalMqttManager.relayStatuses.value;
    final bool? isCurrentlyOn = currentStatuses['1'];
    if (isCurrentlyOn != null) {
      if (_isWaitingForFeedback) {
        if (isCurrentlyOn == _targetRelayState) {
          _feedbackTimer?.cancel();
          setState(() {
            _isWaitingForFeedback = false;
            _relayState = isCurrentlyOn;
          });
        }
      } else {
        setState(() {
          _relayState = isCurrentlyOn;
        });
      }
    }
  }

  Future<void> _toggleRelay() async {
    if (_isWaitingForFeedback) return;
    if (!globalMqttManager.isConnected) {
      ToastHelper.showError('Terputus dari broker MQTT. Menghubungkan ulang...');
      final cleanMqttId = widget.pond.mqttId.startsWith('pkm2026/')
          ? widget.pond.mqttId.substring('pkm2026/'.length)
          : widget.pond.mqttId;
      _connectMqtt(cleanMqttId);
      return;
    }

    final bool nextState = !_relayState;
    final cleanMqttId = widget.pond.mqttId.startsWith('pkm2026/')
        ? widget.pond.mqttId.substring('pkm2026/'.length)
        : widget.pond.mqttId;

    setState(() {
      _isWaitingForFeedback = true;
      _targetRelayState = nextState;
    });

    // Send control packet via MQTT
    globalMqttManager.publishRelayControl(cleanMqttId, 1, nextState);

    // 5 seconds timeout fallback
    _feedbackTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _isWaitingForFeedback) {
        setState(() {
          _isWaitingForFeedback = false;
        });
        ToastHelper.showError('Kincir Utama tidak merespon (Timeout 5s)');
      }
    });
  }

  double _getDoubleVal(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) {
      return double.tryParse(val) ?? 0.0;
    }
    return 0.0;
  }

  bool _checkError(dynamic val) {
    if (val == null) return false;
    return val.toString().toUpperCase() == 'ERROR';
  }

  Map<String, dynamic> _getSuhuStyle(double value) {
    if (value < 25.0) return {'status': 'Dingin', 'isWarning': true};
    if (value <= 32.0) return {'status': 'Normal', 'isWarning': false};
    return {'status': 'Panas', 'isWarning': true};
  }

  Map<String, dynamic> _getDoStyle(double value) {
    if (value < 5.0) return {'status': 'Kritis', 'isWarning': true};
    return {'status': 'Aman', 'isWarning': false};
  }

  Map<String, dynamic> _getPhStyle(double value) {
    if (value < 7.0) return {'status': 'Asam', 'isWarning': true};
    if (value > 8.5) return {'status': 'Basa', 'isWarning': true};
    return {'status': 'Normal', 'isWarning': false};
  }

  Map<String, dynamic> _getTdsStyle(double value) {
    if (value < 1000) return {'status': 'Normal', 'isWarning': false};
    return {'status': 'Tinggi', 'isWarning': true};
  }

  Widget _buildTelemetryCard({
    required String title,
    required String value,
    required String status,
    required IconData icon,
    required bool isWarning,
    required double progress,
    required Color accentColor,
  }) {
    return LiquidGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: accentColor, size: 24),
                if (isWarning)
                  const Icon(Icons.warning_rounded, color: Colors.redAccent, size: 20)
                else
                  Icon(Icons.check_circle_outline, color: Colors.green.shade400, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Status: $status',
                  style: TextStyle(
                    fontSize: 11,
                    color: isWarning ? Colors.redAccent : AppColors.textSecondary,
                    fontWeight: isWarning ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSuhuError = _checkError(_sensorData['suhu']);
    final isPhError = _checkError(_sensorData['ph']);
    final isDoError = _checkError(_sensorData['do']);
    final isTdsError = _checkError(_sensorData['tds']);

    final suhuDouble = isSuhuError ? 0.0 : _getDoubleVal(_sensorData['suhu']);
    final phDouble = isPhError ? 0.0 : _getDoubleVal(_sensorData['ph']);
    final doDouble = isDoError ? 0.0 : _getDoubleVal(_sensorData['do']);
    final tdsDouble = isTdsError ? 0.0 : _getDoubleVal(_sensorData['tds']);

    final suhuStyle = isSuhuError ? {'status': 'Error', 'isWarning': true} : _getSuhuStyle(suhuDouble);
    final phStyle = isPhError ? {'status': 'Error', 'isWarning': true} : _getPhStyle(phDouble);
    final doStyle = isDoError ? {'status': 'Error', 'isWarning': true} : _getDoStyle(doDouble);
    final tdsStyle = isTdsError ? {'status': 'Error', 'isWarning': true} : _getTdsStyle(tdsDouble);

    final suhuVal = isSuhuError ? 'Error' : '${suhuDouble.toStringAsFixed(1)}°C';
    final phVal = isPhError ? 'Error' : phDouble.toStringAsFixed(1);
    final doVal = isDoError ? 'Error' : '${doDouble.toStringAsFixed(1)} mg/L';
    final tdsVal = isTdsError ? 'Error' : '${tdsDouble.toStringAsFixed(0)} PPM';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.pond.namaKolam),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber, width: 1),
            ),
            child: const Center(
              child: Text(
                'Mode Lokal',
                style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // MQTT connection banner status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: globalMqttManager.isConnected
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: globalMqttManager.isConnected ? Colors.green.shade700 : Colors.red.shade700,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    globalMqttManager.isConnected ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
                    color: globalMqttManager.isConnected ? Colors.green.shade400 : Colors.red.shade400,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      globalMqttManager.isConnected
                          ? 'Terhubung ke Broker (Menerima Data)'
                          : 'Terputus dari Broker. Menghubungkan kembali...',
                      style: TextStyle(
                        color: globalMqttManager.isConnected ? Colors.green.shade200 : Colors.red.shade200,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Grid Telemetri
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.95,
              children: [
                _buildTelemetryCard(
                  title: 'SUHU AIR',
                  value: suhuVal,
                  status: suhuStyle['status'],
                  icon: Icons.thermostat,
                  isWarning: suhuStyle['isWarning'],
                  progress: isSuhuError ? 0.0 : (suhuDouble / 50.0),
                  accentColor: const Color(0xFF6CD3F7),
                ),
                _buildTelemetryCard(
                  title: 'DISSOLVED OXYGEN',
                  value: doVal,
                  status: doStyle['status'],
                  icon: Icons.opacity,
                  isWarning: doStyle['isWarning'],
                  progress: isDoError ? 0.0 : (doDouble / 20.0),
                  accentColor: Colors.tealAccent,
                ),
                _buildTelemetryCard(
                  title: 'PH AIR',
                  value: phVal,
                  status: phStyle['status'],
                  icon: Icons.science_outlined,
                  isWarning: phStyle['isWarning'],
                  progress: isPhError ? 0.0 : (phDouble / 14.0),
                  accentColor: Colors.amberAccent,
                ),
                _buildTelemetryCard(
                  title: 'TDS AIR',
                  value: tdsVal,
                  status: tdsStyle['status'],
                  icon: Icons.water_drop_outlined,
                  isWarning: tdsStyle['isWarning'],
                  progress: isTdsError ? 0.0 : (tdsDouble / 2000.0),
                  accentColor: Colors.purpleAccent,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Control Panel
            const Text(
              'PENGATURAN KINCIR (DIRECT CONTROL)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _relayState
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _relayState ? AppColors.primary : Colors.white12,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.settings_input_component,
                        color: _relayState ? AppColors.primary : AppColors.textSecondary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kincir Utama',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isWaitingForFeedback
                                ? 'Mengirim perintah...'
                                : _relayState
                                    ? 'Status: Hidup'
                                    : 'Status: Mati',
                            style: TextStyle(
                              color: _isWaitingForFeedback
                                  ? Colors.amberAccent
                                  : _relayState
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isWaitingForFeedback ? null : _toggleRelay,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isWaitingForFeedback
                            ? Colors.white10
                            : _relayState
                                ? Colors.redAccent.withValues(alpha: 0.2)
                                : AppColors.primary,
                        foregroundColor: _relayState ? Colors.redAccent : Colors.black,
                        side: _relayState
                            ? const BorderSide(color: Colors.redAccent)
                            : BorderSide.none,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isWaitingForFeedback
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.amberAccent,
                              ),
                            )
                          : Text(
                              _relayState ? 'MATIKAN' : 'HIDUPKAN',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

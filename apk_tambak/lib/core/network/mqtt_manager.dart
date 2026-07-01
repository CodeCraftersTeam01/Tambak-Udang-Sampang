import 'dart:async';
import 'dart:math';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttManager {
  static final MqttManager _instance = MqttManager._internal();
  factory MqttManager() => _instance;
  MqttManager._internal();

  MqttServerClient? _client;
  
  final _sensorDataController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get sensorDataStream => _sensorDataController.stream;

  Map<String, dynamic> get latestData => Map.unmodifiable(_currentState);

  // Store current state to emit full map on partial updates
  final Map<String, dynamic> _currentState = {
    'suhu': 0.0,
    'ph': 0.0,
    'do': 0.0,
    'tds': 0.0,
    'aerator': 'OFF',
  };

  Future<void> connect() async {
    if (_client != null && _client!.connectionStatus!.state == MqttConnectionState.connected) {
      return;
    }

    final randomId = 'flutter_client_${Random().nextInt(999999)}';
    _client = MqttServerClient('m-tech.fun', randomId);
    _client!.port = 1883;
    _client!.logging(on: false);
    _client!.keepAlivePeriod = 60;
    _client!.onDisconnected = _onDisconnected;
    _client!.onConnected = _onConnected;
    
    final connMess = MqttConnectMessage()
        .withClientIdentifier(randomId)
        .authenticateAs('mhs1', 'mhs123')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    
    _client!.connectionMessage = connMess;

    try {
      await _client!.connect();
    } catch (e) {
      _client!.disconnect();
      return;
    }

    if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
      _client!.subscribe('pkm2026/t01/#', MqttQos.atMostOnce);
      
      _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final recMess = c[0].payload as MqttPublishMessage;
        final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        final topic = c[0].topic;

        _handlePayload(topic, pt);
      });
    }
  }

  void _handlePayload(String topic, String payload) {
    if (topic == 'pkm2026/t01/suhu') {
      _currentState['suhu'] = double.tryParse(payload) ?? _currentState['suhu'];
    } else if (topic == 'pkm2026/t01/ph') {
      _currentState['ph'] = double.tryParse(payload) ?? _currentState['ph'];
    } else if (topic == 'pkm2026/t01/do') {
      _currentState['do'] = double.tryParse(payload) ?? _currentState['do'];
    } else if (topic == 'pkm2026/t01/tds') {
      _currentState['tds'] = double.tryParse(payload) ?? _currentState['tds'];
    } else if (topic == 'pkm2026/t01/aerator/status') {
      _currentState['aerator'] = payload; // ON or OFF
    }
    
    _sensorDataController.add(Map.from(_currentState));
  }

  void publishAeratorControl(bool isOn) {
    if (_client != null && _client!.connectionStatus!.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(isOn ? 'ON' : 'OFF');
      _client!.publishMessage('pkm2026/t01/aerator/control', MqttQos.atLeastOnce, builder.payload!, retain: true);
    }
  }

  void _onConnected() {
    print('MQTT Connected');
  }

  void _onDisconnected() {
    print('MQTT Disconnected');
  }

  void disconnect() {
    _client?.disconnect();
  }
}

final globalMqttManager = MqttManager();

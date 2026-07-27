import 'dart:async';
import 'dart:math';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter/foundation.dart';

class MqttManager {
  static final MqttManager _instance = MqttManager._internal();
  factory MqttManager() => _instance;
  MqttManager._internal();

  MqttServerClient? _client;
  
  final _sensorDataController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get sensorDataStream => _sensorDataController.stream;

  final ValueNotifier<Map<String, bool>> relayStatuses = ValueNotifier({});

  Map<String, dynamic> get latestData => Map.unmodifiable(_currentState);

  // Store current state to emit full map on partial updates
  final Map<String, dynamic> _currentState = {
    'suhu': 0.0,
    'ph': 0.0,
    'do': 0.0,
    'tds': 0.0,
    'aerator': 'OFF',
  };

  Future<void> connect(String mqttId) async {
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
      _client!.subscribe('pkm2026/$mqttId/#', MqttQos.atLeastOnce);
      
      _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final recMess = c[0].payload as MqttPublishMessage;
        final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        final topic = c[0].topic;

        _handlePayload(topic, pt, mqttId);
      });
    }
  }

  void _handlePayload(String topic, String payload, String mqttId) {
    if (topic == 'pkm2026/$mqttId/suhu') {
      _currentState['suhu'] = double.tryParse(payload) ?? _currentState['suhu'];
    } else if (topic == 'pkm2026/$mqttId/ph') {
      _currentState['ph'] = double.tryParse(payload) ?? _currentState['ph'];
    } else if (topic == 'pkm2026/$mqttId/do') {
      _currentState['do'] = double.tryParse(payload) ?? _currentState['do'];
    } else if (topic == 'pkm2026/$mqttId/tds') {
      _currentState['tds'] = double.tryParse(payload) ?? _currentState['tds'];
    } else if (topic.endsWith('aerator/status')) {
      _currentState['aerator'] = payload; // ON or OFF
      final newMap = Map<String, bool>.from(relayStatuses.value);
      newMap['master'] = (payload == 'ON');
      relayStatuses.value = newMap;
    } else if (topic.contains('aerator_') && topic.endsWith('/status')) {
      final parts = topic.split('aerator_');
      final indexStr = parts[1].split('/')[0];
      final newMap = Map<String, bool>.from(relayStatuses.value);
      newMap[indexStr] = (payload == 'ON');
      relayStatuses.value = newMap;
    }
    
    _sensorDataController.add(Map.from(_currentState));
  }

  void publishMasterControl(String mqttId, bool isOn) {
    if (_client != null && _client!.connectionStatus!.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(isOn ? 'ON' : 'OFF');
      _client!.publishMessage('pkm2026/$mqttId/aerator/control', MqttQos.atLeastOnce, builder.payload!, retain: true);
    }
  }

  void publishRelayControl(String mqttId, int relayIndex, bool isOn) {
    if (_client != null && _client!.connectionStatus!.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(isOn ? 'ON' : 'OFF');
      _client!.publishMessage('pkm2026/$mqttId/aerator_$relayIndex/control', MqttQos.atLeastOnce, builder.payload!, retain: true);
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

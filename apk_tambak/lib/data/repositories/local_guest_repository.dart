import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalPond {
  final String id;
  final String namaKolam;
  final String mqttId;

  LocalPond({
    required this.id,
    required this.namaKolam,
    required this.mqttId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama_kolam': namaKolam,
    'mqtt_id': mqttId,
  };

  factory LocalPond.fromJson(Map<String, dynamic> json) => LocalPond(
    id: json['id'] ?? '',
    namaKolam: json['nama_kolam'] ?? '',
    mqttId: json['mqtt_id'] ?? '',
  );
}

class LocalGuestRepository {
  static const String _key = 'guest_ponds';

  Future<List<LocalPond>> getPonds() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_key);
    if (jsonList == null) return [];

    try {
      return jsonList
          .map((item) => LocalPond.fromJson(json.decode(item)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> savePond(LocalPond pond) async {
    final prefs = await SharedPreferences.getInstance();
    final List<LocalPond> currentPonds = await getPonds();
    
    // Remove if already exists with same ID to support updates, though guest is mostly insert/delete
    currentPonds.removeWhere((p) => p.id == pond.id);
    currentPonds.add(pond);

    final List<String> jsonList = currentPonds
        .map((p) => json.encode(p.toJson()))
        .toList();
    await prefs.setStringList(_key, jsonList);
  }

  Future<void> deletePond(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<LocalPond> currentPonds = await getPonds();
    currentPonds.removeWhere((p) => p.id == id);

    final List<String> jsonList = currentPonds
        .map((p) => json.encode(p.toJson()))
        .toList();
    await prefs.setStringList(_key, jsonList);
  }
}

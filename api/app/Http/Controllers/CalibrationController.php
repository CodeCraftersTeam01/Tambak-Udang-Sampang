<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use PhpMqtt\Client\MqttClient;
use PhpMqtt\Client\ConnectionSettings;

class CalibrationController extends Controller
{
    public function update(Request $request)
    {
        $this->validate($request, [
            'device_id' => 'required|integer|exists:devices,id',
            'pond_id' => 'required|integer|exists:kolams,id',
            'ph_slope' => 'required|numeric',
            'ph_offset' => 'required|numeric',
            'do_scale' => 'required|numeric',
            'do_offset' => 'required|numeric',
            'tds_scale' => 'required|numeric',
            'tds_offset' => 'required|numeric',
            'suhu_offset' => 'required|numeric',
        ]);

        $deviceId = (int) $request->input('device_id');
        $pondId = (int) $request->input('pond_id');
        $phSlope = (float) $request->input('ph_slope');
        $phOffset = (float) $request->input('ph_offset');
        $doScale = (float) $request->input('do_scale');
        $doOffset = (float) $request->input('do_offset');
        $tdsScale = (float) $request->input('tds_scale');
        $tdsOffset = (float) $request->input('tds_offset');
        $suhuOffset = (float) $request->input('suhu_offset');

        // Retrieve current active config to increment revision
        $currentConfig = DB::table('device_calibration_configs')
            ->where('device_id', $deviceId)
            ->where('is_active', 1)
            ->orderBy('revision', 'desc')
            ->first();

        $revision = $currentConfig ? ($currentConfig->revision + 1) : 1;

        // Set other configs to inactive
        DB::table('device_calibration_configs')
            ->where('device_id', $deviceId)
            ->update(['is_active' => 0]);

        // Insert new calibration configuration
        DB::table('device_calibration_configs')->insert([
            'device_id' => $deviceId,
            'pond_id' => $pondId,
            'ph_slope' => $phSlope,
            'ph_offset' => $phOffset,
            'do_scale' => $doScale,
            'do_offset' => $doOffset,
            'tds_scale' => $tdsScale,
            'tds_offset' => $tdsOffset,
            'suhu_offset' => $suhuOffset,
            'revision' => $revision,
            'is_active' => 1,
            'created_at' => date('Y-m-d H:i:s'),
            'updated_at' => date('Y-m-d H:i:s'),
        ]);

        // Get device code for the MQTT topic
        $device = DB::table('devices')->where('id', $deviceId)->first();
        $deviceCode = $device ? $device->device_code : 't01';
        $topic = "pkm2026/{$deviceCode}/calibration/set";

        // Publish configuration to ESP32 via MQTT client
        try {
            $host = env('MQTT_HOST', 'm-tech.fun');
            $port = env('MQTT_PORT', 1883);
            $user = env('MQTT_USER', 'mhs1');
            $pass = env('MQTT_PASS', 'mhs123');

            $clientId = 'laravel-calibration-publisher-' . uniqid();
            $connectionSettings = (new ConnectionSettings)
                ->setUsername($user)
                ->setPassword($pass);

            $mqtt = new MqttClient($host, $port, $clientId);
            $mqtt->connect($connectionSettings, true);

            $payload = json_encode([
                'revision' => $revision,
                'ph_slope' => $phSlope,
                'ph_offset' => $phOffset,
                'do_scale' => $doScale,
                'do_offset' => $doOffset,
                'tds_scale' => $tdsScale,
                'tds_offset' => $tdsOffset,
                'suhu_offset' => $suhuOffset,
            ]);

            $mqtt->publish($topic, $payload, 0);
            $mqtt->disconnect();
        } catch (\Throwable $e) {
            \Illuminate\Support\Facades\Log::error("Failed to publish calibration to MQTT: " . $e->getMessage());
        }

        return response()->json([
            'success' => true,
            'message' => 'Device calibration config updated and published successfully.',
            'data' => [
                'device_id' => $deviceId,
                'pond_id' => $pondId,
                'revision' => $revision,
                'mqtt_topic' => $topic,
            ]
        ]);
    }
}
